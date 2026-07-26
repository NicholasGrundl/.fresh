# Firecrawl Scrape API

Complete documentation for the Firecrawl `/scrape` endpoint.

**Official Docs**: https://docs.firecrawl.dev/features/scrape

## Overview

The scrape endpoint converts web pages into clean, structured data. It handles:
- Proxies, caching, rate limits, JS-blocked content
- Dynamic websites, JavaScript-rendered sites
- PDFs, images, and other document types
- Multiple output formats simultaneously

## Endpoint

```
POST https://api.firecrawl.dev/v2/scrape
```

## Authentication

```bash
Authorization: Bearer YOUR_API_KEY
```

Get your API key from https://www.firecrawl.dev/

## Supported Output Formats

The API can return data in multiple formats simultaneously:

### 1. Markdown
Clean text conversion ideal for LLMs
```json
{
  "formats": ["markdown"]
}
```

### 2. HTML
Standard and raw HTML variants
```json
{
  "formats": ["html", "rawHtml"]
}
```

### 3. Screenshot
Visual captures with fullPage option
```json
{
  "formats": ["screenshot"]
}
```

### 4. Links
Extract all URLs from the page
```json
{
  "formats": ["links"]
}
```

### 5. Images
Image URL collection
```json
{
  "formats": ["images"]
}
```

### 6. Branding
Brand identity extraction (colors, fonts, typography)
```json
{
  "formats": ["branding"]
}
```

## Basic Usage

### cURL Example
```bash
curl -X POST https://api.firecrawl.dev/v2/scrape \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com",
    "formats": ["markdown", "html"]
  }'
```

### Python Example
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

result = firecrawl.scrape(
    url='https://example.com',
    formats=['markdown', 'html']
)

print(result['markdown'])
print(result['html'])
```

### JavaScript/Node.js Example
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({apiKey: 'fc-YOUR_API_KEY'});

const result = await firecrawl.scrape({
  url: 'https://example.com',
  formats: ['markdown', 'html']
});

console.log(result.markdown);
```

## Request Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `url` | string | The URL to scrape |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `formats` | array | `["markdown"]` | Output formats to return |
| `onlyMainContent` | boolean | `true` | Extract only main content, removing nav/footer |
| `includeTags` | array | `[]` | HTML tags to include |
| `excludeTags` | array | `[]` | HTML tags to exclude |
| `headers` | object | `{}` | Custom HTTP headers |
| `waitFor` | integer | `0` | Milliseconds to wait before scraping |
| `timeout` | integer | `30000` | Request timeout in milliseconds |
| `maxAge` | integer | `172800000` | Cache freshness (2 days default) |
| `storeInCache` | boolean | `true` | Whether to cache the result |
| `location` | object | - | Geographic location preferences |
| `actions` | array | `[]` | Actions to perform before scraping |
| `mobile` | boolean | `false` | Use mobile user agent |

## Response Structure

### Success Response
```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nContent...",
    "html": "<html>...</html>",
    "rawHtml": "<html>...</html>",
    "screenshot": "data:image/png;base64,...",
    "links": ["https://example.com/page1", ...],
    "images": ["https://example.com/image1.jpg", ...],
    "metadata": {
      "title": "Page Title",
      "description": "Page description",
      "language": "en",
      "keywords": "keyword1, keyword2",
      "robots": "index, follow",
      "ogTitle": "Open Graph Title",
      "ogDescription": "OG Description",
      "ogImage": "https://example.com/og-image.jpg",
      "ogUrl": "https://example.com",
      "statusCode": 200,
      "sourceURL": "https://example.com"
    }
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message description",
  "statusCode": 400
}
```

## Advanced Features

### 1. Structured Data Extraction

Define schemas to extract specific information:

#### Python with Pydantic
```python
from pydantic import BaseModel, Field
from firecrawl import Firecrawl

class ArticleSchema(BaseModel):
    title: str
    author: str
    published_date: str
    summary: str
    tags: list[str]

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

result = firecrawl.scrape(
    url='https://example.com/article',
    formats=['extract'],
    extract={
        'schema': ArticleSchema.model_json_schema()
    }
)

print(result['extract'])
```

#### JSON Schema
```json
{
  "url": "https://example.com",
  "formats": ["extract"],
  "extract": {
    "schema": {
      "type": "object",
      "properties": {
        "title": {"type": "string"},
        "price": {"type": "number"},
        "availability": {"type": "string"}
      }
    }
  }
}
```

#### Prompt-Based Extraction (No Schema)
```python
result = firecrawl.scrape(
    url='https://example.com/product',
    formats=['extract'],
    extract={
        'prompt': 'Extract the product name, price, and customer rating'
    }
)
```

### 2. Page Interactions

Execute actions before scraping to access dynamic content:

