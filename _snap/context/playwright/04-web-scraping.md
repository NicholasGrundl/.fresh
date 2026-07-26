# Playwright for Web Scraping

## Why Playwright for Web Scraping?

Playwright excels at scraping modern websites that rely heavily on JavaScript for content rendering. Unlike static parsers (BeautifulSoup, lxml), Playwright executes JavaScript and waits for dynamic content to load.

## Key Advantages for Web Scraping

### 1. JavaScript Execution
- Renders Single Page Applications (SPAs) completely
- Handles lazy-loaded content
- Executes AJAX/fetch requests automatically
- Waits for content to appear dynamically

### 2. Browser Automation
- Clicks buttons to reveal content
- Scrolls to trigger infinite loading
- Fills forms and submits search queries
- Handles popups, modals, and overlays

### 3. Reliable Waiting Mechanisms
- Auto-waits for elements to be visible and ready
- Waits for network requests to complete
- Custom wait conditions for specific scenarios
- Reduces race conditions and flakiness

### 4. Cross-Browser Support
- Test scraping logic across Chromium, Firefox, WebKit
- Handle browser-specific rendering differences
- Choose fastest/most compatible browser for your use case

## When to Use Playwright vs. BeautifulSoup

### Use Playwright When:
- ✅ Site heavily uses JavaScript (React, Vue, Angular, etc.)
- ✅ Content loads dynamically via AJAX/fetch
- ✅ Need to interact with page (click, scroll, form submission)
- ✅ Content appears after specific user actions
- ✅ Need screenshots or PDFs of rendered pages
- ✅ Site uses infinite scroll or pagination via JavaScript

### Use BeautifulSoup When:
- ✅ Static HTML with all content in source
- ✅ Simple, fast parsing needed
- ✅ High-volume scraping (thousands of pages)
- ✅ Minimal resource usage required
- ✅ Content doesn't require JavaScript

## Basic Web Scraping Patterns

### Simple Page Scraping

```python
from playwright.sync_api import sync_playwright

def scrape_page(url):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(url, wait_until='networkidle')

        # Get full HTML
        html = page.content()

        # Or extract specific data
        title = page.title()
        heading = page.text_content('h1')

        browser.close()

        return {
            'url': url,
            'title': title,
            'heading': heading,
            'html': html
        }
```

### Extracting Multiple Elements

```python
def scrape_articles(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url)

        # Wait for content to load
        page.wait_for_selector('.article')

        # Extract all articles using evaluate
        articles = page.evaluate('''() => {
            return Array.from(document.querySelectorAll('.article')).map(article => ({
                title: article.querySelector('h2')?.innerText,
                summary: article.querySelector('.summary')?.innerText,
                link: article.querySelector('a')?.href
            }));
        }''')

        browser.close()
        return articles
```

### Using Locators (Recommended)

```python
def scrape_with_locators(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url)

        # Locators auto-wait for elements
        articles = page.locator('.article').all()

        results = []
        for article in articles:
            results.append({
                'title': article.locator('h2').inner_text(),
                'summary': article.locator('.summary').inner_text(),
                'link': article.locator('a').get_attribute('href')
            })

        browser.close()
        return results
```

## Advanced Techniques

### Handling Dynamic Content

```python
def scrape_dynamic_content(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url)

        # Click "Load More" button multiple times
        for _ in range(5):
            try:
                page.click('button:has-text("Load More")', timeout=5000)
                page.wait_for_load_state('networkidle')
            except:
                break  # No more content

        # Now scrape all loaded content
        items = page.locator('.item').all()
        data = [item.inner_text() for item in items]

        browser.close()
        return data
```

### Infinite Scroll Handling

```python
def scrape_infinite_scroll(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url)

        # Scroll to bottom repeatedly
        previous_height = 0
        while True:
            # Scroll to bottom
            page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
            page.wait_for_timeout(2000)  # Wait for content to load

            # Check if new content loaded
            new_height = page.evaluate('document.body.scrollHeight')
            if new_height == previous_height:
                break  # No more content
            previous_height = new_height

        # Scrape all content
        html = page.content()
        browser.close()
        return html
```

### Form Submission

```python
def scrape_search_results(query):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto('https://example.com/search')

        # Fill search form
        page.fill('input[name="q"]', query)
        page.click('button[type="submit"]')

        # Wait for results
        page.wait_for_selector('.search-result')

        # Extract results
        results = page.evaluate('''() => {
            return Array.from(document.querySelectorAll('.search-result')).map(r => ({
                title: r.querySelector('h3')?.innerText,
                url: r.querySelector('a')?.href
            }));
        }''')

        browser.close()
        return results
```

