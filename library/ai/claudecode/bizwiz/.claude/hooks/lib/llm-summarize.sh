#!/usr/bin/env bash
#
# llm-summarize.sh - LLM prompt handler with fallback chain
#
# Purpose: Send prompt to LLM with graceful fallback
# Usage: llm-summarize.sh [--file FILE] < prompt.txt
#        echo "prompt" | llm-summarize.sh
# Output: LLM summary or original prompt (with metadata)
#
# LLM Priority Chain: Gemini → Claude → Ollama → Passthrough
#
# Exit codes:
#   0 - Success (LLM responded or passthrough)
#   1 - Error (invalid input, etc.)

set -euo pipefail

# Path to LLM-specific .env file (same directory as this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLM_ENV_FILE="${SCRIPT_DIR}/.env.llm"

# Store original env values for restoration
ORIGINAL_ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
ORIGINAL_GEMINI_API_KEY="${GEMINI_API_KEY:-}"
ORIGINAL_GOOGLE_API_KEY="${GOOGLE_API_KEY:-}"
ORIGINAL_OLLAMA_MODEL="${OLLAMA_MODEL:-}"
ORIGINAL_OLLAMA_HOST="${OLLAMA_HOST:-}"

# Flag to track if we loaded env
ENV_LOADED=false

# Cleanup function - ALWAYS runs on exit
cleanup_env() {
    if [[ "${ENV_LOADED}" == "true" ]]; then
        # Restore original values
        export ANTHROPIC_API_KEY="${ORIGINAL_ANTHROPIC_API_KEY}"
        export GEMINI_API_KEY="${ORIGINAL_GEMINI_API_KEY}"
        export GOOGLE_API_KEY="${ORIGINAL_GOOGLE_API_KEY}"
        export OLLAMA_MODEL="${ORIGINAL_OLLAMA_MODEL}"
        export OLLAMA_HOST="${ORIGINAL_OLLAMA_HOST}"
        
        # If originals were empty, unset them
        [[ -z "${ORIGINAL_ANTHROPIC_API_KEY}" ]] && unset ANTHROPIC_API_KEY
        [[ -z "${ORIGINAL_GEMINI_API_KEY}" ]] && unset GEMINI_API_KEY
        [[ -z "${ORIGINAL_GOOGLE_API_KEY}" ]] && unset GOOGLE_API_KEY
        [[ -z "${ORIGINAL_OLLAMA_MODEL}" ]] && unset OLLAMA_MODEL
        [[ -z "${ORIGINAL_OLLAMA_HOST}" ]] && unset OLLAMA_HOST
    fi
}

# Set trap to ensure cleanup runs on exit (success, error, or interrupt)
trap cleanup_env EXIT INT TERM

# Load LLM-specific environment if file exists
if [[ -f "${LLM_ENV_FILE}" ]]; then
    # Source the .env file
    set -a  # Automatically export all variables
    source "${LLM_ENV_FILE}"
    set +a  # Stop auto-exporting
    ENV_LOADED=true
fi


# Parse arguments
input_file=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --file|-f)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --file requires a file path" >&2
                exit 1
            fi
            input_file="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--file FILE] < input"
            echo ""
            echo "Sends prompt to LLM with fallback chain:"
            echo "  1. Gemini (gemini-cli or gemini command)"
            echo "  2. Claude (anthropic or claude command)"
            echo "  3. Ollama (ollama command)"
            echo "  4. Passthrough (returns original prompt)"
            echo ""
            echo "Options:"
            echo "  --file, -f FILE   Read prompt from file instead of stdin"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  GOOGLE_API_KEY      Required for Gemini"
            echo "  ANTHROPIC_API_KEY   Required for Claude"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
    esac
done

# Read input from file or stdin
if [[ -n "${input_file}" ]]; then
    if [[ ! -f "${input_file}" ]]; then
        echo "Error: File not found: ${input_file}" >&2
        exit 1
    fi
    prompt_input=$(cat "${input_file}")
else
    # Read from stdin
    prompt_input=$(cat)
fi

# Check if input is empty
if [[ -z "${prompt_input}" ]]; then
    echo "Error: Empty input" >&2
    exit 1
fi

