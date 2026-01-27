#!/usr/bin/env bash
#
# git-context-status.sh - Get current git repository status
#
# Purpose: Capture staged, unstaged, and untracked files
# Usage: git-context-status.sh
# Output: Structured text showing current repository state
#
# Exit codes:
#   0 - Success
#   1 - Error (not a git repo)

set -euo pipefail

# Check if we're in a git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "Error: Not a git repository" >&2
    exit 1
fi

# Output header
echo "=== CURRENT GIT STATUS ==="
echo ""

# Get current branch
current_branch=$(git branch --show-current 2>/dev/null || echo "detached HEAD")
echo "Branch: ${current_branch}"
echo ""

# Get staged files
echo "--- Staged Files (ready to commit) ---"
staged_files=$(git diff --cached --name-only 2>/dev/null || echo "")
if [[ -n "${staged_files}" ]]; then
    echo "${staged_files}" | while IFS= read -r file; do
        echo "  + ${file}"
    done
else
    echo "  (none)"
fi
echo ""

# Get unstaged files (modified but not staged)
echo "--- Unstaged Files (modified, not staged) ---"
unstaged_files=$(git diff --name-only 2>/dev/null || echo "")
if [[ -n "${unstaged_files}" ]]; then
    echo "${unstaged_files}" | while IFS= read -r file; do
        echo "  M ${file}"
    done
else
    echo "  (none)"
fi
echo ""

# Get untracked files
echo "--- Untracked Files (not in git) ---"
untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null || echo "")
if [[ -n "${untracked_files}" ]]; then
    echo "${untracked_files}" | while IFS= read -r file; do
        echo "  ? ${file}"
    done
else
    echo "  (none)"
fi
echo ""

# Get deleted files
echo "--- Deleted Files ---"
deleted_files=$(git ls-files --deleted 2>/dev/null || echo "")
if [[ -n "${deleted_files}" ]]; then
    echo "${deleted_files}" | while IFS= read -r file; do
        echo "  D ${file}"
    done
else
    echo "  (none)"
fi
echo ""

# Summary counts
staged_count=$(echo "${staged_files}" | grep -c . || echo "0")
unstaged_count=$(echo "${unstaged_files}" | grep -c . || echo "0")
untracked_count=$(echo "${untracked_files}" | grep -c . || echo "0")
deleted_count=$(echo "${deleted_files}" | grep -c . || echo "0")

echo "Summary: ${staged_count} staged, ${unstaged_count} unstaged, ${untracked_count} untracked, ${deleted_count} deleted"
echo ""
echo "=== END GIT STATUS ==="
