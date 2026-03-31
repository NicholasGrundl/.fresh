# Anecdote 3: Multi-Tool Edit Flow (Read → Edit → Bash)

**Scenario:** User asks "fix the typo in src/utils.ts on line 5" — Claude reads the file, edits it, then runs tests.

## Sequence Diagram

```
User              queryLoop()          API              Tools            Attachments
 │                    │                 │                 │                  │
 │ "fix the typo     │                 │                 │                  │
 │  in src/utils.ts  │                 │                 │                  │
 │  on line 5"       │                 │                 │                  │
 │───────────────────>│                 │                 │                  │
 │                    │                 │                 │                  │
 │      ════════ ITERATION 1 ════════  │                 │                  │
 │                    │                 │                 │                  │
 │      getSystemPrompt() → [...]      │                 │                  │
 │      appendSystemContext()           │                 │                  │
 │      prependUserContext()            │                 │                  │
 │      normalizeMessagesForAPI()       │                 │                  │
 │                    │                 │                 │                  │
 │                    │ ──── API #1 ──>│                 │                  │
 │                    │  msgs: [ctx, user_msg]           │                  │
 │                    │                 │                 │                  │
 │                    │ <── Response ──│                 │                  │
 │                    │  [text + Read tool_use]          │                  │
 │                    │                 │                 │                  │
 │      runPreToolUseHooks("Read")     │                 │                  │
 │      Read.call(src/utils.ts) ───────────────────────>│                  │
 │      ← file contents ──────────────────────────────<─│                  │
 │      runPostToolUseHooks("Read")    │                 │                  │
 │                    │                 │                 │                  │
 │      getAttachmentMessages() ──────────────────────────────────────────>│
 │      ← skill_listing, deferred_tools ─────────────────────────────────<│
 │      memory prefetch (if settled)   │                 │                  │
 │      skill discovery prefetch       │                 │                  │
 │                    │                 │                 │                  │
 │      ════════ ITERATION 2 ════════  │                 │                  │
 │                    │                 │                 │                  │
 │      normalizeMessagesForAPI()       │                 │                  │
 │      → attachments become           │                 │                  │
 │        <system-reminder> msgs       │                 │                  │
 │                    │                 │                 │                  │
 │                    │ ──── API #2 ──>│                 │                  │
 │                    │  msgs: [ctx, user, asst,         │                  │
 │                    │    tool_result, attachments]     │                  │
 │                    │                 │                 │                  │
 │                    │ <── Response ──│                 │                  │
 │                    │  [text + Edit tool_use]          │                  │
 │                    │                 │                 │                  │
 │      runPreToolUseHooks("Edit")     │                 │                  │
 │      Edit.call({file, old, new}) ──────────────────>│                  │
 │      ← success ────────────────────────────────────<│                  │
 │      runPostToolUseHooks("Edit")    │                 │                  │
 │                    │                 │                 │                  │
 │      getAttachmentMessages() ──────────────────────────────────────────>│
 │      ← edited_text_file notification ─────────────────────────────────<│
 │        (file change detected by watcher)              │                  │
 │                    │                 │                 │                  │
 │      ════════ ITERATION 3 ════════  │                 │                  │
 │                    │                 │                 │                  │
 │      normalizeMessagesForAPI()       │                 │                  │
 │      → edited_text_file attachment  │                 │                  │
 │        becomes <system-reminder>    │                 │                  │
 │                    │                 │                 │                  │
 │                    │ ──── API #3 ──>│                 │                  │
 │                    │  msgs: [ctx, user, asst1,        │                  │
 │                    │    tool_result1, attachments1,   │                  │
 │                    │    asst2, tool_result2,          │                  │
 │                    │    attachments2]                 │                  │
 │                    │                 │                 │                  │
 │                    │ <── Response ──│                 │                  │
 │                    │  [text + Bash tool_use:          │                  │
 │                    │   "npm test"]   │                 │                  │
 │                    │                 │                 │                  │
 │      runPreToolUseHooks("Bash")     │                 │                  │
 │      ┌──────────────────────────┐   │                 │                  │
 │      │ Permission check:        │   │                 │                  │
 │      │ Bash requires user OK    │   │                 │                  │
 │      │ (unless auto-approved    │   │                 │                  │
 │      │  in settings/CLAUDE.md)  │   │                 │                  │
 │ ◄────│ "Allow npm test?" ──────>│   │                 │                  │
 │ "y" ─>│                         │   │                 │                  │
 │      └──────────────────────────┘   │                 │                  │
 │      Bash.call("npm test") ────────────────────────>│                  │
 │      ← test output ───────────────────────────────<─│                  │
 │      runPostToolUseHooks("Bash")    │                 │                  │
 │                    │                 │                 │                  │
 │      getAttachmentMessages()        │                 │                  │
 │                    │                 │                 │                  │
 │      ════════ ITERATION 4 ════════  │                 │                  │
 │                    │                 │                 │                  │
 │                    │ ──── API #4 ──>│                 │                  │
 │                    │                 │                 │                  │
 │                    │ <── Response ──│                 │                  │
 │                    │  [text only, no tools]           │                  │
 │                    │                 │                 │                  │
 │      needsFollowUp = false          │                 │                  │
 │      → return { reason: 'completed' }                │                  │
 │                    │                 │                 │                  │
 │ "Fixed the typo   │                 │                 │                  │
 │  and tests pass." │                 │                 │                  │
 │<───────────────────│                 │                 │                  │
```

