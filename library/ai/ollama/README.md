# AI Development: Ollama + OpenCode

Complete setup for local AI development using Ollama (local model server) and OpenCode (AI coding assistant). This enables you to run powerful coding models locally without relying on cloud services.

## Quick Start

### 1. Install and Start Ollama

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama server (keep this running in background)
ollama serve
```

### 2. Download a Coding Model

In a **new terminal**:

```bash
# Download a coding model (start with 7B for testing)
ollama pull qwen2.5-coder:7b

# Or download larger 14B model (more capable)
ollama pull qwen2.5-coder:14b

# List available models
ollama list
```

### 3. Install OpenCode

```bash
# Install OpenCode
curl -fsSL https://opencode.ai/install | bash

# Or using npm
npm install -g opencode-ai
```

### 4. Start Using

```bash
# Copy this config to your project
cp opencode.json /path/to/your/project/

# Start OpenCode in your project directory
cd /path/to/your/project
opencode

# In OpenCode, run:
/models
# Select your Ollama model from the list
```

## Configuration

The `opencode.json` file in this directory configures OpenCode to use your local Ollama server:

- **Provider:** Uses OpenAI-compatible API to connect to Ollama
- **Endpoint:** `http://localhost:11434/v1` (default Ollama server)
- **Models:** Pre-configured for Qwen2.5-Coder models

## Usage Examples

### Basic AI Coding Assistance

```bash
# Start OpenCode
opencode

# Ask questions about your codebase
"How does authentication work in @src/auth.py?"

# Request new features
"Add a user deletion feature with soft delete and recovery screen"

# Get code explanations
"Explain what this function does in @utils/helpers.py"
```

### Model Management

```bash
# Download additional models
ollama pull codellama:7b
ollama pull deepseek-coder:6.7b

# Remove unused models
ollama rm qwen2.5-coder:7b

# Check model status
ollama ps
```

## Troubleshooting

### "Unable to connect" Error

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Restart Ollama if needed
pkill ollama && ollama serve
```

### Memory Issues

- Use smaller models (7B) on systems with <32GB RAM
- Close other applications when running large models
- Restart Ollama if you encounter memory issues

### Performance Tips

- **GPU Usage:** Ollama automatically detects and uses NVIDIA GPUs
- **Model Selection:** 7B models are fast, 14B models are more capable
- **System Resources:** Ensure adequate RAM for larger models

## Configuration Files

- **Ollama Config:** `~/.ollama/config`
- **OpenCode Config:** `./opencode.json` (project-specific)
- **Models Location:** `~/.ollama/models/`

## Alternative Setup Methods

### Docker Ollama

```bash
# Run Ollama in Docker
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama

# Pull models
docker exec -it ollama ollama pull qwen2.5-coder:7b
```

### Using OpenCode Connect Command

```bash
opencode
# Run: /connect
# Select "Other"
# Enter provider ID: "ollama"
# Enter API key: "sk-dummy" (any key works for local)
# Then use the opencode.json config from this directory
```