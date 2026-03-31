# Anecdote 2: Single Tool Call (Read a File)

**Scenario:** User asks "show me the main entry point" and Claude calls the Read tool on `src/index.ts`, then responds.

## Sequence Diagram

```
User                    queryLoop()              API          Tools          Attachments
 │                          │                     │             │               │
 │ "show me the main       │                     │             │               │
 │  entry point"           │                     │             │               │
 │─────────────────────────>│                     │             │               │
 │                          │                     │             │               │
 │          ┌───────────────────────────────┐     │             │               │
 │          │ TURN 1: Setup                 │     │             │               │
 │          │                               │     │             │               │
 │          │ getSystemPrompt()             │     │             │               │
 │          │ → [intro, system, tasks,      │     │             │               │
 │          │    actions, tools, tone,      │     │             │               │
 │          │    efficiency, ── BOUNDARY ── │     │             │               │
 │          │    session, memory, env,      │     │             │               │
 │          │    FRC, summarize]            │     │             │               │
 │          │                               │     │             │               │
 │          │ appendSystemContext()          │     │             │               │
 │          │ → appends gitStatus           │     │             │               │
 │          │                               │     │             │               │
 │          │ prependUserContext()           │     │             │               │
 │          │ → prepends <system-reminder>  │     │             │               │
 │          │   with CLAUDE.md + date       │     │             │               │
 │          │                               │     │             │               │
 │          │ normalizeMessagesForAPI()      │     │             │               │
 │          │ → clean message array         │     │             │               │
 │          └───────────────────────────────┘     │             │               │
 │                          │                     │             │               │
 │                          │  API call #1        │             │               │
 │                          │  messages: [        │             │               │
 │                          │    meta_ctx_msg,    │             │               │
 │                          │    user_msg         │             │               │
 │                          │  ]                  │             │               │
 │                          │────────────────────>│             │               │
 │                          │                     │             │               │
 │                          │  Response:          │             │               │
 │                          │  [text: "Let me     │             │               │
 │                          │   read the entry",  │             │               │
 │                          │   tool_use: {       │             │               │
 │                          │     name: "Read",   │             │               │
 │                          │     input: {        │             │               │
 │                          │       file_path:    │             │               │
 │                          │       "src/index.ts"│             │               │
 │                          │  }}]                │             │               │
 │                          │<────────────────────│             │               │
 │                          │                     │             │               │
 │          needsFollowUp = true                  │             │               │
 │                          │                     │             │               │
 │          executePostSamplingHooks()            │             │               │
 │          (internal hooks, fire-and-forget)      │             │               │
 │                          │                     │             │               │
 │          ┌───────────────────────────────┐     │             │               │
 │          │ TOOL EXECUTION                │     │             │               │
 │          │                               │     │             │               │
 │          │ runPreToolUseHooks()          │     │             │               │
 │          │ → checks user settings.json  │     │             │               │
 │          │ → checks permissions         │     │             │               │
 │          │                               │     │             │               │
 │          │ Read.call({ file_path:       │     │             │               │
 │          │   "src/index.ts" })           │     │             │               │
 │          │──────────────────────────────────────────────────>│               │
 │          │                               │     │  returns   │               │
 │          │                               │     │  file text │               │
 │          │<──────────────────────────────────────────────────│               │
 │          │                               │     │             │               │
 │          │ runPostToolUseHooks()         │     │             │               │
 │          │ → post-tool hooks from        │     │             │               │
 │          │   settings.json              │     │             │               │
 │          └───────────────────────────────┘     │             │               │
 │                          │                     │             │               │
 │          Tool result → UserMessage             │             │               │
 │          (type: tool_result)                    │             │               │
 │                          │                     │             │               │
 │          ┌───────────────────────────────┐     │             │               │
 │          │ POST-TOOL ATTACHMENTS         │     │             │               │
 │          │                               │     │             │               │
 │          │ getAttachmentMessages()       │     │             │               │
 │          │──────────────────────────────────────────────────────────────────>│
 │          │                               │     │             │               │
 │          │ Returns:                      │     │             │               │
 │          │  - skill_listing (available   │     │             │               │
 │          │    /commands for this ctx)    │     │             │               │
 │          │  - todo_reminder (if tasks    │     │             │               │
 │          │    exist)                     │     │             │               │
 │          │  - deferred tool schemas      │     │             │               │
 │          │    (lazy-loaded tool list)    │     │             │               │
 │          │<──────────────────────────────────────────────────────────────────│
 │          │                               │     │             │               │
 │          │ Memory prefetch (if settled): │     │             │               │
 │          │  → relevant memory files      │     │             │               │
 │          │                               │     │             │               │
 │          │ Skill discovery prefetch:     │     │             │               │
 │          │  → relevant skills for turn   │     │             │               │
 │          └───────────────────────────────┘     │             │               │
 │                          │                     │             │               │
 │          ┌───────────────────────────────┐     │             │               │
 │          │ TURN 2: Follow-up            │     │             │               │
 │          │                               │     │             │               │
 │          │ Same system prompt (cached)   │     │             │               │
 │          │                               │     │             │               │
 │          │ normalizeMessagesForAPI()      │     │             │               │
 │          │ → converts attachments to     │     │             │               │
 │          │   <system-reminder> wrapped   │     │             │               │
 │          │   user messages               │     │             │               │
 │          └───────────────────────────────┘     │             │               │
 │                          │                     │             │               │
 │                          │  API call #2        │             │               │
 │                          │  messages: [        │             │               │
 │                          │    meta_ctx_msg,    │             │               │
 │                          │    user_msg,        │             │               │
 │                          │    assistant_msg,   │             │               │
 │                          │    tool_result_msg, │             │               │
 │                          │    attachment_msgs  │             │               │
 │                          │  ]                  │             │               │
 │                          │────────────────────>│             │               │
 │                          │                     │             │               │
 │                          │  Response:          │             │               │
 │                          │  [text: "Here's..." │             │               │
 │                          │   (no tool_use)]    │             │               │
 │                          │<────────────────────│             │               │
 │                          │                     │             │               │
 │          needsFollowUp = false                 │             │               │
 │          → return { reason: 'completed' }      │             │               │
 │                          │                     │             │               │
 │  "Here's the entry..."  │                     │             │               │
 │<─────────────────────────│                     │             │               │
```

