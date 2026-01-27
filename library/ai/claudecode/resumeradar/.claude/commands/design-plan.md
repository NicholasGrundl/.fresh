---
description: Interactive design document creation from unstructured planning with user confirmation at each stage
allowed-tools: [
  "Bash(find:*)",
  "Bash(ls:*)", 
  "Bash(grep:*)",
  "Bash(tree:*)",
  "Read",
  "Write",
  "Edit",
  "web_search",
  "web_fetch"
]
argument-hint: "[optional focus: 'feature-name'|'system-area'|'all']"
---

## Context

This command creates verified design documents through an interactive, iterative process:
1. **Analyze** - Understand scattered planning materials and current project state
2. **Confirm Direction** - Align on design scope and approach with user
3. **Verify Context** - Ensure technical documentation is available
4. **Generate Design** - Create workable design document for implementation

**Critical Principle:** User confirmation required before advancing to next stage. Iterate until alignment achieved.

---

## Stage 1: Discovery & Analysis

### Task
Explore and understand the current state without making assumptions.

### Process

**1.1 Scan Planning Directory**
```bash
# Discover everything in planning/
find planning/ -type f
tree planning/ -L 3
```

**What to look for:**
- Notes, brainstorms, ideas (*.md, *.txt, *.html)
- Visual materials (*.svg, *.png, diagrams)
- Code snippets, pseudocode, draft implementations
- Any structure (folders, naming patterns) or lack thereof
- Dates, versions, related materials

**1.2 Scan Design Directory**
```bash
# Check existing designs
find design/ -type f 2>/dev/null || echo "No design directory"
ls -lt design/ 2>/dev/null
```

**What to look for:**
- Previous design documents
- Implemented vs. unimplemented designs
- Related areas that might be affected
- Design patterns or structure to maintain

**1.3 Scan Context Directory**
```bash
# Check available context
find context/ -type f 2>/dev/null || echo "No context directory"
tree context/ -L 2
```

**What to look for:**
- Package documentation available
- API references present
- Syntax guides
- Framework documentation
- Gaps that might be needed

**1.4 Quick Repository Scan** (if relevant)
```bash
# Understand current implementation state
find src/ -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null | head -20
ls -la *.md 2>/dev/null
```

**What to look for:**
- Current project structure
- Implemented features
- Coding patterns in use
- Configuration files

### Output to User

Present findings as a structured summary:

```
📊 DISCOVERY ANALYSIS

====================
PLANNING MATERIALS FOUND
====================

Structured Documents (if any):
- planning/[file].md - [brief description of content]
- planning/[file].txt - [brief description]

Scattered Notes/Ideas:
- planning/notes/[files] - [themes identified]
- planning/[random-file] - [content type]

Visual Materials:
- planning/diagrams/[files] - [what they show]
- planning/[image].svg - [subject]

Code/Implementation Drafts:
- planning/draft-[name] - [what it implements]
- planning/[snippet].py - [functionality]

Key Themes Identified:
1. [Theme/Feature Area] - Found in: [files]
2. [Theme/Feature Area] - Found in: [files]
3. [Open questions/gaps]

====================
CURRENT DESIGN STATE
====================

Existing Design Documents:
- design/[file].md - [status: implemented/partial/unknown]
- [No existing designs] OR [List designs]

Design Patterns Observed:
- [Pattern/structure if identifiable]
- [None identified] OR [List]

====================
PROJECT CONTEXT
====================

Available Technical Context:
- context/packages/ - [X] files: [list key packages]
- context/apis/ - [X] files: [list]
- context/syntax/ - [X] files: [list]
- [Missing directory] - Not present

Current Implementation:
- Project structure: [language/framework if identifiable]
- Key directories: [src/, lib/, etc.]
- Configuration: [files found]

====================
INTERPRETATION
====================

What I think you're trying to build:
[High-level interpretation of the planning materials]

Scope appears to be:
[ ] Small feature addition
[ ] New system/module
[ ] Major refactor/redesign
[ ] Full project
[ ] Unclear - need clarification

Related existing designs that might be affected:
- [design file] - [relationship]
- None identified

====================
⚠️  AMBIGUITIES & QUESTIONS
====================

I'm uncertain about:
1. [Question about scope]
2. [Question about priorities]
3. [Conflicting information in planning]
4. [Missing information]
```

