---
description: Archive completed work by consolidating ideas and organizing documentation
allowed-tools: [
  "Bash(find:*)",
  "Bash(ls:*)",
  "Bash(tree:*)",
  "Bash(mkdir:*)",
  "Bash(cp:*)",
  "Read",
  "Write",
  "Edit",
  "Glob"
]
argument-hint: "[optional: project-name to archive specific project]"
---

## Context

This command archives completed work following the project's archival system documented in CLAUDE.md. It consolidates unimplemented ideas, moves completed documentation to archive/, updates DECISIONS.md, and keeps active folders clean.

**User argument:** `$ARGUMENTS` (optional project name to archive, e.g., "deployment", "mvp-visual")

**Safety:** Files are copied to archive, never deleted. At the end, a cleanup `rm` command is presented for manual user review and execution.

---

## Stage 1: Discovery & Analysis

### Task
Scan planning/ and design/ folders to identify completed work, active work, and unimplemented ideas.

### Process

**1.1 Scan Current State**

```bash
# Show current folder structure
echo "=== PLANNING FOLDER ==="
find planning/ -type f -name "*.md" 2>/dev/null | sort

echo "=== DESIGN FOLDER ==="
find design/ -type f -name "*.md" 2>/dev/null | sort

echo "=== EXISTING ARCHIVES ==="
tree archive/ -L 2 2>/dev/null || echo "No archive/ directory yet"

echo "=== IDEAS FOLDER ==="
ls -la planning/ideas/ 2>/dev/null || echo "No planning/ideas/ directory yet"
```

**1.2 Analyze Files**

Read relevant files to determine:
- Which documents are for completed/implemented work
- Which documents contain unimplemented ideas
- Which documents are active/in-progress
- Relationships between planning and design docs

**1.3 Present Discovery to User**

```
📊 WORK ARCHIVE DISCOVERY

====================
PLANNING FOLDER ANALYSIS
====================

[If user specified project name, focus on that project]
[Otherwise, show all files organized by status]

Completed Work (appears finished/implemented):
- planning/[file].md - [brief assessment of status]
- planning/[file].md - [brief assessment]

Active Work (in progress or ready for implementation):
- planning/[file].md - [brief assessment]

Contains Unimplemented Ideas:
- planning/[file].md - [ideas identified]

====================
DESIGN FOLDER ANALYSIS
====================

Completed Designs (implemented):
- design/[file].md - [status assessment]

Active Designs (ready for implementation):
- design/[file].md - [status assessment]

====================
EXISTING ARCHIVES
====================

[If archive/ exists:]
Previously archived projects:
- archive/planning/[project]/ - [X] files
- archive/design/[project]/ - [Y] files

[If no archive/ exists:]
No previous archives found. This will be the first.

====================
INTERPRETATION
====================

[If user specified project name:]
Focus: Archiving "[project-name]" related work
Found: [X] planning docs, [Y] design docs related to this project

[If no project specified:]
Opportunity to archive: [list projects/work that appears complete]

Unimplemented ideas to consolidate: [themes/features identified]

====================
⚠️  QUESTIONS
====================

1. [Is my assessment of completed vs active work correct?]
2. [Should these files be archived together or separately?]
3. [Any files I'm uncertain about - please clarify status]
```

### User Confirmation Required

**Ask user:**
```
Before proceeding, please confirm:

1. Is my assessment of completed vs. active work accurate?
   - Did I misidentify anything?
   - Should any "completed" items remain active?

2. What should be archived in this session?
   - [If user specified project]: Just "[project-name]" work?
   - [If no project specified]: Which completed work should I archive?

3. Are there unimplemented ideas to consolidate?
   - Should I extract ideas from completed docs?
   - Create new consolidated docs in planning/ideas/?

Please respond:
- "Proceed with [project-name]" (archive specific project)
- "Archive [list of items]" (specify what to archive)
- "Wait, [clarification needed]" (if something's wrong)
```

**Iteration:**
- If user corrects assessment → update understanding → re-present → confirm
- If user clarifies scope → adjust plan → re-present → confirm
- Only proceed when user explicitly confirms what to archive

---

## Stage 2: Archival Plan Proposal

### Task
Based on confirmed scope from Stage 1, propose detailed archival plan.

### Process

**2.1 Generate Archival Plan**

