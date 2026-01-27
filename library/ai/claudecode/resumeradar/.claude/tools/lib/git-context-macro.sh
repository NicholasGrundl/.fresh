#!/usr/bin/env bash
#
# git-context-macro.sh - Extract MACRO commit history
#
# Purpose: Get non-MICRO commits (semantic work) with full context
# Usage: git-context-macro.sh [-n COUNT]
# Output: Structured text with commit details and bodies
#
# Exit codes:
#   0 - Success
#   1 - Error (not a git repo, invalid args, etc.)

set -euo pipefail

# Default number of commits to retrieve
DEFAULT_COUNT=5

# Parse arguments
count="${DEFAULT_COUNT}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--count)
            if [[ -z "${2:-}" ]] || ! [[ "${2}" =~ ^[0-9]+$ ]]; then
                echo "Error: -n requires a positive integer" >&2
                exit 1
            fi
            count="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-n COUNT]"
            echo "  -n, --count COUNT   Number of MACRO commits to retrieve (default: ${DEFAULT_COUNT})"
            echo "  -h, --help          Show this help message"
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

# Output header
echo "=== MACRO COMMITS (Last ${count}) ==="
echo ""

# Get MACRO commits (non-MICRO) with full body text
# Using command 5: git log with --invert-grep for non-MICRO commits
# Format: hash, date, subject, blank line, body, separator
git log --grep="MICRO" --invert-grep \
    --format="%h|%ad|%s%n%n%b%n---" \
    --date=short \
    -"${count}" 2>/dev/null || {
    echo "Error: Failed to retrieve git log" >&2
    exit 1
}

# Output footer with count
echo ""
echo "=== END MACRO COMMITS (${count} commits) ==="
