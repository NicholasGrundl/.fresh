# Firecrawl Python SDK

Complete reference for the Firecrawl Python SDK.

**Official Docs**: https://docs.firecrawl.dev/sdks/python
**PyPI Package**: https://pypi.org/project/firecrawl-py/
**GitHub**: https://github.com/mendableai/firecrawl-py

## Installation

```bash
pip install firecrawl-py
```

**Requirements**:
- Python 3.7+
- API key from https://www.firecrawl.dev/

## Authentication

### Environment Variable (Recommended)
```bash
export FIRECRAWL_API_KEY="fc-YOUR_API_KEY"
```

```python
from firecrawl import Firecrawl

# Automatically uses FIRECRAWL_API_KEY
firecrawl = Firecrawl()
```

### Direct Parameter
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")
```

## Core Methods

### 1. scrape()

Extract content from a single URL.

**Signature**:
```python
def scrape(
    url: str,
    formats: list[str] = ["markdown"],
    onlyMainContent: bool = True,
    includeTags: list[str] = [],
    excludeTags: list[str] = [],
    headers: dict = {},
    waitFor: int = 0,
    timeout: int = 30000,
    maxAge: int = 172800000,
    storeInCache: bool = True,
    location: dict = {},
    actions: list[dict] = [],
    mobile: bool = False
) -> dict
```

**Examples**:

```python
# Basic scrape
result = firecrawl.scrape('https://example.com')
print(result['markdown'])

# Multiple formats
result = firecrawl.scrape(
    url='https://example.com',
    formats=['markdown', 'html', 'links', 'screenshot']
)

# With custom headers
result = firecrawl.scrape(
    url='https://api.example.com',
    headers={'Authorization': 'Bearer TOKEN'}
)

# With page actions
result = firecrawl.scrape(
    url='https://dynamic-site.com',
    actions=[
        {"type": "wait", "milliseconds": 2000},
        {"type": "click", "selector": "#load-more"},
        {"type": "wait", "milliseconds": 1000}
    ]
)

# Force fresh content
result = firecrawl.scrape(
    url='https://example.com',
    maxAge=0  # Bypass cache
)
```

**Returns**:
```python
{
    'success': True,
    'markdown': '# Page Title\n\nContent...',
    'html': '<html>...</html>',
    'metadata': {
        'title': 'Page Title',
        'description': 'Description',
        'statusCode': 200,
        'sourceURL': 'https://example.com'
    }
}
```

### 2. crawl()

Crawl an entire website (blocking).

**Signature**:
```python
def crawl(
    url: str,
    limit: int = 100,
    formats: list[str] = ["markdown"],
    onlyMainContent: bool = True,
    includePaths: list[str] = [],
    excludePaths: list[str] = [],
    maxDepth: int = 10,
    allowBackwardLinks: bool = False,
    allowExternalLinks: bool = False,
    ignoreSitemap: bool = False,
    scrapeOptions: dict = {},
    poll_interval: int = 2,
    timeout: int = 300
) -> dict
```

**Examples**:

```python
# Basic crawl (blocks until complete)
result = firecrawl.crawl(
    url='https://example.com',
    limit=50
)

# All pages as list
pages = result['data']
for page in pages:
    print(page['metadata']['title'])

# With path filtering
result = firecrawl.crawl(
    url='https://blog.example.com',
    includePaths=['/posts/*', '/articles/*'],
    excludePaths=['/admin/*', '/private/*'],
    limit=100
)

# With custom scrape options
result = firecrawl.crawl(
    url='https://example.com',
    scrapeOptions={
        'formats': ['markdown', 'links'],
        'onlyMainContent': True,
        'excludeTags': ['nav', 'footer']
    }
)

# Control crawl depth
result = firecrawl.crawl(
    url='https://example.com',
    maxDepth=3,  # Only crawl 3 levels deep
    limit=200
)
```

**Returns**:
```python
{
    'success': True,
    'data': [
        {
            'markdown': '# Page 1...',
            'metadata': {...}
        },
        {
            'markdown': '# Page 2...',
            'metadata': {...}
        }
    ],
    'metadata': {
        'total': 50,
        'completed': 50,
        'failed': 0
    }
}
```

### 3. start_crawl()

Start a crawl job (non-blocking).

**Signature**:
```python
def start_crawl(
    url: str,
    limit: int = 100,
    formats: list[str] = ["markdown"],
    **kwargs
) -> dict
```

**Example**:

```python
# Start crawl job
job = firecrawl.start_crawl(
    url='https://example.com',
    limit=1000
)

job_id = job['jobId']
print(f"Crawl started: {job_id}")