### User Confirmation Required

**Ask user:**
```
Before proceeding, I need your input:

1. Is my interpretation of the planning materials correct?
   - What did I miss or misunderstand?
   - What's not relevant and should be ignored?

2. What is the actual scope of this design work?
   - Specific feature: [user describes]
   - System area: [user describes]
   - Full project: [user describes]

3. Are there existing designs I should maintain consistency with?
   - Which design documents matter?
   - What patterns/decisions must be preserved?

4. What's the priority/focus?
   - What must be in this design?
   - What can be deferred?

Please correct my understanding or confirm I can proceed to planning.
```

**Iteration:**
- If user provides corrections → update analysis → re-present → confirm
- If user clarifies scope → adjust interpretation → re-present → confirm
- Only proceed when user explicitly confirms: **"Yes, proceed to Stage 2"**

---

## Stage 2: Design Direction & Scope Definition

### Task
Define what design document(s) to create and what they should contain.

### Process

**2.1 Based on confirmed understanding from Stage 1, propose design approach:**

```
📋 PROPOSED DESIGN APPROACH

====================
DESIGN DOCUMENT(S) TO CREATE
====================

Primary Design Document:
design/[PROPOSED-NAME].md

Purpose:
[What this design will specify]

Scope:
[What will be included in this design]

Structure (proposed):
1. Overview
2. [Section based on content]
3. [Section based on content]
4. [Section based on content]
5. Implementation Notes
6. Integration Points (if applicable)
7. References

====================
RELATIONSHIP TO EXISTING DESIGNS
====================

Will reference/integrate with:
- design/[existing].md - [how they relate]

Will supersede/update:
- [old design sections] - [what changes]

Will remain independent of:
- [other designs] - [why separate]

====================
KEY QUESTIONS TO ANSWER IN DESIGN
====================

From planning materials, this design needs to address:
1. [Question from planning] → [Design section]
2. [Question from planning] → [Design section]
3. [Technical decision needed] → [Design section]

====================
CONTENT CONSOLIDATION PLAN
====================

Planning materials to consolidate:

Into [Section 1]:
- planning/[file] - [specific content to extract]
- planning/[file] - [specific content to extract]

Into [Section 2]:
- planning/[file] - [specific content to extract]

Gaps to fill:
- [Gap identified] - [how to address]

Conflicts to resolve:
- [Conflicting approaches in planning] - [resolution strategy]

====================
DESIGN DETAIL LEVEL
====================

Proposed detail level:
[ ] High-level architecture (concepts, components, relationships)
[ ] Detailed specification (APIs, data structures, algorithms)
[ ] Implementation guide (step-by-step, code examples)

Rationale: [why this level is appropriate]
```

### User Confirmation Required

**Ask user:**
```
Does this design approach align with your intent?

1. Design document name/location:
   - Is "design/[PROPOSED-NAME].md" appropriate?
   - Should it be named differently?

2. Design scope:
   - Have I included the right things?
   - Is anything missing?
   - Is anything out of scope?

3. Design structure:
   - Do the proposed sections make sense?
   - Should sections be added/removed/renamed?

4. Design detail level:
   - Is the proposed detail level correct?
   - More detailed? Less detailed? Different focus?

5. Consolidation approach:
   - Am I pulling from the right planning materials?
   - Are there other sources to consider?
   - Should anything be excluded?

Please provide feedback or confirm: "Yes, proceed to Stage 3"
```

