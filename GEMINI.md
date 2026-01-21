# GEMINI.md

## Purpose

This repo (`.fresh`) contains dotfiles, shell configs, LLM prompt templates, and setup guides across multiple OS environments.

## My Background

- Python expert—skip syntax basics
- Proficient in JS/HTML/CSS—remind me of non-obvious best practices
- Primary OS targets: macOS, Windows 11 (PowerShell), WSL2 Ubuntu
- Bash-first philosophy; prefer cross-platform solutions when possible

## How We Work

- Be concise. Assume competence.
- When uncertain, ask clarifying questions—but keep them focused (1-3 at a time) so I can respond quickly
- If I have strong opinions, I'll elaborate; otherwise, make a reasonable call and move on
- Avoid over-explaining unless I ask for detail

## This Project

The goal is to organize and maintain config files, dotfiles, and documentation.

Common tasks:
- Reorganizing folder structures
- Moving and renaming files for clarity
- Creating logical hierarchies
- Consolidating or splitting configs

Guidelines:
- Don't hardcode paths or specific filenames in persistent docs—structure will evolve
- Prefer descriptive, lowercase, hyphenated names for files and folders
- Group by purpose or OS when it makes sense
- Ask before bulk deletions or major restructures

## State Tracking

For complex, multi-step operations:
1. Create a root-level `actions.md`.
2. List steps as a markdown checklist (`- [ ] Step description`).
3. Execute one logical step at a time (e.g., one shell command or one file edit).
4. After verifying success, mark the step as complete (`- [x]`) in `actions.md`.
5. Keep it lightweight—no need for elaborate logging in the file itself, just the status.

## Inspecting File Hierarchies

Use the `tree` command to visualize the project structure efficiently.

**Recommended Patterns:**

- **Basic depth-limited view:**
  `tree -L 2` (Shows current directory and one level of subdirectories)
- **Directories only:**
  `tree -d` (Filters out files to show only the folder structure)
- **Directories only with depth limit:**
  `tree -d -L 2`
- **Include hidden files:**
  `tree -a -L 2`
- **Respect .gitignore:**
  `tree --gitignore`
- **Human-readable sizes and permissions:**
  `tree -ph`
- **JSON output for programmatic use:**
  `tree -J -L 2`
