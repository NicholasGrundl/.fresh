# Running Local LLMs with Ollama + OpenCode CLI (verified)

## Executive Summary (kept)

* **Choice**: Ollama + **qwen2.5-coder:14b**. Pull-and-go, OpenAI-compatible endpoint, simple model mgmt. ([Ollama][1])
* **Why 14B for coding**: strong code models, VRAM fits your 16 GB GPU with 4-bit quant. Model exists in Ollama library. ([Ollama][2])

---

## System & Model Sizing Notes (light edits)

Your specs suggest:

* **14B @ Q4_K_M**: fits cleanly; **32B** will page into unified memory and slow down (still fine for experiments).
* Ollama uses **llama.cpp** under the hood and exposes an **OpenAI-compatible** API at `http://localhost:11434/v1`. API key is required-but-ignored (use any string). ([Ollama][1])

> Tip: Quantization *variant tags* (e.g., `:q4_K_M`) are model-package-specific. Many Ollama models publish those variants; if a tag 404s, the package may only ship one default build. Use `ollama show modelname` to see what’s available.

---

## Installation & Environment

### 0) Windows/WSL2 GPU sanity checks (WSL Ubuntu)

```bash
# Inside WSL Ubuntu
nvidia-smi          # must show RTX A5500 and driver
```

If `nvidia-smi` fails in WSL, (a) install/update the NVIDIA *Windows* driver for WSL, then (b) install CUDA userspace in WSL (optional but handy for tooling). ([Ollama][3])

**systemd in WSL**
Ollama’s Linux installer sets up a `systemd` service. On WSL you should enable systemd first:

```
sudo nano /etc/wsl.conf
# add:
[boot]
systemd=true
```

Then in **PowerShell (Windows)**:

```
wsl --shutdown
```

Reopen Ubuntu and confirm `systemctl` works. ([Microsoft Learn][4])

### 1) Install Ollama (Linux/WSL)

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

This installs Ollama and starts a `systemd` service (`ollama.service`). View status/logs:

```bash
systemctl status ollama
journalctl -e -u ollama
```

(If you prefer user-level service: see community snippet for `systemctl --user`.) ([Ollama][3])

**If systemd on WSL gives you trouble**: run foreground server in a tmux/screen:

```bash
ollama serve
```

### 2) Install Node.js (for OpenCode)

Use your preferred method; e.g., Node 20 via `nvm`:

```bash
# quick nvm path (if you use it)
# https://github.com/nvm-sh/nvm
```

(Any recent Node 18+ is fine for OpenCode CLI.)

### 3) Install OpenCode CLI

```bash
npm install -g opencode
opencode --version
```

Docs/reference for commands live here. ([opencode.ai][5])

---

## Pulling & Testing the Model (Ollama)

### 1) Start server (only if not using systemd)

```bash
ollama serve
```

### 2) Pull Qwen Coder 14B

```bash
ollama pull qwen2.5-coder:14b
```

(Other sizes: `:7b`, `:32b`, etc.) ([Ollama][2])

### 3) Local smoke tests

```bash
# Direct chat (REPL)
ollama run qwen2.5-coder:14b
# say: "Write a Python function to parse ISO8601 timestamps."
```

OpenAI-compatible endpoint test:

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
        "model": "qwen2.5-coder:14b",
        "messages": [{"role": "user", "content": "Say this is a test"}]
      }'
```

The OpenAI-compat base URL is `http://localhost:11434/v1`, API key can be any string. ([Ollama][1])

### Monitoring GPU / CPU / RAM While Testing

When you run `ollama run` or make API calls, it’s useful to watch how the model loads and executes on your system. Here are recommended commands:

**GPU usage (VRAM + load):**

```bash
# Shows real-time GPU processes, VRAM usage, and power draw
watch -n 1 nvidia-smi
```

* Check that your RTX A5500 process (`ollama` or `ollama run`) is listed.
* Look for **Memory-Usage** (VRAM) and **GPU-Util** (% load).
* During warm-up, VRAM jumps as layers load; during generation, GPU utilization should spike.

**CPU & RAM usage:**

```bash
# General system monitor (press q to quit)
htop

# or Ubuntu default
top
```

* Look for the `ollama` process. CPU usage will rise if layers spill to CPU (e.g., with models larger than your VRAM).
* Memory (RES) shows RAM use; large models (e.g., 32B) can use 20–40 GB of system RAM via unified memory.

**Combined view with GPU:**

```bash
htop       # CPU & RAM
watch -n 1 nvidia-smi  # GPU
```

Keep both side by side in different terminals or a tmux split.

**Optional: disk/network I/O**

```bash
iotop   # Disk read/write (model caching)
iftop   # Network usage (not usually needed; models are local)
```

**Rules of thumb while testing:**

* If `nvidia-smi` shows **0% GPU utilization** but CPU is pegged → Ollama fell back to CPU (usually a driver/systemd/WSL config issue).
* If RAM usage is very high (>30 GB for 32B models) → you’re in **unified memory mode**, which is slower but expected.
* A healthy 14B Q4_K_M run on your GPU should sit around ~9 GB VRAM, ~60–80 tokens/sec.


