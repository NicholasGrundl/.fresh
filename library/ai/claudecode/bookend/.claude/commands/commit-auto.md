---
description: Automatically generate and create a MACRO commit using LLM analysis of git history
allowed-tools: Bash(.claude/hooks/commit-auto.sh:*), Bash(git log:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git commit:*), Bash(git add:*)
argument-hint: ""
---

## Context

This command automates MACRO commit creation using a modular pipeline:
1. Extract git context (MACRO commits, MICRO commits, current status)
2. Build LLM prompt from template
3. Call LLM (Gemini → Claude → Ollama with fallback)
4. Create [MACRO] commit with generated message

**Note:** This may take 15-60 seconds for large contexts as the LLM processes the git history.

Here is the current <state> of the repository:

<state>

- **Current Branch:** !`git branch --show-current`
- **Recent MICRO Commits:** !`git log --grep="MICRO" --format="%h|%ad|%s" --date=short -20 2>/dev/null || echo "None"`
- **Recent MACRO Commits:** !`git log --grep="MICRO" --invert-grep --format="%h|%ad|%s" --date=short -3 2>/dev/null || echo "None"`
- **Status:** !`git status --short`

</state>

## Your Task

Execute the automated commit pipeline and handle the result:

<steps>

1. **Execute commit-auto script**: Run `.claude/hooks/commit-auto.sh` and capture both stdout and exit code

2. **Handle the result based on exit code**:

   **If exit code 0 (Success):**
   - LLM generated message and commit was created
   - Display the commit using `git log -1 --format="%s%n%n%b"`
   - Report which LLM was used (from script's stderr output)
   - Inform user of success

   **If exit code 2 (Passthrough - LLM unavailable):**
   - The script output contains the enriched prompt (git context)
   - Read the prompt from the script's stdout
   - Use your analysis capabilities to generate a commit message following the macro commit format:
     - Use conventional commit format: `type(scope): description`
     - Add 2-4 paragraphs telling the development story
     - Focus on the journey, iterations, and problem-solving
     - Types: feat, fix, refactor, docs, test, chore
   - Stage all changes with `git add -A`
   - Create the commit with `[MACRO]` prefix using `git commit -m`
   - Report that you generated the message (LLM was unavailable)

   **If exit code 1 (Error):**
   - Report the error from stderr
   - Do NOT create a commit
   - Suggest user check git status and try `/commit-macro` as fallback

3. **Show final result**: Display the created commit hash and message to the user

</steps>

## Notes

- The pipeline uses modular scripts in `.claude/hooks/lib/`
- Progress messages appear on stderr (you'll see "Calling Gemini...", etc.)
- LLM calls may take 30-60 seconds for large contexts (warnings will be shown)
- All [MICRO] commits remain in history; [MACRO] is a summary marker
- If LLM unavailable, you'll generate the message based on git context
