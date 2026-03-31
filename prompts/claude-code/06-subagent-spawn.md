# Anecdote 6: Subagent Spawn (Agent Tool)

**Scenario:** User asks "find all TODO comments and list them". Claude spawns an Explore subagent, which runs Grep independently and returns results.

## Sequence Diagram

```
User           queryLoop()         API          Agent Tool       Subagent queryLoop()    Sub-API
 │                 │                │               │                    │                  │
 │ "find all      │                │               │                    │                  │
 │  TODO comments │                │               │                    │                  │
 │  and list them"│                │               │                    │                  │
 │────────────────>│                │               │                    │                  │
 │                 │                │               │                    │                  │
 │                 │ ── API #1 ───>│               │                    │                  │
 │                 │ <── [text +   │               │                    │                  │
 │                 │   Agent tool_use: {            │                    │                  │
 │                 │     subagent_type: "Explore",  │                    │                  │
 │                 │     prompt: "Find all TODO..." │                    │                  │
 │                 │   }]           │               │                    │                  │
 │                 │                │               │                    │                  │
 │      ┌──────────────────────────────────────────┐                    │                  │
 │      │ AGENT TOOL EXECUTION                     │                    │                  │
 │      │                                          │                    │                  │
 │      │ AgentTool.call():                        │                    │                  │
 │      │  1. Resolve agent definition             │                    │                  │
 │      │     (Explore agent has its own           │                    │                  │
 │      │      system prompt + restricted tools)   │                    │                  │
 │      │                                          │                    │                  │
 │      │  2. buildEffectiveSystemPrompt():        │                    │                  │
 │      │     → uses agent's system prompt         │                    │                  │
 │      │     → NOT the main session prompt        │                    │                  │
 │      │     → appends appendSystemPrompt         │                    │                  │
 │      │       if present                         │                    │                  │
 │      │                                          │                    │                  │
 │      │  3. Start subagent query loop ──────────────────────────────>│                  │
 │      │                                          │                    │                  │
 │      │     Subagent sees:                       │                    │                  │
 │      │     - Its own system prompt              │                    │                  │
 │      │       (Explore agent instructions)       │                    │                  │
 │      │     - prependUserContext() with           │                    │                  │
 │      │       CLAUDE.md + date                   │                    │                  │
 │      │     - A single user message:             │                    │                  │
 │      │       "Find all TODO comments..."        │                    │                  │
 │      │     - Restricted tool set:               │                    │                  │
 │      │       [Glob, Grep, Read, Bash]           │                    │                  │
 │      │       (NO Edit, Write, Agent)            │                    │                  │
 │      │                                          │                    │                  │
 │      │     ┌─── Subagent Iteration 1 ───┐       │                    │                  │
 │      │     │                            │       │                    │                  │
 │      │     │ Sub-API call #1 ──────────────────────────────────────>│                  │
 │      │     │ ← [Grep tool_use:         │       │                    │                  │
 │      │     │    pattern "TODO"]         │       │                    │                  │
 │      │     │                            │       │                    │                  │
 │      │     │ Grep.call() → results      │       │                    │                  │
 │      │     │                            │       │                    │                  │
 │      │     └────────────────────────────┘       │                    │                  │
 │      │                                          │                    │                  │
 │      │     ┌─── Subagent Iteration 2 ───┐       │                    │                  │
 │      │     │                            │       │                    │                  │
 │      │     │ Sub-API call #2 ──────────────────────────────────────>│                  │
 │      │     │ ← [text only: summary]     │       │                    │                  │
 │      │     │                            │       │                    │                  │
 │      │     │ needsFollowUp = false      │       │                    │                  │
 │      │     │ → subagent returns result  │       │                    │                  │
 │      │     └────────────────────────────┘       │                    │                  │
 │      │                                          │                    │                  │
 │      │  4. Collect subagent's final text ←─────────────────────────│                  │
 │      │     as the tool result                   │                    │                  │
 │      │                                          │                    │                  │
 │      └──────────────────────────────────────────┘                    │                  │
 │                 │                │               │                    │                  │
 │      Tool result = subagent's final response    │                    │                  │
 │      getAttachmentMessages()    │               │                    │                  │
 │                 │                │               │                    │                  │
 │                 │ ── API #2 ───>│               │                    │                  │
 │                 │ <── text only │               │                    │                  │
 │                 │                │               │                    │                  │
 │ "Found 12 TODOs │                │               │                    │                  │
 │  across 5 files" │                │               │                    │                  │
 │<────────────────│                │               │                    │                  │
```

## What the Subagent Sees (Different from Main Session)

### Subagent System Prompt

The Explore agent has its **own** system prompt, NOT the full main-session prompt:

```
You are a fast exploration agent specialized for searching codebases.
Your job is to find files, search code, and answer questions about the codebase.

You have access to: Glob, Grep, Read, Bash (read-only commands only).
You do NOT have access to: Edit, Write, Agent, ExitPlanMode, NotebookEdit.

Be thorough but efficient. Return your findings as a clear summary.
```

Plus, `buildEffectiveSystemPrompt()` may append the `appendSystemPrompt` from the parent session (containing tool-specific instructions).

### Subagent Message [0] — Meta Context (injected by prependUserContext)

```
<system-reminder>
As you answer the user's questions, you can use the following context:
# claudeMd
# CLAUDE.md
This is a Next.js app with TypeScript. Run `npm test` for tests.
# currentDate
Today's date is 2026-03-31.
      IMPORTANT: [...]
</system-reminder>
```

### Subagent Message [1] — The Task

```
Find all TODO comments and list them
```

*Note: The subagent does NOT see the parent conversation history. It gets a fresh context with only the task prompt.*

### Subagent's Tool Result Becomes Parent's Tool Result

The subagent's final text response (e.g., "Found 12 TODOs across 5 files: ...") is returned as the `tool_result` content for the Agent tool_use block in the parent conversation.

## What the Main Session's API Call #2 Looks Like

```
[0] meta_ctx
[1] user: "find all TODO comments and list them"
[2] assistant: [text + Agent tool_use]
[3] user: [{
       type: "tool_result",
       tool_use_id: "toolu_01agent",
       content: "Found 12 TODO comments across 5 files:\n\n
         src/routes.ts:15 — TODO: add rate limiting\n
         src/routes.ts:42 — TODO: validate input\n
         src/utils.ts:8 — TODO: optimize for large arrays\n
         ..."
     }]
[4] user: <system-reminder>skill listing...</system-reminder>
```

The parent Claude never sees the Grep results directly — only the subagent's summarized output. This is the key benefit: **protecting the main context window from raw search results**.
