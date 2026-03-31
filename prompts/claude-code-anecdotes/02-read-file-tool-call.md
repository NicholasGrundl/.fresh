# Anecdote 2: Single Tool Call (Read a File)

**Scenario:** User asks "show me the main entry point" and Claude calls the Read tool on `src/index.ts`, then responds.

## Sequence Diagram

```
User        queryLoop()       API        Tools     Attach.    ╎ Notes
 │              │               │          │          │        ╎
 │ "show me the │               │          │          │        ╎
 │  main entry  │               │          │          │        ╎
 │  point"      │               │          │          │        ╎
 │─────────────>│               │          │          │        ╎
 │              │               │          │          │        ╎
 │          ════ ITERATION 1 ═══          │          │        ╎
 │              │               │          │          │        ╎
 │              │ getSystemPrompt()        │          │        ╎ Static + dynamic sections, same as 01
 │              │ appendSystemCtx()        │          │        ╎ Append gitStatus
 │              │ prependUserCtx()         │          │        ╎ Insert msg[0]: CLAUDE.md + date
 │              │ normalizeMsgs() │        │          │        ╎ Clean message array for API
 │              │               │          │          │        ╎
 │              │ ── API #1 ──>│          │          │        ╎ msgs: [meta_ctx, user_msg]
 │              │               │          │          │        ╎
 │              │ <── response ─│          │          │        ╎ text + tool_use: Read("src/index.ts")
 │              │               │          │          │        ╎
 │              │ needsFollowUp=T          │          │        ╎ Has tool_use → continue loop
 │              │ postSamplingHooks()      │          │        ╎ Internal hooks, fire-and-forget
 │              │               │          │          │        ╎
 │              │ preToolHooks()│          │          │        ╎ Check settings.json + permissions
 │              │ Read() ──────────────>│          │        ╎ Read src/index.ts
 │              │ <────────────────────<│          │        ╎ Returns file contents
 │              │ postToolHooks()        │          │        ╎ Post-tool hooks from settings.json
 │              │               │          │          │        ╎
 │              │ tool_result → UserMessage│          │        ╎ Wrap result as tool_result message
 │              │               │          │          │        ╎
 │              │ getAttachments() ──────────────>│        ╎ Collect post-tool context:
 │              │ <──────────────────────────────<│        ╎   skill_listing, todo_reminder,
 │              │               │          │          │        ╎   deferred_tools, memory prefetch,
 │              │               │          │          │        ╎   skill discovery prefetch
 │              │               │          │          │        ╎
 │          ════ ITERATION 2 ═══          │          │        ╎
 │              │               │          │          │        ╎
 │              │ normalizeMsgs() │        │          │        ╎ Attachments → <system-reminder> msgs
 │              │               │          │          │        ╎
 │              │ ── API #2 ──>│          │          │        ╎ msgs: [meta_ctx, user, asst,
 │              │               │          │          │        ╎   tool_result, attachments]
 │              │               │          │          │        ╎
 │              │ <── response ─│          │          │        ╎ Text only, no tool_use
 │              │               │          │          │        ╎
 │              │ needsFollowUp=F          │          │        ╎ No tool_use → exit loop
 │              │ return completed          │          │        ╎
 │              │               │          │          │        ╎
 │ "Here's the  │               │          │          │        ╎
 │  entry..."   │               │          │          │        ╎
 │<─────────────│               │          │          │        ╎
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
