---
description: Analyze project state and provide context for resuming work
allowed-tools: [
  "Bash(git log:*)",
  "Bash(git status:*)",
  "Bash(git diff:*)",
  "Bash(tree:*)",
  "Bash(find:*)",
  "Bash(ls:*)",
  "Bash(stat:*)",
  "Bash(grep:*)",
  "Read",
  "Glob"
]
argument-hint: "[optional: 'quick'|'deep' mode]"
---

## Context

This command provides context for resuming work after a break. It analyzes the project state, recent activity, and current tasks to help you quickly orient yourself or rebuild deep context after extended absence.

**User argument:** `$ARGUMENTS` (optional: "quick" or "deep" to force mode)

**Two modes:**
- **Quick**: Short break (< 3 hours) - What was I just doing?
- **Deep**: Extended absence (days/weeks) - What's the project state and trajectory?

---

## Stage 1: Time Detection & Mode Selection

### Task
Determine how long since last work and select appropriate mode.

### Process

**1.1 Get Last Work Timestamp**

```bash
# When was the last commit?
git log -1 --format="%ar|%aI|%s"
```

Parse output: `relative_time|iso_timestamp|subject`

**1.2 Calculate Time Since Last Work**

From ISO timestamp, calculate hours since last commit.

**1.3 Mode Selection Logic**

```
IF user provided argument ($ARGUMENTS):
  → Use specified mode ("quick" or "deep")
  → Skip to Stage 2

ELSE IF last work < 3 hours ago:
  → Suggest quick mode
  → Ask: "Last worked [X] hours ago. Quick summary? (yes/no/deep)"
  → User chooses

ELSE:
  → No assumption
  → Ask: "Last worked [X] [hours/days] ago. Choose mode:
         - 'quick' - Short break summary
         - 'deep' - Extended absence context rebuild"
  → User chooses
```

**1.4 Present Mode Selection to User**

**If < 3 hours ago:**
```
⏰ TIME SINCE LAST WORK: [X] hours ago

Last commit: [subject line]

This was recent work. Would you like:
- Quick summary (what you were doing, what's next)
- Deep context (full project state and trajectory)

Respond with: "quick" or "deep"
```

**If ≥ 3 hours ago:**
```
📅 TIME SINCE LAST WORK: [X] [hours/days/weeks] ago

Last commit: [subject line]

Choose context level:
- 'quick' - Short summary (what you were doing, immediate next steps)
- 'deep' - Full rebuild (project trajectory, decisions, structure changes)

Respond with: "quick" or "deep"
```

### User Confirmation Required

Wait for user to select mode before proceeding to Stage 2.

---

## Stage 2: Information Gathering (Quick Mode)

### Task
Gather focused information for quick resume from short break.

### Process

**2.1 Last Meaningful Commit**

```bash
# Get last 100 commits, filter out [MICRO] prefix
git log -100 --format="%h|%ar|%s" | grep -v "\[MICRO\]" | head -1
```

Parse: `hash|relative_time|subject`

**2.2 Current Task State**

```bash
# Find in-progress tasks in TASKS-TODO.md
grep -B 2 -A 5 "\[~\]\|\[ \] .*in progress" TASKS-TODO.md 2>/dev/null || echo "No in-progress tasks marked"

# Alternative: look for tasks being worked on
grep -B 3 "- \[ \]" TASKS-TODO.md | head -20
```

**2.3 Uncommitted Changes**

```bash
# What files have changes?
git status --short

# Summary of changes
git diff --stat HEAD
```

**2.4 Recent File Activity**

```bash
# Last 5 modified files in relevant directories (by modification time)
find src/ design/ planning/ -type f \( -name "*.md" -o -name "*.ts" -o -name "*.astro" -o -name "*.js" \) \
  -mtime -1 2>/dev/null | \
  xargs ls -lt 2>/dev/null | head -5
```

**2.5 Active Design/Planning Docs**

```bash
# What docs are actively being referenced?
ls -lt design/*.md planning/*.md 2>/dev/null | head -5
```

---

## Stage 3: Information Gathering (Deep Mode)

### Task
Gather comprehensive information for context rebuild after extended absence.

### Process