## Full Conversation Text (What Claude Sees)

### API Call #1 — Initial request

#### System Prompt
*(Full system prompt — see Anecdote 1)*

#### Messages

**[0] Meta context** *(injected by `prependUserContext()`)*
> Role: user

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

**[1] User message**
> Role: user

```
fix the typo in src/utils.ts on line 5
```

**Response:**
> Role: assistant

```json
[
  { "type": "text", "text": "Let me read the file first." },
  {
    "type": "tool_use",
    "id": "toolu_01read",
    "name": "Read",
    "input": { "file_path": "/Users/alice/projects/my-app/src/utils.ts" }
  }
]
```

---

### API Call #2 — After Read tool

#### Messages

**[0]** Meta context *(same)*

**[1]** User message: `fix the typo in src/utils.ts on line 5`

**[2]** Assistant: `[text: "Let me read the file first.", tool_use: Read]`

**[3]** Tool result:
> Role: user

```json
[{
  "type": "tool_result",
  "tool_use_id": "toolu_01read",
  "content": "  1\texport function calcualteTotal(items: Item[]): number {\n  2\t  let total = 0\n  3\t  for (const item of items) {\n  4\t    total += item.price\n  5\t    total += item.pricee * item.quantity  // typo: pricee\n  6\t  }\n  7\t  return total\n  8\t}\n"
}]
```

**[4]** Skill listing *(injected by `getAttachmentMessages()`, wrapped by `normalizeMessagesForAPI()`)*
> Role: user

```
<system-reminder>
The following skills are available for use with the Skill tool:

- commit: Use this skill to commit changes to git. [...]
- simplify: Review changed code for reuse, quality, and efficiency [...]
</system-reminder>
```

**[5]** Deferred tools *(injected by `getAttachmentMessages()`)*
> Role: user

```
<system-reminder>
The following deferred tools are now available via ToolSearch:
AskUserQuestion
NotebookEdit
TaskCreate
TaskUpdate
WebFetch
WebSearch
</system-reminder>
```

**Response:**
> Role: assistant

```json
[
  { "type": "text", "text": "I see the typo on line 5 — `pricee` should be `price`. Also line 1 has `calcualteTotal` which should be `calculateTotal`. Let me fix both." },
  {
    "type": "tool_use",
    "id": "toolu_01edit",
    "name": "Edit",
    "input": {
      "file_path": "/Users/alice/projects/my-app/src/utils.ts",
      "old_string": "    total += item.pricee * item.quantity  // typo: pricee",
      "new_string": "    total += item.price * item.quantity"
    }
  }
]
```

---

### API Call #3 — After Edit tool

#### Messages (accumulated)

**[0-5]** *(Same as above)*

**[6]** Assistant: `[text + Edit tool_use]`

**[7]** Tool result:
> Role: user

```json
[{
  "type": "tool_result",
  "tool_use_id": "toolu_01edit",
  "content": "Successfully edited file /Users/alice/projects/my-app/src/utils.ts"
}]
```

**[8]** File change notification *(from `getAttachmentMessages()` — the file watcher detected the edit)*
> Role: user

```
<system-reminder>
The file /Users/alice/projects/my-app/src/utils.ts was edited.
(This notification is provided by the system and may not be directly related to the assistant's action.)
</system-reminder>
```

**Response:**
> Role: assistant

```json
[
  { "type": "text", "text": "Fixed. Let me run the tests to verify." },
  {
    "type": "tool_use",
    "id": "toolu_01bash",
    "name": "Bash",
    "input": { "command": "cd /Users/alice/projects/my-app && npm test" }
  }
]
```

*At this point, the user sees a permission prompt: "Allow Bash: npm test?" and approves.*

---

### API Call #4 — After Bash tool

#### Messages (accumulated)

**[0-8]** *(Same as above)*

**[9]** Assistant: `[text: "Fixed. Let me run the tests to verify." + Bash tool_use]`

**[10]** Tool result:
> Role: user

```json
[{
  "type": "tool_result",
  "tool_use_id": "toolu_01bash",
  "content": "> my-app@1.0.0 test\n> jest\n\n PASS  src/__tests__/utils.test.ts\n  calcualteTotal\n    ✓ calculates total correctly (3 ms)\n\nTest Suites: 1 passed, 1 total\nTests:       1 passed, 1 total"
}]
```

**[11]** *(Possible task reminder or skill listing attachment — varies by session state)*

**Response:**
> Role: assistant

```
Fixed `pricee` → `price` on line 5 of `src/utils.ts:5`. Tests pass.

Note: line 1 still has `calcualteTotal` (misspelling of `calculateTotal`) — want me to fix that too?
```

**Loop exits:** no tool_use blocks, returns `{ reason: 'completed' }`.

---

## Key Observations

1. **Each iteration of the while(true) loop = one API call.** The loop continues as long as the response contains `tool_use` blocks.

2. **Attachments are injected AFTER tool results, BEFORE the next API call.** They appear as `<system-reminder>`-wrapped user messages that the user never sees.

3. **The full conversation history grows with each iteration.** API call #4 includes all prior messages — the system prompt is prompt-cached but messages accumulate.

4. **Permission checks happen synchronously during tool execution,** not during API calls. The Bash tool triggers an interactive prompt between API call #3 and #4.

5. **File change notifications (`edited_text_file`)** come from a file watcher, not from the Edit tool itself. They're collected by `getAttachmentMessages()` and injected as attachments.
