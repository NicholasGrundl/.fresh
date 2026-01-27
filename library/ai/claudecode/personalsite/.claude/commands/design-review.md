---
description: Generates external review micro-prompts for design validation by multiple LLMs
allowed-tools: [
  "Bash(find:*)",
  "Bash(ls:*)",
  "Read",
  "Write"
]
argument-hint: "[optional: design-file-name to review specific design]"
---

## Context

This command prepares design documents for external peer review by other LLMs (Claude, Codex, Gemini, Ollama). It generates three specialized micro-prompts that can be copy-pasted into fresh LLM sessions to get unbiased external review of:
1. Design completeness and consistency
2. Technical accuracy and feasibility
3. Scope appropriateness and MVP potential

**Goal:** Get fresh eyes on the design to catch issues, gaps, and opportunities before implementation.

---

## Process

### Step 1: Collect Files for Review

Scan and identify files that reviewers should examine:

```bash
# Find design documents
echo "=== DESIGN DOCUMENTS ==="
find design/ -name "*.md" -type f

# Find critical source files (if they exist)
echo "=== CRITICAL SOURCE FILES ==="
find src/ -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null | head -20
find lib/ -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null | head -20

# Find project documentation
echo "=== PROJECT CONTEXT ==="
ls -la README.md ARCHITECTURE.md 2>/dev/null

# Find relevant context files
echo "=== TECHNICAL CONTEXT ==="
find context/ -name "*.md" -type f 2>/dev/null | head -10
```

### Step 2: Present File List to User

```
📋 FILES IDENTIFIED FOR REVIEW

====================
PRIMARY DESIGN DOCUMENT(S)
====================
[If user specified a design:]
- design/[specified-design].md (PRIMARY FOCUS)

[All designs found:]
- design/[design1].md
- design/[design2].md
- design/[design3].md

====================
SUPPORTING FILES
====================

Related Source Code:
- src/[file].py
- src/[file].js
- [or: "No source files found - new project"]

Project Documentation:
- README.md
- ARCHITECTURE.md
- [or: "No project docs found"]

Technical Context:
- context/packages/[key-package].md
- context/apis/[key-api].md
- [or: "No context files found"]

====================

Which files should the external reviewers examine?

Options:
1. "Primary design only" - Focus on [design-name].md
2. "All designs" - Review all design/*.md files
3. "Design + source" - Include relevant src/ files
4. "Design + context" - Include context/ references
5. "Everything" - Full review of design, source, and context
6. "Custom" - Let me specify exactly which files

[User selects option]
```

**After user confirms file selection, create the file list:**

```
✅ FILES SELECTED FOR REVIEW

The following files will be included in review prompts:

PRIMARY REVIEW FILES:
- design/[file].md
- design/[file].md

SUPPORTING FILES:
- src/[file].py
- context/packages/[package].md
- README.md

Total files: [X]

Generating review micro-prompts...
```

---

### Step 3: Generate Three Micro-Prompts

Create three specialized micro-prompts for comprehensive review:

---

## MICRO-PROMPT 1: Design Completeness & Consistency Review

```markdown
# Design Review: Completeness & Consistency

## Your Task
You are conducting an external peer review of a software design document. Provide objective feedback on completeness, consistency, and logical soundness.

## Files to Review
Please read the following files carefully:

**Primary Design Document(s):**
- `design/[filename].md`
- `design/[filename].md`

**Supporting Context:**
- `src/[filename].ext` (if applicable)
- `context/[filename].md` (if applicable)
- `README.md` (if applicable)

## Review Focus

### 1. Design Completeness
Evaluate if the design provides sufficient information for implementation:
- Are all major components/modules clearly defined?
- Are interfaces and contracts specified?
- Are data models and structures documented?
- Are error handling approaches described?
- Are integration points identified?
- Is configuration/deployment considered?

**For each gap found, identify:**
- What's missing
- Why it's needed
- Where it should be documented

### 2. Internal Consistency
Check for contradictions and inconsistencies:
- Do different sections contradict each other?
- Are naming conventions consistent?
- Are architectural patterns used consistently?
- Do examples match specifications?
- Are assumptions consistent throughout?

**For each inconsistency, identify:**
- Where the contradiction occurs
- What the conflict is
- How to resolve it

### 3. Logical Soundness
Evaluate the design logic:
- Do the proposed solutions actually solve stated problems?
- Are dependencies properly ordered?
- Are there circular dependencies or logic loops?
- Do the architectural choices make sense together?
- Are there missing steps in workflows/processes?

**For each logical issue, identify:**
- What doesn't make sense
- Why it's problematic
- Potential solutions

### 4. Strengths
Identify what the design does well:
- Clear, well-structured sections
- Thorough documentation
- Good use of examples
- Smart architectural decisions
- Proper consideration of edge cases

## Review Output Format

Structure your review as follows:

```markdown
# Design Completeness & Consistency Review