---

## Configure OpenCode to use Ollama

OpenCode supports “providers”. For Ollama, we use the **OpenAI-compatible** provider with a custom `baseURL`.

Create **`opencode.json`** in your project (or where you run `opencode`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1",
        "apiKey": "ollama"   // required by many clients; ignored by Ollama
      },
      "models": {
        "qwen2.5-coder:14b": {
          "name": "Qwen2.5 Coder 14B (local)"
        }
      }
    }
  }
}
```

This is the **official pattern** for OpenCode’s providers and shows the **Ollama** example and `baseURL` you need. ([opencode.ai][7])

> Where do creds live? If you add real providers later (`opencode auth login`), keys are stored under `~/.local/share/opencode/auth.json`. For Ollama, `apiKey` can stay as “ollama”. ([opencode.ai][7])

---

## Using OpenCode with your local model

1. Launch the TUI:

```bash
opencode
```

2. Inside OpenCode, select your model:

* Run `/models` → choose **Ollama (local)** → **Qwen2.5 Coder 14B (local)**.
  (Provider UI and baseURL behavior are documented; OpenCode treats any OpenAI-compatible backend the same.) ([opencode.ai][7])

3. Try coding actions:

* Prompt: “Write a Bash one-liner that finds all `.py` files >1 MB and prints sizes sorted descending.”
* Use tools if you configure them; note that **tool/function calling over OpenAI-compat** can vary by model and is still maturing on Ollama—there are active threads about it. ([GitHub][8])

---

## Verifying Everything (checklist)

* [ ] `nvidia-smi` in WSL shows your GPU and a reasonable driver. ([Ollama][3])
* [ ] `systemctl status ollama` shows **active (running)** (or `ollama serve` is running). ([Ollama][3])
* [ ] `ollama run qwen2.5-coder:14b` responds quickly (first token may be slower as it warms). ([Ollama][2])
* [ ] `curl http://localhost:11434/v1/chat/completions ...` returns JSON content. Base URL is **/v1**. ([Ollama][1])
* [ ] `opencode` → `/models` shows **Ollama (local)** and you can select **Qwen2.5 Coder 14B**. ([opencode.ai][7])

---

## Useful extras & troubleshooting

* **Change model download path** (e.g., to a faster SSD):
  Add to the Ollama service **Environment**: `OLLAMA_MODELS=/your/dir` (via systemd drop-in), then `systemctl daemon-reload && systemctl restart ollama`. ([Ollama][9])

* **Expose Ollama over LAN** (optional): Set `OLLAMA_HOST=0.0.0.0:11434` in the service env and restart. Be mindful of network exposure. ([Ollama][9])

* **Pin Ollama version**:

  ```bash
  curl -fsSL https://ollama.com/install.sh | OLLAMA_VERSION=0.5.7 sh
  ```

  (Example version.) ([Ollama][3])

* **WSL systemd won’t start**: Re-check `/etc/wsl.conf`, ensure **WSL ≥ 0.67.6**, then `wsl --shutdown` and relaunch. ([Microsoft Learn][10])

---

## One-liner “it works” demo

**Ollama only**

```bash
ollama run qwen2.5-coder:14b -p "Write a Python function fizz_buzz(n) with tests."
```

**OpenAI-compat endpoint**

```bash
python - <<'PY'
from openai import OpenAI
c = OpenAI(base_url="http://localhost:11434/v1", api_key="ollama")
r = c.chat.completions.create(model="qwen2.5-coder:14b",
    messages=[{"role":"user","content":"Return a POSIX find command to list .py files >1MB."}])
print(r.choices[0].message.content)
PY
```

(Directly mirrors the docs’ pattern.) ([Ollama][11])


---

[1]: https://ollama.com/blog/openai-compatibility "OpenAI compatibility · Ollama Blog"
[2]: https://ollama.com/library/qwen2.5-coder "qwen2.5-coder"
[3]: https://docs.ollama.com/linux?utm_source=chatgpt.com "Linux"
[4]: https://learn.microsoft.com/en-us/windows/wsl/systemd?utm_source=chatgpt.com "Use systemd to manage Linux services with WSL"
[5]: https://opencode.ai/docs/cli/?utm_source=chatgpt.com "CLI"
[6]: https://piers.rocks/2024/02/25/ollama-wsl2-nvidia-docker.html?utm_source=chatgpt.com "Running ollama laptop with NVIDIA GPU, within WSL2, ..."
[7]: https://opencode.ai/docs/providers/ "Providers | opencode"
[8]: https://github.com/sst/opencode/issues/1068?utm_source=chatgpt.com "Tool use with Ollama models. #1068 - sst/opencode"
[9]: https://docs.ollama.com/faq?utm_source=chatgpt.com "FAQ"
[10]: https://learn.microsoft.com/en-us/windows/wsl/wsl-config?utm_source=chatgpt.com "Advanced settings configuration in WSL"
[11]: https://docs.ollama.com/openai "OpenAI compatibility - Ollama"
