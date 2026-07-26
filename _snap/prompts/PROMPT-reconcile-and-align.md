# Reconcile & Align Session Guide (ALIGN)

This document defines how you run **ALIGN** sessions — reconciling the `_snap` memory files against
reality when they've drifted out of sync. Use it when building has been underway and the docs no
longer match the code or each other.

**Purpose**: Look backward (fix stale docs) AND forward (adjust upcoming specs based on learnings).
Reconcile **ROADMAP / features / SESSION / DECISIONS** vs reality → produce `_snap/ALIGNMENT.md`.

**Where this sits in the lifecycle** (see `_snap/AGENTS.md`):

```
PLAN   idea ─interview→ features/<name>.md  [draft]→[ready]; add to ROADMAP
BUILD  [ready]→[active]; JIT sub-tasks into SESSION.md; close → flush to DECISIONS
ALIGN  reconcile ROADMAP / features / SESSION / DECISIONS vs reality → ALIGNMENT.md   ← you are here
```

**Core principle**: This process is heavily user-driven. Do not assume you know what the user wants.
Surface every decision that has more than one reasonable approach. Always provide a recommended
option with reasoning. Use `AskUserQuestion` with selectable options whenever possible to reduce
typing burden.

---

## Step 0 — Orient (every session, no exceptions)

### 0a. Read the ground truth files

The `_snap` memory spine is future / present / past — read all three, plus any prior report:

1. `_snap/ROADMAP.md` — the *future*: ordered feature list, states, spec links.
2. `_snap/SESSION.md` — the *present*: is a BUILD session mid-flight, or is this stale,
   unflushed scratch from an abandoned session?
3. `_snap/DECISIONS.md` — the *past*: append-only, culled log of what was done and why.
4. The feature specs in `_snap/features/` — each carries a `[state]` prefix + frontmatter `state`.

### 0b. Check for an existing alignment report

- If `_snap/ALIGNMENT.md` **exists** → read it. It contains known drift issues from a prior
  session. Use it as your starting checklist — some items may already be resolved, others may be
  new.
- If it **does not exist** → you will create one in Step 1.

### 0c. Survey the `_snap` structure

Use a lightweight exploration to understand what docs exist and where they live.

<note>
**Exploration strategy — use the most efficient tool available:**

1. **Primary**: Use the `smart-tree` skill if available. It provides intelligent, heuristic-driven
   directory exploration that minimizes token cost.
2. **Fallback**: Use the `tree` bash command. It is fast, efficient, and flexible.
   - Example: `tree _snap -L 2 --dirsfirst` for a quick overview
   - Example: `tree _snap/features -L 1 --filesfirst` for the spec set (state prefixes visible)
   - Run `tree --help` if unfamiliar with flags.
3. **Last resort**: Use `find` with targeted flags if `tree` is unavailable.
   - Dirs only: `find _snap -maxdepth 2 -type d`
   - Specific files: `find _snap -name "*.md" -maxdepth 2`
   - Exclude dirs: `find _snap -path "*/context/*" -prune -o -name "*.md" -print`

**Philosophy**: Explore structure and filenames FIRST. Only grep or read file contents after you
know WHERE to look. This limited-disclosure approach prevents wasting context on irrelevant files.
</note>

Key locations to survey:
- `_snap/` root — ROADMAP / SESSION / DECISIONS / ALIGNMENT
- `_snap/features/` — feature specs (`[state]<name>.md`) and `BACKLOG.md`
- `_snap/archive/` — completed/superseded files + `ARCHIVE.md`

Do NOT read `_snap/context/` proactively. Only search there if information you expect to find in
ROADMAP / features / DECISIONS is missing. Then use targeted grep or smart-tree on specific context
subfolders (see `_snap/context/AGENTS.md`).

### 0d. Establish the situation

Determine:
- Which features are **`[done]`** (per DECISIONS + the code) but not marked so?
- Which features are **`[active]`** or **`[ready]`** (upcoming work)?
- Does each feature's filename `[state]` prefix match its frontmatter `state` *and* reality?
- Is `SESSION.md` live, or stale unflushed scratch that should have been condensed into DECISIONS?
- Is there an existing `ALIGNMENT.md` with unresolved items?

**Present your orientation summary to the user.** Confirm you have the right picture before
proceeding to discovery.

---

## Step 1 — Discover Drift

Systematically compare the ground truth (DECISIONS + SESSION + source code) against the planning
docs (ROADMAP + feature specs). Check each area below and record every discrepancy.

### 1a. ROADMAP states vs reality

Compare `ROADMAP.md` feature states against DECISIONS and the actual code. Flag any feature listed
as `[ready]`/`[active]` that is actually built (`[done]`), or ordered wrongly relative to what's
already been done.

