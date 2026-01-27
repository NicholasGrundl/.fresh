---
description: Creates structured [MACRO] commits for major structural changes
allowed-tools: [
  "Bash(git:*)"
]
argument-hint: "[optional commit message override]"
---

## Context

First, analyze the current repository state:
- Check git status: `git status --short`
- Review staged changes: `git diff --staged`
- Review unstaged changes: `git diff`
- Check recent commits: `git log --oneline -5`

## Your Task

Create a structured [MACRO] commit for major changes with proper assessment and formatting.

## Workflow

### 1. Change Analysis and Assessment

**Repository State Analysis:**
- Count modified files: `git status --porcelain | wc -l`
- Count affected directories: `git status --porcelain | cut -c4- | xargs dirname | sort -u | wc -l`  
- Check for structural changes: `git status --porcelain | grep -E '^(R|D)' | wc -l`
- Identify file types: `git status --porcelain | cut -c4- | grep -E '\.[a-z]+$' | sed 's/.*\.//' | sort | uniq -c`

**File Classification:**
- List untracked files: `git ls-files --others --exclude-standard`
- List unstaged changes: `git diff --name-only`
- List already staged: `git diff --staged --name-only`
- Flag problematic files: `git status --porcelain | grep -E '\.(log|tmp|cache|build)$|node_modules|__pycache__|\.pyc$'`

### 2. Smart Staging Based on Analysis

**Staging Decision Logic:**
- **If 0 staged files**: Need to stage everything for analysis
- **If some staged**: Review what's staged vs what should be included
- **If problematic files found**: Exclude from staging and warn user

**Staging Execution:**
- Stage tracked modifications: `git add -u`
- Review untracked files with user: Present list and get confirmation for each
- Add approved untracked files: `git add [specific-files]`
- Verify final staging: `git diff --staged --stat`
- **Critical**: Ensure no build artifacts or temp files are staged

### 3. MACRO Determination

Based on analysis, determine if changes qualify as [MACRO]:
- YES: Present MACRO commit format to user
- NO: Offer regular commit option or ask user to confirm MACRO anyway

#### When to Use [MACRO] Format

MACRO Assessment Criteria:
- File count: 10+ files modified/added/deleted
- Directory impact: 3+ directories affected
- Structural changes: File moves, renames, or deletions
- Architecture changes: Core module refactoring, build changes
- Project organization: Package structure, configuration changes

- Mass file moves/deletions/renames
- Changes that affect project structure or build process

#### When NOT to Use [MACRO] Format

- Single file changes
- Bug fixes
- Small feature additions
- Documentation updates
- Minor refactoring within a single module

### 4. User Confirmation and Commit Creation
- Generate and present proposed [MACRO] commit message to user
- Ask for explicit confirmation: "Proceed with this commit message?"
- After confirmation, execute: `git commit -m "[the generated message]"`


## Commit Formatting

### MACRO Commit Template

```
[MACRO] <one-to-two sentence summary of the major change>

--------------

Detailed changes:
• <specific change 1 with context/rationale>
• <specific change 2 with context/rationale>
• <specific change 3 with context/rationale>

<optional additional context about why this change was needed>
```

### Specific Guidelines

1. **Start with "[MACRO]"** - This tag indicates a major structural change
2. **Summary line** - One or two sentences explaining the high-level change and its purpose
3. **Clear separator** - Use dashes (`--------------`) to separate summary from details
4. **Detailed breakdown** - Use bullet points (`•`) to list specific changes
5. **Include rationale** - Explain why changes were made when relevant
6. **Be comprehensive** - Cover all significant changes in the commit

**DO NOT** add anything about made with Claude in the commit message. We acall out the use of agents elsewhere in the repo.
- i.e. no "🤖 Generated with [Claude Code](https://claude.ai/code)"
- i.e. no "Co-Authored-By: Claude <noreply@anthropic.com>"

## Examples

### Good Example: Follows format, sufficient detail
```
[MACRO] Archive historical outputs and reorganize project structure. Moved all dated output folders, recordings, and large files to +archive/ directory to clean up repository for proper packaging.

--------------

Detailed changes:
• Consolidated 19 dated output folders (2024-07-12-output through 2025-10-06-output) into +archive/
• Moved data/, output/, output_test/, +recordings/, and summary_files/ directories to +archive/
• All .mkv video files and .wav audio files now archived (total ~27 .mkv files)
• Deleted original locations from git tracking as they're now in +archive/ (ignored by .gitignore)
• Project root now contains only core Python modules, notebooks, and configuration files
• Modified CreateTranscriptProd.ipynb and summarize_transcript.py (existing uncommitted changes)

This cleanup prepares the repository for proper Python packaging by separating active code from historical data/outputs.
```

### Bad Example: Vague, does not follow guidelines, does not follow format.

```
fix stuff

moved some files around and cleaned things up
```

