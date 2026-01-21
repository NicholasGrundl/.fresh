# 🏗️ Reorganization Plan: The Lifecycle Model (Refined)

## 📂 1. Bootstrap (Setup Scripts)
*Goal: Scripts run once to provision a machine.*

- [ ] **Linux Setup**
    - `linux/scripts/setup_environment.sh` -> `bootstrap/linux/setup.sh`
    - `linux/scripts/required_packages.txt` -> `bootstrap/linux/packages.txt`
- [ ] **Windows Setup**
    - `windows/install_dependencies.ps1` -> `bootstrap/windows/install.ps1`
    - `windows/uninstall_dependencies.ps1` -> `bootstrap/windows/uninstall.ps1`
- [ ] **MacOS Setup**
    - `macos/PLACEHOLDER_FRESH_INSTALL.md` -> `bootstrap/macos/README.md`
- [ ] **Common**
    - `linux/scripts/check_environment.sh` -> `bootstrap/common/check_health.sh`

## ⚙️ 2. Core (Runtime Configs)
*Goal: Configs loaded by the environment.*

- [ ] **Bash** (`core/bash/`)
    - `linux/bash/.bash_custom_functions` -> `core/bash/.bash_custom_functions` (Preserve Name)
    - `shell/.bashrc` -> `core/bash/.bashrc` (Main entry point)
    - `shell/.profile` -> `core/bash/.profile`
    - **OS Variants:**
        - `linux/bash/.bashrc` -> `core/bash/.bashrc.linux`
        - `macos/bash/.bashrc` -> `core/bash/.bashrc.macos`
        - `macos/bash/.bash_profile` -> `core/bash/.bash_profile.macos`
- [ ] **PowerShell** (`core/powershell/`)
    - `windows/profile.ps1` -> `core/powershell/profile.ps1`
    - `windows/DiagnosticFunctions.ps1` -> `core/powershell/DiagnosticFunctions.ps1`
    - `windows/EnvFunctions.ps1` -> `core/powershell/EnvFunctions.ps1`
    - `windows/SSHFunctions.ps1` -> `core/powershell/SSHFunctions.ps1`
- [ ] **Git** (`core/git/`)
    - `tools/git/.gitconfig` -> `core/git/.gitconfig`
    - `.gitignore_global` -> `core/git/.gitignore_global`
- [ ] **Starship** (`core/starship/`)
    - `starship/*.toml` -> `core/starship/`
- [ ] **VS Code** (`core/vscode/`)
    - `tools/editors/settings.json` -> `core/vscode/settings.json`
- [ ] **Jupyter** (`core/jupyter/`)
    - `tools/editors/jupyter_lab_config.py` -> `core/jupyter/jupyter_lab_config.py`
- [ ] **Python Ecosystem**
    - `tools/conda/.condarc` -> `core/python/.condarc`
    - `core/uv/` (New directory for future UV configs)
- [ ] **Envs** (`core/envs/`)
    - `templates/nvm-uv/.env.example` -> `core/envs/.env.example.generic`

## 📚 3. Library (On-Demand Resources)
*Goal: Templates, reference docs, and AI prompts.*

- [ ] **AI** (`library/ai/`)
    - `ai/docs/*` -> `library/ai/docs/`
    - `ai/ollama-opencode/*` -> `library/ai/ollama/`
- [ ] **Templates** (`library/templates/`)
    - `templates/python` -> `library/templates/python`
    - `templates/nvm-uv` -> `library/templates/node`
- [ ] **Documentation** (`library/docs/`)
    - `macos/*.md` -> `library/docs/macos/`
    - `windows/*.md` -> `library/docs/windows/`

## 🗑️ 4. Cleanup
- [ ] Remove `+archive`, `tools`, `linux`, `macos`, `windows`, `shell`, `ai`, `agentic_coding`.