Perfect. With those merges, here’s the revised document map:

---

## 00-README.md (Overview & Decision)

* **Description:** The front page: why Ollama + OpenCode, audience, and outcomes.
* **Source lines:** Exec summary, “Why Ollama / When to use alternatives.”
* **Sections:**

  * Purpose & Audience
  * Our Decision (Ollama + Qwen2.5-Coder 14B)
  * When to use alternatives
  * What you’ll build
  * Repo map

---

## 01-system-requirements.md

* **Description:** Machine profile, GPU capability notes, sizing heuristics.
* **Source lines:** Hardware, GPU, model size heuristics.
* **Sections:**

  * Supported OS & WSL notes
  * CPU/RAM/GPU baseline
  * CUDA/driver requirements
  * Model size & quantization heuristics
  * Rules of thumb

---

## 02-prerequisites.md

* **Description:** Pre-flight checks before installing.
* **Source lines:** WSL GPU passthrough, Node.js checks.
* **Sections:**

  * Verify GPU passthrough
  * Fixing missing drivers/CUDA in WSL
  * Verify / Install Node.js

---

## 03-install-and-run-ollama.md

*(merged old 03 + 06)*

* **Description:** End-to-end Ollama: install, start server, pull models, run smoke tests.
* **Source lines:** Install (script/systemd), starting server, curl check, pull & run model, smoke test prompts, GPU monitoring callouts.
* **Sections:**

  * Install Ollama (script/manual)
  * Service management (systemd vs manual)
  * Confirm API is live
  * Pull Qwen2.5-Coder 14B
  * First prompts with `ollama run`
  * API smoke tests with curl/Python
  * Monitoring GPU/CPU/RAM during runs
  * Smoke test checklist

---

## 04-install-and-configure-opencode.md

*(merged old 04 + 05)*

* **Description:** Install OpenCode CLI and connect it to Ollama’s OpenAI-compatible API.
* **Source lines:** npm install, version check, CLI config steps, config.json example.
* **Sections:**

  * Install CLI
  * Verify installation
  * Configure provider & endpoint
  * Confirm config with `opencode config show`
  * Manual config.json example
  * Selecting models inside OpenCode

---

## 05-monitoring-and-debugging.md

* **Description:** Real-time monitoring and debugging workflow.
* **Source lines:** `nvidia-smi`, logs, verbose flags, troubleshooting GPU fallback.
* **Sections:**

  * GPU monitoring tools & interpretation
  * CPU/RAM monitoring
  * Process checks (`ollama ps`)
  * Logs (journalctl, verbose mode)
  * Common symptoms → causes

---

## 06-models-and-use-cases.md

* **Description:** Model selection, multi-model workflows, comparison matrix.
* **Source lines:** Coding models, alternatives (DeepSeek, 7B), multi-model workflows, comparison table.
* **Sections:**

  * Choosing models for tasks
  * Multi-model strategy & VRAM mgmt
  * Comparison matrix
  * Prompt tuning & temp/token guidance

---

## 07-quick-reference.md

* **Description:** Cheat-sheet of Ollama + OpenCode + monitoring commands.
* **Source lines:** Ollama commands, OpenCode CLI, GPU watch one-liners.
* **Sections:**

  * Ollama command reference
  * OpenCode CLI reference
  * Monitoring one-liners

---

## 08-troubleshooting.md

* **Description:** Common issues and a decision tree for resolution.
* **Source lines:** Issues table, CPU fallback, OOM, decision tree.
* **Sections:**

  * Quick triage checklist
  * Symptoms → fixes table
  * Decision tree

---

## 09-advanced-configuration.md

* **Description:** Env vars and expert toggles (safe vs “verify”).
* **Source lines:** Env var list, ~/.bashrc snippet.
* **Sections:**

  * Official supported vars (HOST, MODELS, KEEP_ALIVE, etc.)
  * Per-GPU selection
  * Experimental vars (verify/remove)
  * CORS & remote access

---

## 10-performance-and-benchmarks.md

* **Description:** Throughput, VRAM, latency, thermal notes.
* **Source lines:** Power/thermal, perf tables.
* **Sections:**

  * Measurement methodology
  * Power & temps
  * Tokens/sec by model
  * Interpreting first-token vs steady-state

---

## 11-integration-examples.md

* **Description:** Practical workflows: code review, debugging, docs, modernization.
* **Source lines:** Auto-docs, onboarding flows, troubleshooting sessions, test gen, legacy upgrades, DS pipelines.
* **Sections:**

  * Code review & PR assist
  * Debugging sessions
  * Test generation
  * Doc automation
  * Legacy → modern migration
  * Data science helpers

---

Do you want me to **spin up the skeleton folder structure with all these filenames and section headers prefilled in Markdown** so you can start filling them in, or just keep this as a planning map?