# Poll for status later
status = firecrawl.get_crawl_status(job_id)
```

**Returns**:
```python
{
    'success': True,
    'jobId': 'job_abc123xyz',
    'url': 'https://api.firecrawl.dev/v2/crawl/job_abc123xyz'
}
```

### 4. get_crawl_status()

Check status of crawl job.

**Signature**:
```python
def get_crawl_status(job_id: str) -> dict
```

**Example**:

```python
status = firecrawl.get_crawl_status('job_abc123xyz')

print(f"Status: {status['status']}")
print(f"Progress: {status['completed']} / {status['total']}")

if status['status'] == 'completed':
    pages = status['data']
    for page in pages:
        print(page['metadata']['title'])
```

**Returns**:
```python
{
    'success': True,
    'status': 'scraping',  # or 'completed', 'failed'
    'total': 100,
    'completed': 45,
    'creditsUsed': 45,
    'expiresAt': '2024-01-01T12:00:00Z',
    'data': [...]  # Only when completed
}
```

### 5. cancel_crawl()

Cancel a running crawl job.

**Signature**:
```python
def cancel_crawl(job_id: str) -> dict
```

**Example**:

```python
result = firecrawl.cancel_crawl('job_abc123xyz')
print(result['message'])  # "Crawl job cancelled"
```

### 6. map()

Get all URLs from a website.

**Signature**:
```python
def map(
    url: str,
    search: str = None,
    ignoreSitemap: bool = False,
    includeSubdomains: bool = False,
    limit: int = 5000
) -> dict
```

**Examples**:

```python
# Get all URLs
result = firecrawl.map('https://example.com')
urls = result['links']

# Search for specific URLs
result = firecrawl.map(
    url='https://example.com',
    search='blog'  # Only URLs containing 'blog'
)

# Include subdomains
result = firecrawl.map(
    url='https://example.com',
    includeSubdomains=True
)
```

**Returns**:
```python
{
    'success': True,
    'links': [
        'https://example.com/',
        'https://example.com/about',
        'https://example.com/blog',
        'https://example.com/contact'
    ]
}
```

### 7. extract()

Extract structured data using AI.

**Signature**:
```python
def extract(
    urls: list[str],
    prompt: str = None,
    schema: dict = None,
    enableWebSearch: bool = False,
    limit: int = 100,
    allowExternalLinks: bool = False
) -> dict
```

**Examples**:

```python
from pydantic import BaseModel, Field

# Define schema
class Product(BaseModel):
    name: str
    price: float
    description: str

# Extract with schema
result = firecrawl.extract(
    urls=['https://example.com/products/*'],
    schema=Product.model_json_schema(),
    limit=50
)

# Extract with prompt only
result = firecrawl.extract(
    urls=['https://blog.example.com/*'],
    prompt='Extract article titles, authors, and publication dates'
)

# Extract with both
result = firecrawl.extract(
    urls=['https://example.com'],
    prompt='Extract all pricing information',
    schema={
        'type': 'object',
        'properties': {
            'plans': {
                'type': 'array',
                'items': {
                    'type': 'object',
                    'properties': {
                        'name': {'type': 'string'},
                        'price': {'type': 'number'}
                    }
                }
            }
        }
    }
)
```

**Returns**:
```python
{
    'success': True,
    'data': [
        {
            'url': 'https://example.com/product/1',
            'extract': {
                'name': 'Product 1',
                'price': 99.99,
                'description': 'Description...'
            }
        },
        {
            'url': 'https://example.com/product/2',
            'extract': {
                'name': 'Product 2',
                'price': 149.99,
                'description': 'Description...'
            }
        }
    ]
}
```

### 8. batch_scrape()

Scrape multiple URLs in batch.

**Signature**:
```python
def batch_scrape(
    urls: list[str],
    formats: list[str] = ["markdown"],
    **kwargs
) -> dict
```

**Example**:

```python
urls = [
    'https://example.com/page1',
    'https://example.com/page2',
    'https://example.com/page3'
]

# Start batch job
job = firecrawl.batch_scrape(urls=urls)
job_id = job['jobId']

# Poll for results
status = firecrawl.get_batch_scrape_status(job_id)
```

## Async Support

For non-blocking operations, use `AsyncFirecrawl`.

### Installation
```bash
pip install firecrawl-py[async]
```

### Basic Usage

```python
from firecrawl import AsyncFirecrawl
import asyncio

async def scrape_urls():
    firecrawl = AsyncFirecrawl(api_key="fc-YOUR_API_KEY")

    # Scrape single URL
    result = await firecrawl.scrape('https://example.com')
    print(result['markdown'])

    # Scrape multiple URLs concurrently
    urls = ['https://example.com/page1', 'https://example.com/page2']

    tasks = [
        firecrawl.scrape(url)
        for url in urls
    ]

    results = await asyncio.gather(*tasks)

    for result in results:
        print(result['metadata']['title'])

