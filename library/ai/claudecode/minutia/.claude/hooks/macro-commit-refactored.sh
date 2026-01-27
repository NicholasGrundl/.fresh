#!/bin/bash
# macro-commit.sh - (Refactored) Create summary commits referencing micro commits
#
# PURPOSE: Create macro commits that summarize [MICRO] commits since last [MACRO]
# TRIGGER: Multiple hooks (with thresholds) OR /macro-commit command (manual override)
# APPROACH: Read git history for [MICRO] commits, create [MACRO] summary (no squashing)
#
# REFACTOR HIGHLIGHTS:
# - Reduced redundant git calls by fetching state once at the beginning.
# - Simplified main logic using guard clauses for early exits.
# - Consolidated commit logic using a bash array for arguments.
# - Made LLM provider selection more modular with a loop.
# - Added more comments to explain behavior (e.g., `git add -A`).

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
    git log --oneline --grep="^[MACRO]" -1 --format="%H" 2>/dev/null
}

# Get timestamp of a given commit hash (unix timestamp)
get_commit_timestamp() {
    local commit_hash=$1
    if [ -z "$commit_hash" ]; then
        echo "0"
    else
        git show -s --format=%ct "$commit_hash" 2>/dev/null || echo "0"
    fi
}

# Check if enough time has passed since last macro (for new session detection)
is_new_session() {
    local last_macro_ts=$1
    local current_ts=$(date +%s)
    local time_diff=$((current_ts - last_macro_ts))

    if [ "$time_diff" -ge "$TIME_THRESHOLD_SECONDS" ]; then
        return 0  # true - new session
    else
        return 1  # false - same session
    fi
}

# Get micro commits since a given commit hash
get_micro_commits_since() {
    local last_macro_hash=$1

    if [ -z "$last_macro_hash" ]; then
        # No previous macro, get all micros
        git log --oneline --grep="^[MICRO]" --format="%H|%s|%ai" --reverse 2>/dev/null
    else
        # Get micros since last macro
        git log --oneline --grep="^[MICRO]" --format="%H|%s|%ai" "${last_macro_hash}..HEAD" --reverse 2>/dev/null
    fi
}

# Generate simple fallback commit message
generate_simple_message() {
    local micro_commits=$1
    local micro_count=$(echo "$micro_commits" | grep -c . || echo "0")

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
    local last_macro_hash=$1
    local micro_commits=$2
    local micro_count=$(echo "$micro_commits" | grep -c . || echo "0")

    local diff_range="HEAD~10..HEAD"  # Default fallback
    if [ -n "$last_macro_hash" ]; then
        diff_range="${last_macro_hash}..HEAD"
    fi

    # Get the cumulative diff of all changes (across all micro commits AND staged changes)
    local hist_diff=$(git diff "$diff_range" -- ':!.claude' 2>/dev/null)
    local staged_diff=$(git diff --staged -- ':!.claude' 2>/dev/null)
    local git_diff="$hist_diff\n$staged_diff"

    local changed_files=$( (git diff --name-only "$diff_range"; git diff --name-only --staged) | grep -vE "^\.claude/" | sort -u)

    # Format micro commits for LLM
    local micro_activity=$(echo "$micro_commits" | while IFS='|' read -r hash msg timestamp; do
        # Extract just the message part after [MICRO]
        local clean_msg=$(echo "$msg" | sed 's/^[MICRO] //')
        echo "• ${clean_msg}"
    done)

    # Get recent macro commits for style reference
    local recent_macros=$(git log --oneline --grep="^[MACRO]" -3 2>/dev/null | sed 's/^[MACRO] //' | sed 's/^[a-f0-9]* /• /' || echo "")

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
```diff
$(echo "$git_diff" | head -200)
```

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
    local last_macro_hash=$1
    local micro_commits=$2
    local prompt=$(generate_llm_prompt "$last_macro_hash" "$micro_commits")

    local llms_to_try=("gemini" "claude")
    local llm_message=""

    for llm_cmd in "${llms_to_try[@]}"; do
        if command -v "$llm_cmd" >/dev/null 2>&1; then
            llm_message=$(echo "$prompt" | "$llm_cmd" -p "" 2>/dev/null)
            # Clean up message (preserve newlines, just trim leading/trailing whitespace)
            llm_message=$(echo "$llm_message" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

            if [ -n "$llm_message" ] && [ ${#llm_message} -gt 10 ]; then
                echo "$llm_message"
                return 0 # Success
            fi
        fi
done

    # If loop finishes without success, fall back
    generate_simple_message "$micro_commits"
}

# =============================================================================
# MAIN LOGIC
# =============================================================================

# --- 1. GATHER STATE ONCE ---
echo "🔄 Checking macro commit criteria..."
force_commit=false
if [ -t 0 ] || [ "$1" = "--force" ]; then
    force_commit=true
fi

last_macro_hash=$(find_last_macro)
micro_commits=$(get_micro_commits_since "$last_macro_hash")
micro_count=$(echo "$micro_commits" | grep -c . || echo "0")

has_changes=false
if ! git diff --quiet || ! git diff --staged --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    has_changes=true
fi

# --- 2. GUARD CLAUSES (EARLY EXITS) ---

# Exit if there's nothing to commit at all
if [ "$micro_count" = "0" ] && [ "$has_changes" = "false" ]; then
    echo "No micro commits or changes since last macro. Skipping."
    exit 0
fi

# Apply thresholds only if not forced
if [ "$force_commit" = "false" ]; then
    last_macro_ts=$(get_commit_timestamp "$last_macro_hash")
    if [ "$micro_count" -lt "$MIN_MICRO_COUNT" ] && ! is_new_session "$last_macro_ts"; then
        echo "Skipping: Only ${micro_count} micro commits (need ${MIN_MICRO_COUNT}) and not a new session."
        exit 0
    elif is_new_session "$last_macro_ts"; then
         echo "New session detected (>1 hour since last macro), proceeding with macro commit."
    else
        echo "Threshold met: ${micro_count} micro commits (>= ${MIN_MICRO_COUNT})."
    fi
else
    echo "Manual invocation: bypassing thresholds."
fi

# --- 3. STAGE AND COMMIT ---
echo "🔄 Creating macro commit..."

# Stage any uncommitted changes.
# WARNING: `git add -A` is powerful. It stages ALL unstaged and untracked files
# in the repository. This is intentional to capture the full session state,
# but be aware if you have unrelated work in progress.
if [ "$has_changes" = "true" ]; then
    git add -A 2>/dev/null || true
fi

# Final check: if after staging there are no changes, and there were no micros, exit.
if git diff --staged --quiet && [ "$micro_count" = "0" ]; then
    echo "No changes to commit after staging. Skipping."
    exit 0
fi

# Generate commit message (will fall back to simple if LLM fails)
echo "📝 Generating commit message..."
commit_message=$(generate_llm_message "$last_macro_hash" "$micro_commits")
macro_msg="[MACRO] ${commit_message}"

# Build and execute the commit command
commit_args=("-m" "$macro_msg" "--quiet")
summary_msg=""

if git diff --staged --quiet; then
    # No staged changes, create empty commit to mark the session of micro-commits
    commit_args+=("--allow-empty")
    summary_msg="✓ Macro commit created (empty, summarizes ${micro_count} micro commits)"
else
    summary_msg="✓ Macro commit created (summarizes ${micro_count} micro commits + new changes)"
fi

if git commit "${commit_args[@]}"; then
    echo "$summary_msg"
    exit 0
else
    echo "❌ Failed to create macro commit"
    exit 1
fi
