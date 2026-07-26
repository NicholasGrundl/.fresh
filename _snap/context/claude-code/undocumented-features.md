# Claude Code: Undocumented & Source-Derived Configuration

> **Source:** André Figueira, _"I Read the Claude Code Source Code. Here's Everything You
> Can Configure That the Docs Don't Tell You."_ — buildingbetter.tech, Apr 1 2026.
> <https://buildingbetter.tech/p/i-read-the-claude-code-source-code>
>
> **Provenance / caveat:** Findings come from reading the distributed (minified) npm
> package `@anthropic-ai/claude-code@2.1.87`. These are **undocumented** fields; some are
> explicitly flagged **EXPERIMENTAL** in the source and may change or vanish between
> releases. Verify against your installed version with a throwaway config before relying
> on any of it. This file is captured notes for reference, not official documentation.

## Where things live

| Thing | Personal | Project (git-shareable) |
|---|---|---|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` |
| Skills | `~/.claude/skills/<name>/SKILL.md` | `.claude/skills/<name>/SKILL.md` |
| Agents | `~/.claude/agents/<name>.md` | `.claude/agents/<name>.md` |
| Hook scripts | `~/.claude/hooks/` (convention) — remember `chmod +x` | same |

---

## 1. Hooks can return JSON to modify behavior in real time

Docs say hooks receive JSON on stdin and that **exit code 2 blocks** an operation. The
source shows hooks can also **return JSON on stdout** with event-specific fields that
change Claude Code's behavior mid-flight.

**`PreToolUse`** can return:
- `updatedInput` — rewrite the tool's input before it executes (modify commands mid-flight)
- `permissionDecision` — force `"allow"` or `"deny"` without prompting
- `permissionDecisionReason` — explanation shown in UI
- `additionalContext` — inject text into the conversation context

**`SessionStart`** can return:
- `watchPaths` — set up automatic file watching that triggers FileChanged events
- `initialUserMessage` — prepend content to the first user message
- `additionalContext` — inject context that persists for the whole session

**`PostToolUse`** can return:
- `updatedMCPToolOutput` — modify what Claude sees from an MCP tool response
- `additionalContext` — inject context after a tool runs

**`PermissionRequest`** can return:
- `decision` — programmatically allow/deny with `updatedInput` or `updatedPermissions`

### Example: rewrite `git push` → `git push --dry-run`

`settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/dry-run-pushes.sh"
      }]
    }]
  }
}
```

`~/.claude/hooks/dry-run-pushes.sh`:
```bash
#!/bin/bash
INPUT=$(jq -r '.tool_input.command' < /dev/stdin)
if echo "$INPUT" | grep -q 'git push'; then
  jq -n --arg cmd "$INPUT --dry-run" '{"updatedInput": {"command": $cmd}}'
fi
```
Claude thinks it ran `git push origin main`; the hook quietly rewrote it to add `--dry-run`.

### Example: SessionStart file-watch + git context injection

`settings.json`:
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/session-context.sh",
        "statusMessage": "Loading project context..."
      }]
    }]
  }
}
```

`~/.claude/hooks/session-context.sh`:
```bash
#!/bin/bash
BRANCH=$(git branch --show-current 2>/dev/null)
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

jq -n \
  --arg branch "$BRANCH" \
  --arg changes "$CHANGES" \
  '{
    "watchPaths": ["package.json", ".env", "tsconfig.json"],
    "additionalContext": "Current branch: \($branch). Uncommitted changes: \($changes) files."
  }'
```

### Example: auto-approve read-only bash commands

`settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/auto-approve-readonly.sh"
      }]
    }]
  }
}
```

`~/.claude/hooks/auto-approve-readonly.sh`:
```bash
#!/bin/bash
CMD=$(jq -r '.tool_input.command' < /dev/stdin)
if echo "$CMD" | grep -qE '^(ls|cat|echo|pwd|whoami|date|git status|git log|git diff)'; then
  echo '{"permissionDecision": "allow", "permissionDecisionReason": "Safe read-only command"}'
fi
```

---

## 2. Three undocumented hook config fields

Documented fields: `type`, `command`, `matcher`, `timeout`, `if`, `statusMessage`. The
parser also accepts:

