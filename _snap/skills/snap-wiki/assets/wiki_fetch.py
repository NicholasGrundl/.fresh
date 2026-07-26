# wiki_fetch.py
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "typer",
#     "loguru",
#     "nanoid",
#     "wikipedia-api",
# ]
# ///
"""Search Wikipedia from a natural-language query and export pages to Markdown.

Commands:
    search    query -> ranked candidates (prints; writes a JSON manifest only with -o)
    retrieve  exact titles (or a manifest via -i, narrowed by --pick) -> one .md per page
    wizard    interactive search -> select -> retrieve (humans only; needs a TTY)

Examples:
    uv run wiki_fetch.py search "how bacteria resist antibiotics" -n 10
    uv run wiki_fetch.py search "antibiotic resistance" -o refs.json
    uv run wiki_fetch.py retrieve "Antimicrobial resistance" "Beta-lactamase"
    uv run wiki_fetch.py retrieve -i refs.json --pick 1,3
    uv run wiki_fetch.py wizard "antibiotic resistance"
"""

from __future__ import annotations

import html
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

import typer
import wikipediaapi
from loguru import logger
from nanoid import generate
from wikipediaapi import SearchInfo, SearchProp

app = typer.Typer(add_completion=False, help="Search Wikipedia and export pages to Markdown.")

_HASH_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz"

# Wikimedia's User-Agent policy requires a contact. Override via env or --user-agent.
_DEFAULT_UA = "snap-script-wiki_fetch/1.0 (set WIKI_USER_AGENT with contact info)"


def configure_logging(verbose: bool) -> None:
    """Send loguru to stdout so the invoking agent sees live progress."""
    logger.remove()
    logger.add(
        sys.stdout,
        format="<green>{time:HH:mm:ss}</green> | {level: <7} | {message}",
        level="DEBUG" if verbose else "INFO",
    )


def resolve_output_path(path: Path, clobber: bool) -> Path:
    """Non-clobbering output path: insert a short nanoid before the extension if taken."""
    path.parent.mkdir(parents=True, exist_ok=True)
    if clobber or not path.exists():
        return path
    suffix = generate(_HASH_ALPHABET, 6)
    return path.with_name(f"{path.stem}_{suffix}{path.suffix}")


def _slugify(text: str, max_len: int = 60) -> str:
    """Filesystem-clean slug: lowercase, runs of non-alphanumerics collapsed to '_'."""
    slug = re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")
    return slug[:max_len] or "untitled"


def _strip_html(text: str) -> str:
    """Search snippets arrive with <span class="searchmatch"> markup; flatten to plain text."""
    return html.unescape(re.sub(r"<[^>]+>", "", text)).strip()


def _page_url(title: str, lang: str) -> str:
    # Built locally on purpose: page.fullurl triggers a network call, and we'd pay it
    # once per candidate. The canonical URL form is deterministic from title + lang.
    return f"https://{lang}.wikipedia.org/wiki/{quote(title.replace(' ', '_'))}"


def _make_wiki(lang: str, user_agent: str) -> wikipediaapi.Wikipedia:
    if user_agent == _DEFAULT_UA:
        logger.warning(
            "Placeholder User-Agent in use. Set WIKI_USER_AGENT with contact info "
            "(Wikimedia policy) to avoid being throttled or blocked."
        )
    # ExtractFormat.WIKI yields plain-text section bodies (no wikitext markup), which is
    # what we want for Markdown — we supply our own heading levels from the section tree.
    return wikipediaapi.Wikipedia(
        user_agent=user_agent,
        language=lang,
        extract_format=wikipediaapi.ExtractFormat.WIKI,
    )


def _search(
    wiki: wikipediaapi.Wikipedia, query: str, top: int, lang: str
) -> tuple[list[dict], int, str | None]:
    """Run the query. Returns (candidates, totalhits, suggestion).

    `results.pages` is an insertion-ordered dict in MediaWiki relevance order, so
    enumerate() gives us the rank directly. search_meta is already populated from the
    same call — reading it costs no extra requests.
    """
    results = wiki.search(
        query,
        limit=top,
        prop=[SearchProp.SNIPPET, SearchProp.WORDCOUNT],
        info=[SearchInfo.TOTAL_HITS, SearchInfo.SUGGESTION],
    )
    candidates = [
        {
            "rank": rank,
            "title": title,
            "snippet": _strip_html(page.search_meta.snippet or ""),
            "wordcount": page.search_meta.wordcount,
            "url": _page_url(title, lang),
        }
        for rank, (title, page) in enumerate(results.pages.items(), start=1)
    ]
    return candidates, results.totalhits, results.suggestion


