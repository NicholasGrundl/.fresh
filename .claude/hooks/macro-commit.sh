#!/bin/bash
# macro-commit.sh - Create summary commits referencing micro commits
#
# PURPOSE: Create macro commits that summarize [MICRO] commits since last [MACRO]
# TRIGGER: Multiple hooks (with thresholds) OR /macro-commit command (manual override)
# APPROACH: Read git history for [MICRO] commits, create [MACRO] summary (no squashing)
#
# THRESHOLDS (configurable):
# - MIN_MICRO_COUNT: Minimum number of micro commits to auto-create macro (default: 15)
# - TIME_THRESHOLD_SECONDS: Time since last macro to assume new session (default: 3600 = 1 hour)
#
# PORTABLE SETUP INSTRUCTIONS:
# 1. Make script executable:
#    chmod +x .claude/hooks/macro-commit.sh
#
# 2. Add hooks to .claude/settings.local.json:
#    {
#      "hooks": {
#        "Stop": [{
#          "matcher": "",
#          "hooks": [{"type": "command", "command": ".claude/hooks/macro-commit.sh", "timeout": 45}]
#        }],
#        "PreCompact": [{
#          "matcher": "manual",
#          "hooks": [{"type": "command", "command": ".claude/hooks/macro-commit.sh", "timeout": 45}]
#        }],
#        "SessionEnd": [{
#          "matcher": "",
#          "hooks": [{"type": "command", "command": ".claude/hooks/macro-commit.sh", "timeout": 45}]
#        }]
#      }
#    }
#
# 3. Create /macro-commit slash command in .claude/commands/macro-commit.md:
#    See macro-commit.md for the command template that calls this script

# =============================================================================
# CONFIGURATION
# =============================================================================

WORK_DIR=".claude"
MIN_MICRO_COUNT=15           # Minimum micro commits to trigger auto-macro
TIME_THRESHOLD_SECONDS=3600  # 1 hour in seconds

# Ensure work directory exists
mkdir -p "$WORK_DIR"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Find the last [MACRO] commit hash
find_last_macro() {
    git log --oneline --grep="^\[MACRO\]" -1 --format="%H" 2>/dev/null || echo ""
}

# Get timestamp of last macro commit (unix timestamp)
get_last_macro_timestamp() {
    local last_macro=$(find_last_macro)
    if [ -z "$last_macro" ]; then
        echo "0"
    else
        git show -s --format=%ct "$last_macro" 2>/dev/null || echo "0"
    fi
}

# Check if enough time has passed since last macro (for new session detection)
is_new_session() {
    local last_macro_ts=$(get_last_macro_timestamp)
    local current_ts=$(date +%s)
    local time_diff=$((current_ts - last_macro_ts))

    if [ "$time_diff" -ge "$TIME_THRESHOLD_SECONDS" ]; then
        return 0  # true - new session
    else
        return 1  # false - same session
    fi
}

# Get micro commits since last macro
get_micro_commits_since_last_macro() {
    local last_macro=$(find_last_macro)

    if [ -z "$last_macro" ]; then
        # No previous macro, get all micros
        git log --oneline --grep="^\[MICRO\]" --format="%H|%s|%ai" --reverse 2>/dev/null || echo ""
    else
        # Get micros since last macro
        git log --oneline --grep="^\[MICRO\]" --format="%H|%s|%ai" "${last_macro}..HEAD" --reverse 2>/dev/null || echo ""
    fi
}

# Generate simple fallback commit message
generate_simple_message() {
    local micro_commits=$(get_micro_commits_since_last_macro)
    local micro_count=$(echo "$micro_commits" | grep -c "^\[MICRO\]" || echo "0")

    if [ "$micro_count" = "0" ]; then
        echo "chore: session checkpoint"
    else
        # Extract time range from first and last micro commit
        local time_start=$(echo "$micro_commits" | head -1 | cut -d'|' -f3 | awk '{print $2}')
        local time_end=$(echo "$micro_commits" | tail -1 | cut -d'|' -f3 | awk '{print $2}')
        echo "feat: summary of ${micro_count} micro commits (${time_start}-${time_end})"
    fi
}

