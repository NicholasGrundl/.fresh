# Implementation Session Guide (BUILD)

This document defines how you run **BUILD** sessions. Read it at the start of every session before
touching any code.

**Purpose**: Orient → flip `[ready]→[active]` → decompose sub-tasks → Implement → Close (flush).
One feature (or one task within it) per session.

**Where this sits in the lifecycle** (see `_snap/AGENTS.md`):

```
PLAN   idea ─interview→ features/<name>.md  [draft]→[ready]; add to ROADMAP
BUILD  [ready]→[active]; pick a task ─JIT→ sub-tasks in SESSION.md; commit as you go   ← you are here
       CLOSE → flush SESSION ─condense→ DECISIONS; tick task boxes; bump ROADMAP
ALIGN  reconcile ROADMAP / features / SESSION / DECISIONS vs reality → ALIGNMENT.md
```

**The memory spine you operate on** (future / present / past):
- `_snap/ROADMAP.md` — *future*: which feature is next.
- `_snap/features/[state]<name>.md` — the spec: Executive Overview + Task Checklist + Details.
- `_snap/SESSION.md` — *present*: your live scratchpad; sub-tasks decomposed just-in-time here.
- `_snap/DECISIONS.md` — *past*: append-only, culled log you flush into at close.

**Composability**: Sections marked with `<!-- COMPOSABLE -->` contain project-specific content that
may change between features. The surrounding workflow is generic and stable. When updating
composable sections, preserve the marker comments.

---

## Step 0 — Orient Yourself (every session, no exceptions)

### 0a. Explore the project structure

**Do this FIRST, before reading any files.** Use the `smart-tree` skill (or `tree` as fallback)
to scan the project layout. This builds a mental map of where things live and prevents wasting
context reading irrelevant files.

**Required scans** (run these before reading content):

1. **`_snap` scan** — understand the memory/planning state:
   - `smart-tree` or `tree _snap/ -L 2 --dirsfirst --noreport --gitignore`
   - Identifies: ROADMAP / SESSION / DECISIONS / ALIGNMENT, feature specs (with `[state]` prefix)

2. **Source scan** — understand codebase structure:
   - `smart-tree` or `tree src/ -L 3 --dirsfirst --noreport --gitignore`
   - Identifies: modules, packages, models — where code lives

3. **Test scan** — understand test coverage:
   - `smart-tree` or `tree tests/ -L 2 --dirsfirst --noreport --gitignore`
   - Identifies: which modules have tests, fixture directories

**Philosophy**: Explore structure and filenames FIRST. Only grep or read file contents after you
know WHERE to look. This limited-disclosure approach prevents wasting context on irrelevant files.

**Tool priority**:
1. **Primary**: `smart-tree` skill — intelligent, annotated, recommends read order
2. **Fallback**: `tree` command — fast, flexible, always available
3. **Last resort**: `find` with targeted flags if `tree` is unavailable

### 0b. Read the ground truth

Now that you know where things are, read the key files:

1. Read `_snap/SESSION.md` — the *present*. If it holds an in-flight focus + unfinished sub-tasks,
   a BUILD session is mid-stream — that's where you pick up. If it's reset to the empty template,
   no session is in flight and you're starting one.
2. Read `_snap/ROADMAP.md` — the *future*. Identify the `[active]` feature (if any) or the next
   `[ready]` feature in priority order.
3. Read the feature spec — `_snap/features/[active]<name>.md` (in flight) or `[ready]<name>.md`
   (next up). The Task Checklist is your durable plan.
4. Skim `_snap/DECISIONS.md` — the *past*. Note any prior decisions that constrain this work.
5. Read `CLAUDE.md` / `AGENTS.md` for established patterns and conventions. Follow them exactly.

### 0c. Determine your situation

Based on `SESSION.md` + the feature's state, determine which situation applies:

**A) `SESSION.md` has an active focus with incomplete sub-tasks (feature is `[active]`).**
Pick up where the last session left off. Confirm with the user: "SESSION.md shows sub-task X is
next — should I continue from there?" Then go to Step 2.

**B) `SESSION.md` is at the empty template; the next ROADMAP feature is `[ready]`.**
Go to Step 1 — flip it to `[active]` and decompose the first task into sub-tasks.

**C) The state is ambiguous** (e.g. SESSION half-filled but feature already `[done]`, or ROADMAP
and SESSION disagree). Ask the user before proceeding — and consider whether an **ALIGN** session
is needed first (`PROMPT-reconcile-and-align.md`).

### 0d. Targeted exploration (as needed)

During planning or implementation, you may need to explore specific areas of the codebase in more
depth. Use the `smart-tree` skill to locate files by name before reading them.

