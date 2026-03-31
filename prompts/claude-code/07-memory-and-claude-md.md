# Anecdote 7: Memory System and CLAUDE.md Injection

**Scenario:** User has a CLAUDE.md in their project and memory files from prior sessions. They ask "refactor the auth module". The system injects both automatically.

## Sequence Diagram

```
User              queryLoop()         getUserContext()     getSystemPrompt()     Memory Prefetch
 │                    │                     │                    │                    │
 │ "refactor the     │                     │                    │                    │
 │  auth module"     │                     │                    │                    │
 │───────────────────>│                     │                    │                    │
 │                    │                     │                    │                    │
 │      ┌─ Session init (first query) ─────────────────────────────────────────────┐
 │      │                                  │                    │                    │
 │      │ getUserContext() ───────────────>│                    │                    │
 │      │   Reads CLAUDE.md files:         │                    │                    │
 │      │   - .claude/CLAUDE.md (project)  │                    │                    │
 │      │   - ~/.claude/CLAUDE.md (user)   │                    │                    │
 │      │   - .claude/settings.json dirs   │                    │                    │
 │      │   Returns: {                     │                    │                    │
 │      │     claudeMd: "# Project\n...",  │                    │                    │
 │      │     currentDate: "Today's..."    │                    │                    │
 │      │   }                              │                    │                    │
 │      │ <────────────────────────────────│                    │                    │
 │      │                                  │                    │                    │
 │      │ getSystemPrompt() ──────────────────────────────────>│                    │
 │      │   Calls loadMemoryPrompt():      │                    │                    │
 │      │   - Reads ~/.claude/projects/    │                    │                    │
 │      │     .../memory/MEMORY.md         │                    │                    │
 │      │   - Returns memory system        │                    │                    │
 │      │     instructions (types,         │                    │                    │
 │      │     when to save, etc.)          │                    │                    │
 │      │   - Truncated at 200 lines       │                    │                    │
 │      │ <────────────────────────────────────────────────────│                    │
 │      │                                  │                    │                    │
 │      │ startRelevantMemoryPrefetch() ──────────────────────────────────────────>│
 │      │   Fires side-query to find       │                    │                    │
 │      │   relevant memories for "refactor│                    │                    │
 │      │   the auth module"               │                    │                    │
 │      │   (runs async, consumed later)   │                    │                    │
 │      └──────────────────────────────────────────────────────────────────────────┘
 │                    │                     │                    │                    │
 │      prependUserContext(messages, {      │                    │                    │
 │        claudeMd, currentDate            │                    │                    │
 │      })                                 │                    │                    │
 │                    │                     │                    │                    │
 │                    │ ──── API #1 ───────>│                    │                    │
 │                    │                     │                    │                    │
 │                    │ <── [text + Read]   │                    │                    │
 │                    │                     │                    │                    │
 │      Read tool executes...              │                    │                    │
 │                    │                     │                    │                    │
 │      ┌─ Post-tool attachment phase ─────────────────────────────────────────────┐
 │      │                                  │                    │                    │
 │      │ getAttachmentMessages() → [...]  │                    │                    │
 │      │                                  │                    │                    │
 │      │ Memory prefetch consume:         │                    │                    │
 │      │ ← prefetch settled? ──────────────────────────────────────────────────>│
 │      │   Yes, returns relevant memories │                    │                    │
 │      │                                  │                    │                    │
 │      │ filterDuplicateMemoryAttachments()                    │                    │
 │      │ → removes memories for files     │                    │                    │
 │      │   already Read/Edited this turn  │                    │                    │
 │      │                                  │                    │                    │
 │      │ Creates attachment messages:     │                    │                    │
 │      │  - memory file content           │                    │                    │
 │      │    (relevant memories only)      │                    │                    │
 │      └──────────────────────────────────────────────────────────────────────────┘
 │                    │                     │                    │                    │
 │                    │ ──── API #2 ───────>│                    │                    │
 │                    │ <── response        │                    │                    │
```

## What Claude Sees — The Three Layers of Context

