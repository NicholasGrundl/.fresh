# snap-git · HELP route — git mentor

Use this when the caller needs to *understand* git or *choose a strategy* — not to commit and not
(yet) to recover a broken state. The whole route is **read-only by default**: inspect, explain,
preview with dry-runs, recommend. The caller decides and runs anything that mutates the repo.

> If the repo is actually broken / mid-operation (stuck rebase, detached HEAD, lost work), this is
> the wrong route — use `unstick.md`.

## 1. See the state clearly

```bash
git status                      # working tree + what operation (if any) is in progress
git log --graph --oneline -20   # branch shape and recent history
git log --graph --oneline --all -30   # all branches, to see where things diverge
git branch -vv                  # local branches + their upstreams + ahead/behind
git reflog -20                  # the chronological trail of where HEAD has been
```

Explain back to the caller, in plain terms: what branch they're on, what's staged vs unstaged,
how their branch relates to its upstream (ahead/behind), and where the interesting divergence is.

## 2. Compare before acting

```bash
git diff A...B                  # net difference between two refs
git log --left-right --oneline A...B   # which commits are unique to each side
git diff --stat <ref>           # scope of a change at a glance
```

## 3. Preview a merge/rebase WITHOUT changing anything

- **Merge preview (abortable):**
  ```bash
  git merge --no-commit --no-ff <ref>   # stage the merge but don't commit
  git diff --cached                      # inspect the would-be result
  git merge --abort                      # back out cleanly
  ```
- **Merge preview (zero side effects):** `git merge-tree <base> <ref1> <ref2>` shows the merged
  result and conflicts without touching the index or working tree.
- **Rebase preview:** there's no true dry-run; instead show the plan —
  `git log --oneline <upstream>..HEAD` is the list of commits that would replay. Recommend
  branching a backup first (`git branch backup/<name>`) before any real rebase.

## 4. Strategy guidance (merge vs rebase)

- **Merge** when the branch is shared/pushed or you want to preserve true history — non-destructive,
  creates a merge commit.
- **Rebase** only on *local, unpushed* work to get a linear history — it rewrites commits, so never
  rebase shared branches without coordination.
- When unsure, prefer **merge** (safe, reversible) and say why.

## Posture

- Never run a mutating command here on your own. Show the command, explain the effect, let the
  caller run it.
- When a question edges into "fix my broken repo", switch to the `unstick.md` doctrine
  (non-destructive, diagnose → dry-run → reversible plan).