If the exploration results are ambiguous or don't clearly point to the right files, ask the user
for guidance using the `AskUserQuestion` tool with multiple-choice options rather than guessing.

---

## Step 1 — Plan the Session (flip to `[active]`, decompose sub-tasks)

### 1a. Flip `[ready]→[active]`

Starting work on a `[ready]` feature means flipping it to `[active]` — **this flip *is* the "begin
implementation" step.** Rename the spec's filename prefix `[ready]→[active]` and update its
frontmatter `state`. (The rename is a move — do it as its own step; never bundle a rename with
content edits.) Note it in `_snap/ROADMAP.md`.

### 1b. Break the current task into sub-tasks (just-in-time)

Pick **one** task from the feature's Task Checklist. Decompose *that task* into concrete, ordered
**sub-tasks**. Sub-tasks are session-level and live **only** in `SESSION.md` — they are never
pre-listed in the feature spec.

### 1c. Propose to the user

**Propose the sub-task list to the user before writing any code.** Get sign-off.

### 1d. Persist immediately

Once approved, **write the focus + sub-tasks into `_snap/SESSION.md`** immediately so they persist
even if the session ends early. Mirror them into an ephemeral `TodoWrite` list for live tracking.

`SESSION.md` shape (the *present* — loose, working scratch):

```markdown
# Session — <feature/task focus>

## Focus
<feature/task this session is working on; link the `features/<name>.md` spec>

## Sub-tasks (just-in-time)
- [ ] <session-level step>
- [ ] <session-level step>  <- where we are

## Notes / reasoning / gotchas
<working scratch>

## Open / blockers
- <none | …>
```

### 1e. Choose the development approach per sub-task

| Situation | Approach |
|---|---|
| Module touches external services (APIs, databases, HTTP, an LLM endpoint) | **Tracer Bullet** |
| Pure logic, no external dependencies | **TDD (Red / Green / Refactor)** |

<!-- COMPOSABLE: List modules that qualify for immediate TDD in the current feature.
     Example format:
     | Module | Why TDD works here |
     |---|---|
     | `dedup.find_duplicates()` | Pure Python set logic over parsed bookmarks |
     | Pydantic models (`Bookmark`, `Folder`) | Pure validation logic |
-->

---

## Step 2 — Implement

### Tracer Bullet modules: three passes

**Pass 1 — Prove end-to-end (real external services)**

- Build the thinnest path through the sub-task that satisfies the acceptance criteria.
- Write **one integration test** per task using the app's test harness — the golden source of
  "it works end to end."
- Run against real external services (real APIs, real HTTP, a real LLM endpoint).
- **Capture every external API request+response as a fixture file** immediately after the call
  succeeds — don't defer this. See Fixture Capture Strategy below.
- Tag integration tests with an appropriate marker (e.g. `@pytest.mark.integration`).
- **Gate**: integration test is GREEN before moving to Pass 2.

**Pass 2 — Freeze internals (unit tests with captured fixtures)**

- Write unit tests for every module, using the captured fixture files as mock data.
- Fixtures represent real external behavior — not guessed shapes.
- Code does NOT change in this pass — tests lock in what's working.
- Unit tests must run without any external service access.

**Pass 3 — Build fake classes**

- Build fake/stub implementations of external clients using the captured fixtures.
- Replace raw mock patches with these reusable fake classes.
- Document which tests still require real services vs which use fakes.

### TDD modules: standard cycle

1. Write a failing test (RED) — it must fail because the behavior isn't implemented, not because
   the test is broken.
2. Write the minimum code to make it GREEN.
3. Refactor while GREEN.
4. Repeat.

### During implementation (both approaches)

- Implement one sub-task at a time; tick it in `SESSION.md` + `TodoWrite` as you go.
- Run tests after each sub-task; surface failures immediately.
- **When a test fails unexpectedly**: diagnose whether the test or the code is wrong. Tell the
  user: "This test is RED but I think [the test / the code] is wrong — here's why." Then ask
  whether to fix the test, skip it, or adjust the code.
- **When a sub-task reveals that a future task's interface needs to change**: stop, surface it to
  the user, and get a decision before continuing. Don't silently adjust — and if the change is
  large enough to invalidate the spec, flag that an **ALIGN** pass may be needed.
- Keep the feature's integration test GREEN before considering its tasks done.

---

## Fixture Capture Strategy

For every external API call during Pass 1, capture the real HTTP interaction immediately after it
succeeds.

Each fixture file should contain both the request and response:

```json
{
  "request": { "method": "GET", "url": "...", "headers": {}, "body": null },
  "response": { "status": 200, "headers": {}, "body": { ... } }
}
```

These captured fixtures become the mock data for Pass 2 unit tests and the backing data for
Pass 3 fake classes. Mocks built from real responses don't lie.