### Handling Authentication

```python
def scrape_authenticated_content(url, username, password):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        # Login
        page.goto('https://example.com/login')
        page.fill('input[name="username"]', username)
        page.fill('input[name="password"]', password)
        page.click('button[type="submit"]')

        # Wait for redirect
        page.wait_for_url('**/dashboard')

        # Now scrape protected content
        page.goto(url)
        content = page.content()

        browser.close()
        return content
```

## Performance Optimization

### Block Unnecessary Resources

```python
def scrape_with_blocked_resources(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        # Block images, fonts, and stylesheets
        def handle_route(route):
            resource_type = route.request.resource_type
            if resource_type in ['image', 'font', 'stylesheet']:
                route.abort()
            else:
                route.continue_()

        page.route('**/*', handle_route)

        page.goto(url)
        html = page.content()

        browser.close()
        return html
```

### Reuse Browser for Multiple Pages

```python
def scrape_multiple_pages(urls):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        results = []

        for url in urls:
            page = browser.new_page()
            page.goto(url, wait_until='domcontentloaded')
            results.append({
                'url': url,
                'title': page.title(),
                'html': page.content()
            })
            page.close()  # Close page but keep browser

        browser.close()
        return results
```

### Parallel Scraping with Asyncio

```python
import asyncio
from playwright.async_api import async_playwright

async def scrape_page_async(url, browser):
    page = await browser.new_page()
    await page.goto(url)
    title = await page.title()
    await page.close()
    return {'url': url, 'title': title}

async def scrape_concurrent(urls):
    async with async_playwright() as p:
        browser = await p.chromium.launch()

        # Scrape all URLs concurrently
        tasks = [scrape_page_async(url, browser) for url in urls]
        results = await asyncio.gather(*tasks)

        await browser.close()
        return results

# Run
urls = ['https://example.com', 'https://playwright.dev']
results = asyncio.run(scrape_concurrent(urls))
```

## Network Interception

### Modify Request Headers

```python
def scrape_with_custom_headers(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        context = browser.new_context(
            user_agent='Custom Bot 1.0',
            extra_http_headers={
                'Accept-Language': 'en-US',
                'X-Custom-Header': 'value'
            }
        )

        page = context.new_page()
        page.goto(url)
        html = page.content()

        browser.close()
        return html
```

### Monitor Network Requests

```python
def scrape_and_monitor_api_calls(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        api_calls = []

        # Listen to all requests
        def handle_request(request):
            if '/api/' in request.url:
                api_calls.append({
                    'url': request.url,
                    'method': request.method,
                })

        page.on('request', handle_request)

        page.goto(url)
        page.wait_for_load_state('networkidle')

        browser.close()
        return api_calls
```

### Mock API Responses

```python
def scrape_with_mocked_api(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        # Mock API response
        def handle_route(route):
            if '/api/data' in route.request.url:
                route.fulfill(
                    status=200,
                    content_type='application/json',
                    body='{"mocked": true}'
                )
            else:
                route.continue_()

        page.route('**/*', handle_route)

        page.goto(url)
        html = page.content()

        browser.close()
        return html
```

## Stealth and Anti-Detection

### Basic Stealth Techniques

```python
def scrape_stealthily(url):
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                '--disable-blink-features=AutomationControlled',
            ]
        )

        context = browser.new_context(
            user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            viewport={'width': 1920, 'height': 1080},
            locale='en-US',
            timezone_id='America/New_York',
        )

        page = context.new_page()

        # Remove webdriver flag
        page.add_init_script('''
            Object.defineProperty(navigator, 'webdriver', {
                get: () => false
            });
        ''')

        page.goto(url)
        html = page.content()

        browser.close()
        return html
```

### Using Proxies

```python
def scrape_with_proxy(url, proxy_server):
    with sync_playwright() as p:
        browser = p.chromium.launch(
            proxy={
                'server': proxy_server,
                # Optional authentication
                # 'username': 'user',
                # 'password': 'pass'
            }
        )

        page = browser.new_page()
        page.goto(url)
        html = page.content()

        browser.close()
        return html
```

## Error Handling and Retries

### Robust Scraping Function