### `once: true` — fire exactly once, then auto-remove (first-session setup)
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "[ -f .env ] || cp .env.example .env && echo 'Created .env from template'",
        "once": true,
        "statusMessage": "First-time setup..."
      }]
    }]
  }
}
```

### `async: true` — run in background, never block (fire-and-forget)
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "jq '{timestamp: now, command: .tool_input.command, session: .session_id}' < /dev/stdin >> ~/.claude/audit.jsonl",
        "async": true
      }]
    }]
  }
}
```

### `asyncRewake: true` — non-blocking, but blocks if it exits code 2
Runs in the background like `async`; if it exits 2 it **wakes the model and blocks**.
Non-blocking on the happy path, blocking only on detection (ideal for secret scanning).

`settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/scan-secrets.sh",
        "asyncRewake": true,
        "statusMessage": "Scanning for secrets..."
      }]
    }]
  }
}
```

`~/.claude/hooks/scan-secrets.sh`:
```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // .tool_response.filePath' < /dev/stdin)
if grep -qE '(password|secret|api_key)\s*=' "$FILE" 2>/dev/null; then
  exit 2  # Block: secrets detected
fi
exit 0    # Clean: carry on
```

---

## 3. Undocumented skill frontmatter fields

Documented: `name`, `description`, `allowed-tools`, `argument-hint`, `when_to_use`,
`context`. The parser also accepts six more:

- **`model`** — override the model (`haiku` for cheap/fast, `opus` for complex)
- **`effort`** — `low` | `medium` | `high` | `max` (reasoning depth)
- **`hooks`** — hooks scoped to the skill's lifetime (register on fire, deregister on completion)
- **`agent`** — delegate the skill to a custom agent
- **`disable-model-invocation: true`** — only explicit `/skill-name` works (no auto-fire)
- **`shell: bash`** — which shell to use for execution

### Example: cheap/fast skill on Haiku
```yaml
---
name: quick-lint
description: Fast lint check using the cheapest model
model: haiku
effort: low
allowed-tools: Bash, Read
argument-hint: "[file]"
---
Run the project linter on: $ARGUMENTS
Detect the linter from config (eslint, ruff, clippy) and run it. Report only errors, not warnings.
```

### Example: skill-scoped hooks (type-check + lint on save)
```yaml
---
name: strict-typescript
description: Write TypeScript with type checking on every save
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
hooks:
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "~/.claude/hooks/typecheck-on-save.sh"
          statusMessage: "Type checking..."
        - type: command
          command: "~/.claude/hooks/lint-on-save.sh"
          async: true
---
Write TypeScript with strict enforcement. Every file you touch gets type-checked and linted automatically.
$ARGUMENTS
```

`~/.claude/hooks/typecheck-on-save.sh`:
```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // .tool_response.filePath' < /dev/stdin)
[[ "$FILE" == *.ts ]] && npx tsc --noEmit 2>&1 || true
```

`~/.claude/hooks/lint-on-save.sh`:
```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // .tool_response.filePath' < /dev/stdin)
[[ "$FILE" == *.ts ]] && npx eslint --fix "$FILE" 2>&1 || true
```
When the skill finishes, those hooks disappear — clean scoping.

### Example: delegate a skill to an agent
```yaml
---
name: deep-review
description: Thorough security review delegated to the review agent
agent: security-review
---
Review the following: $ARGUMENTS
```

---

## 4. Undocumented agent frontmatter fields

Custom agents in `.claude/agents/` support:

- **`color`** — `red`, `orange`, `yellow`, `green`, `blue`, `purple`, `pink`, `gray` (UI distinction)
- **`memory`** — persistent memory across invocations:
  - `user` — global, across all projects
  - `project` — per-project
  - `local` — private per-project (gitignored)
- **`omitClaudeMd: true`** — skip the CLAUDE.md hierarchy ("fresh eyes" review)
- **`criticalSystemReminder_EXPERIMENTAL`** — short message re-injected every turn, survives compaction (⚠️ unstable name)
- **`requiredMcpServers`** — MCP server name patterns that must be configured, else the agent won't appear

### Example: learning codebase guide (persistent memory)
```yaml
---
name: codebase-guide
description: Answer questions about the codebase, learning more with each session
tools: [Read, Grep, Glob, Bash]
color: green
memory: project
---
You are a codebase guide with persistent memory. Check your memory first before exploring the code.

After answering a question, save useful context to memory:
- Architecture decisions (type: project)
- Code locations for common tasks (type: reference)
- Patterns and conventions (type: feedback)

Over time, you should answer faster because you remember where things are.
```

