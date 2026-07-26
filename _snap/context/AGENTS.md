# `context/` — External Reference Material

One **subfolder per topic** (library, API, service, tool) holding markdown reference docs —
e.g. `uv/`, `ty/`, `ruff/`, `playwright/`, `pytest/`, `firecrawl/`, `agent-skills/`.

## How to use

- **Search subfolder *names* first.** The directory names are descriptive — scan them before
  reading any contents. Only open files once you know the topic is relevant.
- **Don't bulk-read** `context/` proactively during planning or implementation. Pull a specific
  doc in only when you're about to work with that library/API and need its real surface.

## Adding context

If a topic is missing, ask the user before creating it, then populate the new subfolder from
authoritative sources. Good starting point for curated LLM-friendly docs:
<https://directory.llmstxt.cloud/>

Keep each topic self-contained; prefer a short `README.md` in the subfolder summarizing what's
there and where it came from (source URL).
