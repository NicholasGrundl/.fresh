---
description: Aligns TASKS-TODO.md with design documentation through phased implementation
allowed-tools: [
  "Read",
  "Edit", 
  "Glob"
]
argument-hint: "[optional: 'strict'|'flexible' alignment approach]"
---

Read design documentation and align TASKS-TODO.md to implement the design through well-structured phases.

## Process

1. **Find and read design documentation:**
   - Look for`design/design.md`, or any `.md` files `design/` directories
   - **ERROR HANDLING**: If no design documents exist, inform user and suggest they create planning/design.md first
   - If multiple design docs exist, prioritize `design.md` then read others for context
   - Extract key features, architecture decisions, and implementation requirements

2. **Analyze current TASKS-TODO.md:**
   - Categorize existing tasks as: Foundation (keep), Design-aligned (keep), Orphaned (question), Maintenance (evaluate)
   - Identify gaps between current tasks and design requirements

3. **Create implementation phases:**
   - Group design features into logical phases that are:
     - **Isolated**: Minimal dependencies, can be worked on in parallel
     - **Testable**: Clear success criteria, unit/integration testable
     - **Incremental**: Each phase delivers demonstrable value
   - Ensure proper dependency ordering between phases

4. **Present analysis to user:**
   ```
   ## Design Analysis
   
   **Design Readiness Assessment:**
   - 📊 **Detail Level**: [Too high-level / Good detail / Overly detailed]
   - 🎯 **Focus**: [Too broad / Well-scoped / Too narrow]
   - 🔧 **Implementation Ready**: [Missing tech details / Ready / Over-specified]
   - 📋 **Completeness**: [Major gaps / Mostly complete / Comprehensive]
   
   **Key Design Features:**
   - [Feature 1: description]
   - [Feature 2: description]
   
   **Current Tasks Assessment:**
   ✅ Keep (Foundation): [list]
   ✅ Keep (Design-aligned): [list]  
   ⚠️ Need decision: [list with reasons]
   ➕ Missing for design: [list]
   
   **Proposed Phases:**
   Phase 1: [Name - what it delivers]
   - Task: [specific action]
   - Task: [specific action]
   
   Phase 2: [Name - what it delivers]  
   - Task: [specific action]
   - Task: [specific action]
   
   **Questions:**
   1. Keep these orphaned tasks? [specific items]
   2. Phase order make sense?
   3. Missing any design requirements?
   4. Should we proceed with TASKS-TODO.md update despite design readiness concerns?
   ```

5. **Get explicit user confirmation before updating TASKS-TODO.md:**
   - Present the proposed changes clearly
   - Ask user to explicitly confirm: "Yes, update TASKS-TODO.md with these changes"
   - Wait for confirmation before proceeding
   - If user says no, ask what adjustments they'd like

6. **Update TASKS-TODO.md after user confirmation:**
   - Reorganize with phase-based structure
   - Update priorities to reflect design goals  
   - Add missing design tasks
   - Remove/archive irrelevant tasks
   - Inform user when update is complete

Focus on creating actionable, specific tasks that move toward the design goals while maintaining quality and testability.