# Run
asyncio.run(scrape_urls())
```

### Async Methods

All synchronous methods have async equivalents:

```python
# Async scrape
result = await firecrawl.scrape(url)

# Async crawl
result = await firecrawl.crawl(url)

# Async map
result = await firecrawl.map(url)

# Async extract
result = await firecrawl.extract(urls, schema)
```

### WebSocket Watcher

Monitor crawl progress in real-time:

```python
from firecrawl import AsyncFirecrawl
import asyncio

async def watch_crawl():
    firecrawl = AsyncFirecrawl(api_key="fc-YOUR_API_KEY")

    # Start crawl
    job = await firecrawl.start_crawl(
        url='https://example.com',
        limit=100
    )

    job_id = job['jobId']

    # Watch progress
    async for status in firecrawl.watcher(job_id):
        print(f"Status: {status['status']}")
        print(f"Progress: {status['completed']} / {status['total']}")

        if status['status'] == 'completed':
            print("Crawl complete!")
            break

asyncio.run(watch_crawl())
```

## Pagination

The SDK supports auto-pagination for large result sets.

### Auto-Pagination (Default)

```python
# Automatically aggregates all pages
result = firecrawl.crawl(
    url='https://example.com',
    limit=1000  # Will paginate automatically
)

# All pages in result['data']
print(f"Total pages: {len(result['data'])}")
```

### Manual Pagination

```python
from firecrawl.pagination import PaginationConfig

# Configure pagination
pagination = PaginationConfig(
    max_pages=10,  # Max pages to fetch
    max_results=100,  # Max results to return
    max_wait_time=60  # Max seconds to wait
)

result = firecrawl.crawl(
    url='https://example.com',
    limit=1000,
    pagination=pagination
)
```

## Error Handling

### Exception Types

```python
from firecrawl.exceptions import (
    FirecrawlError,
    AuthenticationError,
    RateLimitError,
    PaymentRequiredError,
    ServerError
)
```

### Error Handling Example

```python
from firecrawl import Firecrawl
from firecrawl.exceptions import FirecrawlError, RateLimitError

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

try:
    result = firecrawl.scrape('https://example.com')

except RateLimitError as e:
    print(f"Rate limited: {e.message}")
    print("Please wait before retrying")

except PaymentRequiredError as e:
    print(f"Out of credits: {e.message}")
    print("Please upgrade your plan")

except AuthenticationError as e:
    print(f"Auth failed: {e.message}")
    print("Check your API key")

except FirecrawlError as e:
    print(f"Firecrawl error: {e.message}")
    print(f"Status code: {e.status_code}")

except Exception as e:
    print(f"Unexpected error: {e}")
```

### Retry Logic

```python
import time
from firecrawl.exceptions import RateLimitError, ServerError