### 1b. Spec links + state prefixes

Check that links in `ROADMAP.md` point to files that actually exist (a `[state]` prefix change
renames the file — links go stale). For each spec, check the filename `[state]` prefix matches its
frontmatter `state`. Flag mismatches.

### 1c. `[done]` / `[active]` spec content accuracy

For each completed or in-flight feature, spot-check its spec:
- Is the filename still `[active]` (or `[ready]`) when the work is actually done?
- Do the Task Checklist boxes reflect what was actually built?
- Does the spec mention decisions that changed during implementation?
- Are there tasks the original spec didn't anticipate (surfaced in DECISIONS / SESSION)?

### 1d. DECISIONS completeness

Compare decisions visible in `SESSION.md` and the git `[MACRO]` history against `DECISIONS.md`.
Flag significant decisions that happened but were never condensed into the append-only log.

### 1e. SESSION staleness

Check whether `SESSION.md` holds stale, unflushed content from a session that ended without a
proper close. If so, flag it: the fix is to condense it into `DECISIONS.md` and reset SESSION to
its template (a BUILD-close flush, done here as remediation).

### 1f. BACKLOG staleness

Scan `_snap/features/BACKLOG.md` for items that reference outdated assumptions (tech choices that
changed, ideas that were already built, descriptions that no longer match).

### 1g. Upcoming feature specs — forward-looking drift

For the next 1-2 `[ready]` features, check if their specs assume things that changed:
- Dependencies that were already pulled forward into earlier features
- Modules/models/config that already exist
- Patterns or interfaces that shifted during prior builds
- Architecture decisions made during implementation that aren't reflected

### 1h. Conventions staleness (`AGENTS.md` / `CLAUDE.md`)

Check whether alignment fixes affect the canonical rules:
- `_snap/AGENTS.md` (and the per-folder `AGENTS.md` in `context/`, `features/`) — structure,
  memory model, conventions. `CLAUDE.md` is a symlink — never edit it directly; edit `AGENTS.md`.
- Root project `CLAUDE.md` — project overview, conventions, paths.

### 1i. Archive candidates

List any `[done]` specs in `_snap/features/` that could be archived (move to `_snap/archive/` +
append an `ARCHIVE.md` entry).

### 1j. Produce the alignment report

Write or update `_snap/ALIGNMENT.md` with all findings. Use this format:

```markdown
# Alignment Report

*Generated: YYYY-MM-DD*
*Purpose: Identify inconsistencies between `_snap` docs and actual project state.*
*Action: Use this list to triage and fix with the user.*

---

## 1. <Area> — <Summary>

**File**: `path/to/file.md`

### 1a. <Specific issue>
<Description of the discrepancy>
**Current**: <what the doc says>
**Reality**: <what's actually true>

---

## Summary: Priority Order for Fixes

1. **<Most impactful>** — <why>
2. **<Next>** — <why>
```

**After writing the report, present a summary to the user before moving to triage.**

---

## Step 2 — Triage with User

This is the most important step. Do not skip or rush it.

### 2a. Present findings by priority group

Group the alignment issues into categories:
- **Critical** — blocks or misleads the next BUILD session (e.g., an upcoming spec assumes code
  that already exists differently).
- **Important** — a source of truth is wrong (e.g., ROADMAP states, state-prefix mismatches,
  broken spec links, unflushed SESSION).
- **Housekeeping** — stale references, backlog cleanup, archiving `[done]` specs.

### 2b. Ask the user what to do with each group

Use `AskUserQuestion` for each priority group. Always:
- Provide a **recommended option** as the first choice, marked with "(Recommended)"
- Include **reasoning** in the option description explaining why you recommend it
- Offer "Defer" and "Skip" as options alongside "Fix now"

Example interaction pattern:
```
Question: "ROADMAP.md lists 2 features as [ready] that are actually [done], and 1 spec link is
broken after a state-prefix rename. How should we handle this?"
Options:
  - Fix all now (Recommended) — ROADMAP is the future/source-of-truth; stale states mislead the
    next BUILD session
  - Fix states only, defer the link — the link is lower-risk if the spec is still findable
  - Defer all — note in the alignment report for later
```

### 2c. For `[done]` specs, ask per-spec

For each completed feature spec, ask:
- **Archive** — move to `_snap/archive/`, add an `ARCHIVE.md` entry, fix any links pointing to it.
- **Update in-place** — flip to `[done]`, update stale content, keep in `features/`.
- **Leave as-is** — it's fine where it is for now.

### 2d. For forward-looking changes, present options

When an upcoming feature spec needs adjustment, present the specific options:
- What the spec currently says
- What reality suggests it should say
- Whether to update now or flag it for the BUILD session to handle