def _print_candidates(candidates: list[dict], suggestion: str | None, totalhits: int) -> None:
    if suggestion:
        logger.info(f'Did you mean: "{suggestion}"?')
    logger.info(f"{totalhits} total hits; showing {len(candidates)}")
    for c in candidates:
        # Plain print (not the logger) keeps the table clean for a human to scan/copy.
        print(f"  [{c['rank']:>2}] {c['title']}  ({c['wordcount']} words)")
        if c["snippet"]:
            print(f"       {c['snippet'][:160]}")


def _write_manifest(
    path: Path, query: str, lang: str, candidates: list[dict],
    totalhits: int, suggestion: str | None, clobber: bool,
) -> Path:
    final = resolve_output_path(path, clobber)
    payload = {
        "query": query,
        "lang": lang,
        "totalhits": totalhits,
        "suggestion": suggestion,
        "retrieved": datetime.now(timezone.utc).isoformat(),
        "candidates": candidates,
    }
    final.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
    return final


def _sections_to_md(sections, depth: int, out: list[str]) -> None:
    """Recurse the section tree into Markdown headings.

    The page title is H1, so top-level sections start at H2 and nest from there.
    """
    for s in sections:
        out.append(f"\n{'#' * depth} {s.title}\n")
        if s.text.strip():
            out.append(s.text.strip() + "\n")
        _sections_to_md(s.sections, depth + 1, out)


def _page_to_markdown(page, lang: str) -> str:
    frontmatter = [
        "---",
        f'title: "{page.title}"',
        f"url: {_page_url(page.title, lang)}",
        f"pageid: {page.pageid}",
        f"language: {lang}",
        f"retrieved: {datetime.now(timezone.utc).isoformat()}",
        "---",
        "",
        f"# {page.title}",
        "",
    ]
    body: list[str] = []
    if page.summary.strip():
        body.append(page.summary.strip() + "\n")
    _sections_to_md(page.sections, depth=2, out=body)
    return "\n".join(frontmatter) + "\n".join(body) + "\n"


def _retrieve_one(wiki, title: str, out_dir: Path, lang: str, clobber: bool) -> Path | None:
    page = wiki.page(title)
    if not page.exists():
        logger.error(f"Page not found: {title!r}")
        return None
    md = _page_to_markdown(page, lang)
    # Slug from the canonical title so redirects land on their resolved name.
    final = resolve_output_path(out_dir / f"{_slugify(page.title)}.md", clobber)
    final.write_text(md, encoding="utf-8")
    logger.info(f"Wrote {final}")
    return final


def _parse_pick(spec: str, n: int) -> list[int]:
    """Parse '1,3,5' / '1-4' / '1-3,5' into sorted unique 1-based indices within [1, n]."""
    picked: set[int] = set()
    try:
        for part in (p.strip() for p in spec.split(",")):
            if not part:
                continue
            if "-" in part:
                lo, hi = (int(x) for x in part.split("-", 1))
                picked.update(range(lo, hi + 1))
            else:
                picked.add(int(part))
    except ValueError:
        raise typer.BadParameter(f"Could not parse selection: {spec!r}")
    valid = sorted(i for i in picked if 1 <= i <= n)
    if not valid:
        raise typer.BadParameter(f"Selection picked nothing in range 1..{n}")
    return valid


@app.command()
def search(
    query: str = typer.Argument(..., help="Natural-language search string."),
    top: int = typer.Option(10, "--top", "-n", help="Number of candidates to keep."),
    lang: str = typer.Option("en", "--lang", help="Wikipedia language edition."),
    output: Path = typer.Option(
        None, "--output", "-o",
        help="Write a JSON manifest here. A directory (or '.') auto-names "
             "<slug>_search.json inside it; otherwise the path is used verbatim. "
             "Omit to print only.",
    ),
    user_agent: str = typer.Option(
        _DEFAULT_UA, "--user-agent", envvar="WIKI_USER_AGENT", help="Contact UA (Wikimedia policy)."
    ),
    clobber: bool = typer.Option(False, "--clobber", help="Overwrite an existing manifest."),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Enable DEBUG logging."),
) -> None:
    """Resolve a query to ranked candidate pages and print them.

    Prints a ranked table to stdout and writes nothing unless -o/--output is given.
    The printed list is enough to pick a title and call `retrieve` directly; export
    is only for when you want a manifest to feed `retrieve -i`.
    """
    configure_logging(verbose)
    wiki = _make_wiki(lang, user_agent)
    logger.info(f"Searching {lang}.wikipedia for: {query!r}")
    candidates, totalhits, suggestion = _search(wiki, query, top, lang)
    if not candidates:
        logger.warning("No results.")
        raise typer.Exit(code=0)
    _print_candidates(candidates, suggestion, totalhits)

    # Export only when -o is given. A directory target gets an auto-derived filename;
    # anything else is treated as the exact file path.
    if output is not None:
        out_path = output / f"{_slugify(query)}_search.json" if output.is_dir() else output
        final = _write_manifest(out_path, query, lang, candidates, totalhits, suggestion, clobber)
        logger.info(f"Wrote manifest {final}")


