# Playwright Installation Guide

## System Requirements

### Python Version
- **Minimum**: Python 3.8 or higher
- **Recommended**: Python 3.10+ for best performance and features

### Operating System Support

| OS | Supported Versions | Architectures |
|----|-------------------|---------------|
| **Windows** | Windows 11+, Windows Server 2019+ | x86-64 |
| **macOS** | macOS 14 (Ventura) or later | x86-64, arm64 (Apple Silicon) |
| **Linux** | Debian 12/13, Ubuntu 22.04/24.04 | x86-64, arm64 |

Note: Other Linux distributions may work but are not officially supported.

### Disk Space
- Approximately 1.5-2 GB for browser binaries (all three browsers)
- Each browser requires 400-700 MB

## Installation Methods

### Method 1: pip (Recommended)

#### Basic Installation
```bash
# Install Playwright library
pip install playwright

# Download browser binaries
playwright install
```

#### Install Specific Browsers
```bash
# Install only Chromium
playwright install chromium

# Install Chromium and Firefox
playwright install chromium firefox

# Install all browsers explicitly
playwright install chromium firefox webkit
```

#### Install with Testing Plugin
```bash
# Install with pytest plugin
pip install pytest-playwright

# Download browsers
playwright install
```

### Method 2: Anaconda/Conda

#### Setup Conda Channels
```bash
# Add required channels
conda config --add channels conda-forge
conda config --add channels microsoft
```

#### Install Package
```bash
# Install Playwright
conda install playwright

# Download browsers
playwright install
```

#### With Pytest Plugin
```bash
# Install with pytest support
conda install pytest-playwright

# Download browsers
playwright install
```

### Method 3: uv (Modern Python Package Manager)

For projects using `uv` (like bookmark_organizer):

```bash
# Add Playwright to project
uv add playwright

# Download browsers (run in uv environment)
uv run playwright install

# Or install specific browsers
uv run playwright install chromium
```

## Browser Installation

### What Gets Installed
The `playwright install` command downloads:
- Browser binaries (Chromium, Firefox, WebKit)
- Browser dependencies and drivers
- System-specific native libraries

### Installation Locations

**Linux/macOS**: `~/.cache/ms-playwright/`
**Windows**: `%USERPROFILE%\AppData\Local\ms-playwright\`

### Browser-Specific Installation

```bash
# Install only what you need
playwright install chromium        # ~270 MB
playwright install firefox         # ~85 MB
playwright install webkit          # ~60 MB (Linux/macOS)
```

### System Dependencies (Linux)

On Linux, you may need to install system dependencies:

```bash
# Install system dependencies automatically
playwright install-deps

# Or for specific browser
playwright install-deps chromium
```

Common dependencies include:
- libgstreamer
- libwebkit2gtk
- libxcomposite
- libxdamage
- libxrandr
- fonts-liberation

## Verifying Installation

### Test Basic Import
```python
# Test sync API
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    print(f"Chromium: {p.chromium}")
    print(f"Firefox: {p.firefox}")
    print(f"WebKit: {p.webkit}")
```

### Test Browser Launch
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('https://playwright.dev')
    print(f"Title: {page.title()}")
    browser.close()
```

### Check Installed Browsers
```bash
# List installed browsers
playwright --version
```

## Updating Playwright

### Update Python Package
```bash
# Update with pip
pip install playwright --upgrade

# Update with conda
conda update playwright

# Update with uv
uv add playwright --upgrade
```

### Update Browsers
```bash
# Update all browsers
playwright install

# Or update specific browser
playwright install chromium
```

### Combined Update
```bash
# Update both package and browsers
pip install pytest-playwright playwright -U
playwright install
```

## Configuration

### Environment Variables

#### Browser Binary Location
```bash
# Set custom browser location
export PLAYWRIGHT_BROWSERS_PATH=/path/to/browsers
```

#### Skip Browser Download
```bash
# Skip download during installation (for Docker, CI)
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
```

#### Headless Mode Default
```python
# Control via Python (recommended)
browser = p.chromium.launch(headless=True)  # Default
browser = p.chromium.launch(headless=False)  # Show browser
```

### Docker Installation

For containerized environments:

```dockerfile
FROM python:3.11-slim

# Install Playwright
RUN pip install playwright

# Install browsers and dependencies
RUN playwright install --with-deps chromium

# Your app code
COPY . /app
WORKDIR /app
```

### CI/CD Installation

#### GitHub Actions
```yaml
- name: Install Playwright
  run: |
    pip install playwright
    playwright install chromium --with-deps
```

#### GitLab CI
```yaml
before_script:
  - pip install playwright
  - playwright install chromium --with-deps
```

## Troubleshooting

### Common Issues

#### Browser Download Fails
```bash
# Try manual download
playwright install --force chromium

# Check network connectivity
curl https://playwright.azureedge.net/

# Use proxy if needed
export HTTPS_PROXY=http://proxy:port
playwright install
```

#### Missing System Dependencies (Linux)
```bash
# Install all dependencies
sudo playwright install-deps

# Or install manually
sudo apt-get install libnss3 libatk1.0-0 libatk-bridge2.0-0 \
  libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 \
  libxfixes3 libxrandr2 libgbm1 libasound2
```

#### Import Errors
```python
# Wrong import (common mistake)
import playwright  # ❌ Wrong

# Correct imports
from playwright.sync_api import sync_playwright  # ✅ Sync
from playwright.async_api import async_playwright  # ✅ Async
```

#### Permission Issues
```bash
# Fix browser binary permissions (Linux/macOS)
chmod +x ~/.cache/ms-playwright/*/chromium*/chrome-linux/chrome
```

### Verification Script

Save as `verify_playwright.py`:

```python
#!/usr/bin/env python3
from playwright.sync_api import sync_playwright

def test_browsers():
    results = {}

    with sync_playwright() as p:
        for browser_type in [p.chromium, p.firefox, p.webkit]:
            try:
                browser = browser_type.launch()
                page = browser.new_page()
                page.goto('https://playwright.dev')
                title = page.title()
                browser.close()
                results[browser_type.name] = f"✅ Works (title: {title})"
            except Exception as e:
                results[browser_type.name] = f"❌ Failed ({str(e)})"

    for browser, status in results.items():
        print(f"{browser}: {status}")

if __name__ == "__main__":
    test_browsers()
```

Run with:
```bash
python verify_playwright.py
# Or with uv
uv run verify_playwright.py
```

## Best Practices

1. **Pin versions** in requirements.txt/pyproject.toml for reproducibility
2. **Install specific browsers** if you don't need all three
3. **Use --with-deps** in CI/CD to get system dependencies
4. **Cache browser binaries** in CI to speed up builds
5. **Update regularly** to get latest browser features and security patches

## Resource Requirements

### Per-Browser Memory Usage
- **Chromium**: ~150-200 MB base + page content
- **Firefox**: ~100-150 MB base + page content
- **WebKit**: ~80-120 MB base + page content

### Concurrent Instances
- Each browser instance requires additional resources
- Recommend limiting parallel browsers based on available RAM
- 4GB RAM: 2-3 concurrent browsers
- 8GB RAM: 4-6 concurrent browsers
- 16GB RAM: 8-12 concurrent browsers

## Next Steps

After installation:
1. Review Python API documentation (see 03-python-api.md)
2. Explore Page class methods (see 05-page-api.md)
3. Try web scraping examples (see 04-web-scraping.md)
4. Read official docs: https://playwright.dev/python/docs/intro
