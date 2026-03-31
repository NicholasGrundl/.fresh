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
User        queryLoop()       API        Hooks                   ╎ Notes
 │              │               │          │                      ╎
 │ "fix the bug │               │          │                      ╎
 │  and run     │               │          │                      ╎
 │  tests"      │               │          │                      ╎
 │─────────────>│               │          │                      ╎
 │              │               │          │                      ╎
 │              │ ── API #1 ──>│          │                      ╎
 │              │ <── response ─│          │                      ╎ text + tool_use: Edit
 │              │               │          │                      ╎
 │          ─── TOOL: Edit ─────          │                      ╎
 │              │               │          │                      ╎
 │              │ zodValidate() │          │                      ╎ Schema + input validation
 │              │ validateInput()          │                      ╎
 │              │               │          │                      ╎
 │              │ preToolHooks("Edit") ──>│                      ╎ Matches "Edit" in settings.json
 │              │               │          │                      ╎ Spawns: node lint-check.js
 │              │               │          │                      ╎ Env: TOOL_NAME, TOOL_INPUT, TOOL_USE_ID
 │              │ <── { "decision": "allow" }                    ╎ Hook stdout JSON
 │              │               │          │                      ╎
 │              │ resolvePermission()      │                      ╎ Hook allows → check rule-based perms
 │              │               │          │                      ╎   → no deny rules → ALLOWED
 │              │               │          │                      ╎
 │              │ Edit.call() ──┐          │                      ╎ Execute the edit
 │              │ <── success ──┘          │                      ╎
 │              │               │          │                      ╎
 │              │ postToolHooks("Edit")   │                      ╎ No PostToolUse matcher → skipped
 │              │               │          │                      ╎
 │              │ ── API #2 ──>│          │                      ╎ Accumulated msgs + tool_result
 │              │ <── response ─│          │                      ╎ text + tool_use: Bash("npm test")
 │              │               │          │                      ╎
 │          ─── TOOL: Bash ─────          │                      ╎
 │              │               │          │                      ╎
 │              │ zodValidate() │          │                      ╎
 │              │ preToolHooks("Bash")    │                      ╎ No PreToolUse matcher → skipped
 │              │               │          │                      ╎
 │ <── "Allow npm test?" ──────│          │                      ╎ Bash not auto-allowed → prompt user
 │ ── "y" ─────>│               │          │                      ╎
 │              │               │          │                      ╎
 │              │ Bash.call() ──┐          │                      ╎ Run npm test
 │              │ <── output ───┘          │                      ╎
 │              │               │          │                      ╎
 │              │ postToolHooks("Bash") ─>│                      ╎ Matches "Bash" in settings.json
 │              │               │          │                      ╎ Spawns: echo "[LOG]..." >> audit.log
 │              │ <─────────────────────<─│                      ╎ No JSON output → no effect
 │              │               │          │                      ╎ (if returned additional_context →
 │              │               │          │                      ╎  becomes attachment in next call)
 │              │               │          │                      ╎
 │              │ ── API #3 ──>│          │                      ╎
 │              │ <── response ─│          │                      ╎ Text only, no tool_use
 │              │               │          │                      ╎
 │ "Fixed.      │               │          │                      ╎
 │  Tests pass."│               │          │                      ╎
 │<─────────────│               │          │                      ╎
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