@app.command()
def retrieve(
    titles: list[str] = typer.Argument(None, help="Exact page titles (as printed by `search`)."),
    input_path: Path = typer.Option(
        None, "--input", "-i",
        help="Read titles from a search manifest (the JSON written by `search -o`). "
             "Narrow with --pick. This is the input mirror of search's -o.",
    ),
    pick: str = typer.Option(None, "--pick", help='Manifest indices, e.g. "1,3,5" or "1-4". Omit = all.'),
    output: Path = typer.Option(Path("."), "--output", "-o", help="Output directory for .md files."),
    lang: str = typer.Option("en", "--lang", help="Wikipedia language edition."),
    user_agent: str = typer.Option(
        _DEFAULT_UA, "--user-agent", envvar="WIKI_USER_AGENT", help="Contact UA (Wikimedia policy)."
    ),
    clobber: bool = typer.Option(False, "--clobber", help="Overwrite existing .md files."),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Enable DEBUG logging."),
) -> None:
    """Fetch full pages and export one Markdown file per page.

    Provide titles directly, or read them from a search manifest with -i/--input
    (optionally narrowed by --pick). -i is the input mirror of search's -o.
    """
    configure_logging(verbose)

    chosen: list[str] = list(titles or [])
    if input_path is not None:
        if not input_path.exists():
            logger.error(f"Manifest not found: {input_path}")
            raise typer.Exit(code=1)
        data = json.loads(input_path.read_text(encoding="utf-8"))
        cands = data.get("candidates", [])
        lang = data.get("lang", lang)  # honor the language the manifest was searched in
        idxs = _parse_pick(pick, len(cands)) if pick else list(range(1, len(cands) + 1))
        chosen.extend(cands[i - 1]["title"] for i in idxs)

    if not chosen:
        logger.error("No titles to fetch. Pass titles, or -i/--input MANIFEST [--pick].")
        raise typer.Exit(code=1)

    wiki = _make_wiki(lang, user_agent)
    written = sum(_retrieve_one(wiki, t, output, lang, clobber) is not None for t in chosen)
    logger.info(f"Done: {written}/{len(chosen)} page(s) written under {output}/")
    if written == 0:
        raise typer.Exit(code=1)


@app.command()
def wizard(
    query: str = typer.Argument(..., help="Natural-language search string."),
    top: int = typer.Option(10, "--top", "-n", help="Number of candidates to show."),
    output: Path = typer.Option(Path("."), "--output", "-o", help="Output directory for .md files."),
    lang: str = typer.Option("en", "--lang", help="Wikipedia language edition."),
    user_agent: str = typer.Option(
        _DEFAULT_UA, "--user-agent", envvar="WIKI_USER_AGENT", help="Contact UA (Wikimedia policy)."
    ),
    clobber: bool = typer.Option(False, "--clobber", help="Overwrite existing .md files."),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Enable DEBUG logging."),
) -> None:
    """Interactive: search, pick from the results, then retrieve. Needs a TTY (humans only)."""
    configure_logging(verbose)
    # An agent can't answer a prompt and would hang here — fail fast and redirect.
    if not sys.stdin.isatty():
        logger.error("wizard needs an interactive terminal. Use `search` then `retrieve` for scripted runs.")
        raise typer.Exit(code=1)

    wiki = _make_wiki(lang, user_agent)
    logger.info(f"Searching {lang}.wikipedia for: {query!r}")
    candidates, totalhits, suggestion = _search(wiki, query, top, lang)
    if not candidates:
        logger.warning("No results.")
        raise typer.Exit(code=0)
    _print_candidates(candidates, suggestion, totalhits)

    raw = typer.prompt('Select page(s) to retrieve (e.g. "1" or "1,3,5" or "1-4")')
    idxs = _parse_pick(raw, len(candidates))
    written = sum(
        _retrieve_one(wiki, candidates[i - 1]["title"], output, lang, clobber) is not None
        for i in idxs
    )
    logger.info(f"Done: {written}/{len(idxs)} page(s) written under {output}/")


if __name__ == "__main__":
    app()