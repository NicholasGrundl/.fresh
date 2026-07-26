# Anthropic Python SDK — context

**Source:** `python_sdk.md` — the official Anthropic Python SDK page (user-staged 2026-06-02),
covering SDK install/config and usage. Pulled for the Bookmark MVP LLM stages (Tasks 7–8).

## What `python_sdk.md` covers (sufficient for build)

- Client construction: `Anthropic()` / `AsyncAnthropic()`; reads `ANTHROPIC_API_KEY` from env;
  `.close()` / context-manager lifecycle.
- Messages API basics: `client.messages.create(model=, max_tokens=, messages=[...])` → `.content`.
- Token/cost logging: `message.usage` → `input_tokens` / `output_tokens`.
- Robustness: built-in retries (2×, exp backoff on 429/5xx/timeout/conn), `max_retries`,
  `timeout`; error hierarchy (`RateLimitError`, `APITimeoutError`, `APIStatusError`, …).
  → Lean on the SDK's own retries; add `tenacity` only if a real gap surfaces.
- Batches API (`client.messages.batches`) — post-MVP cost lever (non-goal now).
- Type system: responses are Pydantic models (`.to_dict()`/`.to_json()`).

## Gaps NOT covered here (close at Task 7)

The staged doc does **not** cover the two patterns the spec relies on:

1. **Forced tool-use / structured output** — only the high-level `@beta_tool` + `tool_runner`
   (auto agent loop) is shown, not the manual `tools=[{name, input_schema}]` +
   `tool_choice={"type":"tool","name":…}` → read the `tool_use` block's `.input` pattern that
   yields `{summary, descriptive_name}` in one call.
2. **Prompt caching** — not mentioned; spec needs `cache_control: {"type":"ephemeral"}` on the
   shared system prompt.
3. Model catalog/pricing — minor; default `claude-sonnet-4-6` is locked in `config.py`.

**Decision (2026-06-02, Task 3):** close gaps 1–2 by invoking the in-harness **`claude-api`
skill** when writing `tools/llm.py` in Task 7 — it is purpose-built and always current, so no
web docs were staged here.
