# snap-git · UNSTICK route — careful recovery

Use this when the repo is in a bad or confusing state and the goal is to get back to safety
**without losing work**. The entire route is built around one idea: **diagnose → preview →
propose a reversible plan → the caller executes.** You never run destructive commands yourself.

## Safety doctrine (non-negotiable)

- **Never run, on your own initiative**, any of these — only ever *propose* them, with an explicit
  confirmation from the caller first, and a backup in place:
  `git reset --hard`, `git clean -fd`, `git push --force` (use `--force-with-lease` if forced),
  `git branch -D`, `git checkout -- <file>` (discards changes), interactive history rewrites
  (`rebase -i`, `filter-branch`, `filter-repo`).
- **Make a safety net before any risky step:** `git branch backup/<desc>` at the current HEAD, or
  `git stash` to park dirty work. `reflog` is the ultimate undo trail — almost nothing is truly
  lost for ~90 days.
- **Prefer reversible tools:** `git revert` over `git reset`; a new branch over moving an existing
  one; `--force-with-lease` over `--force`.

## 1. Diagnose first (read-only)

```bash
git status                       # what operation is in progress, what's staged/dirty
git reflog -30                   # where HEAD has been — the recovery map
git log --graph --oneline --all -30
git stash list
```

Name the situation out loud before proposing anything.

## 2. Common situations → reversible recovery

**Mid-rebase / mid-merge, want out:**
```bash
git rebase --abort     # or: git merge --abort
```
Returns to the pre-operation state. Safe and complete.

**Mid-conflict, want to finish instead of abort:** resolve files, `git add <file>`, then
`git rebase --continue` / `git commit` (for a merge). Show the conflicted set with `git status`.

**Detached HEAD with commits you want to keep:**
```bash
git branch keep/<desc>           # name the current HEAD so it isn't lost
git switch <your-branch>         # then merge/cherry-pick keep/<desc> as desired
```

**"I lost a commit" (after a reset/rebase):**
```bash
git reflog -50                   # find the lost commit's hash
git branch recovered <hash>      # re-anchor it on a branch — no data created/destroyed
```

**Committed to the wrong branch:**
```bash
git branch correct-branch        # mark the commits
git switch correct-branch        # they're now here; remove them from the wrong branch via
                                 # a proposed reset (with backup + confirmation) — see doctrine
```

**Uncommitted changes blocking a switch/pull:**
```bash
git stash push -m "wip: <desc>"  # park them reversibly
# ...do the switch/pull...
git stash pop                    # restore
```

**Accidentally staged the wrong thing:** `git restore --staged <path>` (unstages, keeps the edits).

## 3. Present the plan

Hand the caller a **numbered list of exact commands**, each with a one-line "what this does", in
the order to run them — with the backup step first. Note any step that is irreversible and require
an explicit "yes" before they run it. Then stop; they execute, one at a time, and report back.
