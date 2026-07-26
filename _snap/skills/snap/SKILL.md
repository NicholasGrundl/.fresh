---
name: snap
description: >
  Router for a project's `_snap/` workspace. Invoke it manually (e.g. `/snap`, or
  `/snap <what to focus on>` to pass intent directly). Defers to the user's intent first:
  asks whether to PLAN / BUILD / ALIGN (or something else) and hands off to the matching
  playbook in `references/`. Only self-orients on the cross-session memory (ROADMAP /
  SESSION / DECISIONS) when the user explicitly asks "you tell me what to do."
  Manual-only — this skill is not meant to auto-trigger.
alwaysLoaded: false
---

# snap — route a `_snap` session

`_snap` is a portable, per-project workspace that keeps project state in plain files (cross-session
memory + feature specs + phase playbooks). **This skill's one job: defer to the user's intent and
hand off to the right playbook.** It does not restate how the system is built — the project's
`_snap/AGENTS.md` is the source of truth for structure and conventions, and each phase playbook in
`references/` is the authoritative procedure.

## Cardinal rule — read nothing first

When `/snap` fires, **do not read the spine, open files, run git, or investigate anything yet.** The
user invoked snap for a reason — your job is to surface that reason, not to guess it. There is
exactly **one** branch where you self-orient (the *"Ask LLM what to work on"* option below); everywhere else the
user names the phase/focus and you go straight to the playbook, which reads what it needs.

## Step 1 — capture intent (arg) or ask for it (bare)

**If the user typed anything after `/snap`** — a focus, a task, or a phase (e.g.
`/snap finish the scan progress bar`, `/snap plan the lancedb backend`,
`/snap something feels out of sync`) — treat that text as their stated intent. Map it to a phase
(PLAN / BUILD / ALIGN) and go straight to that playbook. Only the *playbook* reads what it needs. If
the text gives a focus but the phase is genuinely ambiguous, ask *just* that one phase question —
still don't investigate first.

**If there's no arg**, immediately ask (via `AskUserQuestion`), having read nothing. Present these
five choices — four named options plus the free-form fifth:

- **BUILD** — implement a task on a `[ready]`/`[active]` feature
- **PLAN** — interview an idea into a `features/<name>.md` spec
- **ALIGN** — reconcile drift between the docs and reality → `ALIGNMENT.md`
- **Ask LLM what to work on** — *the only branch where you self-orient* (see below)
- **Describe your intent** — free-form: the user types a focus/task/phase in their own words. This is
  the same as passing it as an arg, and covers the common case where they just forgot to. Treat
  whatever they type exactly like the arg case in Step 1 (map it to a phase, go to the playbook).

`AskUserQuestion` takes at most four explicit options, so wire the first four as the named buttons
and let the built-in **"Other"** slot *be* the **Describe your intent** option — relabel it that way
in your phrasing. Route on their answer; don't pre-empt it by reading files.

## The phases

- **PLAN** — an *idea with no `[ready]` spec yet*: interview it into `features/<name>.md`, or finish
  converging a `[draft]`. Output is a spec, **not** code.
- **BUILD** — a `[ready]` or in-flight `[active]` feature; implement **one** task. (`SESSION.md`
  with an active focus + incomplete sub-tasks = mid-stream resume; empty template + next ROADMAP
  feature `[ready]` = fresh start, flip `[ready]→[active]`.) The playbook handles this.
- **ALIGN** — the memory files and reality have **drifted** (SESSION half-filled but the feature is
  `[done]`, ROADMAP and SESSION contradict, specs describe code that isn't there or vice versa).
  Output is `ALIGNMENT.md`.

If the user picked a phase but a sub-choice is unambiguous-to-them yet unclear to you, ask — a wrong
phase corrupts the memory spine; a quick question never does.

## "Ask LLM what to work on" — the only self-orient branch

**Only** when the user chooses this (or otherwise explicitly asks you to figure out what's open):
now read the spine, past → future → present, to learn where the project is, then present concrete
choices and let the user pick — do **not** start work off your own read.

- **`_snap/DECISIONS.md`** — *past*: append-only, newest-first log; the onboarding doc. Read first.
- **`_snap/ROADMAP.md`** — *future*: the ordered features; what's `[active]` / next `[ready]`.
- **`_snap/SESSION.md`** — *present*: the live scratchpad — session mid-flight, or reset to empty?

Surface what's open (mid-flight session? next `[ready]` feature? a `[draft]` to converge? drift?) as
concrete PLAN / BUILD / ALIGN options and wait for the choice.

## Run the playbook

Once the phase is settled, open the matching playbook in `references/` and follow it — it is the
authoritative procedure:

- **PLAN** → [`references/PROMPT-interview-and-plan.md`](references/PROMPT-interview-and-plan.md)
- **BUILD** → [`references/PROMPT-orient-and-implement.md`](references/PROMPT-orient-and-implement.md)
- **ALIGN** → [`references/PROMPT-reconcile-and-align.md`](references/PROMPT-reconcile-and-align.md)
