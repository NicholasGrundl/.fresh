---
name: snap-wiki
description: "Search Wikipedia from a natural-language query and export full pages to clean Markdown, via a bundled PEP 723 `uv run` script. Invoke it manually (e.g. `/snap-wiki`) to pull reference material, background, or sources from Wikipedia into a project — building a context corpus or seeding a `_snap/context/<topic>/` reference folder. Two-step flow: `search` resolves a query to ranked candidate pages, `retrieve` fetches chosen pages as one Markdown file each (YAML frontmatter + section-tree headings); a `wizard` command does it interactively for humans (needs a TTY). Manual-only — this skill is not meant to auto-trigger; reach for it intentionally when you want Wikipedia knowledge pulled in."
metadata:
  author: nicholasgrundl
  version: "0.1"
compatibility: Requires `uv` on PATH (the script fetches its own inline deps) and network access to Wikipedia. Set `WIKI_USER_AGENT` with contact info per Wikimedia's User-Agent policy to avoid throttling.
---

# snap-wiki

Search Wikipedia and export pages to **clean Markdown**. The artifact is a single bundled
PEP 723 script — `assets/wiki_fetch.py` — that runs with `uv run` (no install, no virtualenv;
it declares its own deps). It is built for agent use, with an interactive mode for humans.

Each retrieved page becomes one `.md` file with YAML frontmatter (`title`, `url`, `pageid`,
`language`, `retrieved`) and the page's section tree rendered as nested Markdown headings —
ready to drop into a project as reference context.

## The workflow (agents: two steps)

**`search` → `retrieve`.** Search resolves a fuzzy query to exact page titles; retrieve fetches
them. Keep them separate so you can inspect candidates before spending the page fetches.

1. **Search** — natural-language query → a ranked candidate list (printed to stdout):
   ```bash
   uv run assets/wiki_fetch.py search "how bacteria resist antibiotics" -n 10
   ```
   The printed table (rank · title · wordcount · snippet) is usually enough to pick titles and
   call `retrieve` directly. Add `-o DIR/` (or `-o file.json`) to also write a **manifest** —
   a JSON record of the candidates — when you want to pipe the selection into `retrieve`.

2. **Retrieve** — exact titles, or a manifest narrowed by `--pick`, → one `.md` per page:
   ```bash
   uv run assets/wiki_fetch.py retrieve "Antimicrobial resistance" "Beta-lactamase" -o _snap/context/amr/
   uv run assets/wiki_fetch.py retrieve -i refs.json --pick 1,3 -o _snap/context/amr/
   ```
   `--pick` accepts `1,3,5` or ranges `1-4`. Omit it to take every candidate in the manifest.

**Humans:** `wizard` does search → pick → retrieve in one interactive pass. It **needs a TTY**
and will fail fast otherwise, so agents must use `search` + `retrieve` instead:
```bash
uv run assets/wiki_fetch.py wizard "antibiotic resistance"
```

## Conventions

- **Output location.** Default is the current directory. In a `_snap` project, prefer
  `-o _snap/context/<topic>/` — that's the home for external reference docs (one subfolder per
  topic). Filenames are slugified from the canonical page title (redirects resolve first).
- **Never clobber.** An existing target gets a short nanoid suffix before its extension instead
  of being overwritten; `--clobber` opts into overwriting. The final path is logged.
- **Manifest is the hand-off.** `search -o` writes it; `retrieve -i` reads it. The manifest
  records the query, language, total hits, suggestion, and ranked candidates. `retrieve` honors
  the language the manifest was searched in.
- **Live progress on stdout.** loguru logs to stdout (INFO; `-v` for DEBUG) so progress surfaces
  inline in the agent's tool output. The candidate table is printed plainly for easy scanning.
- **Language.** `--lang` selects the Wikipedia edition (default `en`).

## User-Agent policy

Wikimedia requires a contact in the User-Agent. Set it once via env so every call is compliant:
```bash
export WIKI_USER_AGENT="myproject/1.0 (you@example.com)"
```
Without it the script warns and uses a placeholder UA that may be throttled or blocked. `--user-agent`
overrides per-call.

## Bundled files

- `assets/wiki_fetch.py` — the PEP 723 script; `search` / `retrieve` / `wizard`. Run any command
  with `--help` for its authoritative, always-current options.

## Skill location

This skill may be installed under `.claude/skills/` (Claude) or `.agents/skills/` (other agents).
Reference the bundled script by its path **relative to this SKILL.md** (`assets/wiki_fetch.py`) so
it works regardless of the install root. Retrieved Markdown lands in the *project*, not the skill.
