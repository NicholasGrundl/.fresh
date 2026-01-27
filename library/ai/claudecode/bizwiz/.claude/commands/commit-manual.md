---
description: Generates and executes a git commit based on current changes.
allowed-tools: Bash(git add:.), Bash(git commit:*)
argument-hint: "[optional commit title]"
---

## Context

Here is the current <state> of the repository:

<state>

- **Current Branch:** !`git branch --show-current`
- **Staged and Unstaged Changes:**
  !`git diff HEAD`
- **Recent Commits:**
  !`git log --oneline -40`
- **Status:**
  !`git status --short`

</state>

## Your Task

Based on the context above, please perform the following <steps> one at a time:

<steps>

1.  **Analyze the changes and context** in the <state> thoroughly to understand the purpose, scope, and recent trajectroy of work in the repo.
2.  **Generate a commit message** following the Conventional Commits guidelines and any additional <additional_guidelines>. The user's argument is: `$ARGUMENTS`
3.  **Stage all current changes** by executing the `git add .` command.
4.  **Commit the staged changes** by executing the `git commit` command with the exact commit message you just generated. If there are no changes but a series of MICRO commite, make an empty commit summarizing the body of work (e.g. `--allow-empty`)

5. Update the user with a message. Include the commit type and subject, then an even more abridged summary of the content in bulleted form.

</steps>


<additional_guidelines>
The message must include a type, a subject, and a detailed body. 

If the user provided an argument, use it as the subject for the commit message. 

Do not include anything about claude code 

Include a initial prefix that is the robot emoji top indicate an agentic system created the commit
</additional_guidelines>

**IMPORTANT**

DO NOT EVER INCLUDE ANYTHING ABOUt CLAude coDE wRITING THE COMMIT.

for example never include:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
    
Co-Authored-By: Claude <noreply@anthropic.com>
```