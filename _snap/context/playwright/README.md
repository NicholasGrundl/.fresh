# Playwright Documentation - Quick Reference

This directory contains documentation for Playwright, Microsoft's open-source browser automation framework.

## What is Playwright?

Playwright is a modern browser automation library that enables reliable, fast automation of Chromium, Firefox, and WebKit browsers. It's particularly powerful for web scraping JavaScript-heavy websites and performing browser automation tasks.

## Key Features

- **Multi-browser support**: Chromium, Firefox, WebKit (Safari)
- **Cross-platform**: Windows, macOS, Linux
- **Async & Sync APIs**: Both synchronous and asynchronous Python APIs
- **JavaScript rendering**: Handles dynamic content and SPAs
- **Developer-friendly**: Auto-waiting, detailed selectors, debugging tools
- **Open source**: Apache 2.0 license, completely free

## Quick Start

```python
# Installation
pip install playwright
playwright install

# Basic usage (sync API)
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto('https://example.com')
    html = page.content()  # Get full HTML
    browser.close()
```

## Documentation Files

1. **01-overview.md** - Project overview, features, and licensing
2. **02-installation.md** - Installation guide and system requirements
3. **03-python-api.md** - Python API reference and usage patterns
4. **04-web-scraping.md** - Web scraping capabilities and best practices
5. **05-page-api.md** - Page class methods for content extraction

## Use Cases for Bookmark Organizer

Playwright is particularly useful for:

- **JavaScript-heavy sites**: Extracts content from SPAs and dynamic pages
- **Metadata extraction**: Gets actual rendered page titles, descriptions, and content
- **Screenshot capture**: Takes visual snapshots of bookmarked pages
- **Link validation**: Checks if bookmarked URLs still work
- **Content preview**: Retrieves actual page content for analysis

## Licensing & Cost

- **License**: Apache 2.0 (open source)
- **Cost**: Completely free
- **Commercial use**: Allowed without restrictions
- **Note**: Microsoft offers a paid cloud testing service (Azure Playwright Testing), but the core library is free

## Official Resources

- **Website**: https://playwright.dev/python
- **GitHub**: https://github.com/microsoft/playwright-python
- **PyPI**: https://pypi.org/project/playwright/
- **API Docs**: https://playwright.dev/python/docs/api/class-playwright

## Quick Comparison: Playwright vs Alternatives

| Feature | Playwright | Puppeteer | Selenium |
|---------|-----------|-----------|----------|
| Browsers | Chromium, Firefox, WebKit | Chromium only | All major browsers |
| Speed | Fast | Fastest | Slowest |
| JavaScript handling | Excellent | Excellent | Good |
| Developer experience | Excellent | Good | Fair |
| Python support | Official | Third-party | Official |
| License | Apache 2.0 | Apache 2.0 | Apache 2.0 |

## Next Steps

- Read through the numbered documentation files for detailed information
- Check the official Playwright Python docs for latest updates
- Review code examples in 03-python-api.md and 04-web-scraping.md