## Full Conversation Text (What Claude Sees)

### API Call #1

#### System Prompt
*(Same as Anecdote 1 — the full system prompt. Omitted for brevity.)*

#### Message [0] — Meta User Context (injected)

> **Role: user** *(isMeta: true, invisible to end user)*

```
<system-reminder>
As you answer the user's questions, you can use the following context:
# claudeMd
# CLAUDE.md

This is a Next.js app with TypeScript. Run `npm test` for tests.

# currentDate
Today's date is 2026-03-31.

      IMPORTANT: this context may or may not be relevant to your tasks. You should not respond to this context unless it is highly relevant to your task.
</system-reminder>
```

#### Message [1] — User Message

> **Role: user**

```
show me the main entry point
```

#### Response — Assistant Message

> **Role: assistant**

```json
[
  { "type": "text", "text": "Let me read the main entry point." },
  {
    "type": "tool_use",
    "id": "toolu_01abc123",
    "name": "Read",
    "input": { "file_path": "/Users/alice/projects/my-app/src/index.ts" }
  }
]
```

---

### Tool Execution Phase (between API calls)

**Pre-hook check:** `runPreToolUseHooks()` — no user hooks configured, passes.

**Permission check:** Read tool is auto-allowed in default mode.

**Tool runs:** `Read.call()` returns file contents.

**Post-hook check:** `runPostToolUseHooks()` — no user hooks configured, passes.

**Tool result becomes a UserMessage:**

```json
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01abc123",
      "content": "  1\timport express from 'express'\n  2\timport { router } from './routes.js'\n  3\t\n  4\tconst app = express()\n  5\tapp.use('/api', router)\n  6\tapp.listen(3000, () => console.log('Server running on :3000'))\n"
    }
  ]
}
```

**Attachment generation:** `getAttachmentMessages()` produces:

```json
[
  {
    "type": "attachment",
    "attachment": {
      "type": "skill_listing",
      "content": "The following skills are available for use with the Skill tool:\n\n- commit: ...\n- review-pr: ...\n- simplify: ..."
    }
  }
]
```

This attachment becomes (after `normalizeMessagesForAPI()`):

```json
{
  "role": "user",
  "content": "<system-reminder>\nThe following skills are available for use with the Skill tool:\n\n- commit: ...\n- review-pr: ...\n- simplify: ...\n</system-reminder>"
}
```

---

### API Call #2

#### System Prompt
*(Same — prompt-cached from call #1)*

#### Message [0] — Meta User Context
*(Same as call #1 — prompt-cached)*

#### Message [1] — User Message

> **Role: user**

```
show me the main entry point
```

#### Message [2] — Assistant Message (from call #1)

> **Role: assistant**

```json
[
  { "type": "text", "text": "Let me read the main entry point." },
  {
    "type": "tool_use",
    "id": "toolu_01abc123",
    "name": "Read",
    "input": { "file_path": "/Users/alice/projects/my-app/src/index.ts" }
  }
]
```

#### Message [3] — Tool Result

> **Role: user**

```json
[
  {
    "type": "tool_result",
    "tool_use_id": "toolu_01abc123",
    "content": "  1\timport express from 'express'\n  2\timport { router } from './routes.js'\n  3\t\n  4\tconst app = express()\n  5\tapp.use('/api', router)\n  6\tapp.listen(3000, () => console.log('Server running on :3000'))\n"
  }
]
```

#### Message [4] — Skill Listing Attachment (injected)

> **Role: user** *(invisible to end user — from AttachmentMessage)*

```
<system-reminder>
The following skills are available for use with the Skill tool:

- commit: Use this skill to commit changes to git. [...]
- review-pr: Use this skill to review a pull request. [...]
- simplify: Review changed code for reuse, quality, and efficiency [...]
</system-reminder>
```

#### Response — Assistant Message

> **Role: assistant**

```
Here's `src/index.ts` — it's a minimal Express server:

- Creates an Express app
- Mounts the router at `/api`
- Listens on port 3000

The actual route handlers live in `./routes.js`. Want me to look at that file?
```

**Loop exits:** no tool_use blocks, returns `{ reason: 'completed' }`.
