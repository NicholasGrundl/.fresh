#!/usr/bin/env bash
#
# git-context-micro.sh - Extract MICRO commit history with file statistics
#
# Purpose: Get MICRO commits (auto file edits) with diff stats
# Usage: git-context-micro.sh [-n COUNT]
#        By default, gets MICROs since last MACRO commit
#        With -n flag, forces last N global MICROs (deep history)
# Output: Structured text with commit details and file change stats
#
# Exit codes:
#   0 - Success
#   1 - Error (not a git repo, invalid args, etc.)

set -euo pipefail

# Parse arguments
force_count=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--count)
            if [[ -z "${2:-}" ]] || ! [[ "${2}" =~ ^[0-9]+$ ]]; then
                echo "Error: -n requires a positive integer" >&2
                exit 1
            fi
            force_count="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-n COUNT]"
            echo "  Default: Get MICRO commits since last MACRO commit"
            echo "  -n, --count COUNT   Force last N global MICRO commits (override range)"
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

# Determine range to query
if [[ -n "${force_count}" ]]; then
    # Force mode: get last N global MICROs
    range_desc="Last ${force_count} (global)"
    git_range=""
    count_flag="-${force_count}"
else
    # Default mode: get MICROs since last MACRO
    last_macro_hash=$(git log --grep="MICRO" --invert-grep --format="%h" -1 2>/dev/null || echo "")

    if [[ -n "${last_macro_hash}" ]]; then
        range_desc="Since last MACRO (${last_macro_hash})"
        git_range="${last_macro_hash}..HEAD"
        count_flag=""
    else
        # No MACRO found, get all MICROs
        range_desc="All (no MACRO found)"
        git_range=""
        count_flag=""
    fi
fi

# Output header
echo "=== MICRO COMMITS (${range_desc}) ==="
echo ""

# Get MICRO commits with file statistics
if [[ -n "${git_range}" ]]; then
    # Range-based query (since last MACRO)
    git log --grep="MICRO" \
        --stat \
        --format="%n %h|%ad|%s" \
        --date=short \
        ${git_range} 2>/dev/null || {
        echo "Error: Failed to retrieve git log" >&2
        exit 1
    }
else
    # Count-based query (forced N or all MICROs)
    git log --grep="MICRO" \
        --stat \
        --format="%n %h|%ad|%s" \
        --date=short \
        ${count_flag} 2>/dev/null || {
        echo "Error: Failed to retrieve git log" >&2
        exit 1
    }
fi

# Output footer
echo ""
echo "=== END MICRO COMMITS ==="
