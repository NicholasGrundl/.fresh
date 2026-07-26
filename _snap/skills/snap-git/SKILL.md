---
name: snap-git
description: "Composes a `[MACRO]` checkpoint commit message for a `_snap` project. Invoke it manually (e.g. `/snap-git`): it reads the working tree and the work since the last MACRO, then returns a ready-to-use `[MACRO] <feature>: <subject>` message — shell-safe for `git commit -m\"[message]\"` — plus a brief reminder of the usual `git add .` then `git commit -m\"…\"` flow. You run it, the skill does not. MACRO commits are the main checkpoints (the greppable stops in history, via `git log --grep`); your freeform WIP commits are the local stops between them. If instead you need a git mentor or to unstick a messy git state, it points you to `references/help.md` or `references/unstick.md`. Manual-only — not meant to auto-trigger. Read-only / dry-run posture; it proposes, you execute."
metadata:
  author: nicholasgrundl
  version: "0.1"
compatibility: Requires `git` on PATH. The skill never runs destructive or history-rewriting commands itself — it presents the message and command for you to run.
---

# snap-git — compose a `[MACRO]` checkpoint

This skill composes the **`[MACRO]` checkpoint commit** you'll run yourself. Its rule is *propose,
don't execute*: it reads and analyzes the repo, then hands you the message and the command —
staging and committing are yours. This matches the `_snap` doctrine that the human makes the
actual commit.

**The two-tier history model (why MACRO matters):**

- **`[MACRO]` commits = the main stops.** Curated checkpoints at a task/feature boundary (≈ one
  `_snap` DECISIONS entry). The `[MACRO]` prefix is a deliberate **grep anchor**:
  `git log --grep='\[MACRO\]' --oneline` gives the high-level story of the project at a glance.
- **Freeform WIP commits = the local stops.** Your small, between-checkpoint saves
  ("stashing progress", "wip: …"). These stay **freeform and manual — not this skill's job**. To
  read the detailed story between two checkpoints, look at `git log <macroA>..<macroB> --oneline`.

This skill only composes the MACRO. The freeform locals are yours to make however you like.

> **Not composing a MACRO?** Two other jobs live in references — read the matching file and follow it:
> - **Git mentor** (understand oddities, choose merge vs rebase, dry-run a merge) → `references/help.md`
> - **Unstick a messy state** (stuck rebase, detached HEAD, lost work — carefully, non-destructively) → `references/unstick.md`
>
> If it's genuinely unclear which of the three you need, say so and ask before acting.

---

## Composing the MACRO

### 1. Read the state (read-only)

```bash
git branch --show-current
git status --short                         # glance before `git add .` — catch stray/secret files
git diff HEAD                              # staged + unstaged — the actual changes to describe
git log --grep='\[MACRO\]' --oneline -5   # the recent checkpoints + the prefix/style in use
git log <last-macro>..HEAD --oneline      # the freeform WIP story since the last checkpoint
```

The last two are the point of the MACRO: you're summarizing **the whole arc since the previous
checkpoint**, not just the latest edit.

### 2. Analyze before writing

- **Synthesize the arc:** read the WIP commits + the diff since the last MACRO and distill what
  this checkpoint *accomplishes* and *why* — an executive summary, not a changelog of every keystroke.
- **Group into themes:** collapse related work into a handful of bullets.
- **Match the existing style** visible in the recent `[MACRO]` log (prefix, scope, tense).

### 3. Write the message

```
[MACRO] <feature/task>: <concise imperative subject — one line, never the whole body>

<Executive summary: a short paragraph (a few sentences is fine) framing what this
checkpoint achieves and why it mattered. This is the "main stop" description.>

- <theme>: what changed and why
- <theme>: what changed and why

<NNN tests …, ruff/ty clean>   # status-line footer, when relevant
```

- **Keep the `[MACRO]` prefix and the brackets** — it's the grep anchor; don't drop or unbracket it.
- **Subject stays on one line.** Never jam the body into the subject (it ruins `git log --oneline`).
- **Scope** is the feature/task (e.g. `textual-tui T7`), matching the `_snap` feature in play.
- **No tool/AI attribution.** No 'Generated with…' / 'Co-Authored-By: …' lines — you are the author.
- **Shell-safe by construction — this is a hard rule.** The message is always pasted into a basic
  `git commit -m"[message]"` (double-quoted). So the message must contain **no characters that break
  a double-quoted shell string**: never use the double-quote `"` inside the message (use single
  quotes `'…'` to quote a term instead), and avoid backticks `` ` ``, `$`, backslash `\`, and a
  trailing `!`. Em-dashes (—), arrows (→), parens, and `#` are fine. If you catch yourself wanting a
  `"`, switch it to `'`. Verify the whole message — subject *and* body — is paste-safe before
  returning it.

### 4. Return the message — don't commit, don't write commands

**Return only the composed `[MACRO]` message** — the subject line and body, as text the caller can
copy straight into `git commit -m"[message]"`. Do **not** build out a full multi-line command to
run: the caller already knows to use `git commit -m"…"`. Just hand over the message.

End with a **brief one-line reminder** of the usual flow — typically `git add .`, then
`git commit -m"[message]"`. Two situations to note in that one line only when they apply:

- **Stray/secret files** in `git status --short` → flag them so the caller can stage selectively
  instead of `git add .`.
- **Clean tree** (work already committed as WIP since the last MACRO) → there's nothing to stage,
  so the caller lands the message as an empty checkpoint marker with `git commit --allow-empty -m"…"`.

Then offer to refine the wording. **Stop there** — let the caller run it.