```python
result = firecrawl.scrape(
    url='https://example.com',
    formats=['markdown'],
    actions=[
        {"type": "wait", "milliseconds": 2000},
        {"type": "click", "selector": "#load-more-button"},
        {"type": "wait", "milliseconds": 1000},
        {"type": "scroll", "direction": "down"},
        {"type": "write", "text": "search query", "selector": "#search-input"},
        {"type": "press", "key": "Enter"}
    ]
)
```

Available actions:
- `wait`: Pause for specified milliseconds
- `click`: Click an element
- `scroll`: Scroll up/down/left/right
- `write`: Type text into input
- `press`: Press keyboard key

### 3. Caching Control

#### Default Caching (2 days)
```python
result = firecrawl.scrape(url='https://example.com')
# Uses cache if page was scraped in last 2 days
```

#### Force Fresh Content
```python
result = firecrawl.scrape(
    url='https://example.com',
    maxAge=0  # Force fresh scrape
)
```

#### Disable Caching
```python
result = firecrawl.scrape(
    url='https://example.com',
    storeInCache=False  # Don't cache this result
)
```

#### Custom Cache Duration
```python
result = firecrawl.scrape(
    url='https://example.com',
    maxAge=3600000  # 1 hour in milliseconds
)
```

### 4. Location & Language Targeting

Specify geographic location for region-appropriate content:

```python
result = firecrawl.scrape(
    url='https://example.com',
    location={
        'country': 'US',  # ISO country code
        'languages': ['en-US']
    }
)
```

Benefits:
- Proper proxying from specified country
- Language-appropriate content
- Geo-targeted pricing/offers
- Regional compliance

### 5. Custom Headers

Add authentication or custom headers:

```python
result = firecrawl.scrape(
    url='https://example.com',
    headers={
        'Authorization': 'Bearer USER_TOKEN',
        'X-Custom-Header': 'value'
    }
)
```

### 6. Mobile Scraping

Use mobile user agent:

```python
result = firecrawl.scrape(
    url='https://example.com',
    mobile=True
)
```

### 7. Content Filtering

#### Include Only Specific Tags
```python
result = firecrawl.scrape(
    url='https://example.com',
    includeTags=['article', 'h1', 'h2', 'p']
)
```

#### Exclude Specific Tags
```python
result = firecrawl.scrape(
    url='https://example.com',
    excludeTags=['nav', 'footer', 'aside', 'script']
)
```

#### Only Main Content
```python
result = firecrawl.scrape(
    url='https://example.com',
    onlyMainContent=True  # Default, removes nav/footer/sidebar
)
```

### 8. Anti-Bot Protection (Stealth Mode)

For sites with advanced detection:

```bash
curl -X POST https://api.firecrawl.dev/v2/scrape \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -d '{
    "url": "https://protected-site.com",
    "stealth": true
  }'
```

Note: Stealth mode may be slower and consume more resources.

## Batch Scraping

Scrape multiple URLs simultaneously:

### Python Batch Example
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

urls = [
    'https://example.com/page1',
    'https://example.com/page2',
    'https://example.com/page3'
]

# Synchronous batch scrape
results = []
for url in urls:
    result = firecrawl.scrape(url=url, formats=['markdown'])
    results.append(result)

# Or use the batch endpoint
batch_result = firecrawl.batch_scrape(
    urls=urls,
    formats=['markdown']
)
```

### Batch Endpoint
```bash
POST https://api.firecrawl.dev/v2/batch/scrape
```

Returns a job ID for asynchronous processing:
```json
{
  "success": true,
  "jobId": "job_123456"
}
```

Poll for results:
```python
status = firecrawl.get_batch_scrape_status(job_id='job_123456')
```

## Async Operations

For non-blocking operations:

```python
from firecrawl import AsyncFirecrawl
import asyncio

async def scrape_urls():
    firecrawl = AsyncFirecrawl(api_key="fc-YOUR_API_KEY")

    urls = ['https://example.com/page1', 'https://example.com/page2']

    # Concurrent scraping
    tasks = [
        firecrawl.scrape(url=url, formats=['markdown'])
        for url in urls
    ]

    results = await asyncio.gather(*tasks)
    return results

# Run async function
results = asyncio.run(scrape_urls())
```

## Error Handling

### Python Error Handling
```python
from firecrawl import Firecrawl
from firecrawl.exceptions import FirecrawlError

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

try:
    result = firecrawl.scrape(url='https://example.com')
except FirecrawlError as e:
    print(f"Error: {e.message}")
    print(f"Status code: {e.status_code}")
```

### Common Errors

| Status Code | Error | Solution |
|-------------|-------|----------|
| 400 | Bad Request | Check URL format and parameters |
| 401 | Unauthorized | Verify API key |
| 402 | Payment Required | Out of credits, upgrade plan |
| 429 | Rate Limited | Slow down requests, check rate limits |
| 500 | Server Error | Retry request, contact support if persistent |

## Best Practices

### 1. Use Appropriate Formats
```python
# For LLM processing
result = firecrawl.scrape(url=url, formats=['markdown'])

