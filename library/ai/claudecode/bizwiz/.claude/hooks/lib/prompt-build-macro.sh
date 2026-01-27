#!/usr/bin/env bash
#
# prompt-build-macro.sh - Build LLM prompt from git context and template
#
# Purpose: Combine git context with template to create LLM prompt
# Usage: git-context-full.sh | prompt-build-macro.sh [--template FILE]
# Output: Complete prompt ready for LLM
#
# Exit codes:
#   0 - Success
#   1 - Error (template not found, invalid input, etc.)

set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default template location
DEFAULT_TEMPLATE="${SCRIPT_DIR}/../templates/macro-commit-prompt.txt"

# Parse arguments
template_file="${DEFAULT_TEMPLATE}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --template|-t)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --template requires a file path" >&2
                exit 1
            fi
            template_file="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--template FILE] < git-context"
            echo ""
            echo "Builds LLM prompt by combining git context with template."
            echo "Git context should be piped via stdin."
            echo ""
            echo "Options:"
            echo "  --template, -t FILE   Template file (default: ${DEFAULT_TEMPLATE})"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Template placeholders:"
            echo "  {{GIT_CONTEXT}}       Replaced with git context from stdin"
            echo "  {{TIMESTAMP}}         Replaced with current timestamp"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
    esac
done

# Check if template exists
if [[ ! -f "${template_file}" ]]; then
    echo "Error: Template file not found: ${template_file}" >&2
    echo "Use --template to specify a different template or create the default template." >&2
    exit 1
fi

# Read git context from stdin
git_context=$(cat)

# Check if input is empty
if [[ -z "${git_context}" ]]; then
    echo "Error: Empty git context input" >&2
    exit 1
fi

# Read template
template=$(cat "${template_file}")

# Get current timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Replace placeholders in template
# Note: Using process substitution to avoid issues with special characters
output="${template}"
output="${output//\{\{GIT_CONTEXT\}\}/$git_context}"
output="${output//\{\{TIMESTAMP\}\}/$timestamp}"

# Output the complete prompt
echo "${output}"
