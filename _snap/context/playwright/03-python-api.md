# Playwright Python API Reference

## API Overview

Playwright for Python provides two parallel API styles:
- **Synchronous API** (`playwright.sync_api`): For traditional Python code
- **Asynchronous API** (`playwright.async_api`): For asyncio-based applications

Both APIs provide identical functionality; choose based on your application's architecture.

## Playwright Class

The root object that provides access to browser types and utilities.

### Core Properties

| Property | Type | Description |
|----------|------|-------------|
| `chromium` | BrowserType | Launch or connect to Chromium browsers |
| `firefox` | BrowserType | Launch or connect to Firefox browsers |
| `webkit` | BrowserType | Launch or connect to WebKit browsers |
| `devices` | Dict | Device configurations for mobile emulation |
| `request` | APIRequest | Web API testing capabilities |
| `selectors` | Selectors | Install custom selector engines |

### Methods

#### `stop()`
Terminates the Playwright instance. Only needed when created outside a context manager.

```python
# Manual cleanup (REPL usage)
p = sync_playwright().start()
# ... use playwright ...
p.stop()
```

## Synchronous API

### Basic Usage Pattern

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    # Launch browser
    browser = p.chromium.launch()

    # Create page
    page = browser.new_page()

    # Navigate and interact
    page.goto('https://example.com')

    # Extract content
    html = page.content()

    # Cleanup
    browser.close()
```

### Multi-Browser Example

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    for browser_type in [p.chromium, p.firefox, p.webkit]:
        browser = browser_type.launch()
        page = browser.new_page()
        page.goto('http://playwright.dev')
        page.screenshot(path=f'example-{browser_type.name}.png')
        browser.close()
```

### REPL Usage (Interactive Development)

```python
# Start interactive session
from playwright.sync_api import sync_playwright

p = sync_playwright().start()
browser = p.chromium.launch()
page = browser.new_page()
page.goto('https://example.com')

# Explore interactively
page.title()
page.content()

# When done
browser.close()
p.stop()
```

## Asynchronous API

### Basic Usage Pattern

```python
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        await page.goto('https://example.com')
        html = await page.content()
        await browser.close()
        return html

# Run async function
result = asyncio.run(main())
```

### Async Multi-Page Example

```python
import asyncio
from playwright.async_api import async_playwright

async def scrape_page(url, browser):
    page = await browser.new_page()
    await page.goto(url)
    title = await page.title()
    await page.close()
    return title

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch()

        # Scrape multiple pages concurrently
        urls = ['https://example.com', 'https://playwright.dev']
        tasks = [scrape_page(url, browser) for url in urls]
        titles = await asyncio.gather(*tasks)

        await browser.close()
        return titles

titles = asyncio.run(main())
```

### Async REPL

```bash
# Start async REPL
python -m asyncio
```

```python
# Inside async REPL
from playwright.async_api import async_playwright

p = await async_playwright().start()
browser = await p.chromium.launch()
page = await browser.new_page()
await page.goto('https://example.com')

# Explore
await page.title()
await page.content()

# Cleanup
await browser.close()
await p.stop()
```

## BrowserType Class

Provides methods to launch or connect to browsers.

### Launch Options

```python
browser = p.chromium.launch(
    headless=True,          # Run in background (default)
    slow_mo=50,             # Slow down by 50ms for debugging
    timeout=30000,          # Launch timeout (ms)
    args=['--start-maximized'],  # Browser arguments
    downloads_path='/tmp/downloads',  # Download location
    chromium_sandbox=True,  # Enable sandbox (Linux)
)
```

### Common Launch Configurations

#### Headless Mode (Default)
```python
browser = p.chromium.launch()  # headless=True by default
```

#### Headed Mode (Visible Browser)
```python
browser = p.chromium.launch(headless=False)
```

#### Debug Mode (Slow Motion)
```python
browser = p.chromium.launch(
    headless=False,
    slow_mo=100  # 100ms delay between actions
)
```

#### Custom Browser Arguments
```python
browser = p.chromium.launch(
    args=[
        '--disable-blink-features=AutomationControlled',
        '--disable-web-security',
        '--no-sandbox',
    ]
)
```

## Browser Class

Represents a browser instance.

### Key Methods

```python
# Create new context (isolated session)
context = browser.new_context()

# Create page directly
page = browser.new_page()

# Get all contexts
contexts = browser.contexts

# Close browser
browser.close()
```

### Browser Contexts

Contexts are isolated browser sessions (like incognito mode):

```python
# Create context with custom settings
context = browser.new_context(
    viewport={'width': 1920, 'height': 1080},
    user_agent='Custom User Agent',
    locale='en-US',
    timezone_id='America/New_York',
    geolocation={'latitude': 40.7128, 'longitude': -74.0060},
    permissions=['geolocation'],
    color_scheme='dark',
)

# Use context
page = context.new_page()
page.goto('https://example.com')

# Cleanup
context.close()
```

## Page Class (Brief Overview)

The Page class is covered in detail in `05-page-api.md`. Here's a quick reference:

### Navigation
```python
page.goto('https://example.com')
page.go_back()
page.go_forward()
page.reload()
```