# Generate LLM prompt for commit message
generate_llm_prompt() {
    local last_macro=$(find_last_macro)
    local diff_range="HEAD~10..HEAD"  # Default fallback

    if [ -n "$last_macro" ]; then
        diff_range="${last_macro}..HEAD"
    fi

    # Get all micro commits in this range
    local micro_commits=$(get_micro_commits_since_last_macro)
    local micro_count=$(echo "$micro_commits" | grep -c "^\[MICRO\]" || echo "0")

    # Get the cumulative diff of all changes (across all micro commits AND staged changes)
    local hist_diff=$(git diff "$diff_range" -- ':!.claude/micro_commits.log' ':!.claude/last_macro_commit' ':!.claude/macro_amend.lock' 2>/dev/null)
    local staged_diff=$(git diff --staged -- ':!.claude/micro_commits.log' ':!.claude/last_macro_commit' ':!.claude/macro_amend.lock' 2>/dev/null)
    local git_diff="$hist_diff\n$staged_diff"

    local hist_changed_files=$(git diff --name-only "$diff_range" 2>/dev/null | grep -vE "^\.claude/(micro_commits\.log|last_macro_commit|macro_amend\.lock)")
    local staged_changed_files=$(git diff --name-only --staged 2>/dev/null | grep -vE "^\.claude/(micro_commits\.log|last_macro_commit|macro_amend\.lock)")
    local changed_files=$(echo -e "$hist_changed_files\n$staged_changed_files" | sort -u)

    # Format micro commits for LLM
    local micro_activity=$(echo "$micro_commits" | while IFS='|' read -r hash msg timestamp; do
        # Extract just the message part after [MICRO]
        local clean_msg=$(echo "$msg" | sed 's/^\[MICRO\] //')
        echo "• ${clean_msg}"
    done)

    # Get recent macro commits for style reference
    local recent_macros=$(git log --oneline --grep="^\[MACRO\]" -3 2>/dev/null | sed 's/^\[MACRO\] //' | sed 's/^[a-f0-9]* /• /' || echo "")

    cat << EOF
Generate a concise git commit message summarizing this development session.

## Example Format

Given this mock session:
- Micro Commits: Edit: auth.js, Edit: login.test.js, Edit: auth.js
- Changed Files: src/auth.js, tests/login.test.js
- Diff: Added JWT validation, fixed edge case in token refresh

Expected output (plain text, no markdown):
feat(auth): add JWT token validation with refresh logic

Initial implementation added basic JWT validation but encountered issues with
expired tokens. After testing edge cases, added automatic token refresh mechanism
that handles expiry gracefully.

Fixed a bug where concurrent requests would trigger multiple refresh attempts.
Solution uses a simple lock to ensure only one refresh happens at a time.

Tests updated to cover the new refresh flow and edge cases.

## Your Session Data

Micro Commits (${micro_count} total):
$micro_activity

Changed Files:
$(echo "$changed_files" | sed 's/^/• /')

Cumulative Diff:
\`\`\`diff
$(echo "$git_diff")
\`\`\`

Previous macro commits (for style reference):
$recent_macros

## Requirements
- Use conventional commit format: type(scope): description
- Keep title under 72 chars
- Add 2-4 paragraphs in the body telling the "dev story"
- Include failures, retries, iterations, and final success
- Focus on the development journey and problem-solving process
- Types: feat, fix, refactor, docs, test, chore
- Return ONLY the commit message as plain text (no markdown code blocks, no [MACRO] prefix)

Your response:
EOF
}

# Generate LLM commit message (synchronous)
generate_llm_message() {
    local prompt=$(generate_llm_prompt)

    # Try LLMs in order: gemini (fewer API restrictions, longer context),claude
    local llm_message=""
    if command -v gemini >/dev/null 2>&1; then
        llm_message=$(echo "$prompt" | gemini -p "" 2>/dev/null)
    elif command -v claude >/dev/null 2>&1; then
        llm_message=$(echo "$prompt" | claude -p "" 2>/dev/null)
    fi

    # Clean up message (preserve newlines, just trim leading/trailing whitespace)
    llm_message=$(echo "$llm_message" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

    # If we got a good message, use it; otherwise fall back to simple message
    if [ -n "$llm_message" ] && [ ${#llm_message} -gt 10 ]; then
        echo "$llm_message"
    else
        generate_simple_message
    fi
}

# =============================================================================
# MAIN LOGIC
# =============================================================================

# Detect if this is a manual invocation (via /macro-commit) or auto (via Stop hook)
force_commit=false
if [ -t 0 ] || [ "$1" = "--force" ]; then
    # stdin is a terminal OR --force flag passed = manual invocation
    force_commit=true
fi

echo "🔄 Checking macro commit criteria..."

# Check if there are any [MICRO] commits since last [MACRO]
micro_commits=$(get_micro_commits_since_last_macro)
micro_count=$(echo "$micro_commits" | grep -c "^\[MICRO\]" 2>/dev/null || echo "0")

# Also check for unstaged/staged changes
has_changes=false
if ! git diff --quiet || ! git diff --staged --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    has_changes=true
fi

# Exit early if nothing to commit
if [ "$micro_count" = "0" ] && [ "$has_changes" = "false" ]; then
    echo "No micro commits or changes since last macro. Skipping."
    exit 0
fi

# Apply thresholds (unless forced)
if [ "$force_commit" = "false" ]; then
    # Check threshold 1: Minimum micro commit count
    if [ "$micro_count" -lt "$MIN_MICRO_COUNT" ]; then
        # Check threshold 2: Time-based (new session detection)
        if ! is_new_session; then
            echo "Skipping: Only ${micro_count} micro commits (need ${MIN_MICRO_COUNT}) and not a new session"
            exit 0
        else
            echo "New session detected (>1 hour since last macro), proceeding with macro commit"
        fi
    else
        echo "Threshold met: ${micro_count} micro commits (>= ${MIN_MICRO_COUNT})"
    fi
else
    echo "Manual invocation: bypassing thresholds"
fi

echo "🔄 Creating macro commit..."

# Stage any uncommitted changes
if [ "$has_changes" = "true" ]; then
    git add -A 2>/dev/null || true
fi

# Check if we now have staged changes (after micro commits or new changes)
if git diff --staged --quiet && [ "$micro_count" = "0" ]; then
    echo "No changes to commit after staging. Skipping."
    exit 0
fi

# Generate LLM message (synchronous, will fall back to simple if LLM fails)
echo "📝 Generating commit message..."
commit_message=$(generate_llm_message)
macro_msg="[MACRO] ${commit_message}"

# Create the macro commit
if git diff --staged --quiet; then
    # No staged changes, create empty commit to mark the session
    if git commit --allow-empty -m "$macro_msg" --quiet 2>/dev/null; then
        echo "✓ Macro commit created (empty, summarizes ${micro_count} micro commits)"
        exit 0
    fi
else
    # Has staged changes, create normal commit
    if git commit -m "$macro_msg" --quiet 2>/dev/null; then
        echo "✓ Macro commit created (summarizes ${micro_count} micro commits + new changes)"
        exit 0
    fi
fi

echo "❌ Failed to create macro commit"
exit 1