**Iteration:**
- If user wants different structure → revise proposal → re-present → confirm
- If user clarifies scope → adjust design plan → re-present → confirm
- If user identifies missing materials → incorporate → re-present → confirm
- Only proceed when user explicitly confirms: **"Yes, proceed to Stage 3"**

---

## Stage 3: Technical Context Verification

### Task
Ensure all technical references in planning can be verified before writing design.

### Process

**3.1 Extract technical references from planning materials:**

```bash
# Identify technical terms, packages, APIs mentioned
grep -r "import\|require\|package\|library\|API\|framework" planning/
```

**3.2 Create technical inventory from planning:**

```
🔍 TECHNICAL CONTEXT INVENTORY

====================
TECHNOLOGIES REFERENCED IN PLANNING
====================

Languages/Runtimes:
- [Language] version [X] - Mentioned in: [files]

Packages/Libraries:
- [package-name] - Used for: [purpose] - Mentioned in: [files]
- [package-name] - Used for: [purpose] - Mentioned in: [files]

APIs/Services:
- [API name] - Purpose: [what for] - Mentioned in: [files]

Frameworks/Tools:
- [framework] - Purpose: [what for] - Mentioned in: [files]

Patterns/Architectures:
- [pattern name] - Mentioned in: [files]

====================
CONTEXT VERIFICATION STATUS
====================

✓ Available in context/:
- [package] - context/packages/[file].md
- [API] - context/apis/[file].md

⚠️  Partially documented:
- [item] - context/[file].md exists but incomplete
- Missing: [specific info needed]

❌ Not documented:
- [package] - No documentation in context/
- [API] - No documentation in context/
- [syntax/pattern] - No reference found

====================
CONTEXT ACQUISITION PLAN
====================

Need to acquire context for:

1. [package-name] version [X]
   Purpose in design: [why we need this]
   Search strategy: Official docs for [package-name]
   Save to: context/packages/[package-name].md

2. [API-name]
   Purpose in design: [why we need this]
   Search strategy: [API] official documentation
   Save to: context/apis/[API-name].md

3. [pattern/syntax]
   Purpose in design: [why we need this]
   Search strategy: [framework] [pattern] guide
   Save to: context/syntax/[framework]-[pattern].md

Total items needing context: [X]
Estimated web searches needed: [Y]
```

### User Confirmation Required

**Ask user:**
```
I've identified technical items that need verification.

OPTION 1: I search the web for context
I can search for and fetch:
- [List items to search]

This will take [estimated] web searches/fetches.
I'll save documentation to context/ for future use.

OPTION 2: You provide context
If you have documentation, you can:
- Paste content directly
- Share URLs for me to fetch
- Upload documentation files

OPTION 3: Proceed with partial context
I can write the design with:
- ✓ Verified items (using existing context)
- ⚠️ Unverified items (flagged as assumptions)

OPTION 4: Skip items
Tell me which items to exclude from the design.

What would you like to do?
- "Search for [all/specific items]"
- "I'll provide [specific items]"
- "Proceed with partial context"
- "Skip [specific items]"
```

**3.3 If user approves web search:**

For each item, search interactively:

```
🔍 Searching: [package-name] official documentation

Search query: "[package-name] official documentation"
[Perform web_search]

Found sources:
1. [URL] - [title] - [Official/Community/Tutorial]
2. [URL] - [title] - [Official/Community/Tutorial]

Which should I fetch for detailed context?
Options:
- "Fetch #1" (recommended if official)
- "Fetch #2"
- "Fetch both"
- "Search with different terms"
- "Skip this item"

[User responds]

[If user says fetch]
📥 Fetching: [URL]
[Perform web_fetch]

✓ Retrieved [X]KB of documentation

Key information found:
- [Feature/capability mentioned in planning]: ✓ Confirmed
- [Feature/capability mentioned in planning]: ❌ Not available
- [API method]: Signature: [signature]
- Version support: [version info]

Save this to context/packages/[package-name].md?
- "Yes, save it"
- "No, just use it for this design"
- "Edit before saving"
```

