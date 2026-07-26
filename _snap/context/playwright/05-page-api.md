# Playwright Page Class API

The Page class is the primary interface for interacting with web pages in Playwright. This document covers the most important methods for web scraping and content extraction.

## Page Overview

A Page provides methods to:
- Navigate to URLs and manage browser history
- Extract HTML content and page metadata
- Locate and interact with elements
- Execute JavaScript in the page context
- Wait for content, events, and network activity
- Capture screenshots and generate PDFs

## Navigation Methods

### `goto(url, **kwargs)`

Navigate to a URL. Returns the main resource response.

```python
# Basic navigation
page.goto('https://example.com')

# With options
response = page.goto(
    'https://example.com',
    wait_until='networkidle',  # 'load', 'domcontentloaded', 'networkidle'
    timeout=30000,             # 30 seconds
    referer='https://google.com'  # Set referer header
)

# Check response status
if response.status >= 400:
    print(f"Error: {response.status}")
```

**Wait Until Options:**
- `'load'`: Wait for load event (default)
- `'domcontentloaded'`: Wait for DOMContentLoaded event (faster)
- `'networkidle'`: Wait for network to be idle (most reliable for SPAs)

### `go_back(**kwargs)`

Navigate to the previous page in history.

```python
page.goto('https://example.com/page1')
page.goto('https://example.com/page2')
page.go_back()  # Returns to page1
```

### `go_forward(**kwargs)`

Navigate forward through browser history.

```python
page.go_back()
page.go_forward()
```

### `reload(**kwargs)`

Refresh the current page.

```python
page.reload(wait_until='networkidle')
```

## Content Extraction Methods

### `content()`

Get the full HTML content of the page, including doctype.

```python
html = page.content()
print(html)  # Complete HTML source
```

This returns the fully rendered HTML after JavaScript execution, not the raw source.

### `title()`

Get the page title.

```python
title = page.title()
print(f"Page title: {title}")
```

### `url`

Get the current URL (property, not method).

```python
current_url = page.url
print(f"Currently at: {current_url}")
```

### `inner_text(selector, **kwargs)`

Get the text content of an element.

```python
# Get text from specific element
text = page.inner_text('h1')

# With timeout
text = page.inner_text('.article-content', timeout=5000)
```

### `text_content(selector, **kwargs)`

Similar to `inner_text()` but returns raw text content.

```python
# inner_text respects CSS visibility, text_content does not
visible_text = page.inner_text('p')      # Only visible text
all_text = page.text_content('p')        # All text, even hidden
```

### `get_attribute(selector, name, **kwargs)`

Get an element's attribute value.

```python
# Get link href
href = page.get_attribute('a.external', 'href')

# Get image src
src = page.get_attribute('img.logo', 'src')

# Get data attributes
data = page.get_attribute('.widget', 'data-id')
```

## Element Locators

Locators are the recommended way to interact with elements. They auto-wait and retry.

### `locator(selector, **kwargs)`

Create a locator for elements matching a selector.

```python
# Create locator
button = page.locator('button.submit')

# Use locator
button.click()
text = button.inner_text()

# Locators for multiple elements
items = page.locator('.list-item').all()
for item in items:
    print(item.inner_text())
```

### Semantic Locators (Recommended)

```python
# By role (accessibility)
page.get_by_role('button', name='Submit').click()
page.get_by_role('link', name='Home').click()

# By text
page.get_by_text('Welcome').click()
page.get_by_text('Submit', exact=True).click()

# By label
page.get_by_label('Username').fill('user123')

# By placeholder
page.get_by_placeholder('Enter email').fill('user@example.com')

# By title
page.get_by_title('Close dialog').click()

# By test ID
page.get_by_test_id('submit-button').click()
```

### Locator Chaining

```python
# Find article, then find heading within it
article = page.locator('article.featured')
heading = article.locator('h2')
print(heading.inner_text())

# Complex chains
price = page.locator('.product').filter(has_text='Laptop').locator('.price').inner_text()
```

## Waiting Methods

### `wait_for_selector(selector, **kwargs)`

Wait for an element matching selector to appear.

```python
# Wait for element to appear
page.wait_for_selector('.content-loaded')

# With options
page.wait_for_selector(
    '.modal',
    state='visible',    # 'attached', 'detached', 'visible', 'hidden'
    timeout=10000       # 10 seconds
)
```

### `wait_for_load_state(state, **kwargs)`

Wait for the page to reach a specific load state.

```python
# Wait for network to be idle
page.wait_for_load_state('networkidle')

# Other states
page.wait_for_load_state('load')              # Wait for load event
page.wait_for_load_state('domcontentloaded')  # Wait for DOM ready
```

### `wait_for_timeout(timeout)`

Wait for a specific amount of time (milliseconds).

```python
# Wait 2 seconds
page.wait_for_timeout(2000)
```

**Note:** Prefer `wait_for_selector()` or `wait_for_load_state()` over `wait_for_timeout()` when possible, as they're more reliable.