### Example: fresh-eyes reviewer (no project bias)
```yaml
---
name: fresh-eyes
description: Review code without project-specific biases
tools: [Read, Grep, Glob]
omitClaudeMd: true
effort: high
color: blue
---
Review this code purely from first principles. You have no project context. Focus on correctness, security, performance, and readability by industry standards.
```

### Example: critical reminder (EXPERIMENTAL)
```yaml
---
name: prod-deployer
description: Manages production deployments with strict safety checks
tools: [Bash, Read, Grep]
color: red
criticalSystemReminder_EXPERIMENTAL: "Always run migrations with --dry-run first. Never skip the staging verification step."
---
```
> ⚠️ `EXPERIMENTAL` is in the actual field name. Anthropic's engineers consider it
> unstable — could be removed/renamed any release. Use only for nice-to-have reminders.

---

## 5. Auto-mode classifier ("YOLO Classifier") accepts plain English

The `autoMode` field in `settings.json` configures auto-approval. The internal name is the
"YOLO Classifier" (`yoloClassifier.ts`).

```json
{
  "autoMode": {
    "allow": [
      "Bash(npm test)",
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Read",
      "Grep",
      "Glob"
    ],
    "soft_deny": [
      "Bash(git push *)",
      "Bash(rm *)",
      "Write(.env*)"
    ],
    "environment": [
      "NODE_ENV=development",
      "This is a local dev machine with no production database access",
      "All Docker containers use isolated networks",
      "The test suite is safe to run repeatedly, it uses a dedicated test database"
    ]
  }
}
```
- `allow` patterns → auto-approved. `soft_deny` → always require confirmation.
- **`environment` is the interesting one** — not patterns, but plain-English context strings
  the classifier reads to reason about your setup ("No production access" → less paranoid
  about destructive ops; "Test database is isolated" → tests always safe).

---

## 6. The learning loop toggles

```json
{
  "autoMemoryEnabled": true,
  "autoDreamEnabled": true
}
```
- **`autoMemoryEnabled`** — after each session, a background agent extracts durable memories
  (preferences, patterns, decisions) to `~/.claude/projects/<path>/memory/` in the standard
  memory frontmatter format.
- **`autoDreamEnabled`** — every 24h, if ≥5 sessions have accumulated, a background agent
  consolidates memories: merges duplicates, resolves contradictions, converts relative dates
  to absolute, prunes stale entries.

> Directly relevant to the `_blueprint` cross-session meta-memory goal — and this project
> already uses a `~/.claude/projects/.../memory/` dir. Worth confirming whether these flags
> are on and whether we want the dream consolidation.

---

## 7. Magic Docs — background-maintained doc sections

Source regex: `/^#\s*MAGIC\s+DOC:\s*(.+)$/im`. Must be an **H1**, case-insensitive. The next
line can be italic instructions (`_underscores_` or `*asterisks*`) scoping the update agent:

```markdown
# MAGIC DOC: API Endpoint Reference
_Only document public REST endpoints. Include method, path, request body, response schema, and auth requirements._

## Endpoints

(content auto-maintained by Claude Code)
```
Without the instruction line, the agent tries to update everything. The update agent runs in
the background, restricted to editing only that file. Deleting the header stops tracking.

> Candidate approach for the `great-docs` documentation effort — auto-maintained reference
> sections for the bookmark CLI.

---

## 8. Full permission rule syntax (glob, not regex)

```
Bash(npm *)              # wildcard after "npm "
Bash(git commit *)       # specific subcommand
Read(*.ts)               # file extension
Read(src/**/*.ts)        # recursive directory with extension
Write(src/**)            # recursive, all files
mcp__slack               # all tools on slack server
mcp__slack__*            # explicit wildcard (same effect)
mcp__slack__post_message # specific tool
Bash(npm:*)              # legacy colon prefix (word boundary)
```
- `*` matches within boundaries (shell-glob style); `**` matches recursively.
- MCP tools use double underscores: `mcp__<server>__<tool>`.
- The `if` field in hooks uses this **same** syntax. No regex.

