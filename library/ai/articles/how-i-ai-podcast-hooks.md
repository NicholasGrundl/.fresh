## Automate Code Quality and Fixes with AI Stop Hooks (verbatim steps from the blog extract)

### 1) Create a stop hook script

Write a script (for example in TypeScript) using the **Claude Agent SDK** that runs whenever the agent “stops” (i.e., completes a task).

### 2) Run quality checks when files change

In the script:

* Detect whether the AI modified any files.
* If changes exist, run a quality gate (linter/typecheck), e.g.:

  * `bun typecheck`

### 3) If checks fail, automatically prompt the AI to fix errors

If the quality check fails:

* Capture the error output/report.
* Print a JSON payload to stdout that instructs the AI to fix the specific issues (Claude reads the hook’s `console.log` output).

Example prompt payload (snippet):

```json
{"prompt": "Please fix the TypeScript errors. Here is the report: ..."}
```

### 4) If checks pass, optionally trigger a commit

If all checks succeed:

* Kick off a follow-on action, such as having a background agent generate a git commit message and commit the changes.

### 5) Configure the hook in Claude Code settings

Add your hook command to the tool’s settings file (example shown: `settings.local.json`) so Claude Code runs it on stop.

Example configuration (snippet):

```json
{
  "claude.hooks.stop": [
    {
      "command": "bun run claude-hooks/index.ts"
    }
  ]
}
```

---

## Concrete implementation (Stop hook script)

```ts
import { $ } from "bun";
import type { StopHookInput, HookJSONOutput } from "@anthropic-ai/claude-agent-sdk"

const input: StopHookInput = await Bun.stdin.json();

const gitStatus = await $`git status --porcelain`.quiet();
const filesChanged = gitStatus.text().trim().length > 0;

if (filesChanged) {
  const typecheckErrors = await $`bun typecheck`.throws(false).quiet().text();

  if (typecheckErrors) {
    const output: HookJSONOutput = {
      decision: "block",
      reason: `
Please fix the TypeScript errors.
The following is a report from "bun typecheck". Don't do any other investigation.
<errors-to-fix>
${typecheckErrors}
</errors-to-fix>
`.trim(),
    }

    console.log(JSON.stringify(output, null, 2));
  } else {
    await $`claude --print --dangerously-skip-permissions --settings .claude/hooks/no-hooks.json --model haiku "No errors found. Create a commit message for the changes. Don't commit any sensitive or temp files. You're running in script which runs often, so don't overthink anything."`.quiet().text();
  }
}
```

---

## Transcript best practices and gotchas

### Use stop hooks as a programmable “definition of done”

Instead of manually prompting “run typecheck” / “fix lint” / “commit,” encode your required checks so the agent can’t stop until the repo meets your quality bar.

### Gate expensive checks on whether files changed

Run a cheap “did anything change?” probe first (e.g., `git status --porcelain`), then only run heavier checks (typecheck, lint, build) when needed.

### Combine structured diagnostics + natural-language instructions

Let terminal commands produce authoritative error output, then feed that output back to the agent with clear instructions on what to fix.

### Keep the fix prompt narrow and focused

The transcript explicitly suggests language like:

* “Please fix the TypeScript errors.”
* “Don’t do any other investigation.”
  And then passing only the error report. This reduces wandering and prevents unrelated edits.

### stdout is the hook “control plane” (major gotcha)

When communicating from a hook back to Claude, you return a JSON payload via `console.log`. That means:

* Any other output on stdout can interfere with the hook response.
* Use `.quiet()` on commands to avoid printing tool output to stdout.
* Use `console.error` (stderr) for debugging logs.

### Prevent recursion when calling `claude` from the hook

If the “success path” runs `claude` again (e.g., commit generation), disable hooks for that nested run using a dedicated settings file (e.g., `--settings .claude/hooks/no-hooks.json`) to avoid infinite loops.

### Team scaling: put the baseline in shared settings

The transcript calls out that hooks can be kept local (personal settings) or shared across the team (repo settings). For orgs, having someone own and standardize these hooks can create consistent baseline quality and efficiency across engineers.

### Other checks to consider beyond TypeScript

Ideas mentioned in the transcript:

* formatting
* linting
* file length / complexity constraints
* circular dependency checks
* duplicate-code detection / refactor suggestions
* other CI-style checks moved earlier (pre-commit / pre-push style gates), selectively due to cost

---

## Demo behavior described in the transcript (what it looks like in practice)

* Agent makes a change.
* Stop hook runs and finds typecheck errors.
* Hook blocks the stop and returns the error report.
* Agent reads the report, fixes the issue, and stops again.
* Stop hook runs a second time, sees no errors, and triggers the commit workflow.
* Result: task is automatically checked, fixed, and finalized with minimal extra human prompting.