### 2e. Build the fix list

After triage, compile an ordered list of what to fix. Confirm the list with the user before
starting.

---

## Step 3 — Execute Fixes

Work through the fix list one area at a time.

### 3a. Fix cadence

- Fix one document or one logical group of changes at a time.
- After each fix, briefly state what was changed.
- Before moving to the next area, check in with the user if the fix involved any judgment calls.
- **Moves are sacred**: any archive/rename is its own step (plain `mv`), never bundled with a
  content edit. Commits are handled by the git hooks / the user.

### 3b. Decision points during fixing

As you fix docs, you will encounter micro-decisions. Surface them rather than assuming:
- "This spec says we'd use httpx but we ended up on Playwright. Replace the reference, or add a
  note about why the approach changed?"
- "DECISIONS is missing 3 decisions from the last build. Backfill all, or just the ones that
  affect upcoming features?"

Use `AskUserQuestion` with recommended options for any decision that has more than one reasonable
approach.

### 3c. What to fix (common patterns)

- **Feature state wrong in ROADMAP** → update the state to match DECISIONS + code.
- **Broken spec link in ROADMAP** (after a `[state]` rename) → fix the path.
- **Filename prefix ≠ frontmatter `state`** → reconcile both to reality (the prefix rename is a move).
- **Spec still `[active]` but work is done** → flip to `[done]`; tick remaining Task Checklist boxes.
- **Decision happened but isn't in DECISIONS** → backfill a culled entry.
- **`SESSION.md` holds stale unflushed scratch** → condense into DECISIONS; reset SESSION template.
- **Upcoming spec assumes code that already exists** → add an "Already implemented" note + file path.
- **BACKLOG item references an outdated choice** → update the description to match reality.
- **`[done]` spec in `features/`** → ask the user: archive, update-in-place, or leave.
- **`AGENTS.md` convention/structure outdated** → update `AGENTS.md` (never the `CLAUDE.md` symlink).

### 3d. Forward-looking spec updates

When updating upcoming feature specs:
- **Do** note what already exists (with file paths) so the BUILD session doesn't rebuild it.
- **Do** flag design questions that surfaced during prior builds.
- **Don't** rewrite the spec — that's for a PLAN session.
- **Don't** change interfaces or architecture without explicit user approval.

---

## Step 4 — Close the Session

### 4a. Update the alignment report

Edit `_snap/ALIGNMENT.md`:
- Mark resolved items (or remove them).
- Keep deferred items with a note about why they were deferred.
- Add any new issues discovered during fixing.
- Update the "Generated" date.

### 4b. Reconcile the memory spine if needed

If the alignment session revealed that work was further along (or behind) than recorded:
- Bump `_snap/ROADMAP.md` states/ordering.
- Backfill or correct `_snap/DECISIONS.md`.
- Reset `_snap/SESSION.md` if it held stale scratch.

### 4c. Session summary

Present to the user:
- **Fixed**: list of docs updated and what changed.
- **Deferred**: list of items saved for later (with reasoning).
- **Decisions made**: any new decisions that should land in `DECISIONS.md`.
- **Next**: what the next BUILD or ALIGN session should focus on.

---

## Search Hierarchy — Where to Find Information

When looking for information during this session, search in this order:

1. `_snap/DECISIONS.md` — the *past*: ground truth of what was done and why.
2. `_snap/SESSION.md` — the *present*: in-flight work (or stale scratch to flush).
3. `_snap/ROADMAP.md` — the *future*: ordered feature list and states.
4. `_snap/features/[state]<name>.md` — per-feature specs (Executive Overview + Task Checklist + Details).
5. `_snap/features/BACKLOG.md` — unscheduled ideas.
6. `_snap/context/` — **only as fallback** when info isn't found above. Use targeted grep or
   smart-tree on specific subfolders, not a broad scan.
7. Source code (`src/`, `tests/`) — for verifying claims in docs against actual implementation.

---

## Anti-Patterns — What NOT to Do

- **Don't silently fix things.** Every fix that involves a judgment call should be surfaced.
- **Don't batch all fixes without check-ins.** Fix one area, check in, move to the next.
- **Don't rewrite upcoming feature specs.** Note what changed and flag questions — full rewrites
  are for PLAN sessions.
- **Don't read `_snap/context/` proactively.** It's reference material, not planning docs. Only
  search there when something is missing from the expected locations.
- **Don't edit `CLAUDE.md` symlinks.** Edit the canonical `AGENTS.md`; the symlink follows.
- **Don't assume the user wants to archive `[done]` specs.** Always ask.
- **Don't skip the triage step.** The user may want to defer things you think are urgent, or
  prioritize things you think are minor.