```
📋 PROPOSED ARCHIVAL PLAN

====================
PROJECT: [project-name]
====================

Archive Date: [YYYY-MM-DD]

====================
ARCHIVE STRUCTURE TO CREATE
====================

New directories:
- archive/planning/[project-name]/
- archive/design/[project-name]/

====================
FILES TO ARCHIVE
====================

Planning Documents → archive/planning/[project-name]/:
- planning/[file].md → [file].md (with archive header added)
- planning/[file].md → [file].md (with archive header added)
- [Total: X files]

Design Documents → archive/design/[project-name]/:
- design/[file].md → [file].md (with archive header added)
- design/[file].md → [file].md (with archive header added)
- [Total: Y files]

====================
IDEA CONSOLIDATION PLAN
====================

[If unimplemented ideas found:]

New consolidated documents to create:

1. planning/ideas/[idea-name].md
   Source: planning/[original-file].md
   Content: [extracted unimplemented concepts]
   Original will be archived after extraction

2. planning/ideas/[another-idea].md
   Source: planning/[another-file].md
   Content: [extracted concepts]

[If no ideas to consolidate:]
No unimplemented ideas to extract. All files contain completed work only.

====================
ARCHIVE READMES
====================

Will create:
- archive/planning/[project-name]/README.md
  Status: [Completed/Deferred/Cancelled]
  Summary: [2-3 sentence summary]

- archive/design/[project-name]/README.md
  Status: [Completed/Deferred/Cancelled]
  Summary: [2-3 sentence summary]

====================
DECISIONS.MD UPDATES
====================

Will add section: "YYYY-MM-DD: [Project Name]"

Key decisions to document:
1. [Decision made] - [Rationale] - Status: Implemented
2. [Decision made] - [Rationale] - Status: Deferred
3. [Alternative rejected] - [Why not chosen]

====================
CLEANUP COMMAND
====================

After archival complete, you'll manually execute:

```bash
rm planning/[file].md \\
   planning/[file].md \\
   design/[file].md \\
   design/[file].md
```

(You'll review and execute this after verifying archive is correct)

====================
ACTIVE FOLDERS AFTER CLEANUP
====================

planning/ will contain:
- [active-file].md (in progress)
- [active-file].md (ready for implementation)
- ideas/[idea].md (unimplemented concepts)

design/ will contain:
- [active-design].md (ready for implementation)

All completed work will be in archive/[planning|design]/[project-name]/
```

### User Confirmation Required

**Ask user:**
```
Does this archival plan look correct?

1. Files to archive:
   - Are all the right files included?
   - Should anything be added or excluded?

2. Idea consolidation:
   - Should these ideas be extracted?
   - Are the consolidated doc names appropriate?

3. Archive organization:
   - Is "[project-name]" the right archive folder name?
   - Should any files be organized differently?

4. Decisions to document:
   - Did I identify the key decisions?
   - Are there other important decisions to record?

5. Final state:
   - Will active folders contain the right files?
   - Is anything being archived that should stay active?

Please respond:
- "Proceed with archival" (execute the plan)
- "Change [specific aspect]" (modify the plan)
- "Stop, [issue]" (if something's wrong)
```

**Iteration:**
- If user wants changes → revise plan → re-present → confirm
- If user identifies issues → address concerns → re-present → confirm
- Only proceed when user explicitly confirms: **"Proceed with archival"**

---

## Stage 3: Execute Archival

### Task
Execute the confirmed archival plan: create structure, consolidate ideas, copy files, create READMEs, update DECISIONS.md.

### Process

**3.1 Create Archive Structure**

```bash
mkdir -p archive/planning/[project-name]
mkdir -p archive/design/[project-name]
mkdir -p planning/ideas  # if doesn't exist
```

Report: `✓ Created archive directories`

**3.2 Consolidate Ideas (if applicable)**

For each consolidated idea doc:
1. Read original source file(s)
2. Extract unimplemented concepts
3. Create planning/ideas/[idea-name].md with:
   - Header referencing original source
   - Consolidated idea content
   - Link trail to archived original

Report: `✓ Created [X] consolidated idea documents`

**3.3 Copy Files to Archive with Headers**

For each file to archive:
1. Copy to archive/[planning|design]/[project-name]/[filename].md
2. Read the copied file
3. Add archive header to the copied file:
   ```markdown
   # [Original Title] (Archived YYYY-MM-DD)

   > **Archived:** YYYY-MM-DD
   > **Status:** [Completed and implemented|Superseded|Reference]
   > **See also:** Related decisions in root DECISIONS.md

   ---

   [Original content...]
   ```

Report progress: `✓ Archived [X/Y] files...`

