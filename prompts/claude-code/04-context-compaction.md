# Anecdote 4: Auto-Compaction Mid-Conversation

**Scenario:** After many turns of editing files, the context exceeds the compaction threshold. The system auto-compacts before the next API call, summarizing old messages.

## Sequence Diagram

```
User              queryLoop()          API         Compact Service    Attachments
 │                    │                 │               │                │
 │  (turn N, context  │                 │               │                │
 │   is ~180k tokens) │                 │               │                │
 │ "now update the    │                 │               │                │
 │  README"           │                 │               │                │
 │───────────────────>│                 │               │                │
 │                    │                 │               │                │
 │      ════════ ITERATION START ══════                │                │
 │                    │                 │               │                │
 │      getMessagesAfterCompactBoundary()              │                │
 │      → returns all messages since last compact      │                │
 │                    │                 │               │                │
 │      applyToolResultBudget()                        │                │
 │      → trims oversized tool results                 │                │
 │                    │                 │               │                │
 │      appendSystemContext()                           │                │
 │      prependUserContext()                            │                │
 │                    │                 │               │                │
 │      ┌─────────────────────────────────────────┐    │                │
 │      │ AUTO-COMPACT CHECK                      │    │                │
 │      │                                         │    │                │
 │      │ deps.autocompact(messages, ...)         │    │                │
 │      │ → tokenCountWithEstimation() > threshold│    │                │
 │      │ → triggers compaction                   │    │                │
 │      │─────────────────────────────────────────────>│                │
 │      │                                         │    │                │
 │      │ Compact service:                        │    │                │
 │      │  1. Takes all messages                  │    │                │
 │      │  2. Calls Haiku/Sonnet to summarize     │    │                │
 │      │  3. Returns summary + preserved tail    │    │                │
 │      │<─────────────────────────────────────────────│                │
 │      │                                         │    │                │
 │      │ buildPostCompactMessages():             │    │                │
 │      │  → compact_boundary_message             │    │                │
 │      │  → summary attachment (the digest)      │    │                │
 │      │  → re-injected memory instructions      │    │                │
 │      │  → re-injected skill listing            │    │                │
 │      │  → re-injected MCP instructions         │    │                │
 │      │  → preserved recent messages (tail)     │    │                │
 │      │                                         │    │                │
 │      │ messagesForQuery = postCompactMessages  │    │                │
 │      └─────────────────────────────────────────┘    │                │
 │                    │                 │               │                │
 │                    │ ──── API call ─>│               │                │
 │                    │  msgs: [        │               │                │
 │                    │    ctx,         │               │                │
 │                    │    compact_summary,             │                │
 │                    │    memory_reinject,             │                │
 │                    │    skill_reinject,              │                │
 │                    │    ...preserved_tail,           │                │
 │                    │    user_msg     │               │                │
 │                    │  ]              │               │                │
 │                    │                 │               │                │
 │                    │ <── Response ──│               │                │
 │                    │  [text only]   │               │                │
 │                    │                 │               │                │
 │ "Updated README." │                 │               │                │
 │<───────────────────│                 │               │                │
```

## What Changes After Compaction

### Before compaction — API sees ~50 messages:
```
[0]  meta_ctx (CLAUDE.md + date)
[1]  user: "read src/index.ts"
[2]  assistant: [text + Read tool_use]
[3]  user: [tool_result: file contents]
[4]  user: <system-reminder>skill listing</system-reminder>
[5]  user: "now add error handling"
[6]  assistant: [text + Edit tool_use]
[7]  user: [tool_result: edit success]
[8]  user: <system-reminder>edited_text_file notification</system-reminder>
...  (30+ more messages from prior turns)
[48] user: "now update the README"
```

### After compaction — API sees ~8 messages:
```
[0]  meta_ctx (CLAUDE.md + date)  ← re-injected by prependUserContext()
[1]  user: <system-reminder>       ← compact summary
       Here is a summary of the conversation so far:
       The user asked to read src/index.ts, then requested error
       handling be added to the Express routes. Several files were
       edited: src/index.ts (added try-catch), src/routes.ts
       (added error middleware), src/utils.ts (fixed typo).
       Tests were run and passed. The user then asked to update
       the README.
     </system-reminder>
[2]  user: <system-reminder>       ← re-injected memory instructions
       # auto memory
       You have a persistent, file-based memory system at [...]
     </system-reminder>
[3]  user: <system-reminder>       ← re-injected skill listing
       The following skills are available [...]
     </system-reminder>
[4]  assistant: [last assistant msg from preserved tail]
[5]  user: [last tool_result from preserved tail]
[6]  user: "now update the README"  ← preserved (recent enough)
```

### Key points about compaction:

1. **The system prompt itself is NOT compacted** — it stays the same. Only messages are summarized.

2. **Memory instructions, skill listings, and MCP instructions are RE-INJECTED** after compaction via `buildPostCompactMessages()`. Without this, Claude would lose awareness of the memory system and available skills.

3. **A "preserved tail"** of recent messages is kept verbatim — typically the last 1-2 turns. The exact cutoff depends on token budget.

4. **The compact summary itself becomes a `<system-reminder>`-wrapped user message** — Claude sees it as context, not as something a human typed.

5. **`clearSystemPromptSections()`** is called, forcing dynamic system prompt sections to recompute on the next API call (they may have changed during the conversation).