**3.1 Project Trajectory (Meaningful Commits)**

```bash
# Last 10 meaningful commits (excluding [MICRO])
git log -100 --format="%h|%ar|%s" | grep -v "\[MICRO\]" | head -10

# Verify at least one non-MICRO commit exists
MEANINGFUL_COUNT=$(git log -100 --format="%s" | grep -v "\[MICRO\]" | wc -l)

# If all MICRO, inform user of unusual state
```

**3.2 Recent Decisions**

```bash
# Recent DECISIONS.md entries (last 30 days context)
# Find date headers and get surrounding context
grep -B 1 -A 30 "^## 202" DECISIONS.md 2>/dev/null | head -80
```

**3.3 Recently Completed Work**

```bash
# Check archive for recently archived projects
ls -lt archive/planning/ archive/design/ 2>/dev/null | head -10
```

**3.4 Current Active Work**

```bash
# Active planning documents
ls -lt planning/*.md 2>/dev/null | head -8

# Active design documents
ls -lt design/*.md 2>/dev/null | head -8

# Ideas backlog
ls -la planning/ideas/ 2>/dev/null
```

**3.5 Project Structure (Strategic Tree)**

```bash
# Source code structure (4 levels deep, exclude noise)
tree -L 4 src/ --dirsfirst -I 'node_modules|dist|.git|__pycache__|*.pyc|.next|.cache' 2>/dev/null || \
  find src/ -maxdepth 4 -type d | head -30

# Documentation structure (2-3 levels)
tree -L 2 planning/ design/ -I 'node_modules|.git' 2>/dev/null || \
  ls -R planning/ design/ | head -30

# Archive structure (3 levels to show projects)
tree -L 3 archive/ -I 'node_modules|.git' 2>/dev/null || \
  ls -R archive/ | head -20
```

**3.6 File Modifications (What Changed While Away)**

Calculate time since last work from Stage 1, then:

```bash
# Files modified since last work (use calculated days)
# If last work was 7 days ago, use -mtime -7
find src/ design/ planning/ -type f -mtime -[DAYS] 2>/dev/null | \
  xargs ls -lt 2>/dev/null | head -10

# New files created
find . -name "*.md" -o -name "*.ts" -o -name "*.astro" -mtime -[DAYS] -type f 2>/dev/null | \
  grep -v node_modules | head -10
```

**3.7 Uncommitted Changes**

```bash
# Current git status
git status --short

# Diff summary
git diff --stat HEAD
```

---

## Stage 4: Context Synthesis (Quick Mode)

### Output Format

```
⏰ WORK STATUS: Quick Resume

====================
TIME CONTEXT
====================

Last worked: [X hours ago]
Last commit: [relative time]: [subject]

====================
WHAT YOU WERE DOING
====================

Last meaningful work:
[hash] ([time ago]): [commit subject]
[commit body if available, first 2-3 lines]

====================
CURRENT TASK
====================

[If found in TASKS-TODO.md:]
From TASKS-TODO.md:

Phase: [Phase name]
  [~] [Task in progress]  ← ACTIVE
  [ ] [Next task]
  [ ] [Following task]

[If no clear in-progress task:]
Active tasks in TASKS-TODO.md:
  [List next 3-5 pending tasks]

====================
RECENT FILE CHANGES
====================

[If uncommitted changes:]
Uncommitted changes:
  [M/A/D] [filename] ([type of change inferred])
  [M/A/D] [filename]

[If no changes:]
Working directory clean

Recently modified files:
  [filename] - [modification time]
  [filename] - [modification time]

====================
ACTIVE REFERENCES
====================

Recent design/planning docs:
  - [design-file].md (modified [time ago])
  - [planning-file].md (modified [time ago])

====================
QUICK CONTEXT
====================

You were: [Inferred activity from commit + files + tasks]

Next steps: [Specific actionable next step from task or commit context]

Reference docs:
  - [relevant-doc].md:[line] (if specific section identifiable)

====================
READY TO CONTINUE?
====================

Context loaded. You can pick up where you left off.

[If uncommitted changes:]
Note: You have uncommitted changes in [X] files. Review with `git status`.

🚀 Ready to continue!
```

---