# For HTML parsing
result = firecrawl.scrape(url=url, formats=['html'])

# For visual verification
result = firecrawl.scrape(url=url, formats=['screenshot'])

# Multiple formats
result = firecrawl.scrape(url=url, formats=['markdown', 'links', 'images'])
```

### 2. Leverage Caching
```python
# First scrape - fetches fresh
result1 = firecrawl.scrape(url='https://example.com')

# Second scrape within 2 days - uses cache (no credit cost)
result2 = firecrawl.scrape(url='https://example.com')

# Force fresh when needed
result3 = firecrawl.scrape(url='https://example.com', maxAge=0)
```

### 3. Handle Dynamic Content
```python
# Wait for content to load
result = firecrawl.scrape(
    url='https://dynamic-site.com',
    actions=[
        {"type": "wait", "milliseconds": 3000}
    ]
)

# Click to load more
result = firecrawl.scrape(
    url='https://site.com',
    actions=[
        {"type": "click", "selector": ".load-more"},
        {"type": "wait", "milliseconds": 1000}
    ]
)
```

### 4. Extract Structured Data
```python
# Use schemas for consistent extraction
from pydantic import BaseModel

class BookmarkData(BaseModel):
    title: str
    description: str
    main_topic: str
    keywords: list[str]

result = firecrawl.scrape(
    url=bookmark_url,
    formats=['extract'],
    extract={'schema': BookmarkData.model_json_schema()}
)
```

### 5. Batch Process
```python
# Process bookmarks in batches
bookmarks = [...]  # List of bookmark URLs
batch_size = 50

for i in range(0, len(bookmarks), batch_size):
    batch = bookmarks[i:i+batch_size]
    for url in batch:
        result = firecrawl.scrape(url=url)
        # Process result
```

## Rate Limits

See 06-rate-limits.md for detailed rate limit information.

**Quick Reference**:
- Free: 10 requests/minute
- Hobby: 100 requests/minute
- Standard: 500 requests/minute
- Growth: 5000 requests/minute

## Cost Optimization

### 1. Use Cache
- Set appropriate `maxAge` values
- Don't set `maxAge=0` unless necessary
- Save 50-80% on duplicate URLs

### 2. Only Request Needed Formats
```python
# Bad - requests all formats
result = firecrawl.scrape(url, formats=['markdown', 'html', 'screenshot', 'links'])

# Good - only what you need
result = firecrawl.scrape(url, formats=['markdown'])
```

### 3. Filter Content
```python
# Reduce processing time and cost
result = firecrawl.scrape(
    url=url,
    onlyMainContent=True,
    excludeTags=['script', 'style', 'nav', 'footer']
)
```

## Use Cases for Bookmark Organizer

### 1. Enrich Bookmarks with Content
```python
def enrich_bookmark(bookmark_url):
    result = firecrawl.scrape(
        url=bookmark_url,
        formats=['markdown', 'links'],
        onlyMainContent=True
    )

    return {
        'url': bookmark_url,
        'content': result['markdown'],
        'outbound_links': result['links'],
        'title': result['metadata']['title'],
        'description': result['metadata']['description']
    }
```

### 2. Extract Bookmark Metadata
```python
def extract_bookmark_info(bookmark_url):
    result = firecrawl.scrape(
        url=bookmark_url,
        formats=['markdown']
    )

    metadata = result['metadata']
    return {
        'title': metadata.get('title'),
        'description': metadata.get('description'),
        'keywords': metadata.get('keywords'),
        'og_image': metadata.get('ogImage')
    }
```

### 3. Detect Dead Bookmarks
```python
def check_bookmark_alive(bookmark_url):
    try:
        result = firecrawl.scrape(url=bookmark_url)
        status_code = result['metadata']['statusCode']
        return status_code == 200
    except FirecrawlError:
        return False
```

### 4. Generate Summaries
```python
from pydantic import BaseModel

class PageSummary(BaseModel):
    main_topic: str
    summary: str
    category: str

def summarize_bookmark(bookmark_url):
    result = firecrawl.scrape(
        url=bookmark_url,
        formats=['extract'],
        extract={
            'schema': PageSummary.model_json_schema(),
            'prompt': 'Summarize the main topic and categorize this page'
        }
    )

    return result['extract']
```

## Next Steps

- **Extract API**: See 04-api-extract.md for advanced structured extraction
- **Python SDK**: See 05-python-sdk.md for complete SDK reference
- **Rate Limits**: See 06-rate-limits.md for limits and concurrency
- **Examples**: Check GitHub for more examples