### `wait_for_url(url, **kwargs)`

Wait until the URL matches a pattern.

```python
# Wait for exact URL
page.wait_for_url('https://example.com/dashboard')

# Wait for URL pattern
page.wait_for_url('**/dashboard')
page.wait_for_url('https://example.com/**')

# With regex
import re
page.wait_for_url(re.compile(r'.*dashboard.*'))
```

### `wait_for_function(expression, **kwargs)`

Wait for a JavaScript function to return truthy value.

```python
# Wait for custom condition
page.wait_for_function('() => document.querySelectorAll(".item").length > 10')

# With argument
page.wait_for_function('selector => !!document.querySelector(selector)', '.loaded')
```

## JavaScript Execution

### `evaluate(expression, **kwargs)`

Execute JavaScript and return the result. The result must be serializable.

```python
# Simple expression
height = page.evaluate('() => document.body.scrollHeight')

# With return value
data = page.evaluate('''() => {
    return {
        title: document.title,
        url: window.location.href,
        cookies: document.cookie
    };
}''')

# With arguments
result = page.evaluate('x => x * 2', 5)  # Returns 10
```

### `evaluate_handle(expression, **kwargs)`

Execute JavaScript and return a JSHandle (for non-serializable values).

```python
# Get element handle
element_handle = page.evaluate_handle('() => document.querySelector(".article")')

# Use element handle
text = element_handle.inner_text()
```

### `add_init_script(script, **kwargs)`

Add script to run before page loads (useful for stealth techniques).

```python
# Remove webdriver flag
page.add_init_script('''
    Object.defineProperty(navigator, 'webdriver', {
        get: () => false
    });
''')

# Add before navigation
page.add_init_script('window.customFlag = true')
page.goto('https://example.com')
```

## Event Handling

### `expect_event(event, **kwargs)`

Wait for a specific page event.

```python
# Wait for popup
with page.expect_event('popup') as popup_info:
    page.click('a[target="_blank"]')
popup = popup_info.value

# Wait for download
with page.expect_download() as download_info:
    page.click('a.download-link')
download = download_info.value
download.save_as('/path/to/save')
```

### `expect_request(url_or_predicate, **kwargs)`

Wait for a request matching URL or predicate.

```python
# Wait for specific API call
with page.expect_request('**/api/data') as request_info:
    page.click('button.load-data')
request = request_info.value
print(request.url)
```

### `expect_response(url_or_predicate, **kwargs)`

Wait for a response matching URL or predicate.

```python
# Wait for API response
with page.expect_response('**/api/users') as response_info:
    page.goto('https://example.com/users')
response = response_info.value
data = response.json()
```

### Event Listeners

```python
# Listen to console messages
def handle_console(msg):
    print(f"Console: {msg.text}")

page.on('console', handle_console)

# Listen to page errors
def handle_error(error):
    print(f"Error: {error}")

page.on('pageerror', handle_error)

# Listen to requests
def handle_request(request):
    print(f"Request: {request.url}")

page.on('request', handle_request)
```

## Screenshots and PDFs

### `screenshot(**kwargs)`

Capture a screenshot of the page.

```python
# Full page screenshot
page.screenshot(path='screenshot.png', full_page=True)

# Viewport only
page.screenshot(path='viewport.png')

# Get as bytes
image_bytes = page.screenshot()

# Specific element
element = page.locator('.chart')
element.screenshot(path='chart.png')

# With options
page.screenshot(
    path='screenshot.png',
    full_page=True,
    type='png',  # or 'jpeg'
    quality=80,  # JPEG quality (0-100)
    clip={'x': 0, 'y': 0, 'width': 800, 'height': 600}  # Crop region
)
```

### `pdf(**kwargs)`

Generate a PDF of the page (Chromium only).

```python
# Basic PDF
page.pdf(path='page.pdf')

# With options
page.pdf(
    path='page.pdf',
    format='A4',              # Paper format
    print_background=True,     # Include backgrounds
    margin={'top': '1cm', 'right': '1cm', 'bottom': '1cm', 'left': '1cm'},
    landscape=False,
    page_ranges='1-5',        # Specific pages
)
```

## Network Interception

### `route(url, handler, **kwargs)`

Intercept and handle network requests.

```python
# Block images
def handle_route(route):
    if route.request.resource_type == 'image':
        route.abort()
    else:
        route.continue_()

page.route('**/*', handle_route)

# Modify requests
def modify_request(route):
    headers = route.request.headers
    headers['X-Custom'] = 'value'
    route.continue_(headers=headers)

page.route('**/*', modify_request)

# Mock API response
def mock_api(route):
    if '/api/data' in route.request.url:
        route.fulfill(
            status=200,
            content_type='application/json',
            body='{"mocked": true}'
        )
    else:
        route.continue_()

page.route('**/*', mock_api)
```

### `unroute(url, handler=None)`

Remove route handler.

```python
page.unroute('**/*')  # Remove all handlers
page.unroute('**/*', handle_route)  # Remove specific handler
```

## Form Interaction

