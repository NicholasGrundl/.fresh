#!/bin/bash
# micro-commit.sh - Fast, instant commits for every file change
#
# PURPOSE: Create [MICRO] checkpoint commits for file modification operations
# TRIGGER: PostToolUse hook - Captures:
#   - Direct file edits: Edit, Write, Delete, NotebookEdit, MultiEdit
#   - Bash file operations: mv, cp, mkdir, sed -i, output redirection (>)
#   - Package managers: npm, yarn, pnpm, uv (install/add/remove/update/sync)
#   - Code generation: npx create-*
# SPEED: Near-instant (no LLM calls, no log files)
#
# SETUP:
# 1. chmod +x .claude/hooks/micro-commit.sh
# 2. Add to .claude/settings.local.json:
#    {
#      "hooks": {
#        "PostToolUse": [{
#          "matcher": "Edit|Write|Delete|NotebookEdit|MultiEdit|Bash(mv .*)|Bash(cp .*)|Bash(mkdir .*)|Bash(sed -i.*)|Bash(.*>.*)|Bash(npm (install|add|remove|update).*)|Bash(yarn (add|remove).*)|Bash(pnpm (add|remove).*)|Bash(uv (add|remove|sync).*)|Bash(npx create.*)",
#          "hooks": [{"type": "command", "command": ".claude/hooks/micro-commit.sh", "timeout": 10}]
#        }]
#      }
#    }

set -e

# Read hook input from stdin
input=$(cat)

# Extract hook context
hook_event_name=$(echo "$input" | jq -r '.hook_event_name // "unknown"')
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // "unknown"')

# Only process PostToolUse events
if [ "$hook_event_name" != "PostToolUse" ]; then
    echo "Not a PostToolUse event, skipping"
    exit 0
fi

# Check if there are any changes (including untracked files)
if git diff --quiet && git diff --staged --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "No changes to commit"
    exit 0
fi

# Auto-stage all changes
git add -A 2>/dev/null || true

# Check again after staging
if git diff --staged --quiet; then
    echo "No staged changes after git add"
    exit 0
fi

# Create micro commit
timestamp=$(date '+%H:%M:%S')
filename=$(basename "$file_path")
commit_msg="[MICRO] ${tool_name}: ${filename} @ ${timestamp}"

# Commit with message
if git commit -m "$commit_msg" --quiet 2>/dev/null; then
    echo "✓ ${commit_msg}"
else
    echo "Failed to create micro commit (this is normal if no changes)"
    exit 0
fi

exit 0