def scrape_with_retry(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            return firecrawl.scrape(url)

        except RateLimitError:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"Rate limited, waiting {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise

        except ServerError:
            if attempt < max_retries - 1:
                print(f"Server error, retrying ({attempt + 1}/{max_retries})...")
                time.sleep(1)
            else:
                raise

# Use with retry
result = scrape_with_retry('https://example.com')
```

## Advanced Patterns

### 1. Batch Processing with Progress

```python
from tqdm import tqdm

def process_bookmarks(urls):
    results = []

    for url in tqdm(urls, desc="Processing bookmarks"):
        try:
            result = firecrawl.scrape(
                url=url,
                formats=['markdown'],
                onlyMainContent=True
            )
            results.append(result)

        except FirecrawlError as e:
            print(f"Failed to scrape {url}: {e}")
            continue

    return results

# Process 100 bookmarks with progress bar
bookmarks = [...]  # List of URLs
results = process_bookmarks(bookmarks)
```

### 2. Concurrent Async Processing

```python
import asyncio
from firecrawl import AsyncFirecrawl

async def scrape_concurrent(urls, max_concurrent=10):
    firecrawl = AsyncFirecrawl(api_key="fc-YOUR_API_KEY")

    # Semaphore to limit concurrency
    semaphore = asyncio.Semaphore(max_concurrent)

    async def scrape_one(url):
        async with semaphore:
            try:
                return await firecrawl.scrape(url)
            except Exception as e:
                print(f"Error scraping {url}: {e}")
                return None

    # Run all with concurrency limit
    tasks = [scrape_one(url) for url in urls]
    results = await asyncio.gather(*tasks)

    # Filter out failures
    return [r for r in results if r is not None]

# Process 1000 URLs with max 10 concurrent
urls = [...]
results = asyncio.run(scrape_concurrent(urls, max_concurrent=10))
```

### 3. Caching Results Locally

```python
import json
import hashlib
from pathlib import Path

def scrape_with_cache(url, cache_dir='./cache'):
    cache_path = Path(cache_dir)
    cache_path.mkdir(exist_ok=True)

    # Generate cache key
    url_hash = hashlib.md5(url.encode()).hexdigest()
    cache_file = cache_path / f"{url_hash}.json"

    # Check cache
    if cache_file.exists():
        with open(cache_file, 'r') as f:
            return json.load(f)

    # Scrape and cache
    result = firecrawl.scrape(url)

    with open(cache_file, 'w') as f:
        json.dump(result, f)

    return result

# Use cached scraping
result = scrape_with_cache('https://example.com')
```

### 4. Progress Tracking for Large Crawls

```python
def crawl_with_progress(url, limit=1000):
    # Start crawl job
    job = firecrawl.start_crawl(url=url, limit=limit)
    job_id = job['jobId']

    print(f"Crawl started: {job_id}")

    # Poll with progress
    import time
    from tqdm import tqdm

    pbar = tqdm(total=limit, desc="Crawling")

    while True:
        status = firecrawl.get_crawl_status(job_id)

        # Update progress
        completed = status.get('completed', 0)
        pbar.n = completed
        pbar.refresh()

        if status['status'] == 'completed':
            pbar.close()
            return status['data']

        elif status['status'] == 'failed':
            pbar.close()
            raise Exception(f"Crawl failed: {status.get('error')}")

        time.sleep(2)

# Crawl with progress bar
pages = crawl_with_progress('https://example.com', limit=500)
```

## Configuration

### Custom Base URL (Self-Hosted)

```python
firecrawl = Firecrawl(
    api_key="fc-YOUR_API_KEY",
    base_url="https://your-firecrawl-instance.com"
)
```

### Custom Timeout

```python
result = firecrawl.scrape(
    url='https://slow-site.com',
    timeout=60000  # 60 seconds
)
```

### Custom User Agent

```python
result = firecrawl.scrape(
    url='https://example.com',
    headers={
        'User-Agent': 'CustomBot/1.0'
    }
)
```

## Best Practices

### 1. Use Environment Variables

```python
# .env file
FIRECRAWL_API_KEY=fc-YOUR_API_KEY

# Code
from firecrawl import Firecrawl
from dotenv import load_dotenv

load_dotenv()
firecrawl = Firecrawl()  # Uses env var
```

### 2. Handle Rate Limits

```python
import time

def rate_limited_scrape(urls, requests_per_minute=100):
    delay = 60 / requests_per_minute
    results = []

    for url in urls:
        result = firecrawl.scrape(url)
        results.append(result)
        time.sleep(delay)

    return results
```

### 3. Validate Responses

```python
def safe_scrape(url):
    result = firecrawl.scrape(url)

    if not result.get('success'):
        raise Exception(f"Scrape failed: {result.get('error')}")

    if not result.get('markdown'):
        raise Exception("No markdown content returned")

    return result
```

### 4. Use Type Hints

```python
from typing import List, Dict, Any
from firecrawl import Firecrawl

def process_urls(
    firecrawl: Firecrawl,
    urls: List[str]
) -> List[Dict[str, Any]]:
    results: List[Dict[str, Any]] = []

    for url in urls:
        result = firecrawl.scrape(url)
        results.append(result)

    return results
```

## Examples for Bookmark Organizer

### 1. Enrich Single Bookmark

```python
def enrich_bookmark(url: str) -> dict:
    result = firecrawl.scrape(
        url=url,
        formats=['markdown', 'links'],
        onlyMainContent=True,
        maxAge=86400000  # 1 day cache
    )

    return {
        'url': url,
        'title': result['metadata']['title'],
        'description': result['metadata'].get('description', ''),
        'content': result['markdown'],
        'links': result.get('links', []),
        'status_code': result['metadata']['statusCode']
    }
```

### 2. Batch Enrich Bookmarks

```python
def enrich_bookmarks_batch(urls: list[str]) -> list[dict]:
    enriched = []

    for url in tqdm(urls, desc="Enriching bookmarks"):
        try:
            data = enrich_bookmark(url)
            enriched.append(data)
        except Exception as e:
            print(f"Failed to enrich {url}: {e}")
            enriched.append({
                'url': url,
                'error': str(e)
            })

    return enriched
```

### 3. Extract Bookmark Metadata

```python
from pydantic import BaseModel

class BookmarkMeta(BaseModel):
    title: str
    summary: str
    category: str
    keywords: list[str]

def extract_bookmark_meta(urls: list[str]) -> list[dict]:
    result = firecrawl.extract(
        urls=urls,
        schema=BookmarkMeta.model_json_schema(),
        prompt='Analyze and categorize this bookmark'
    )

    return result['data']
```

## See Also

- **Scrape API**: See 03-api-scrape.md for scraping details
- **Extract API**: See 04-api-extract.md for extraction details
- **Rate Limits**: See 06-rate-limits.md for limits
- **Pricing**: See 02-pricing.md for costs