# Check prompt size and warn if large
prompt_size=${#prompt_input}
if (( prompt_size > 15000 )); then
    # Rough token estimate: ~4 characters per token
    estimated_tokens=$((prompt_size / 4))
    echo "Warning: Large context (~${estimated_tokens} tokens, ${prompt_size} chars)" >&2
    echo "         LLM may take 30-60 seconds to respond..." >&2
fi

# Function to try Gemini
try_gemini() {
    local prompt="$1"

    # Check if gemini command exists
    if ! command -v gemini &> /dev/null; then
        return 1
    fi

    # Check for API key - multiple possible environment variables
    # GEMINI_API_KEY is the primary one, GOOGLE_API_KEY is alternative
    if [[ -z "${GEMINI_API_KEY:-}" ]] && [[ -z "${GOOGLE_API_KEY:-}" ]]; then
        return 1
    fi

    # Try calling gemini without timeout (timeout handled at top level)
    # Explicitly scope API keys to this command only (defense-in-depth)
    # Use positional argument (not deprecated --prompt flag) and specify model
    local result
    if result=$(GEMINI_API_KEY="${GEMINI_API_KEY:-}" \
                GOOGLE_API_KEY="${GOOGLE_API_KEY:-}" \
                gemini -m gemini-2.5-flash "$prompt" 2>/dev/null); then
        if [[ -n "${result}" ]]; then
            echo "<!-- LLM: Gemini CLI (gemini-2.5-flash) -->"
            echo "<!-- Status: Success -->"
            echo ""
            echo "${result}"
            return 0
        fi
    fi

    return 1
}

# Function to try Claude
try_claude() {
    local prompt="$1"

    # Check if claude command exists
    if ! command -v claude &> /dev/null; then
        return 1
    fi

    # Check for API key - Claude Code prioritizes ANTHROPIC_API_KEY env var
    # If not set, it will try interactive auth which won't work in scripts
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        return 1
    fi

    # Try calling claude in print mode without timeout (timeout handled at top level)
    # Explicitly scope API key to this command only (defense-in-depth)
    # --allowedTools "" disables all tools for pure text generation
    local result
    if result=$(ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" \
                claude -p "$prompt" \
                --allowedTools "" 2>/dev/null); then
        if [[ -n "${result}" ]]; then
            echo "<!-- LLM: Claude Code -->"
            echo "<!-- Status: Success -->"
            echo ""
            echo "${result}"
            return 0
        fi
    fi

    return 1
}

# Function to try Ollama
try_ollama() {
    local prompt="$1"

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        return 1
    fi

    # Get server host (support both direct and OpenAI-compatible endpoints)
    # Default to localhost:11434 (Ollama native endpoint)
    local ollama_host="${OLLAMA_HOST:-localhost:11434}"
    
    # Check if ollama server is running
    # Test the root endpoint (returns "Ollama is running")
    if ! curl -s "http://${ollama_host}/" &> /dev/null; then
        return 1
    fi

    # Determine model to use (default to qwen2.5-coder:14b per your preference)
    local model="${OLLAMA_MODEL:-qwen2.5-coder:14b}"
    
    # Check if the model is available locally
    # ollama list shows: NAME ID SIZE MODIFIED
    if ! ollama list 2>/dev/null | grep -q "^${model}"; then
        return 1
    fi

    # Try calling ollama without timeout (timeout handled at top level)
    # Explicitly scope env vars to this command only (defense-in-depth)
    local result
    if result=$(OLLAMA_MODEL="${model}" \
                OLLAMA_HOST="${ollama_host}" \
                ollama run "${model}" "$prompt" 2>/dev/null); then
        if [[ -n "${result}" ]]; then
            echo "<!-- LLM: Ollama (${model}) -->"
            echo "<!-- Status: Success -->"
            echo "<!-- Host: ${ollama_host} -->"
            echo ""
            echo "${result}"
            return 0
        fi
    fi

    return 1
}

# Function for passthrough
passthrough() {
    local prompt="$1"

    echo "<!-- LLM: None (Passthrough) -->"
    echo "<!-- Status: No LLM available -->"
    echo "<!-- Reason: All LLMs failed or unavailable -->"
    echo ""
    echo "${prompt}"
    return 0
}

# Try each LLM in priority order
# Note: No timeout wrapper - LLM CLIs handle their own timeouts
echo "Calling Gemini (gemini-2.5-flash)..." >&2
if try_gemini "${prompt_input}"; then
    exit 0
fi

echo "Gemini unavailable, trying Claude..." >&2
if try_claude "${prompt_input}"; then
    exit 0
fi

echo "Claude unavailable, trying Ollama..." >&2
if try_ollama "${prompt_input}"; then
    exit 0
fi

# All LLMs failed, passthrough
echo "All LLMs unavailable, using passthrough..." >&2
passthrough "${prompt_input}"
exit 0
