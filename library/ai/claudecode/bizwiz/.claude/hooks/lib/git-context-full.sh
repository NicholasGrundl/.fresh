#!/usr/bin/env bash
#
# git-context-full.sh - Orchestrator for complete git project context
#
# Purpose: Combine MACRO history, MICRO history, and current status
# Usage: git-context-full.sh [--macro-count N] [--micro-count N]
# Output: Complete structured project context
#
# Exit codes:
#   0 - Success
#   1 - Error (not a git repo, missing dependencies, etc.)

set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default counts
DEFAULT_MACRO_COUNT=5

# Parse arguments
macro_count="${DEFAULT_MACRO_COUNT}"
micro_count_override=""  # Empty means use default (since last MACRO)

while [[ $# -gt 0 ]]; do
    case "$1" in
        --macro-count)
            if [[ -z "${2:-}" ]] || ! [[ "${2}" =~ ^[0-9]+$ ]]; then
                echo "Error: --macro-count requires a positive integer" >&2
                exit 1
            fi
            macro_count="$2"
            shift 2
            ;;
        --micro-count)
            if [[ -z "${2:-}" ]] || ! [[ "${2}" =~ ^[0-9]+$ ]]; then
                echo "Error: --micro-count requires a positive integer" >&2
                exit 1
            fi
            micro_count_override="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--macro-count N] [--micro-count N]"
            echo ""
            echo "Combines git context from multiple sources:"
            echo "  - MACRO commits (semantic work)"
            echo "  - MICRO commits (file changes)"
            echo "  - Current git status"
            echo ""
            echo "Options:"
            echo "  --macro-count N   Number of MACRO commits (default: ${DEFAULT_MACRO_COUNT})"
            echo "  --micro-count N   Force last N global MICRO commits (default: since last MACRO)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "Error: Not a git repository" >&2
    exit 1
fi

# Check for required scripts
required_scripts=(
    "git-context-macro.sh"
    "git-context-micro.sh"
    "git-context-status.sh"
)

for script in "${required_scripts[@]}"; do
    if [[ ! -x "${SCRIPT_DIR}/${script}" ]]; then
        echo "Error: Required script not found or not executable: ${script}" >&2
        echo "Expected location: ${SCRIPT_DIR}/${script}" >&2
        exit 1
    fi
done

# Output header with timestamp
echo "========================================"
echo "GIT PROJECT CONTEXT"
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""

# Run git-context-status.sh
"${SCRIPT_DIR}/git-context-status.sh" || {
    echo "Error: Failed to get git status" >&2
    exit 1
}

echo ""
echo ""

# Run git-context-macro.sh
"${SCRIPT_DIR}/git-context-macro.sh" -n "${macro_count}" || {
    echo "Error: Failed to get MACRO commits" >&2
    exit 1
}

echo ""
echo ""

# Run git-context-micro.sh
if [[ -n "${micro_count_override}" ]]; then
    # User specified count, force global MICRO query
    "${SCRIPT_DIR}/git-context-micro.sh" -n "${micro_count_override}" || {
        echo "Error: Failed to get MICRO commits" >&2
        exit 1
    }
else
    # Default: get MICROs since last MACRO
    "${SCRIPT_DIR}/git-context-micro.sh" || {
        echo "Error: Failed to get MICRO commits" >&2
        exit 1
    }
fi

# Output footer
echo ""
echo "========================================"
echo "END GIT PROJECT CONTEXT"
echo "========================================"
