#!/usr/bin/env bash
# commit-auto.sh - Automated MACRO commit using modular LLM pipeline
#
# PURPOSE: Create [MACRO] commits using LLM-generated summaries
# APPROACH: Pipeline git-context → prompt-build → llm-summarize → commit
# EXIT CODES:
#   0 - Success (commit created with LLM message)
#   1 - Error (pipeline failed)
#   2 - Passthrough (LLM unavailable, manual generation needed)

set -euo pipefail

# Configuration
WORK_DIR=".claude"
mkdir -p "$WORK_DIR"

# Helper functions
has_file_changes() {
    # Check for untracked, unstaged, or staged files
    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        return 0  # true - has changes
    fi
    return 1  # false - no changes
}

last_commit_is_micro() {
    local last_subject=$(git log -1 --format="%s" 2>/dev/null || echo "")
    if echo "$last_subject" | grep -q "^\[MICRO\]"; then
        return 0  # true - last commit is MICRO
    fi
    return 1  # false - last commit is not MICRO
}

count_micro_commits() {
    # Count MICROs since last MACRO
    local last_macro=$(git log --grep="MICRO" --invert-grep --format="%h" -1 2>/dev/null || echo "")
    if [[ -n "${last_macro}" ]]; then
        git log --grep="MICRO" --format="%H" "${last_macro}..HEAD" 2>/dev/null | wc -l | tr -d ' '
    else
        git log --grep="MICRO" --format="%H" 2>/dev/null | wc -l | tr -d ' '
    fi
}

run_llm_pipeline() {
    # Run the modular pipeline
    # Capture stdout (LLM output) only, let stderr (progress messages) pass through
    local pipeline_output=$(.claude/hooks/lib/git-context-full.sh | \
                      .claude/hooks/lib/prompt-build-macro.sh | \
                      .claude/hooks/lib/llm-summarize.sh)

    # Detect which LLM was used (or passthrough)
    local llm_used="Unknown"
    local llm_status="Unknown"

    if echo "$pipeline_output" | head -5 | grep -q "<!-- LLM:"; then
        llm_used=$(echo "$pipeline_output" | grep "<!-- LLM:" | head -1 | sed 's/.*LLM: \(.*\) -->/\1/')
        llm_status=$(echo "$pipeline_output" | grep "<!-- Status:" | head -1 | sed 's/.*Status: \(.*\) -->/\1/')
    fi

    # Check if this was a passthrough (LLM unavailable)
    if echo "$llm_used" | grep -q "Passthrough"; then
        echo "⚠️  LLM unavailable, passthrough mode" >&2
        echo "$pipeline_output"  # Output the prompt for manual processing
        exit 2  # Signal that manual generation is needed
    fi

    # Strip HTML comment metadata lines
    local commit_message=$(echo "$pipeline_output" | grep -v "^<!--" | sed '/^$/d')

    # Validate we got a real message
    if [ -z "$commit_message" ] || [ ${#commit_message} -lt 10 ]; then
        echo "❌ Failed to generate valid commit message" >&2
        echo "Output was: $pipeline_output" >&2
        exit 1
    fi

    # Build full commit message with [MACRO] prefix
    local commit_title=$(echo "$commit_message" | head -1)
    local commit_body=$(echo "$commit_message" | tail -n +2)

    # Construct full message (handle case where body might be empty)
    local full_message
    if [ -n "$commit_body" ]; then
        full_message="[MACRO] ${commit_title}
${commit_body}"
    else
        full_message="[MACRO] ${commit_title}"
    fi

    # Create the commit
    local files_changed=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    local micro_count=$(count_micro_commits)

    if git diff --staged --quiet; then
        # No staged changes, create empty commit to summarize MICROs
        if git commit --allow-empty -m "$full_message" --quiet 2>/dev/null; then
            echo "✓ Macro commit created (no file changes, ${micro_count} MICROs summarized)" >&2
        else
            echo "❌ Failed to create commit" >&2
            exit 1
        fi
    else
        # Has staged changes, create normal commit
        if git commit -m "$full_message" --quiet 2>/dev/null; then
            echo "✓ Macro commit created (${files_changed} files changed, ${micro_count} MICROs summarized)" >&2
        else
            echo "❌ Failed to create commit" >&2
            exit 1
        fi
    fi

    # Report success
    echo "" >&2
    echo "📊 Summary:" >&2
    echo "  LLM: ${llm_used}" >&2
    echo "  Status: ${llm_status}" >&2
    echo "  Commit: $(git rev-parse --short HEAD)" >&2
}

# ============================================================================
# MAIN LOGIC: 3 simple cases
# ============================================================================

echo "🔄 Checking for changes and MICRO commits..." >&2

# Case 1: File changes detected (untracked, unstaged, or staged)
if has_file_changes; then
    echo "📦 Changes detected, staging and generating commit..." >&2
    git add -A
    run_llm_pipeline
    exit 0
fi

# Case 2: No file changes, but last commit is MICRO
if last_commit_is_micro; then
    echo "📝 No file changes, but MICRO commits detected..." >&2
    micro_count=$(count_micro_commits)
    echo "    Found ${micro_count} MICROs since last MACRO" >&2
    git add -A  # (no-op, but keeps logic consistent)
    run_llm_pipeline
    exit 0
fi

# Case 3: Nothing to do
echo "ℹ️  No changes or MICRO commits to summarize" >&2
exit 0