## Executive Summary
[2-3 sentences on overall design quality]

## Strengths
1. [Strength] - [Why this is good]
2. [Strength] - [Why this is good]

## Completeness Issues

### Critical Gaps (blocks implementation)
- **[Component/Section]**: [What's missing] - [Impact]

### Important Gaps (should be added)
- **[Component/Section]**: [What's missing] - [Impact]

### Nice-to-Have Gaps (can defer)
- **[Component/Section]**: [What's missing] - [Impact]

## Consistency Issues
- **[Section A] vs [Section B]**: [Contradiction] - [Recommended resolution]

## Logical Issues
- **[Area]**: [Logic problem] - [Why problematic] - [Suggested fix]

## Recommendations
1. [High priority action]
2. [Medium priority action]
3. [Low priority action]

## Overall Assessment
- Ready for implementation: [Yes/No/With modifications]
- Confidence level: [High/Medium/Low]
- Estimated effort to address issues: [Low/Medium/High]
```

## Important Guidelines
- Be objective and constructive
- Focus on substantive issues, not style preferences
- If something is unclear, say "unclear" rather than assuming
- Distinguish between critical issues and nice-to-haves
- Provide specific examples when identifying problems

---

**After completing your review, save it as:**
`design/review-design-[claude|codex|gemini|ollama].md`

Replace the bracketed name with the LLM you are using.
```

---

## MICRO-PROMPT 2: Technical Accuracy & Feasibility Review

```markdown
# Design Review: Technical Accuracy & Feasibility

## Your Task
You are conducting an external technical review of a software design. Focus on technical correctness, API usage, and implementation feasibility.

## Files to Review
Please read the following files carefully:

**Primary Design Document(s):**
- `design/[filename].md`
- `design/[filename].md`

**Supporting Context:**
- `src/[filename].ext` (if applicable)
- `context/[filename].md` (if applicable)
- `README.md` (if applicable)

## Review Focus

### 1. Technical Accuracy
Verify technical claims and specifications:
- Are package/library names correct?
- Are version requirements realistic?
- Are API methods and signatures accurate?
- Is syntax shown in examples valid?
- Are technical capabilities correctly described?
- Are performance claims reasonable?

**CRITICAL: Only flag as incorrect if you are CERTAIN it's wrong**
- If you're unsure, mark as "Needs verification" not "Incorrect"
- Provide source/reasoning for any correction
- Don't assume newer/older API versions

### 2. API & Framework Usage
Review how external dependencies are used:
- Are APIs used correctly according to their docs?
- Are framework patterns followed properly?
- Are deprecated features being used?
- Are there better APIs/methods for the use case?
- Are authentication/authorization properly handled?
- Are rate limits/quotas considered?

### 3. Implementation Feasibility
Assess if the design can actually be built:
- Are technical dependencies available and compatible?
- Are integrations realistic (not overly complex)?
- Are performance expectations achievable?
- Are security considerations adequate?
- Are scalability concerns addressed?
- Are there technical blockers not mentioned?

### 4. Potential Hallucinations
**Only flag if you are CERTAIN:**
- Non-existent APIs or methods
- Impossible feature combinations
- Made-up package names
- Incorrect signatures you can verify

**If uncertain, flag as "Verify this claim"**

### 5. Technical Risks
Identify potential technical problems:
- Untested technology combinations
- Known compatibility issues
- Performance bottlenecks
- Security vulnerabilities
- Maintenance challenges

## Review Output Format

Structure your review as follows:

```markdown
# Technical Accuracy & Feasibility Review

## Executive Summary
[2-3 sentences on technical soundness]

## Technical Strengths
1. [Good technical decision] - [Why it's good]
2. [Appropriate tool choice] - [Why it fits]

## Accuracy Issues

### Confirmed Errors (certain these are wrong)
- **[API/Package/Claim]**: [What's wrong] - [Correct information] - [Source]

### Needs Verification (uncertain, should check)
- **[API/Package/Claim]**: [Why uncertain] - [How to verify]

### Suspicious Claims (seem unlikely but not certain)
- **[Claim]**: [Why suspicious] - [Recommendation]

## API & Framework Usage

### Incorrect Usage
- **[API/Framework]**: [How it's used incorrectly] - [Correct usage]

### Suboptimal Usage
- **[API/Framework]**: [Current approach] - [Better alternative] - [Why better]

### Missing Considerations
- **[API/Framework]**: [What's not addressed] - [Why it matters]

## Feasibility Concerns

### Technical Blockers (likely can't be done as designed)
- **[Component/Feature]**: [Why it's blocked] - [What needs to change]

### Risky Approaches (possible but problematic)
- **[Component/Feature]**: [Risk] - [Mitigation or alternative]

### Performance Concerns
- **[Component/Feature]**: [Concern] - [Impact] - [Recommendation]

### Security Concerns
- **[Component/Feature]**: [Vulnerability] - [Severity] - [How to address]

## Technical Recommendations
1. [Critical fix needed]
2. [Important improvement]
3. [Optimization opportunity]

## Implementation Confidence
- Can be built as designed: [Yes/No/With modifications]
- Technical risk level: [Low/Medium/High]
- Suggested prototyping areas: [list]

## Red Flags
[Any dealbreaker technical issues that must be resolved]
```

## Important Guidelines
- **ONLY flag errors you're CERTAIN about** - provide sources
- Distinguish between wrong, suboptimal, and risky approaches
- Consider real-world implementation challenges
- Focus on technical substance, not code style
- Be specific about what needs verification
- Acknowledge when you're unsure

---

**After completing your review, save it as:**
`design/review-design-[claude|codex|gemini|ollama].md`

Replace the bracketed name with the LLM you are using.
```

---

## MICRO-PROMPT 3: Scope & MVP Appropriateness Review

```markdown
# Design Review: Scope & MVP Analysis

## Your Task
You are conducting an external review focused on project scope, MVP viability, and priorities. Help identify what's essential vs. what can be deferred.

## Files to Review
Please read the following files carefully:

**Primary Design Document(s):**
- `design/[filename].md`
- `design/[filename].md`

**Supporting Context:**
- `src/[filename].ext` (if applicable)
- `context/[filename].md` (if applicable)
- `README.md` (if applicable)

## Review Focus

### 1. Scope Assessment
Evaluate if the design scope is appropriate:
- Is the scope clearly defined?
- Is it trying to do too much at once?
- Is it too narrow and missing essentials?
- Are there unnecessary features/components?
- Are there scope creep indicators?
- Does complexity match stated goals?

### 2. MVP Identification
Determine what's truly minimum viable:
- What's the core value proposition?
- What's the smallest implementable subset that delivers value?
- Which components are actually needed for MVP?
- Which features can be deferred post-MVP?
- Are there "nice-to-haves" disguised as requirements?

### 3. Prioritization Analysis
Evaluate if priorities are sensible:
- Are dependencies properly sequenced?
- Are high-value items identified?
- Are quick wins vs. long-term investments balanced?
- Is there a logical implementation order?
- Are risks addressed appropriately?

### 4. Scope Reduction Opportunities
Identify specific ways to reduce scope WITHOUT losing core value:
- Features that can be simplified
- Components that can be deferred
- Integrations that can wait
- Polish/optimization that's premature
- Alternative approaches that are simpler

### 5. Critical Missing Scope
Identify if anything MUST be added:
- Essential components not included
- Critical integrations missing
- Necessary infrastructure overlooked
- Required error handling absent
- Important security/compliance gaps

## Review Output Format

Structure your review as follows:

```markdown
# Scope & MVP Appropriateness Review

## Executive Summary
[2-3 sentences on scope appropriateness]

## Current Scope Assessment
- **Overall Scope**: [Too Large / Appropriate / Too Small]
- **Complexity Level**: [Low / Medium / High]
- **Implementation Estimate**: [Small / Medium / Large project]

## Core Value Proposition
[What problem does this solve? What's the essential value?]

## MVP Analysis

### Essential for MVP (can't ship without)
1. **[Component/Feature]** - [Why essential]
2. **[Component/Feature]** - [Why essential]

### Important but Deferrable (ship without, add soon)
1. **[Component/Feature]** - [Why can wait] - [When to add]
2. **[Component/Feature]** - [Why can wait] - [When to add]

### Nice-to-Have (defer indefinitely)
1. **[Component/Feature]** - [Why not critical]
2. **[Component/Feature]** - [Why not critical]

### Over-Engineered Areas
- **[Component/Feature]**: [Why it's over-engineered] - [Simpler alternative]

## Scope Reduction Recommendations

### High Impact Reductions (remove these, keep value)
1. **Remove: [Component/Feature]**
   - Current approach: [description]
   - Simpler alternative: [description]
   - Time saved: [estimate]
   - Value lost: [minimal/none]

2. **Simplify: [Component/Feature]**
   - Current complexity: [description]
   - Simplified approach: [description]
   - Trade-offs: [what you lose]

### Medium Impact Reductions (defer these)
1. **Defer: [Component/Feature]**
   - Why defer: [reasoning]
   - When to add: [post-MVP milestone]

## Critical Missing Scope

### Must Add
1. **[Missing Component]** - [Why critical] - [Impact of absence]

### Should Add
1. **[Missing Component]** - [Why important] - [Risk of absence]

## Recommended Implementation Phases

### Phase 1: MVP (minimum viable)
- [Component/Feature]
- [Component/Feature]
- **Goal**: [What this enables]
- **Effort**: [estimate]

### Phase 2: Post-MVP (add value)
- [Component/Feature]
- [Component/Feature]
- **Goal**: [What this enables]
- **Effort**: [estimate]

### Phase 3: Enhancement (nice-to-have)
- [Component/Feature]
- [Component/Feature]
- **Goal**: [What this enables]
- **Effort**: [estimate]

## Scope Risks
- **Over-scoping**: [Specific risks of trying to do too much]
- **Under-scoping**: [Specific risks of missing essentials]

## Final Recommendations

### If Scope is Too Large
1. [Specific reduction]
2. [Specific simplification]
3. [Specific deferral]
- **New estimated effort**: [reduced estimate]

### If Scope is Appropriate
- [Confirmation of good scope decisions]
- [Minor tweaks if any]

### If Scope is Too Small
1. [What to add]
2. [Why it's needed]
3. [When to add it]

## Confidence Assessment
- Scope appropriate for goals: [Yes/No/Needs adjustment]
- MVP clearly defined: [Yes/No/Needs clarity]
- Priorities sensible: [Yes/No/Needs reordering]
```

## Important Guidelines
- Focus on VALUE delivered, not features built
- Be realistic about implementation time/effort
- Distinguish between essential and nice-to-have
- Consider user/business perspective, not just technical
- Suggest concrete simplifications, not just "reduce scope"
- Acknowledge when scope is actually appropriate

---

**After completing your review, save it as:**
`design/review-design-[claude|codex|gemini|ollama].md`

Replace the bracketed name with the LLM you are using.
```

---

### Step 4: Provide Execution Guidance

Present the complete guide to the user:

```
✅ REVIEW MICRO-PROMPTS GENERATED

====================
HOW TO EXECUTE THE REVIEW
====================

You now have three specialized micro-prompts for external design review.

### Step-by-Step Process:

**1. Copy Micro-Prompt 1: Design Completeness**
   - Open a NEW session with Claude, Codex, Gemini, or Ollama
   - Copy the entire "MICRO-PROMPT 1" content above
   - Paste into the new session
   - Upload/provide the listed files
   - Wait for the review

**2. Copy Micro-Prompt 2: Technical Accuracy**
   - Open ANOTHER NEW session (same or different LLM)
   - Copy the entire "MICRO-PROMPT 2" content above
   - Paste into the new session
   - Upload/provide the listed files
   - Wait for the review

**3. Copy Micro-Prompt 3: Scope & MVP**
   - Open ANOTHER NEW session (same or different LLM)
   - Copy the entire "MICRO-PROMPT 3" content above
   - Paste into the new session
   - Upload/provide the listed files
   - Wait for the review

**4. Collect Reviews**
   Each LLM will provide a markdown-formatted review.
   Save each review to the design folder with the naming convention:
   
   - `design/review-design-claude.md` (if using Claude)
   - `design/review-design-codex.md` (if using Codex/GPT)
   - `design/review-design-gemini.md` (if using Gemini)
   - `design/review-design-ollama.md` (if using Ollama)

### Recommended Review Strategy:

**Option A: Diverse Perspectives (Best)**
- Prompt 1 → Claude
- Prompt 2 → Gemini
- Prompt 3 → Codex
- Get different "personalities" reviewing different aspects

**Option B: Consensus Building**
- All 3 prompts → Same LLM (e.g., all Claude)
- Get consistent perspective across all review types
- Good for establishing baseline

**Option C: Comprehensive (Most thorough)**
- Each prompt → All 4 LLMs
- 12 total reviews
- Time-consuming but extremely thorough
- Great for critical designs

**Option D: Quick Validation**
- Prompt 1 + Prompt 3 → One LLM
- Focus on completeness and scope
- Skip technical accuracy if confident
- Fastest approach

### Why Use Fresh LLM Sessions?

- **Unbiased review**: Fresh session has no context, acts as true external reviewer
- **No contamination**: Previous conversations don't influence judgment
- **Objective perspective**: Reviews the design on its own merits
- **Catches assumptions**: Things clear to you might not be clear to fresh eyes

### Tips for Best Reviews:

1. **Provide ALL listed files** to the reviewing LLM
2. **Use NEW sessions** - don't use this session for review
3. **Don't guide the reviewer** - let them find issues naturally
4. **Review multiple times** if design changes significantly
5. **Compare reviews** from different LLMs to find consensus issues

====================
REVIEW FILES WILL BE SAVED TO
====================

After each external LLM completes their review, save their output as:

- `design/review-design-claude.md`
- `design/review-design-codex.md`
- `design/review-design-gemini.md`
- `design/review-design-ollama.md`

You can have multiple reviews from the same LLM type by adding dates:
- `design/review-design-claude-2025-10-31.md`

====================
FILES TO PROVIDE TO REVIEWERS
====================

When you paste the micro-prompt into a new LLM session, also provide these files:

[List the confirmed files from Step 2]

You can:
- Upload files directly (if the LLM interface supports it)
- Copy-paste file contents into the conversation
- Provide file paths if in a coding environment

====================
AFTER REVIEWS ARE COMPLETE
====================

Once you have collected reviews from external LLMs:

1. Read through all reviews
2. Look for common issues identified by multiple reviewers
3. Prioritize issues:
   - Critical issues (all reviewers agree)
   - Important issues (most reviewers mention)
   - Nice-to-have improvements (one reviewer suggests)

4. Update your design based on feedback
5. Consider running reviews again if major changes made

====================
READY TO START REVIEWS
====================

The three micro-prompts are ready above. Copy them into fresh LLM sessions to begin your external design review process.

Good luck! 🎯
```

---

## Output Files Created

This command does NOT create files directly. Instead, it:

1. **Displays three micro-prompts** that user copies to external LLMs
2. **Provides instructions** on how to execute reviews
3. **Specifies naming convention** for where external LLMs save their reviews:
   - `design/review-design-claude.md`
   - `design/review-design-codex.md`
   - `design/review-design-gemini.md`
   - `design/review-design-ollama.md`

---

## Command Completion

After displaying all three micro-prompts and execution guidance:

```
📋 REVIEW PROCESS SETUP COMPLETE

Three specialized micro-prompts have been generated above:
✓ Micro-Prompt 1: Design Completeness & Consistency Review
✓ Micro-Prompt 2: Technical Accuracy & Feasibility Review
✓ Micro-Prompt 3: Scope & MVP Appropriateness Review

Files identified for review:
[List of files]

Next Steps:
1. Copy each micro-prompt into fresh LLM sessions
2. Provide the listed files to each reviewer
3. Collect the reviews
4. Save reviews to design/ folder with proper naming
5. Analyze feedback and update design

The external review process is in your hands now! 🚀
```