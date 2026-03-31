# Claude Code Agent Loop: Architecture Overview

This document maps the core agent loop and every injection point where
non-visible content is added to the conversation before it hits the API.

## The Core Loop

```
src/query.ts  →  query()  →  queryLoop()
```

`queryLoop()` is an infinite `while(true)` async generator. Each iteration:

1. **Prepare messages** — trim, budget, snip, microcompact, collapse
2. **Build system prompt** — static sections + dynamic sections + system context
3. **Auto-compact** — if context is too large, summarize old messages
4. **Call the API** — `deps.callModel()` streams response tokens
5. **Process tool_use blocks** — dispatch to tool handlers
6. **Collect attachments** — memory, skills, file-change notifications, hooks
7. **Continue or exit** — if tool_use blocks existed, loop; otherwise return

## Injection Point Map

```
┌──────────────────────────────────────────────────────────┐
│                    SYSTEM PROMPT                          │
│  Built by: getSystemPrompt() in constants/prompts.ts     │
│                                                          │
│  ┌─ Static (globally cacheable) ──────────────────────┐  │
│  │  getSimpleIntroSection()     — identity + safety    │  │
│  │  getSimpleSystemSection()    — system rules         │  │
│  │  getSimpleDoingTasksSection()— coding guidelines    │  │
│  │  getActionsSection()         — caution guidance     │  │
│  │  getUsingYourToolsSection()  — tool usage rules     │  │
│  │  getSimpleToneAndStyleSection() — formatting        │  │
│  │  getOutputEfficiencySection()   — conciseness       │  │
│  └────────────────────────────────────────────────────┘  │
│  ═══ SYSTEM_PROMPT_DYNAMIC_BOUNDARY ═══                  │
│  ┌─ Dynamic (session-specific, uncached) ─────────────┐  │
│  │  getSessionSpecificGuidanceSection() — agents etc.  │  │
│  │  loadMemoryPrompt()          — MEMORY.md system     │  │
│  │  computeSimpleEnvInfo()      — CWD, git, model, OS  │  │
│  │  getLanguageSection()        — i18n preference      │  │
│  │  getOutputStyleSection()     — custom output style  │  │
│  │  getMcpInstructionsSection() — MCP server prompts   │  │
│  │  getScratchpadInstructions() — scratchpad dir       │  │
│  │  getFunctionResultClearingSection() — FRC warning   │  │
│  │  SUMMARIZE_TOOL_RESULTS_SECTION                     │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  appendSystemContext():                                   │
│    + gitStatus (branch, status, recent commits)          │
│    + cacheBreaker (ant-only debug injection)             │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│              MESSAGES (before API call)                    │
│                                                          │
│  prependUserContext() inserts a META user message at [0]: │
│  ┌────────────────────────────────────────────────────┐  │
│  │ <system-reminder>                                  │  │
│  │ As you answer the user's questions, you can use    │  │
│  │ the following context:                             │  │
│  │ # claudeMd                                        │  │
│  │ {contents of all CLAUDE.md files}                  │  │
│  │ # currentDate                                     │  │
│  │ Today's date is 2026-03-31.                       │  │
│  │ IMPORTANT: this context may or may not be          │  │
│  │ relevant to your tasks.                            │  │
│  │ </system-reminder>                                 │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  normalizeMessagesForAPI():                               │
│    - Filters virtual/display-only messages                │
│    - Reorders attachments (bubble up past user msgs)      │
│    - Strips unavailable tool references                   │
│    - Merges consecutive same-role messages                 │
│    - Converts AttachmentMessages → UserMessages           │
│      (each wrapped in <system-reminder> tags)             │
│    - Strips orphaned thinking blocks                      │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│           AFTER TOOL CALLS (per iteration)                │
│                                                          │
│  1. Tool results returned as UserMessage (tool_result)    │
│                                                          │
│  2. getAttachmentMessages() yields:                       │
│     - edited_text_file  (file change notifications)      │
│     - plan_mode         (plan mode instructions)         │
│     - skill_listing     (available /commands)            │
│     - skill_discovery   (AI-surfaced relevant skills)    │
│     - todo_reminder     (task list state)                │
│     - task_reminder     (task progress)                  │
│     - queued_commands   (user typed while tools ran)     │
│     - hook_additional_context (from pre/post hooks)      │
│     - critical_system_reminder (tool-specific hints)     │
│                                                          │
│  3. Memory prefetch attachments (relevant memories)       │
│                                                          │
│  4. Skill discovery prefetch (relevant skills for turn)   │
│                                                          │
│  All attachments become <system-reminder>-wrapped         │
│  UserMessages in the next API call.                       │
└──────────────────────────────────────────────────────────┘
```

## Key Functions Reference

| Function | File | Purpose |
|----------|------|---------|
| `query()` | `src/query.ts:219` | Entry point, delegates to queryLoop |
| `queryLoop()` | `src/query.ts:241` | The infinite while(true) agent loop |
| `getSystemPrompt()` | `src/constants/prompts.ts:444` | Builds full system prompt array |
| `buildEffectiveSystemPrompt()` | `src/utils/systemPrompt.ts:41` | Resolves prompt priority (override/agent/custom/default) |
| `appendSystemContext()` | `src/utils/api.ts:437` | Appends git status to system prompt |
| `prependUserContext()` | `src/utils/api.ts:449` | Injects CLAUDE.md + date as message[0] |
| `normalizeMessagesForAPI()` | `src/utils/messages.ts:1989` | Transforms internal messages → API format |
| `wrapInSystemReminder()` | `src/utils/messages.ts:3097` | Wraps text in `<system-reminder>` tags |
| `getAttachmentMessages()` | `src/utils/attachments.ts` | Generates post-tool-call context |
| `runTools()` | `src/services/tools/toolOrchestration.ts:19` | Dispatches tool_use blocks to handlers |
| `runPreToolUseHooks()` | `src/services/tools/toolHooks.ts:435` | User-configured pre-tool hooks |
| `runPostToolUseHooks()` | `src/services/tools/toolHooks.ts:39` | User-configured post-tool hooks |
| `executePostSamplingHooks()` | `src/utils/hooks/postSamplingHooks.ts:45` | Internal post-model hooks |