**3.4 Create Archive READMEs**

Using the Archive README Template from CLAUDE.md:

**archive/planning/[project-name]/README.md:**
```markdown
# [Project Name] (Archived YYYY-MM-DD)

## Status
[✅ Completed | ⏸️ Deferred | ❌ Cancelled]

## Summary
[2-3 sentence summary of what was accomplished or decided]

## Key Files
- [filename].md - [brief description]
- [filename].md - [brief description]

## Related Decisions
See root DECISIONS.md entries for YYYY-MM-DD

## Unimplemented Ideas
[If applicable:]
- [Idea description] - See planning/ideas/[filename].md
- [Another idea] - Deferred because [reason]

[If none:]
All planned features were implemented.

## Related Archives
- archive/design/[project-name]/ - Related design specifications

## Context
[Brief context about when work was done, what it achieved, current status]
```

**archive/design/[project-name]/README.md:**
```markdown
# [Project Name] Design Documentation (Archived YYYY-MM-DD)

## Status
[✅ Completed and implemented | ⏸️ Deferred]

## Summary
[2-3 sentence summary of design scope and implementation status]

## Key Files
- [filename].md - [brief description]

## Related Decisions
See root DECISIONS.md for YYYY-MM-DD decisions

## Implementation Results
[Bullet list of what was implemented from the design]

## Active Work
[If applicable: any related designs still active in design/]

## Related Archives
- archive/planning/[project-name]/ - Related planning documents

## Context
[Design creation date, implementation timeline, reference for future work]
```

Report: `✓ Created archive README files`

**3.5 Update DECISIONS.md**

Read existing DECISIONS.md, then add new section using the format from CLAUDE.md:

```markdown
## YYYY-MM-DD: [Project/Feature Name]

### Decision: [Clear decision statement]
**Rationale:** [Why this approach was chosen]
**Alternatives considered:** [Other options evaluated]
**Archived docs:** archive/[planning|design]/[project]/[file].md
**Status:** Implemented | Deferred | Rejected

[Repeat for each major decision]
```

Report: `✓ Updated DECISIONS.md with [X] decisions`

**3.6 Present Completion Summary**

```
✅ ARCHIVAL EXECUTION COMPLETE

====================
WHAT WAS ARCHIVED
====================

Planning Documents:
✓ Copied [X] files to archive/planning/[project-name]/
✓ Added archive headers with date stamps
✓ Created archive README

Design Documents:
✓ Copied [Y] files to archive/design/[project-name]/
✓ Added archive headers with date stamps
✓ Created archive README

Idea Consolidation:
[If applicable:]
✓ Created [Z] consolidated docs in planning/ideas/
✓ Extracted unimplemented concepts
✓ Added source references

[If not applicable:]
○ No ideas to consolidate (all work was implemented)

Decision Log:
✓ Added [W] decisions to DECISIONS.md
✓ Documented rationale and alternatives

====================
VERIFICATION
====================

Archive structure created:
```

```bash
tree archive/[planning|design]/[project-name]/ -L 1
```

```
Idea docs created:
```

```bash
ls -la planning/ideas/ 2>/dev/null
```

```
DECISIONS.md updated:
✓ New section added for YYYY-MM-DD

====================
⚠️  ORIGINAL FILES STILL IN PLACE
====================

The following original files have been COPIED to archive but NOT deleted:

planning/:
- planning/[file].md
- planning/[file].md

design/:
- design/[file].md

These originals are still in their original locations.
```

---

## Stage 4: Cleanup Proposal

### Task
Present the cleanup command for user to manually review and execute.

### Process

**4.1 Generate Cleanup Command**

```
🧹 CLEANUP COMMAND READY

====================
FILES TO REMOVE
====================

The following files have been successfully archived and can now be removed from active folders:

Planning files:
- planning/[file].md → archived to archive/planning/[project]/[file].md
- planning/[file].md → archived to archive/planning/[project]/[file].md

Design files:
- design/[file].md → archived to archive/design/[project]/[file].md

[If ideas were consolidated:]
Original files (ideas extracted):
- planning/[original].md → ideas consolidated to planning/ideas/[idea].md

====================
MANUAL CLEANUP COMMAND
====================

Please review the archived files in archive/[planning|design]/[project-name]/ to verify everything is correct.

When ready, execute this command to remove the originals:

```bash
rm planning/[file].md \\
   planning/[file].md \\
   design/[file].md
