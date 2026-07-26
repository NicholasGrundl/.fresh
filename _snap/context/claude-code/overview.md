# Claude Code CLI Configuration and Hooks

## Overview
Claude Code CLI hooks are user-defined shell commands or scripts that execute automatically at various predetermined points in Claude Code's lifecycle. They provide deterministic control over Claude Code's behavior, ensuring specific actions always occur rather than relying on the Language Model (LLM) to choose to run them.

## Configuration Hierarchy
Hooks can be configured at different levels, with the following precedence:
1.  **Local Project Settings:** `.claude/settings.local.json` (git-ignored, for machine-specific overrides)
2.  **Project Settings:** `.claude/settings.json` (shared with the team)
3.  **User Settings:** `~/.claude/settings.json` (global user preferences)

## Management
- **CLI Command:** Run `/hooks` within Claude Code to open the interactive hooks configuration interface.
- **Matchers:** You can define pattern matchers (e.g., specific tool names) to control when hooks fire.

## Hook Events
Claude Code exposes several lifecycle events where hooks can be attached:

### 1. Tool Execution Hooks
*   **`PreToolUse`**
    *   **Trigger:** Runs before Claude executes any tool.
    *   **Purpose:** Validate inputs, check permissions, or block dangerous operations.
    *   **Behavior:** If the hook exits with **code 2**, it stops Claude from executing the tool and can provide feedback/error messages back to the context.
*   **`PostToolUse`**
    *   **Trigger:** Runs after a tool call completes.
    *   **Purpose:** Formatting (e.g., running `prettier`), logging, or cleanup.
*   **`PermissionRequest`**
    *   **Trigger:** Runs when a permission dialog is about to be shown to the user.
    *   **Purpose:** Automatically allow or deny actions based on logic.

### 2. Session & Agent Lifecycle Hooks
*   **`SessionStart`**: Runs at the beginning of a session.
*   **`SessionEnd`**: Runs at the end of a session.
*   **`UserPromptSubmit`**: Runs immediately when the user submits a prompt, before Claude processes it.
*   **`Stop`**: Runs when Claude Code finishes responding (the turn ends).
*   **`SubagentStop`**: Runs when a subagent task completes.
*   **`PreCompact`**: Runs before Claude Code performs a context compaction operation (to save tokens).

### 3. Notification Hooks
*   **`Notification`**: Runs when Claude Code sends a notification, allowing for custom alerting or integration with other systems.

## Hook Types
*   **Bash Command Hooks:** Execute standard shell commands or scripts.
*   **Prompt-based Hooks:** (Currently for `Stop` and `SubagentStop`) Use an LLM to evaluate whether to allow or block an action based on a prompt.

## Example Use Cases
*   **Automatic Formatting:** Run `prettier` or `gofmt` in a `PostToolUse` hook after any file edit.
*   **Compliance Logging:** Log every executed command in a `PreToolUse` hook.
*   **Linting/Feedback:** Run a linter in a `PostToolUse` hook; if it fails, feed the error back to Claude to fix it immediately.
*   **Safety Rails:** Block modifications to specific sensitive files or directories (like `.env` or production configs) using `PreToolUse`.
*   **Git Workflow:** Create checkpoint commits after file changes or squash commits at the end of a task.

## Security Considerations
Hooks run with the same permissions as the user running Claude Code. Malicious hooks could potentially exfiltrate data or damage the system. Always review hook implementations, especially in shared projects.