```python
from playwright.sync_api import sync_playwright, TimeoutError

def scrape_with_retry(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            with sync_playwright() as p:
                browser = p.chromium.launch()
                page = browser.new_page()
                page.goto(url, timeout=30000)
                page.wait_for_load_state('domcontentloaded')
                html = page.content()
                browser.close()
                return html

        except TimeoutError:
            if attempt == max_retries - 1:
                raise
            print(f"Timeout on attempt {attempt + 1}, retrying...")
            continue

        except Exception as e:
            print(f"Error: {e}")
            if attempt == max_retries - 1:
                raise
            continue

    return None
```

## Data Extraction Techniques

### Using JavaScript Evaluation

```python
def extract_structured_data(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url)

        # Extract data using JavaScript
        data = page.evaluate('''() => {
            const products = [];
            document.querySelectorAll('.product').forEach(product => {
                products.push({
                    name: product.querySelector('.name')?.innerText,
                    price: product.querySelector('.price')?.innerText,
                    image: product.querySelector('img')?.src
                });
            });
            return products;
        }''')

        browser.close()
        return data
```

### Combining with BeautifulSoup

```python
from bs4 import BeautifulSoup

def scrape_then_parse(url):
    # Use Playwright to render JavaScript
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url, wait_until='networkidle')
        html = page.content()
        browser.close()

    # Then parse with BeautifulSoup
    soup = BeautifulSoup(html, 'lxml')
    titles = [h2.text for h2 in soup.find_all('h2')]

    return titles
```

## Bookmark Scraping Use Cases

### Extract Page Metadata

```python
def extract_bookmark_metadata(url):
    """Extract rich metadata from a bookmarked URL."""
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        try:
            page.goto(url, timeout=30000, wait_until='domcontentloaded')

            metadata = page.evaluate('''() => {
                return {
                    title: document.title,
                    description: document.querySelector('meta[name="description"]')?.content,
                    ogTitle: document.querySelector('meta[property="og:title"]')?.content,
                    ogDescription: document.querySelector('meta[property="og:description"]')?.content,
                    ogImage: document.querySelector('meta[property="og:image"]')?.content,
                    favicon: document.querySelector('link[rel="icon"]')?.href,
                    lang: document.documentElement.lang,
                };
            }''')

            browser.close()
            return metadata

        except Exception as e:
            browser.close()
            return {'error': str(e)}
```

### Take Page Screenshot

```python
def screenshot_bookmark(url, output_path):
    """Capture visual snapshot of bookmarked page."""
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={'width': 1920, 'height': 1080})
        page.goto(url, wait_until='networkidle')

        # Full page screenshot
        page.screenshot(path=output_path, full_page=True)

        browser.close()
```

### Validate Bookmark Links

```python
def validate_bookmark(url):
    """Check if bookmark URL is still valid."""
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        try:
            response = page.goto(url, timeout=15000)
            status = response.status if response else None

            browser.close()

            return {
                'url': url,
                'valid': status and status < 400,
                'status_code': status,
                'final_url': page.url  # After redirects
            }

        except Exception as e:
            browser.close()
            return {
                'url': url,
                'valid': False,
                'error': str(e)
            }
```

## Best Practices

1. **Always use headless mode** in production (faster, less resources)
2. **Reuse browser instances** for multiple pages
3. **Block unnecessary resources** (images, fonts) if only text needed
4. **Set reasonable timeouts** to avoid hanging
5. **Handle errors gracefully** with retries
6. **Respect robots.txt** and rate limits
7. **Use async API** for concurrent scraping
8. **Close pages and browsers** to prevent memory leaks
9. **Monitor resource usage** when scraping at scale
10. **Use context managers** (`with` statements) for cleanup

## Performance Comparison

For the Bookmark Organizer project:

| Task | BeautifulSoup | Playwright |
|------|---------------|------------|
| Parse static HTML | ⚡ Fastest | 🐢 Overkill |
| JavaScript-rendered content | ❌ Cannot handle | ✅ Perfect |
| Extract metadata | ⚠️ Limited to source | ✅ Full access |
| Screenshot generation | ❌ Not possible | ✅ Built-in |
| Link validation | ⚠️ Needs requests | ✅ Built-in |
| Resource usage | 💚 Very low | ⚠️ Moderate |
| Speed (100 pages) | 💚 Seconds | ⚠️ Minutes |

## Conclusion

Playwright is ideal for:
- Enriching bookmarks with rendered metadata
- Validating and checking bookmark URLs
- Capturing page screenshots
- Extracting content from JavaScript-heavy sites

Combine Playwright (for JavaScript sites) with BeautifulSoup (for static sites) for optimal performance.