```

**IMPORTANT:**
1. First verify archived files are complete and correct
2. Check planning/ideas/ contains consolidated concepts (if applicable)
3. Review DECISIONS.md was updated properly
4. Only then execute the rm command above

====================
VERIFICATION CHECKLIST
====================

Before running the cleanup command, verify:

□ Archive files exist and are complete:
  `ls -la archive/planning/[project-name]/`
  `ls -la archive/design/[project-name]/`

□ Archive headers were added (check a few files):
  `head -10 archive/planning/[project-name]/[file].md`

□ Archive READMEs created:
  `cat archive/planning/[project-name]/README.md`
  `cat archive/design/[project-name]/README.md`

□ Ideas consolidated (if applicable):
  `ls -la planning/ideas/`
  `cat planning/ideas/[idea].md`

□ DECISIONS.md updated:
  `grep -A 5 "YYYY-MM-DD: [Project]" DECISIONS.md`

□ Ready to remove originals:
  Execute the rm command above

====================
AFTER CLEANUP
====================

Once you've executed the rm command, your folders will be clean:

planning/ - Only active work and ideas/
design/ - Only active designs
archive/ - All completed work preserved
DECISIONS.md - Decision history documented

You can verify with:
```bash
tree planning/ -L 2
tree design/ -L 1
tree archive/ -L 2
```
```

### User Action Required

**Tell user:**
```
Archive process complete! 🎉

Next steps:
1. Review the archived files to verify everything is correct
2. Check the verification checklist above
3. When ready, manually execute the cleanup rm command
4. Verify final folder state with tree commands

I cannot execute the rm command for you - this ensures you have full control over what gets deleted and can verify the archive first.

Would you like me to help verify anything before you run the cleanup?
```

---

## Stage 5: Final Summary

### Task
After user confirms cleanup (or chooses to keep originals), provide final summary.

### Output

```
🎯 WORK ARCHIVE PROCESS COMPLETE

====================
SUMMARY
====================

Project: [project-name]
Archive Date: YYYY-MM-DD

Archived:
- [X] planning documents → archive/planning/[project-name]/
- [Y] design documents → archive/design/[project-name]/

[If ideas consolidated:]
Consolidated:
- [Z] idea documents → planning/ideas/

Documented:
- [W] decisions → DECISIONS.md (YYYY-MM-DD section)

Archive READMEs:
✓ archive/planning/[project-name]/README.md
✓ archive/design/[project-name]/README.md

====================
ARCHIVAL SYSTEM BENEFITS
====================

✅ Completed work preserved with context
✅ Unimplemented ideas consolidated for future reference
✅ Decision rationale documented
✅ Active folders kept lean and focused
✅ Future reference made easy through READMEs

====================
CURRENT STATE
====================

Active planning/:
[List remaining files]

Active design/:
[List remaining files]

Ideas backlog:
planning/ideas/ - [X] consolidated ideas

Archived work:
archive/ - [List archived projects]

====================
NEXT ARCHIVE SESSION
====================

When you complete more work, run:
`/work-archive [next-project-name]`

This process is now documented and repeatable. The archive/ folder will grow with your completed work, while planning/ and design/ stay focused on active development.

Great job keeping your documentation organized! 🚀
```

---

## Command Principles

### Safety First
- **Never delete files automatically** - only copy to archive
- Present cleanup commands for manual user review
- User maintains full control over what gets removed
- Archive verified before any cleanup suggested

### User Confirmation at Every Stage
- Discovery → confirm assessment
- Plan → confirm archival approach
- Execution → automatic (copying/creating only)
- Cleanup → user executes manually after verification

### Preserve Information
- Copy files, don't move them initially
- Add archive headers with dates and context
- Create comprehensive READMEs
- Document decisions with rationale
- Link related archives together

### Consolidate Ideas
- Extract unimplemented concepts from completed work
- Create focused idea documents in planning/ideas/
- Reference original sources
- Maintain link trail from idea → archived original

### Keep It Organized
- Mirror planning/design structure in archive
- Use consistent naming (project-name in kebab-case)
- Date all archives and headers
- Maintain clear status indicators

---

## Error Handling

If at any stage you cannot proceed:

```
⚠️ BLOCKED - Need User Input

I cannot proceed because:
[Specific reason]

What I need from you:
[Specific information/decision/clarification]

Options:
1. [Option to move forward]
2. [Alternative approach]
3. [Skip this and continue]

How would you like to proceed?
```

Never assume. Always ask. Always confirm. Never delete without user approval.