### `fill(selector, value, **kwargs)`

Fill an input field.

```python
# Fill text input
page.fill('input[name="username"]', 'john_doe')

# Clear and fill
page.fill('input[name="email"]', '')  # Clear
page.fill('input[name="email"]', 'new@example.com')
```

### `click(selector, **kwargs)`

Click an element.

```python
# Simple click
page.click('button.submit')

# With options
page.click(
    'button',
    button='left',      # 'left', 'right', 'middle'
    click_count=2,      # Double click
    delay=100,          # Delay between mousedown and mouseup (ms)
    position={'x': 10, 'y': 10},  # Click at specific position
    modifiers=['Shift'],  # Hold modifier keys
    timeout=5000
)
```

### `check(selector, **kwargs)` / `uncheck(selector, **kwargs)`

Check or uncheck a checkbox.

```python
page.check('input[type="checkbox"]')
page.uncheck('input[type="checkbox"]')
```

### `select_option(selector, values, **kwargs)`

Select option(s) from a dropdown.

```python
# By value
page.select_option('select', 'option1')

# By label
page.select_option('select', label='Option 1')

# Multiple options
page.select_option('select[multiple]', ['option1', 'option2'])
```

### `type(selector, text, **kwargs)`

Type text with keyboard events (slower than `fill` but more realistic).

```python
page.type('input[name="search"]', 'playwright', delay=100)
```

### `press(selector, key, **kwargs)`

Press a keyboard key.

```python
page.press('input', 'Enter')
page.press('input', 'Control+A')
page.press('input', 'Backspace')
```

## Viewport and Display

### `set_viewport_size(viewport_size)`

Set viewport dimensions.

```python
page.set_viewport_size({'width': 1920, 'height': 1080})
```

### `viewport_size`

Get current viewport size.

```python
size = page.viewport_size
print(f"Width: {size['width']}, Height: {size['height']}")
```

## Console and Errors

### `console_messages()`

Get recent console messages (up to 200).

```python
messages = page.console_messages()
for msg in messages:
    print(f"{msg.type}: {msg.text}")
```

### `page_errors()`

Get recent page errors (up to 200).

```python
errors = page.page_errors()
for error in errors:
    print(f"Error: {error}")
```

## Frames and iframes

### `frame(name=None, url=None)`

Get a frame by name or URL.

```python
frame = page.frame(name='content-frame')
frame.click('button')
```

### `frame_locator(selector)`

Create locator for elements inside an iframe.

```python
# Access element inside iframe
frame_element = page.frame_locator('iframe#content').locator('button')
frame_element.click()
```

### `frames`

Get all frames on the page.

```python
all_frames = page.frames
for frame in all_frames:
    print(frame.url)
```

## Practical Examples

### Extract All Links

```python
links = page.evaluate('''() => {
    return Array.from(document.querySelectorAll('a')).map(a => ({
        text: a.innerText,
        href: a.href
    }));
}''')
```

### Extract Metadata

```python
metadata = page.evaluate('''() => {
    return {
        title: document.title,
        description: document.querySelector('meta[name="description"]')?.content,
        ogImage: document.querySelector('meta[property="og:image"]')?.content,
        canonical: document.querySelector('link[rel="canonical"]')?.href
    };
}''')
```

### Scroll to Bottom

```python
page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
```

### Check if Element Exists

```python
# Using locator count
count = page.locator('.element').count()
exists = count > 0

# Or with evaluate
exists = page.evaluate('() => !!document.querySelector(".element")')
```

### Get Computed Style

```python
color = page.evaluate('''selector => {
    const el = document.querySelector(selector);
    return window.getComputedStyle(el).color;
}''', '.element')
```

## Timeout Configuration

### Set Default Timeout

```python
# Set default timeout for all operations
page.set_default_timeout(30000)  # 30 seconds

# Set navigation timeout
page.set_default_navigation_timeout(60000)  # 60 seconds
```

### Per-Operation Timeout

```python
# Override default for specific operation
page.click('button', timeout=5000)
page.goto('https://example.com', timeout=15000)
```

## Page Context

Each page belongs to a browser context:

```python
context = page.context
print(context)  # BrowserContext

# Get all pages in context
pages = context.pages
```

## Closing Pages

```python
# Close the page
page.close()

# Check if page is closed
is_closed = page.is_closed()
```

## Best Practices

1. **Use locators over direct element access** - They auto-wait and retry
2. **Prefer semantic selectors** - `get_by_role()`, `get_by_text()` over CSS
3. **Use networkidle for SPAs** - More reliable than 'load'
4. **Set reasonable timeouts** - Prevent hanging on slow sites
5. **Clean up resources** - Close pages when done
6. **Use evaluate() for bulk extraction** - More efficient than multiple queries
7. **Handle errors gracefully** - Network issues, timeouts, missing elements
8. **Avoid wait_for_timeout()** - Use condition-based waits instead

## Complete API Reference

For the full Page API documentation:
https://playwright.dev/python/docs/api/class-page
