---
description: Creates a macro commit consolidating recent micro commits with LLM-generated summary
allowed-tools: Bash(.claude/hooks/macro-commit.sh:*), Bash(git branch:*), Bash(git log:*), Bash(git status:*)
argument-hint: ""
---

## Context

This command manually triggers the macro commit process which:
1. Creates a [MACRO] commit that summarizes all [MICRO] commits since the last macro
2. Generates commit message using LLM (synchronous, ~5-10 seconds)
3. Bypasses automatic thresholds (micro count and time-based checks)

Here is the current <state> of the repository:

<state>

- **Current Branch:** !`git branch --show-current`
- **Recent Micro Commits:** !`git log --oneline --grep=MICRO -10`
- **Recent Macro Commits:** !`git log --oneline --grep=MACRO -3`
- **Status:** !`git status --short`

</state>

## Your Task

Execute the macro commit script with force flag to bypass thresholds:

<steps>

1. **Execute the macro commit script**: Run `.claude/hooks/macro-commit.sh --force`
2. **Report the result**: Inform the user about the macro commit creation
3. **Show the commit**: Display the final commit message using `git log -1 --format="%s%n%n%b"`

</steps>

## Notes

- The `--force` flag bypasses automatic thresholds (minimum micro count and time checks)
- LLM message generation is synchronous (will block for a few seconds)
- If no LLM is available, falls back to simple auto-generated message
- All [MICRO] commits remain in history; [MACRO] is just a summary marker