**Repeat for each context item with user approval at each step**

**3.4 Present final context status:**

```
✅ CONTEXT VERIFICATION COMPLETE

====================
CONTEXT STATUS
====================

✓ Verified from existing context:
- [item] → context/[file].md
- [item] → context/[file].md

✓ Verified from web search:
- [item] → [URL] → Saved to context/[file].md
- [item] → [URL] → Saved to context/[file].md

⚠️ Partially verified:
- [item] → [what's verified] → [what's assumed]

❌ Unverified (will be flagged in design):
- [item] → Reason: [couldn't find/user skipped]

====================
DESIGN READINESS
====================

Technical basis for design:
- [X]% of technical claims can be verified
- [Y] items will be marked as assumptions
- [Z] items excluded per user direction

Ready to proceed with design generation?
```

### User Confirmation Required

**Ask user:**
```
Context verification complete. 

1. Is the context sufficient to proceed?
   - Do you need more information on any item?
   - Should I search for anything else?

2. Are you comfortable with unverified items being flagged?
   - Should I try different search strategies?
   - Do you want to provide information?

3. Any last-minute context to add?
   - Documentation to share?
   - Known limitations to include?

Please confirm: "Yes, proceed to Stage 4 - Generate Design"
```

**Iteration:**
- If user wants more context → search additional items → verify → re-present → confirm
- If user provides information → incorporate → update status → re-present → confirm
- Only proceed when user explicitly confirms: **"Yes, proceed to Stage 4"**

---

## Stage 4: Design Document Generation

### Task
Create the design document consolidating planning, verified with context, consistent with existing designs.

### Process

**4.1 Generate design document based on all confirmed decisions**

Create: `design/[CONFIRMED-NAME].md`