### Layer 1: System Prompt — Memory Instructions (from `loadMemoryPrompt()`)

This is embedded in the system prompt as a dynamic section:

```
# auto memory

You have a persistent, file-based memory system at `/Users/alice/.claude/projects/-Users-alice-projects-my-app/memory/`. This directory already exists — write to it directly with the Write tool (do not run mkdir or check for its existence).

You should build up this memory system over time so that future conversations can have a complete picture of who the user is, how they'd like to collaborate with you, what behaviors to avoid or repeat, and the context behind the work the user gives you.

[... full memory type definitions, when_to_save rules, examples ...]

## When to access memories
- When memories seem relevant, or the user references prior-conversation work.
- You MUST access memory when the user explicitly asks you to check, recall, or remember.

[... full MEMORY.md index contents, up to 200 lines ...]
```

### Layer 2: User Context Message — CLAUDE.md (from `prependUserContext()`)

This is the first message in the conversation:

```
<system-reminder>
As you answer the user's questions, you can use the following context:
# claudeMd
# Project CLAUDE.md

This is a Next.js 14 app with TypeScript and Prisma ORM.

## Commands
- `npm test` — run Jest tests
- `npm run lint` — ESLint + Prettier
- `npx prisma migrate dev` — run migrations

## Architecture
- src/auth/ — authentication module (JWT + sessions)
- src/api/ — Express route handlers
- src/db/ — Prisma schema and client

## Rules
- Always run tests after editing auth/ files
- Use Prisma transactions for multi-table updates
- Never commit .env files

# User CLAUDE.md (~/.claude/CLAUDE.md)

Preferred style: functional over OOP. Use early returns.

# currentDate
Today's date is 2026-03-31.

      IMPORTANT: this context may or may not be relevant to your tasks. You should not respond to this context unless it is highly relevant to your task.
</system-reminder>
```

### Layer 3: Memory Prefetch Attachments (from `filterDuplicateMemoryAttachments()`)

After the first tool call, relevant memories are injected as attachments:

```
<system-reminder>
The following memory files may be relevant to your current task:

--- memory/feedback_auth_testing.md ---
---
name: Auth module testing preference
description: User wants integration tests for auth, not mocks
type: feedback
---

Integration tests for auth/ must hit a real database, not mocks.
**Why:** Prior incident where mock/prod divergence masked a broken migration.
**How to apply:** When writing or modifying tests in src/auth/__tests__/, always use the test database connection, never jest.mock() the Prisma client.

--- memory/project_auth_rewrite.md ---
---
name: Auth rewrite context
description: Auth middleware rewrite driven by compliance requirements
type: project
---

Auth middleware rewrite is driven by legal/compliance requirements around session token storage, not tech-debt cleanup.
**Why:** Legal flagged the old middleware for storing session tokens in a way that doesn't meet new compliance requirements.
**How to apply:** Scope decisions should favor compliance over ergonomics. Any changes to session handling must use encrypted, httpOnly cookies with SameSite=Strict.
</system-reminder>
```

## The Difference Between CLAUDE.md and Memory

| Aspect | CLAUDE.md | Memory |
|--------|-----------|--------|
| **When injected** | Every API call (message[0]) | After first tool call (if relevant) |
| **Where in prompt** | `prependUserContext()` → user message | Attachment → `<system-reminder>` user message |
| **Who writes it** | User manually edits the file | Claude writes via Write tool |
| **Scope** | Broad project rules, commands, architecture | Specific learnings, preferences, context |
| **Persistence** | Lives in repo (`.claude/CLAUDE.md`) or user home | Lives in `~/.claude/projects/.../memory/` |
| **Token cost** | Always present (cached via prompt caching) | Only injected when relevant (AI-filtered) |

## Memory Prompt in System Prompt vs. Memory Content in Messages

The system prompt contains the **instructions for HOW to use memory** (types, when to save, format). This is always present.

The actual **memory file contents** are injected as attachment messages only when the AI prefetch determines they're relevant to the current task. This keeps token costs down — you don't pay for irrelevant memories every turn.