## Stage 5: Context Synthesis (Deep Mode)

### Output Format

```
📊 WORK STATUS: Deep Context Rebuild

====================
TIME CONTEXT
====================

Last worked: [X days/weeks ago]
Time away: [Duration in human-readable format]

====================
PROJECT TRAJECTORY (Last [N] Meaningful Commits)
====================

[For each meaningful commit, newest first:]
[hash] ([time ago]): [subject]
  [First 2 lines of body if meaningful]

[If all commits are MICRO:]
⚠️ Note: Last 100 commits are all auto-commits ([MICRO])
        No manual commits found recently.

====================
KEY DECISIONS (Last 30 Days)
====================

[From DECISIONS.md, if entries found:]

## [Date]: [Project/Feature Name]

### Decision: [Decision summary]
**Rationale:** [Why]
**Status:** [Implemented/Deferred/Rejected]

[Next decision...]

[If no recent decisions:]
No decisions documented in last 30 days.

====================
RECENTLY COMPLETED WORK
====================

[From TASKS-COMPLETED.md:]
Completed phases:
  ✅ [Phase name] (completed [date])
  ✅ [Phase name] (completed [date])

[From archive/ structure:]
Archived projects:
  📦 archive/planning/[project-name]/ (archived [date from README])
  📦 archive/design/[project-name]/ (archived [date from README])

[If nothing found:]
No recently completed work logged.

====================
CURRENT WORK STATE
====================

Active Planning Documents:
  - planning/[file].md ([last modified])
  - planning/[file].md ([last modified])

Active Design Documents:
  - design/[file].md ([last modified])
  - design/[file].md ([last modified])

Ideas Backlog:
  planning/ideas/ - [X] idea documents
  - [idea-name].md
  - [idea-name].md

Tasks In Progress:
  [From TASKS-TODO.md]
  Phase: [Phase name]
    [~] [Task marked in progress]
    [ ] [Next pending task]

====================
PROJECT STRUCTURE
====================

Source Code (src/):
[tree output for src/ at depth 4, formatted]

Documentation:
planning/ - [X] active docs
design/ - [Y] active docs
archive/ - [Z] archived projects

[Abbreviated tree output showing high-level structure]

====================
WHAT CHANGED WHILE AWAY
====================

Files modified in last [X] days:
  [Modified file list with dates]

New files created:
  [New file list if significant]

New archives created:
  [Archive folders created while away]

Meaningful commits while away: [Count]
Auto-commits ([MICRO]): [Count]

====================
WHERE YOU LEFT OFF
====================

Last focus: [Inferred from last meaningful commit + active tasks]

Progress: [Status from tasks or files]

Blocked by: [Check for any blockers in tasks/comments]
            [Or: "Nothing - ready to continue"]

Next task: [Specific next action from TASKS-TODO.md]

Recent context: [Summary of recent work trajectory]

====================
RECOMMENDATIONS
====================

[If many uncommitted changes:]
⚠️ Review uncommitted changes: [X] files modified
   Run `git status` to see what's pending

[If tasks marked in progress but no recent commits:]
⚠️ Task marked in progress but no recent activity
   Review task status in TASKS-TODO.md

[If new decisions or archives:]
📋 Review recent decisions in DECISIONS.md
📦 Check archived work in archive/[project]/

[If ideas added:]
💡 New ideas added to planning/ideas/ while away

====================
READY TO REBUILD CONTEXT
====================

[Context summary paragraph synthesizing above information]

You were last working on: [Specific work]
The project has [progressed/remained stable/had major changes]
[X] meaningful commits since you left

Suggested next steps:
1. [Most immediate action from tasks]
2. [Follow-up action]
3. [Reference to review if needed]

🚀 Context rebuilt! Ready to continue.
```

---

## Stage 6: Smart Commit Analysis (Helper Logic)

### Robust Commit Filtering

