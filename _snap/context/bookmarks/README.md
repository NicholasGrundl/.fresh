# context/bookmarks — reference knowledge about browser bookmarks

Durable domain reference for the bookmark file format and its risks. Backs parser work and a
future "security & privacy audit" feature (see `features/BACKLOG.md`).

- **`netscape-bookmark-format.md`** — the Netscape/Chrome bookmark export HTML format (nested
  `<DL>`/`<DT>`, `<H3>` folders, `<A HREF>` links, timestamps). What `parser.py` consumes.
- **`file-format-risks.md`** — security risks in the *file structure*: `javascript:` bookmarklets,
  embedded `<script>` tags, `on*` event handlers; deterministic detection patterns.
  *(Relocated from `features/` during Pass-3 triage — it's reference, not a spec.)*
- **`url-security-risks.md`** — sensitive data in *URLs*: API keys/tokens, PII, session ids, magic
  links; keyword + regex + entropy detection patterns.
  *(Relocated from `features/` during Pass-3 triage.)*
