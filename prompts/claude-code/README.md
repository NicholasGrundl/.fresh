# Claude Code Agent Loop — Anecdote Examples

These documents show exactly what happens behind the scenes when Claude Code
processes your prompts. Each anecdote includes a sequence diagram of the
functions called and what they inject, followed by a full-text rendition of
the conversation including all invisible prompt additions.

## Documents

| # | Anecdote | Key Concept |
|---|----------|-------------|
| [00](00-architecture-overview.md) | Architecture Overview | Map of every injection point and function |
| [01](01-simple-question.md) | Simple Question (no tools) | System prompt + userContext + one API call |
| [02](02-read-file-tool-call.md) | Single Tool Call (Read) | Tool execution → tool_result → attachments → follow-up API call |
| [03](03-multi-tool-edit-flow.md) | Multi-Tool Edit (Read → Edit → Bash) | Multiple loop iterations, permission prompts, file change notifications |
| [04](04-context-compaction.md) | Auto-Compaction | What happens when context exceeds threshold — summary + re-injection |
| [05](05-hooks-and-permissions.md) | Hooks and Permissions | Pre/post tool hooks, permission decision flow, hook blocking |
| [06](06-subagent-spawn.md) | Subagent Spawn (Agent Tool) | Separate system prompt, restricted tools, context isolation |
| [07](07-memory-and-claude-md.md) | Memory and CLAUDE.md | Three layers: system prompt instructions, CLAUDE.md context, memory prefetch |

## How to Read These

Each anecdote has two sections:

1. **Sequence Diagram** — shows the exact functions called and what they add
   to the context at each step. Read top-to-bottom to follow the flow.

2. **Full Conversation Text** — shows the actual messages sent to the API,
   including all `<system-reminder>` injections, meta context messages, and
   attachment messages that the user never sees.

## Source Code Entry Points

- Agent loop: `src/query.ts` — `query()` / `queryLoop()`
- System prompt: `src/constants/prompts.ts` — `getSystemPrompt()`
- Context injection: `src/utils/api.ts` — `prependUserContext()` / `appendSystemContext()`
- Message normalization: `src/utils/messages.ts` — `normalizeMessagesForAPI()`
- Attachments: `src/utils/attachments.ts` — `getAttachmentMessages()`
- Tool execution: `src/services/tools/toolExecution.ts` — `runToolUse()`
- Tool hooks: `src/services/tools/toolHooks.ts` — `runPreToolUseHooks()` / `runPostToolUseHooks()`
- Compaction: `src/services/compact/compact.ts` — `buildPostCompactMessages()`
- Memory: `src/memdir/memdir.ts` — `loadMemoryPrompt()`