### Content Extraction
```python
html = page.content()           # Full HTML
title = page.title()            # Page title
url = page.url                  # Current URL
```

### Element Interaction
```python
page.click('button')
page.fill('input[name="q"]', 'search query')
page.select_option('select', 'value')
page.check('input[type="checkbox"]')
```

### Waiting
```python
page.wait_for_selector('.loaded')
page.wait_for_load_state('networkidle')
page.wait_for_timeout(1000)  # Wait 1 second
```

## Device Emulation

Playwright includes device descriptors for mobile emulation.

### Using Device Presets

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    # Get iPhone 13 descriptor
    iphone_13 = p.devices['iPhone 13']

    browser = p.chromium.launch()
    context = browser.new_context(**iphone_13)
    page = context.new_page()
    page.goto('https://example.com')

    browser.close()
```

### Available Devices

```python
# List all available devices
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    print(list(p.devices.keys()))
```

Common devices include:
- `'iPhone 13'`, `'iPhone 13 Pro'`, `'iPhone 14'`
- `'iPad Pro'`, `'iPad Mini'`
- `'Pixel 5'`, `'Galaxy S9+'`
- `'Desktop Chrome'`, `'Desktop Firefox'`

### Custom Device Configuration

```python
context = browser.new_context(
    viewport={'width': 375, 'height': 667},
    user_agent='Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
    device_scale_factor=2,
    is_mobile=True,
    has_touch=True,
)
```

## Error Handling

### Common Exceptions

```python
from playwright.sync_api import sync_playwright, TimeoutError, Error

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()

    try:
        page.goto('https://example.com', timeout=5000)
    except TimeoutError:
        print("Navigation timeout")
    except Error as e:
        print(f"Playwright error: {e}")
    finally:
        browser.close()
```

### Timeout Configuration

```python
# Global timeout
page.set_default_timeout(30000)  # 30 seconds

# Per-action timeout
page.click('button', timeout=5000)
page.goto('https://example.com', timeout=10000)
```

## Logging and Debugging

### Environment Variables

```bash
# Enable debug logging
export DEBUG=pw:api
python script.py

# Or in Python
import os
os.environ['DEBUG'] = 'pw:api'
```

### Headed Mode for Debugging

```python
browser = p.chromium.launch(
    headless=False,  # Show browser
    slow_mo=1000,    # 1 second between actions
    devtools=True    # Open DevTools automatically
)
```

### Screenshots for Debugging

```python
# Take screenshot on error
try:
    page.click('.missing-element')
except:
    page.screenshot(path='debug.png')
    raise
```

## Context Manager Best Practices

### Recommended Pattern

```python
from playwright.sync_api import sync_playwright

def scrape_url(url):
    with sync_playwright() as p:
        with p.chromium.launch() as browser:
            page = browser.new_page()
            page.goto(url)
            return page.content()
```

### Reusing Browser Instance

```python
def scrape_multiple_urls(urls):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        results = []

        for url in urls:
            page = browser.new_page()
            page.goto(url)
            results.append(page.content())
            page.close()  # Close page, keep browser

        browser.close()
        return results
```

## API Request (Web API Testing)

Playwright can also make HTTP requests without a browser:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    request_context = p.request.new_context()

    # GET request
    response = request_context.get('https://api.example.com/data')
    print(response.json())

    # POST request
    response = request_context.post(
        'https://api.example.com/submit',
        data={'key': 'value'}
    )

    request_context.dispose()
```

## Selectors

Playwright supports multiple selector strategies:

### CSS Selectors
```python
page.click('button.submit')
page.fill('#username', 'user')
```

### XPath Selectors
```python
page.click('xpath=//button[@type="submit"]')
```

### Text Selectors
```python
page.click('text=Submit')
page.click('text="Exact Match"')
```

### Accessible Selectors (Recommended)
```python
page.click('role=button[name="Submit"]')
page.fill('label=Username')
```

## Performance Optimization

### Reuse Browser Instances
```python
# Good: Reuse browser for multiple pages
browser = p.chromium.launch()
for url in urls:
    page = browser.new_page()
    page.goto(url)
    # ... scrape ...
    page.close()
browser.close()

# Bad: Launch new browser for each page
for url in urls:
    browser = p.chromium.launch()
    page = browser.new_page()
    # ...
    browser.close()
```

### Block Unnecessary Resources
```python
def route_handler(route):
    # Block images, fonts, stylesheets
    if route.request.resource_type in ['image', 'font', 'stylesheet']:
        route.abort()
    else:
        route.continue_()

page.route('**/*', route_handler)
```

## API Documentation Links

- **Full API Reference**: https://playwright.dev/python/docs/api/class-playwright
- **Page Class**: https://playwright.dev/python/docs/api/class-page
- **Browser**: https://playwright.dev/python/docs/api/class-browser
- **BrowserContext**: https://playwright.dev/python/docs/api/class-browsercontext
- **Locators**: https://playwright.dev/python/docs/api/class-locator

## Next Steps

- For detailed Page methods, see `05-page-api.md`
- For web scraping examples, see `04-web-scraping.md`
- Review official docs for latest API updates
