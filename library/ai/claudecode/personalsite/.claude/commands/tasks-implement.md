---
description: Selects and implements the next logical task(s) from TASKS-TODO.md
allowed-tools: [
  "Bash(git:*)",
  "Bash(grep:*)",
  "Bash(ls:*)",
  "Read", 
  "Edit", 
  "TodoWrite"
]
argument-hint: "[optional: 'phase-1'|'phase-2'|'phase-3' or specific task focus]"
---

## Context

First, analyze the current project state:
- Check git status: `git status --short`
- Check current tasks: `grep -c "\- \[ \]" TASKS-TODO.md`
- List project structure: `ls -la`

## Your Task

Select and implement the next logical task(s) from TASKS-TODO.md with focused execution.

## Workflow

### 1. Task Analysis
- Read TASKS-TODO.md to identify all pending work
- Select 1-3 related tasks based on:
  - Priority level and dependencies
  - Logical grouping and effort balance
  - Current project phase

### 2. Implementation Planning
- Create focused TodoWrite plan with specific subtasks
- Break down selected tasks into actionable steps
- Set clear priorities (high/medium/low)

### 3. Systematic Execution
- Mark ONE todo as in_progress when starting
- Complete each subtask fully before proceeding
- Mark completed immediately when finished
- Update TodoWrite in real-time

## Working Principles

- **Follow the plan** - Implement tasks as specified in TASKS-TODO.md, don't expand scope
- **Dependencies first** - Complete prerequisite tasks before dependent ones
- **One task focus** - Complete selected tasks fully before moving to others
- **Stay in scope** - Avoid refactoring, improvements, or features not in the task list
- **Manageable chunks** - Select 1-3 related tasks per session

## Examples

### ✅ Good: Well-Scoped Chunk

**Hypothetical TODO items:**
- [ ] Fix unused imports in auth.py
- [ ] Fix unused imports in database.py  
- [ ] Fix unused imports in api.py
- [ ] Run ruff --fix on all modules
- [ ] Set up pytest directory structure
- [ ] Write unit tests for auth functions
- [ ] Add comprehensive README

**Good chunk selection:**
```
Focus: "Import cleanup and linting fixes"
Tasks: 
1. Fix unused imports in auth.py
2. Fix unused imports in database.py
3. Fix unused imports in api.py
4. Run ruff --fix on all modules
```

**Why this is good:**
- Related tasks that can be done together
- Manageable scope (30-60 minutes)
- Clear completion criteria
- Sets up foundation for other work
- No complex dependencies

### ❌ Bad: Chunk Too Large

**Bad chunk selection:**
```
Focus: "Complete all high priority items"
Tasks:
1. Fix all import issues across 12 modules
2. Set up entire testing infrastructure 
3. Write comprehensive test suite
4. Create full API documentation
5. Refactor database layer
6. Add CI/CD pipeline
7. Create Docker containers
```

**Why this is bad:**
- Way too much work for one session (4-8 hours)
- Mixes different types of work (cleanup, testing, docs, infrastructure)
- High chance of getting overwhelmed or distracted
- Hard to track progress meaningfully

### ❌ Bad: Illogical Dependencies

**Hypothetical TODO items:**
- [ ] Fix critical import errors preventing code from running
- [ ] Set up pytest structure
- [ ] Write unit tests for payment processing
- [ ] Add Docker configuration
- [ ] Create performance benchmarks
- [ ] Fix linting issues

**Bad chunk selection:**
```
Focus: "Testing and performance work"
Tasks:
1. Write unit tests for payment processing
2. Create performance benchmarks
3. Set up pytest structure
```

**Why this is bad:**
- Ignores critical blocking issue (import errors)
- Wrong order - pytest structure should come before writing tests
- Can't write reliable tests if code has import errors
- Performance benchmarks are premature when basic functionality is broken