```json
{
  "permissions": {
    "allow": [
      "Bash(npm *)", "Bash(git status)", "Bash(git diff *)",
      "Read(src/**)", "Read(tests/**)", "Grep", "Glob",
      "mcp__database__query"
    ],
    "deny": [
      "Bash(rm -rf *)", "Write(/etc/**)", "Write(.env*)",
      "mcp__slack__delete_*"
    ],
    "ask": [
      "Bash(git push *)", "Write(*.json)", "Write(*.lock)",
      "mcp__slack__post_message"
    ]
  }
}
```

---

## 9. `context: fork` and the model/cache gotcha

Setting `context: fork` on a skill runs it as a **background forked subagent**. Forks share
the parent's prompt cache via a typed contract (`CacheSafeParams`) and produce byte-identical
API request prefixes to maximize cache hits.

**Gotcha:** setting a *different model* on a forked skill breaks the cache (prefixes diverge →
cache miss → full price). Either omit `model` or use `model: inherit` on forked skills.

Use forks for heavy work (security scans, dependency analysis, doc generation, test runs):
```yaml
---
name: full-audit
description: Comprehensive codebase audit running in the background
context: fork
allowed-tools: Bash, Read, Grep, Glob, WebSearch
effort: high
---
Run a comprehensive audit:
- Security scan (grep for dangerous patterns, check dependencies for CVEs)
- Code quality (duplicated logic, dead code, missing error handling)
- Test coverage (untested critical paths)
- Dependency health (outdated packages, unused deps, license issues)

Write a detailed report to /tmp/audit-report.md when complete.
```

---

## 10. Putting it together

### Self-improving reviewer (memory + scoped hooks)
`.claude/agents/reviewer.md`:
```yaml
---
name: reviewer
description: Code reviewer that learns your codebase patterns over time
tools: [Read, Grep, Glob, Bash]
effort: high
color: yellow
memory: project
hooks:
  PostToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "~/.claude/hooks/log-review.sh"
          async: true
---
Before reviewing, read your memory for past findings on this codebase.

Review git diff HEAD~1 for:
- Patterns you've flagged before (check memory)
- New issues worth flagging
- Resolved issues from past reviews

After review, save to memory:
- New patterns found (type: feedback)
- Recurring issues (type: project)

End with VERDICT: PASS, FAIL, or NEEDS_REVIEW.
```

### SessionStart context + auto-approve + asyncRewake safety net
`settings.json`:
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/session-context.sh",
        "statusMessage": "Loading project context..."
      }]
    }],
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/auto-approve-readonly.sh"
      }, {
        "type": "command",
        "command": "~/.claude/hooks/block-dangerous.sh",
        "asyncRewake": true,
        "statusMessage": "Safety check..."
      }]
    }]
  }
}
```

`~/.claude/hooks/block-dangerous.sh`:
```bash
#!/bin/bash
CMD=$(jq -r '.tool_input.command' < /dev/stdin)
echo "$CMD" | grep -qE '(rm -rf /|sudo rm|chmod 777|> /dev/)' && exit 2 || exit 0
```

### Skill with model override + effort + agent delegation
```yaml
---
name: architecture-review
description: Deep architecture review using max effort, delegated to fresh-eyes agent
agent: fresh-eyes
effort: max
---
Review the architecture of this project. Ignore existing conventions (the agent has omitClaudeMd: true).
Focus on: $ARGUMENTS

Evaluate structural decisions, dependency graph health, separation of concerns, and scalability characteristics.
```

---

## Takeaways for this project

- [ ] **Verify** these fields exist in our installed Claude Code version before depending on
      them (article reads `@2.1.87`; APIs drift, EXPERIMENTAL ones especially).
- [ ] Check whether `autoMemoryEnabled` / `autoDreamEnabled` are on — they overlap with the
      `_blueprint` cross-session meta-memory goal (§6).
- [ ] Consider a **read-only auto-approver** `PreToolUse` hook to cut permission prompts
      (complements the existing `fewer-permission-prompts` skill).
- [ ] Evaluate **Magic Docs** (§7) for the `great-docs` documentation effort.
- [ ] For review/audit agents, try `omitClaudeMd: true` (§4) for an unbiased pass.
- [ ] Treat `criticalSystemReminder_EXPERIMENTAL` as off-limits for now (explicitly unstable).
