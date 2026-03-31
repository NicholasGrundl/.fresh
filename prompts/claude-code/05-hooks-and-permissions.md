# Anecdote 5: User Hooks and Permission Flow

**Scenario:** A user has configured a pre-tool hook in settings.json that runs a linter before every Edit, and a post-tool hook that logs Bash commands. Claude tries to edit a file and run a test.

## Hook Configuration (settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "node /scripts/lint-check.js \"$TOOL_INPUT\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[LOG] Bash ran: $TOOL_INPUT\" >> /tmp/claude-audit.log"
          }
        ]
      }
    ]
  }
}
```

## Sequence Diagram

```
User              queryLoop()         API         toolExecution     Hook Process
 │                    │                │               │                │
 │ "fix the bug      │                │               │                │
 │  and run tests"   │                │               │                │
 │───────────────────>│                │               │                │
 │                    │                │               │                │
 │                    │ ── API #1 ───>│               │                │
 │                    │ <── [text +   │               │                │
 │                    │   Edit tool_use] ──           │                │
 │                    │                │               │                │
 │      ┌──────────────────────────────────────────────┐               │
 │      │ TOOL EXECUTION: Edit                         │               │
 │      │                                              │               │
 │      │ 1. Zod schema validation ✓                   │               │
 │      │ 2. tool.validateInput() ✓                    │               │
 │      │                                              │               │
 │      │ 3. runPreToolUseHooks("Edit", input)         │               │
 │      │    → finds matcher "Edit" in settings.json   │               │
 │      │    → spawns: node lint-check.js "$TOOL_INPUT"│               │
 │      │    ──────────────────────────────────────────────────────────>│
 │      │                                              │               │
 │      │    Hook process receives env vars:           │               │
 │      │      TOOL_NAME=Edit                          │               │
 │      │      TOOL_INPUT={"file_path":"...","old_string":"..."}       │
 │      │      TOOL_USE_ID=toolu_01xyz                 │               │
 │      │                                              │               │
 │      │    Hook stdout (JSON):                       │               │
 │      │    { "decision": "allow" }                   │               │
 │      │    ←─────────────────────────────────────────────────────────│
 │      │                                              │               │
 │      │ 4. resolveHookPermissionDecision()           │               │
 │      │    Hook says "allow" → check rule-based      │               │
 │      │    permissions (deny/ask rules still apply)  │               │
 │      │    → no deny rules → allowed                 │               │
 │      │                                              │               │
 │      │ 5. Edit.call({...}) → success               │               │
 │      │                                              │               │
 │      │ 6. runPostToolUseHooks("Edit", result)       │               │
 │      │    → no PostToolUse matcher for "Edit"       │               │
 │      │    → skipped                                 │               │
 │      └──────────────────────────────────────────────┘               │
 │                    │                │               │                │
 │      Tool result message yielded    │               │                │
 │      Attachments collected          │               │                │
 │                    │                │               │                │
 │                    │ ── API #2 ───>│               │                │
 │                    │ <── [text +   │               │                │
 │                    │   Bash tool_use: "npm test"]  │                │
 │                    │                │               │                │
 │      ┌──────────────────────────────────────────────┐               │
 │      │ TOOL EXECUTION: Bash                         │               │
 │      │                                              │               │
 │      │ 1. Zod schema validation ✓                   │               │
 │      │                                              │               │
 │      │ 2. runPreToolUseHooks("Bash", input)         │               │
 │      │    → no PreToolUse matcher for "Bash"        │               │
 │      │    → skipped                                 │               │
 │      │                                              │               │
 │      │ 3. Permission check (canUseTool):            │               │
 │      │    → Bash is NOT auto-allowed                │               │
 │ ◄────│    → prompt user: "Allow Bash: npm test?"    │               │
 │ "y" ─>│                                             │               │
 │      │                                              │               │
 │      │ 4. Bash.call("npm test") → output            │               │
 │      │                                              │               │
 │      │ 5. runPostToolUseHooks("Bash", result)       │               │
 │      │    → finds matcher "Bash" in settings.json   │               │
 │      │    → spawns: echo "[LOG]..." >> audit.log    │               │
 │      │    ──────────────────────────────────────────────────────────>│
 │      │    ←─────────────────────────────────────────────────────────│
 │      │    (no JSON output → no effect on response)  │               │
 │      │                                              │               │
 │      │ If hook returned additional_context:         │               │
 │      │   → would become hook_additional_context     │               │
 │      │     attachment in next API call              │               │
 │      └──────────────────────────────────────────────┘               │
 │                    │                │               │                │
 │                    │ ── API #3 ───>│               │                │
 │                    │ <── text only │               │                │
 │                    │                │               │                │
 │ "Fixed. Tests pass."               │               │                │
 │<───────────────────│                │               │                │
```

## What Claude Sees When a Hook Blocks

If the lint-check hook had returned `{ "decision": "deny", "reason": "Linting errors found" }`:

### The tool result would be:

```json
{
  "type": "tool_result",
  "tool_use_id": "toolu_01xyz",
  "content": "Tool use was blocked by a PreToolUse hook.\nHook command: node /scripts/lint-check.js \"$TOOL_INPUT\"\nReason: Linting errors found",
  "is_error": true
}
```

### And a hook_additional_context attachment:

```
<system-reminder>
The Edit tool was blocked by a pre-tool-use hook.
Hook: node /scripts/lint-check.js "$TOOL_INPUT"
Reason: Linting errors found

The user has configured this hook to enforce code quality. Adjust your edit to fix linting issues before retrying.
</system-reminder>
```

## What Claude Sees When a Hook Adds Context

If a post-tool hook returns `{ "additional_context": "Note: this file is part of the public API" }`:

```
<system-reminder>
Note: this file is part of the public API
</system-reminder>
```

This appears as a user message after the tool result, before the next API call.

## Permission Decision Flow

```
Hook says "allow"?
  ├── Yes → Check rule-based permissions
  │         ├── Rule says "deny" → DENIED (rules override hooks)
  │         ├── Rule says "ask"  → PROMPT USER
  │         └── No rule          → ALLOWED
  │
  ├── No hook / no decision → Normal permission flow
  │         ├── Auto-allowed tool? → ALLOWED
  │         ├── Auto-mode classifier? → depends on classifier
  │         └── Interactive? → PROMPT USER
  │
  └── Hook says "deny" → DENIED (tool blocked, error result)
```