```markdown
# [Design Title]

*Generated: [date]*
*Design Status: Draft for Review*

> **Design Scope**: [scope from Stage 2]
> **Consolidates**: [planning materials from Stage 2]
> **Context Verified**: [date of Stage 3]

---

## Overview

### Purpose
[From confirmed Stage 2 scope]

### Background
[Context from planning materials - what problem this solves]

### Scope
**In Scope:**
- [Item from Stage 2 confirmation]
- [Item from Stage 2 confirmation]

**Out of Scope:**
- [Item explicitly excluded]
- [Item deferred]

### Related Designs
[References to existing designs from Stage 2]

---

## [Section 2 - Based on confirmed structure]

[Consolidate planning content as confirmed in Stage 2]

**Technical Approach:**
[Verified against context from Stage 3]

**Key Technologies:**
| Technology | Version | Purpose | Verification |
|------------|---------|---------|--------------|
| [Package]  | [X.X]   | [Use]   | ✓ context/[file].md |
| [Package]  | [X.X]   | [Use]   | ✓ Web: [URL] |
| [Package]  | [X.X]   | [Use]   | ⚠️ Assumed (see notes) |

---

## [Section 3 - Based on confirmed structure]

[Consolidate planning content]

**Implementation Details:**

```[language]
// Verified example from context/[source]
[Code pattern that's been verified]
```

**Alternative Approaches Considered:**
[From planning materials, with evaluation]

---

## [Additional sections per confirmed structure]

---

## Integration Points

### With Existing Systems
[How this integrates with current implementation]

### With Existing Designs
[Consistency with design/[other].md]

---

## Assumptions & Limitations

### Verified Assumptions
✓ [Assumption] - Verified via: [context source]

### Unverified Assumptions
⚠️ [Assumption] - **NEEDS VERIFICATION**: [what to verify]
⚠️ [Assumption] - **NEEDS VERIFICATION**: [what to verify]

### Known Limitations
[From context documentation]

---

## Open Questions

❓ [Question from planning not yet answered]
❓ [Technical decision deferred]
❓ [Area needing prototyping/testing]

---

## Implementation Notes

### Prerequisites
[What needs to exist before implementing this]

### Implementation Order
1. [Step/component]
2. [Step/component]

### Testing Considerations
[How to validate this design]

---

## References

### Planning Sources
- `planning/[file]` - [what was used from this]
- `planning/[file]` - [what was used from this]

### Context Sources
**Existing Context:**
- `context/[file].md` - [what was verified]

**Acquired Context:**
- `context/[file].md` - [new context added]
- Source: [URL]

**Unverified Items:**
- [Item] - No reliable source found
- Recommendation: [how to address]

### Related Designs
- `design/[file].md` - [relationship]

---

## Revision History

| Date | Change | Reason |
|------|--------|--------|
| [date] | Initial design | Consolidated from planning/ |

---

## Next Steps

1. **Review this design**
   - Validate technical approach
   - Verify completeness
   - Check consistency with existing designs

2. **Address open questions**
   - [Specific question] → [how to resolve]
   - [Specific question] → [how to resolve]

3. **Verify unverified assumptions**
   - [Item] → [research/prototype/test]

4. **Generate implementation tasks**
   - Use this design to create SESSION-TASKS.md
   - Break down into implementable units

5. **Update as needed**
   - This is a living document
   - Update based on implementation learnings
```

**4.2 Present design to user:**

```
✅ DESIGN DOCUMENT GENERATED

====================
DESIGN SUMMARY
====================

Document: design/[name].md
Size: [X] lines / [Y] sections
Status: Draft for Review

Consolidates:
- [X] planning documents
- [Y] code snippets/drafts
- [Z] notes and ideas

Verified against:
- [X] existing context files
- [Y] newly acquired context sources

Contains:
- [X] verified technical decisions
- [Y] unverified assumptions (flagged)
- [Z] open questions identified

====================
DESIGN HIGHLIGHTS
====================

Key technical decisions:
1. [Decision] - Verified via [source]
2. [Decision] - Verified via [source]

Open questions remaining:
1. [Question] - Needs [resolution approach]
2. [Question] - Needs [resolution approach]

Unverified assumptions:
1. [Assumption] - Recommend [how to verify]

====================
CONSISTENCY CHECK
====================

✓ Consistent with: design/[existing].md
✓ Uses established patterns from: [project area]
⚠️ Deviates from: [area] - Reason: [justification]

====================
DESIGN COMPLETENESS
====================

Ready for implementation: [%]
- ✓ Core approach defined
- ✓ Technical stack verified
- ⚠️ [X] open questions
- ⚠️ [Y] assumptions to verify

[View full design document]
```

### User Confirmation & Iteration

**Ask user:**
```
Please review the generated design document.

Questions for you:

1. **Content & Structure**
   - Does it capture your intent from planning?
   - Are sections organized logically?
   - Is anything missing or extraneous?

2. **Technical Decisions**
   - Do the verified technical choices make sense?
   - Are there better alternatives?
   - Any concerns about the approach?

3. **Completeness**
   - Is it detailed enough to implement from?
   - Are the open questions the right ones?
   - Should anything be fleshed out more?

4. **Consistency**
   - Does it fit with existing designs?
   - Are patterns consistent with the project?
   - Any conflicts to resolve?

5. **Next Actions**
   - Are you ready to use this for implementation?
   - Should we iterate on any sections?
   - Need to resolve open questions first?

Options:
- "Looks good, this design is ready to work from"
- "Revise [specific section] to [requested change]"
- "Add more detail on [topic]"
- "The approach is wrong, let's rethink [area]"
- "Resolve [open question] before finalizing"
```

**Iteration Loop:**
```
If user requests changes:
  → Make specific revisions
  → Re-present changed sections
  → Ask: "Does this address your feedback?"
  → If yes: "Any other changes?"
  → If no: Iterate again

If user identifies issues:
  → Discuss alternative approaches
  → Potentially return to Stage 2 (scope) or Stage 3 (context)
  → Update design based on new direction
  → Re-present

When user confirms "ready to work from":
  → Proceed to final summary
```

---

## Stage 5: Final Summary & Handoff

### Output

```
🎯 DESIGN PROCESS COMPLETE

====================
FINAL DESIGN DOCUMENT
====================

Location: design/[name].md
Status: Ready for Implementation

====================
PROCESS SUMMARY
====================

**Stage 1 - Discovery:**
- Analyzed [X] planning files
- Reviewed [Y] existing designs
- Scanned project structure

**Stage 2 - Direction:**
- Confirmed scope: [scope]
- Defined structure: [sections]
- [X] iterations to align

**Stage 3 - Context:**
- Verified [X] technical items
- Acquired [Y] new context sources
- Saved [Z] files to context/
- [W] items flagged as unverified

**Stage 4 - Generation:**
- Generated [sections] section design
- [X] iterations to refine
- Final confirmation received

====================
DESIGN CHARACTERISTICS
====================

Verified Content: [%]
- [X] technical decisions verified
- [Y] code patterns confirmed
- [Z] API usages validated

Unverified Content:
- [X] assumptions flagged
- [Y] open questions documented

Consistency:
- ✓ Aligns with design/[existing].md
- ✓ Follows project patterns
- ✓ Integrated with current state

====================
CONTEXT UPDATES
====================

New context files created:
- context/packages/[file].md - [description]
- context/apis/[file].md - [description]

Context available for future designs:
- [Total] packages documented
- [Total] APIs referenced
- [Total] syntax guides

====================
RECOMMENDED NEXT STEPS
====================

1. **Address Open Questions** (if any)
   - [Question] → [recommended approach]
   - [Question] → [recommended approach]

2. **Verify Assumptions** (if any)
   - [Assumption] → [test/research/prototype]
   - [Assumption] → [test/research/prototype]

3. **Generate Implementation Tasks**
   - Use `/tasks-generate` with this design
   - Create SESSION-TASKS.md for systematic implementation

4. **Keep Design Updated**
   - Update as you learn during implementation
   - Document deviations and reasons
   - Refine based on real-world testing

5. **Maintain Context**
   - Add learnings to context/ as you go
   - Update version info when upgrading
   - Document gotchas and workarounds

====================
YOU'RE READY TO BUILD
====================

This design is workable and ready for implementation. It consolidates your planning, is verified against available technical documentation, and is consistent with your project's current state.

Start implementation with confidence, and remember:
- The design will evolve as you build
- Keep it updated with learnings
- It's a living document, not set in stone

Good luck! 🚀
```

---

## Command Principles

### User-in-the-Loop Philosophy

**Every stage requires explicit confirmation:**
- Present findings/proposals clearly
- Ask specific questions
- Wait for user feedback
- Iterate until aligned
- Only proceed with explicit "proceed to next stage" confirmation

**Embrace iteration:**
- Assume first interpretation may be wrong
- Expect multiple rounds of refinement
- User feedback is more valuable than speed
- Getting it right > getting it done fast

### Handling Unstructured Planning

**Expect chaos:**
- No standard structure
- Mixed file types
- Incomplete information
- Conflicting ideas
- Scattered notes

**Be detective, not judge:**
- Find themes in chaos
- Present what's there without criticism
- Identify gaps without blame
- Ask clarifying questions
- Build structure from unstructured

### Context is Key

**Three-tier approach:**
1. Use what exists in context/
2. Acquire what's missing (with permission)
3. Flag what can't be verified

**Always save for reuse:**
- Build up context library
- Future designs benefit
- Reduce repeated web searches

### Design Quality

**Workable > Perfect:**
- Design should be implementable
- Some unknowns are okay
- Flag assumptions clearly
- Document open questions
- Plan for iteration

**Consistency matters:**
- Check existing designs
- Maintain patterns
- Integrate with current state
- Explain deviations

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

Never assume. Always ask. Always confirm.
