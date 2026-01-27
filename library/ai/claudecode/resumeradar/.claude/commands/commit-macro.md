---
description: Creates a macro commit consolidating recent micro commits with LLM-generated summary
allowed-tools: Bash(.claude/tools/lib/commit-auto.sh:*), Bash(git branch:*), Bash(git log:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git commit:*), Bash(git add:*)
argument-hint: ""
---

## Context

This command manually triggers the macro commit process using the automated pipeline:
1. Creates a [MACRO] commit that summarizes all [MICRO] commits since the last macro
2. Generates commit message using LLM via the modular pipeline
3. Same as `/commit-auto` but intended for manual invocation

Here is the current <state> of the repository:

<state>

- **Current Branch:** !`git branch --show-current`
- **Recent Micro Commits:** !`git log --oneline --grep=MICRO -10`
- **Recent Macro Commits:** !`git log --oneline --grep=MACRO -3`
- **Status:** !`git status --short`

</state>

## Your Task

Execute the commit-auto script to create the macro commit:

<steps>

1. **Execute the script**: Run `.claude/tools/lib/commit-auto.sh` and capture both stdout and exit code

2. **Handle the result based on exit code**:

   **If exit code 0 (Success):**
   - LLM generated message and commit was created
   - Display the commit using `git log -1 --format="%s%n%n%b"`
   - Report which LLM was used (from script's stderr output)
   - Inform user of success

   **If exit code 2 (Passthrough - LLM unavailable):**
   - The script output contains the enriched prompt (git context)
   - Read the prompt from the script's stdout
   - Use your analysis capabilities to generate a commit message following the macro commit format
   - Stage all changes with `git add -A`
   - Create the commit with `[MACRO]` prefix using `git commit -m`
   - Report that you generated the message (LLM was unavailable)

   **If exit code 1 (Error):**
   - Report the error from stderr
   - Do NOT create a commit
   - Suggest user check git status

3. **Show final result**: Display the created commit hash and message to the user

</steps>

## Notes

- This uses the same pipeline as `/commit-auto`
- LLM calls may take 30-60 seconds for large contexts (warnings will be shown)
- All [MICRO] commits remain in history; [MACRO] is a summary marker
- If LLM unavailable, you'll generate the message based on git context