```bash
# Function to get meaningful commits
get_meaningful_commits() {
  local count=$1  # How many to retrieve

  # Get last 100 commits, filter out [MICRO] prefix
  git log -100 --format="%h|%ar|%s|%b" | grep -v "\[MICRO\]" | head -n "$count"

  # Verify we found at least one
  local found=$(git log -100 --format="%s" | grep -v "\[MICRO\]" | wc -l | tr -d ' ')

  if [ "$found" -eq 0 ]; then
    echo "⚠️ All recent 100 commits are [MICRO] auto-commits"
    echo "This is unusual - manual commits may be very old"
  fi
}

# Usage:
# Quick mode: get_meaningful_commits 1
# Deep mode: get_meaningful_commits 10
```

### Parse Commit Format

```
Format: hash|relative_time|subject|body
Parse:
  - hash: First field
  - relative_time: Second field (e.g., "3 hours ago")
  - subject: Third field (commit title)
  - body: Fourth field (may be empty)

Display:
  [hash] ([relative_time]): [subject]
  [body first 2-3 lines if not empty]
```

---

## Command Principles

### User-Driven Mode Selection
- Never assume which mode user wants
- When recent (< 3 hours), suggest quick mode but allow deep
- When not recent, present both options clearly
- Respect explicit mode argument if provided

### Efficient Information Gathering
- Use `tree` for structure (fast, hierarchical)
- Use `grep -v "[MICRO]"` to filter commits (excludes noise)
- Use `find` with time filters for recent files
- Use `ls -lt` for recent-first sorting
- Strategic depth: 4 levels src/, 2-3 elsewhere

### Actionable Output
- Always end with "what's next"
- Reference specific files (with line numbers when possible)
- Provide clear re-entry point
- Highlight blockers or pending decisions

### Context-Aware Analysis
- Synthesize information, don't just dump data
- Infer what user was doing from multiple sources
- Flag unusual states (all MICRO commits, stale in-progress tasks)
- Adapt depth based on time away

---

## Error Handling

### No Git History
```
⚠️ NO GIT HISTORY FOUND

This doesn't appear to be a git repository or has no commits yet.

Cannot provide work status without git history.
```

### No Recent Meaningful Commits
```
⚠️ UNUSUAL STATE

Last 100 commits are all [MICRO] auto-commits.

This means:
- No manual commits in recent history
- May need to expand search
- Or this is a new repository

Showing most recent auto-commit activity instead...
```

### No TASKS-TODO.md
```
⚠️ NO TASKS FILE

TASKS-TODO.md not found.

Cannot show current task status. Showing recent commit activity only.
```

### Empty Working Directory
```
✅ CLEAN STATE

No active work detected:
- No uncommitted changes
- No in-progress tasks
- Working directory clean

Last activity: [last commit info]
```

---

## Usage Examples

### Quick Resume
```
$ /work-status

⏰ TIME SINCE LAST WORK: 2 hours ago
Last commit: docs: update deployment guide

Would you like:
- Quick summary (what you were doing, what's next)
- Deep context (full project state and trajectory)

> quick

[Quick summary output...]
```

### Deep Context with Explicit Mode
```
$ /work-status deep

📊 WORK STATUS: Deep Context Rebuild

Last worked: 8 days ago
Time away: 1 week, 1 day

[Full deep context output...]
```

### Auto-Detect Recent Work
```
$ /work-status

⏰ TIME SINCE LAST WORK: 45 minutes ago
Last commit: feat: add color palette

This was recent work. Quick summary? (yes/no/deep)

> yes

[Quick summary output...]
```

---

## Implementation Notes

### Time Calculation
```bash
# Get ISO timestamp from last commit
LAST_COMMIT_ISO=$(git log -1 --format="%aI")

# Current time
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Calculate difference in seconds (requires date utilities)
# Convert to hours for threshold check
# < 10800 seconds = < 3 hours = suggest quick mode
```

### Tree Efficiency
- Don't read file contents unless necessary
- Use `tree` to see structure without reading
- Use `--dirsfirst` to show folders first
- Exclude common noise patterns upfront

### Smart Inference
Combine multiple signals:
- Last commit message → what feature/task
- Modified files → which component/area
- In-progress tasks → explicit statement of work
- Recent docs → reference material being used

Synthesize into: "You were [doing X] on [component Y] using [approach Z]"

### Respect User's Time
- Quick mode: < 30 lines output, immediately actionable
- Deep mode: Comprehensive but organized into scannable sections
- Always end with "what's next" - don't make user hunt for it
