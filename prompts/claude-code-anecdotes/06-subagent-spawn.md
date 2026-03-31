# Anecdote 6: Subagent Spawn (Agent Tool)

**Scenario:** User asks "find all TODO comments and list them". Claude spawns an Explore subagent, which runs Grep independently and returns results.

## Sequence Diagram

```
User        queryLoop()       API        AgentTool    sub-queryLoop()  Sub-API   ╎ Notes
 │              │               │            │              │             │       ╎
 │ "find all    │               │            │              │             │       ╎
 │  TODO comments               │            │              │             │       ╎
 │  and list    │               │            │              │             │       ╎
 │  them"       │               │            │              │             │       ╎
 │─────────────>│               │            │              │             │       ╎
 │              │               │            │              │             │       ╎
 │              │ ── API #1 ──>│            │              │             │       ╎
 │              │ <── response ─│            │              │             │       ╎ text + Agent tool_use:
 │              │               │            │              │             │       ╎   type=Explore, prompt="Find..."
 │              │               │            │              │             │       ╎
 │          ─── AGENT TOOL EXECUTION ───    │              │             │       ╎
 │              │               │            │              │             │       ╎
 │              │ AgentTool.call() ────────>│              │             │       ╎
 │              │               │            │              │             │       ╎
 │              │               │            │ resolveAgent()             │       ╎ Get Explore agent definition
 │              │               │            │ buildSystemPrompt()       │       ╎ Agent's OWN prompt, not parent's
 │              │               │            │              │             │       ╎ Restricted tools: Glob,Grep,Read,Bash
 │              │               │            │              │             │       ╎
 │              │               │            │ start loop ─>│             │       ╎ Fresh context: agent prompt +
 │              │               │            │              │             │       ╎   CLAUDE.md + single user msg
 │              │               │            │              │             │       ╎
 │              │               │            │          ═ SUB-ITER 1 ═   │       ╎
 │              │               │            │              │             │       ╎
 │              │               │            │              │ ── call ──>│       ╎ Sub-API call #1
 │              │               │            │              │ <── resp ──│       ╎ tool_use: Grep("TODO")
 │              │               │            │              │             │       ╎
 │              │               │            │              │ Grep() ─────┐      ╎ Execute search
 │              │               │            │              │ <── results ┘      ╎
 │              │               │            │              │             │       ╎
 │              │               │            │          ═ SUB-ITER 2 ═   │       ╎
 │              │               │            │              │             │       ╎
 │              │               │            │              │ ── call ──>│       ╎ Sub-API call #2
 │              │               │            │              │ <── resp ──│       ╎ Text only → summary
 │              │               │            │              │             │       ╎
 │              │               │            │              │ followUp=F  │       ╎ No tool_use → subagent exits
 │              │               │            │              │             │       ╎
 │              │               │            │ <── result ──│             │       ╎ Subagent's final text becomes
 │              │ <── tool_result ──────────│              │             │       ╎   the Agent tool_result
 │              │               │            │              │             │       ╎
 │              │ getAttachments()           │              │             │       ╎
 │              │               │            │              │             │       ╎
 │              │ ── API #2 ──>│            │              │             │       ╎ Parent sees summarized output,
 │              │ <── response ─│            │              │             │       ╎   never raw Grep results
 │              │               │            │              │             │       ╎
 │ "Found 12    │               │            │              │             │       ╎
 │  TODOs across│               │            │              │             │       ╎
 │  5 files"    │               │            │              │             │       ╎
 │<─────────────│               │            │              │             │       ╎
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
