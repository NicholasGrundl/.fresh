# Miniconda - Lightweight Python Environment Manager

Miniconda is a minimal installer for conda, providing a base Python installation and the conda package manager. It's ideal for creating a general-purpose Python environment for exploration, data analysis, and interactive work.

## Why Miniconda?

- **System-wide base environment**: A go-to Python setup for general exploration
- **Interactive work**: Perfect for Jupyter notebooks and data analysis
- **Complementary to UV**: Use conda for exploration, UV for project-specific work
- **Package availability**: Access to both conda and pip packages
- **Environment management**: Create isolated environments for different purposes

## Miniconda vs UV: When to Use Each

### Use Miniconda Base Environment For:
- **Exploratory data analysis**: Quick experiments and one-off analyses
- **Jupyter notebooks**: Interactive development and visualization
- **Learning and prototyping**: Testing ideas without project setup
- **General Python shell**: Ad-hoc scripting and command-line work

### Use UV For:
- **Project-specific dependencies**: Isolated, reproducible project environments
- **Production code**: Applications with defined dependency requirements
- **Team collaboration**: Shared requirements.txt and pyproject.toml files
- **Fast iteration**: Quick package installs and updates

### Can You Mix Them?
**Yes!** You can use `uv pip install` inside an activated conda environment. This gives you:
- Conda's environment isolation
- UV's fast package installation
- Best of both worlds for complex workflows

## Installation

### 1. Download and Install Miniconda

Visit the official Miniconda page and follow the installation instructions for macOS:

**Official Installation Guide**: https://www.anaconda.com/docs/getting-started/miniconda/install#macos-2

**Quick Download** (check website for latest version):
Download and install the latest miniconda (intel macos) with these commands:
```bash
mkdir -p ~/miniconda3
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
```

After installing, close and reopen your terminal application or refresh it by running the following command:
```bash
source ~/miniconda3/bin/activate
```

Then, initialize conda on all available shells by running the following command:
```bash
conda init --all
```


**Default installation location**: `~/miniconda3`


### 2. Verify Installation

```bash
# Reload your shell
source ~/.bash_profile

# Test conda (using full path since we didn't auto-initialize)
~/miniconda3/bin/conda --version
```

## Manual Activation Setup

Since we chose not to auto-initialize conda, we need to set it up for manual activation.

### One-Time Setup

Run this once to enable conda for your shell:

```bash
~/miniconda3/bin/conda init bash
```

This will add initialization code to your `.bashrc` (it will be commented out in our config).

### Activate Base Environment

Whenever you want to use conda:

```bash
# Activate the base environment
conda activate base

# Your prompt will now show (base)
# You now have access to all base environment packages
```

### Deactivate

When you're done:

```bash
conda deactivate
```

## Setting Up the Base Environment

Once conda is installed and you can activate it, set up your base environment with essential packages.

### Recommended Base Environment Packages

```bash
# Activate base environment
conda activate base

# Install core data science packages
pip install pandas numpy scipy

# Install visualization packages
pip install matplotlib seaborn

# Install JupyterLab
pip install jupyterlab

# Install networking
pip install requests

# Install LLM SDK packages (use pip for these)
pip install openai anthropic google-generativeai
```

### Verify Installation

```bash
# Check installed packages
pip list

# Test imports in Python
python 
import pandas
```

## Basic Usage

### Working with the Base Environment

```bash
# Activate when you need it
conda activate base

# Start JupyterLab for interactive work
jupyter lab

# Run Python scripts
python my_script.py

# Use IPython for interactive Python
ipython

# Deactivate when done
conda deactivate
```

### Creating Additional Environments

While we focus on the base environment, you can create specialized environments:

```bash
# Create a new environment for a specific Python version
conda create -n myproject python=3.11

# Activate it
conda activate myproject

# Install packages
conda install pandas jupyter

# List all environments
conda env list

# Remove an environment
conda env remove -n myproject
```

## Common Workflows

### Quick Data Exploration

```bash
# Activate conda
conda activate base

# Start JupyterLab
jupyter lab

# Work in notebooks with all packages available
# When done, just close JupyterLab and deactivate
conda deactivate
```

### LLM Development and Testing

```bash
# Activate base environment with LLM SDKs
conda activate base

# Test OpenAI API
python
>>> import openai
>>> # Your code here

# Test Anthropic API
>>> import anthropic
>>> # Your code here

# Test Google Gemini
>>> from google import generativeai as genai
>>> # Your code here
```

### Quick Script with Multiple Libraries

```bash
# Activate base
conda activate base

# Run your script (has access to all base packages)
python analysis.py

# Done
conda deactivate
```

### Using UV Inside Conda (Advanced)

```bash
# Activate conda environment
conda activate base

# Use UV for fast package installation
uv pip install some-package

# Package is installed in the conda environment
# Benefits: UV speed + Conda environment isolation
```

## Integration with Projects

### Project-Based Work (Use UV)

For projects with defined requirements:

```bash
# DON'T activate conda
cd ~/projects/my-project

# Use UV for project setup
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt

# Work on project...

deactivate
```

### Exploration Then Project Migration

```bash
# 1. Explore in conda
conda activate base
jupyter lab
# ... experiment with packages ...
# ... figure out what you need ...
conda deactivate

# 2. Create proper project with UV
cd ~/projects/new-project
uv init
uv venv
source .venv/bin/activate
uv add pandas numpy matplotlib  # Add what you determined you need

# 3. Continue with UV-managed project
```

## Updating and Maintenance

### Update Conda

```bash
conda activate base
conda update conda
```

### Update All Packages in Base

```bash
conda activate base
conda update --all
```

### Update Specific Package

```bash
conda activate base
conda update pandas
```

### Clean Up

```bash
# Remove unused packages and caches
conda clean --all
```



## Configuration

### Set conda to not auto-activate base

This is already the default in our setup, but if conda auto-activates:

```bash
conda config --set auto_activate_base false
```

### Useful conda settings

```bash
# Show channel URLs when listing packages
conda config --set show_channel_urls true

# Always use strict channel priority
conda config --set channel_priority strict
```

## When NOT to Use Conda

- **Lightweight projects**: Just use UV with a venv
- **Production deployments**: Use UV with locked requirements
- **CI/CD pipelines**: UV is faster and more reproducible
- **Docker containers**: Prefer UV for smaller image sizes
- **Team projects**: UV + requirements.txt is more standard

## See Also

- [Official Conda Documentation](https://docs.conda.io/)
- [Miniconda Installation Guide](https://docs.conda.io/en/latest/miniconda.html)
- [UV Setup](../uv/) - Project-based Python package management
- [Bash Setup](../bash/) - Shell configuration (conda activation notes)
- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)
- [OpenAI Python SDK](https://github.com/openai/openai-python)
- [Anthropic Python SDK](https://github.com/anthropics/anthropic-sdk-python)
- [Google Generative AI Python SDK](https://github.com/google/generative-ai-python)