<!-- COMPOSABLE: Define the fixture directory structure for the current project.
     Example (bookmark MVP — link-visiting + LLM enrichment):
     ```
     tests/fixtures/
       http/
         example_com.json
         github_repo.json
       llm/
         summarize_page.json
         classify_folder.json
     ```
-->

---

## Step 3 — Close the Session (flush)

Closing a BUILD session means **flushing the *present* into the *past*** — condensing `SESSION.md`
into `DECISIONS.md`, ticking the feature's checklist, and bumping the ROADMAP. This roll-up is a
standardized step (the planned `git-session-infra` flush skill, offered by a gated "done?" session
hook). Do it explicitly:

1. **Condense `SESSION.md` → `DECISIONS.md`** (newest first). One entry, culled to the signal:

   ```markdown
   ## YYYY-MM-DD — <feature/task>

   **Set out to:** <the task/sub-tasks this session targeted>
   **Why:** <motivation / constraint>
   **How it ended:** <done | partial> — <what's GREEN, fixtures captured, what's left>
   **Why we stopped:** <complete | handoff point | blocker>
   **Next:** <where the next BUILD session picks up>
   ```

2. **Tick the feature's Task Checklist** in `_snap/features/[active]<name>.md` for every task
   completed this session.

3. **If all tasks are ticked**, flip `[active]→[done]` (rename prefix + frontmatter `state`; a move
   — its own step). Otherwise leave it `[active]`.

4. **Bump `_snap/ROADMAP.md`** — update the feature's state / ordering; if `[done]`, move it out of
   "Now" and condense it into the DECISIONS narrative.

5. **Macro-commit** — a human-readable `[MACRO]` checkpoint at the task/feature boundary
   (≈ this DECISIONS entry). Commits themselves are handled by the git hooks / the user — don't run
   `git commit` yourself.

6. **Reset `SESSION.md`** back to the empty template, with a `_Last flush:_` footer pointing at the
   new DECISIONS entry.

---

<reference_content>

## Reference: Development Approaches

These definitions are included for completeness. The operational instructions above tell you
*when* to use each approach — this section defines *what* each approach means in full detail.

### Test-Driven Development (TDD)

TDD means the test defines the behavior before the implementation exists. The cycle is:

1. **Assess** what tests are needed (unit, integration, edge cases). Think about what real
   behavior needs to be proven — not just code coverage.
2. **Plan fixtures first.** Before writing any test, think about the lifecycle of dependencies:
   what needs a client, what needs a database, what needs a mock. Define `conftest.py` fixtures
   that cover these. Reuse fixtures from previous tasks where they fit. Extend elegantly rather
   than duplicating. Keep fixtures concise but powerful.
3. **Write RED tests.** Each test should fail initially — but fail for the right reason (the
   behavior isn't implemented yet, not because the test is broken). A RED test that passes
   trivially is not a RED test.
4. **Write code to make tests GREEN.** Implement the minimum code needed to satisfy each test.
   Don't over-implement. The test defines the contract.
5. **Handle imperfect tests.** If a RED test turns out to be wrong — the spec was ambiguous, the
   assumption was bad, the approach changed — surface it explicitly. Decide: change the test,
   skip it, or make the code match it. Log the decision.
6. **Repeat across sessions.** Each session picks up the RED/GREEN state and continues.

### Tracer Bullet Development

Tracer bullet means proving end-to-end flow first, then hardening the internals.

1. **Build the thinnest working path.** For each task, build just enough code to make the full
   flow work — input to processing to output — against real dependencies. No stubs, no fakes.
   Real services, real tokens, real HTTP. It doesn't have to be clean. It has to work.
2. **Write one integration test.** A single end-to-end integration test that captures the full
   flow. This is the golden source — "if this passes, the task works." It doesn't test internals.
   It tests outcomes.
3. **Refine while the integration test stays GREEN.** Once the tracer bullet works, improve the
   implementation: clean up code, extract modules, add error handling. The integration test tells
   you if you broke anything.
4. **Freeze the internals with unit tests.** As a second pass, add unit and detailed integration
   tests to lock in the internal behavior. By now the code is stable — these tests document and
   protect what's already working.

### Why we combine them

When interface design is already done (from specs with clear interfaces, data models, and
acceptance criteria), the bigger risk is "do external services actually behave like we think they
do?" — mocks can't answer that. We answer it by running against real services first and capturing
the actual responses as fixtures. Those real-response fixtures then become the basis for unit test
mocks, so the mocks reflect reality rather than assumptions.

Pure-logic modules don't have this problem. Their inputs and outputs are fully known, so TDD
gives fast feedback without integration overhead.

</reference_content>
