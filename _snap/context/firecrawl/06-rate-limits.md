# Firecrawl Rate Limits

Complete documentation on rate limits and concurrency restrictions.

**Official Docs**: https://docs.firecrawl.dev/rate-limits

## Overview

Firecrawl implements rate limits to:
- Prevent abuse and ensure fair usage
- Maintain service stability
- Protect against accidental overuse

Rate limits vary by subscription tier and endpoint.

## Concurrent Browser Limits

Maximum number of pages that can be processed simultaneously:

| Plan | Concurrent Browsers | Use Case |
|------|-------------------|----------|
| Free | 2 | Testing, small projects |
| Hobby | 5 | Personal projects |
| Standard | 50 | Production apps |
| Growth | 100 | High-volume apps |
| Scale/Enterprise | 150+ | Enterprise scale |

**What this means**:
- During crawling, Firecrawl processes multiple pages at once
- Concurrent limit determines how many pages can be scraped simultaneously
- Higher concurrency = faster crawl completion
- Hitting the limit queues additional pages

**Example**:
```python
# With 50 concurrent browsers (Standard plan)
# Crawling 500 pages:
# - 50 pages processed simultaneously
# - Next 50 start when first batch completes
# - Much faster than processing sequentially
```

## API Rate Limits (Requests per Minute)

Rate limits for each endpoint by plan:

### Detailed Rate Limit Table

| Plan | /scrape | /map | /search | /crawl | /extract | /batch/scrape | /crawl/status | /extract/status |
|------|---------|------|---------|--------|----------|---------------|---------------|-----------------|
| **Free** | 10 | 10 | 1 | 5 | 10 | 5 | 1500 | 1500 |
| **Hobby** | 100 | 100 | 15 | 50 | 100 | 50 | 1500 | 1500 |
| **Standard** | 500 | 500 | 50 | 250 | 500 | 250 | 1500 | 1500 |
| **Growth** | 5000 | 5000 | 250 | 2500 | 1000 | 2500 | 25000 | 25000 |

### Endpoint Descriptions

**Scrape Endpoints**:
- `/scrape` - Single page scraping
- Rate limit applies per minute
- Most commonly used endpoint

**Map Endpoint**:
- `/map` - URL discovery
- Same limits as scrape
- Useful before crawling

**Search Endpoint**:
- `/search` - Web search with content
- Lower limits due to higher resource usage
- Free tier: Only 1 request/minute

**Crawl Endpoints**:
- `/crawl` - Start crawl job
- `/batch/scrape` - Batch scraping (same as crawl)
- Limits for starting jobs, not individual pages

**Extract Endpoint**:
- `/extract` - Structured data extraction
- Growth tier has lower limit (1000) due to LLM usage
- More resource-intensive than scraping

**Status Endpoints**:
- `/crawl/status` - Check crawl job status
- `/extract/status` - Check extract job status
- Much higher limits for polling
- Free/Hobby/Standard: 1500 req/min
- Growth: 25000 req/min

## Special Limitations

### FIRE-1 Agent

The FIRE-1 AI agent has independent rate limits:

**All Plans**: 10 requests/minute for:
- `/scrape` with FIRE-1 agent
- `/extract` with FIRE-1 agent

**Why lower?**
- FIRE-1 uses advanced AI for navigation
- More computationally expensive
- Prevents resource exhaustion

**Example**:
```python
# Regular scrape: 100 req/min (Hobby plan)
result = firecrawl.scrape('https://example.com')

# FIRE-1 scrape: 10 req/min (all plans)
result = firecrawl.scrape(
    'https://complex-site.com',
    agent='fire-1'
)
```

## Rate Limit Headers

API responses include rate limit information:

```
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 487
X-RateLimit-Reset: 1640000000
```

**Python SDK** (check headers):
```python
import requests

response = requests.post(
    'https://api.firecrawl.dev/v2/scrape',
    headers={'Authorization': 'Bearer YOUR_API_KEY'},
    json={'url': 'https://example.com'}
)

print(f"Limit: {response.headers.get('X-RateLimit-Limit')}")
print(f"Remaining: {response.headers.get('X-RateLimit-Remaining')}")
print(f"Resets at: {response.headers.get('X-RateLimit-Reset')}")
```

## Rate Limit Errors

### 429 Too Many Requests

When you exceed rate limits:

```json
{
  "success": false,
  "error": "Rate limit exceeded",
  "statusCode": 429,
  "retryAfter": 30
}
```

**Handling in Python**:
```python
from firecrawl import Firecrawl
from firecrawl.exceptions import RateLimitError
import time

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

try:
    result = firecrawl.scrape('https://example.com')

except RateLimitError as e:
    retry_after = e.retry_after or 60
    print(f"Rate limited. Waiting {retry_after} seconds...")
    time.sleep(retry_after)

    # Retry
    result = firecrawl.scrape('https://example.com')
```

## Calculating Rate Limits for Your Use Case

### Example 1: Scraping Bookmarks (Free Plan)

**Scenario**: 500 bookmarks, Free plan (10 req/min)

```python
# Calculation
bookmarks = 500
rate_limit = 10  # requests per minute
time_required = bookmarks / rate_limit  # 50 minutes

# Safe implementation with rate limiting
import time

def scrape_bookmarks_free(urls):
    results = []
    delay = 60 / 10  # 6 seconds between requests

    for url in urls:
        result = firecrawl.scrape(url)
        results.append(result)
        time.sleep(delay)  # Respect rate limit

    return results

# Time: ~50 minutes for 500 bookmarks
```

### Example 2: Batch Processing (Standard Plan)

**Scenario**: 10,000 bookmarks, Standard plan (500 req/min)

```python
# Calculation
bookmarks = 10000
rate_limit = 500  # requests per minute
time_required = bookmarks / rate_limit  # 20 minutes

# Implementation
def scrape_bookmarks_standard(urls):
    results = []
    batch_size = 500
    delay = 60  # 1 minute between batches

    for i in range(0, len(urls), batch_size):
        batch = urls[i:i+batch_size]

        # Process batch (500 requests in ~1 minute)
        for url in batch:
            result = firecrawl.scrape(url)
            results.append(result)

        # Wait before next batch
        if i + batch_size < len(urls):
            time.sleep(delay)

    return results

# Time: ~20 minutes for 10,000 bookmarks
```

### Example 3: Using Crawl Jobs (Avoids Rate Limits)

**Scenario**: Crawl 1000 URLs without hitting rate limits

```python
# Instead of 1000 individual scrape requests
# Use crawl job (only 1 request to start)

job = firecrawl.start_crawl(
    url='https://example.com/*',
    limit=1000
)

# Poll status (status endpoint has 1500 req/min limit)
while True:
    status = firecrawl.get_crawl_status(job['jobId'])

    if status['status'] == 'completed':
        pages = status['data']
        break

    time.sleep(2)  # Poll every 2 seconds

# Advantages:
# - Only 1 request to start
# - Backend handles concurrent processing
# - Respects concurrent browser limits
# - Much faster than sequential scraping
```

## Optimizing for Rate Limits

### 1. Use Appropriate Endpoints

**Bad** - Individual scrapes (hits rate limit):
```python
# 1000 requests, hits 500/min limit
for url in urls:  # 1000 URLs
    result = firecrawl.scrape(url)
```

**Good** - Crawl job (1 request):
```python
# 1 request to start, backend handles processing
job = firecrawl.start_crawl(url='https://example.com/*', limit=1000)
```

### 2. Batch Requests Intelligently

```python
import time

def rate_limited_batch(urls, rate_limit=500):
    batch_size = rate_limit
    delay = 60  # 1 minute

    for i in range(0, len(urls), batch_size):
        batch = urls[i:i+batch_size]

        # Process batch
        for url in batch:
            firecrawl.scrape(url)

        # Wait before next batch
        if i + batch_size < len(urls):
            time.sleep(delay)
```

### 3. Use Async with Semaphore

```python
import asyncio
from firecrawl import AsyncFirecrawl

async def rate_limited_async(urls, rate_limit=500):
    firecrawl = AsyncFirecrawl(api_key="fc-YOUR_API_KEY")

    # Semaphore limits concurrent requests
    semaphore = asyncio.Semaphore(rate_limit)

    async def scrape_one(url):
        async with semaphore:
            return await firecrawl.scrape(url)

    # Process in batches
    batch_size = rate_limit
    for i in range(0, len(urls), batch_size):
        batch = urls[i:i+batch_size]
        tasks = [scrape_one(url) for url in batch]

        # Run batch
        await asyncio.gather(*tasks)

        # Wait before next batch
        if i + batch_size < len(urls):
            await asyncio.sleep(60)
```

### 4. Implement Exponential Backoff

```python
import time

def scrape_with_backoff(url, max_retries=5):
    for attempt in range(max_retries):
        try:
            return firecrawl.scrape(url)

        except RateLimitError as e:
            if attempt == max_retries - 1:
                raise

            # Exponential backoff
            wait_time = 2 ** attempt
            print(f"Rate limited, waiting {wait_time}s...")
            time.sleep(wait_time)
```

### 5. Monitor Rate Limit Headers

```python
import requests

class RateLimitedFirecrawl:
    def __init__(self, api_key):
        self.api_key = api_key
        self.remaining = None
        self.limit = None

    def scrape(self, url):
        response = requests.post(
            'https://api.firecrawl.dev/v2/scrape',
            headers={'Authorization': f'Bearer {self.api_key}'},
            json={'url': url}
        )

        # Update rate limit info
        self.limit = int(response.headers.get('X-RateLimit-Limit', 0))
        self.remaining = int(response.headers.get('X-RateLimit-Remaining', 0))

        # Warn if low
        if self.remaining < 10:
            print(f"Warning: Only {self.remaining} requests remaining")

        return response.json()
```

## Concurrent Processing Best Practices

### 1. Respect Concurrent Browser Limits

```python
# Standard plan: 50 concurrent browsers
# Don't exceed this in your implementation

import asyncio

async def crawl_concurrent(urls, max_concurrent=50):
    semaphore = asyncio.Semaphore(max_concurrent)

    async def scrape_one(url):
        async with semaphore:
            return await firecrawl.scrape(url)

    tasks = [scrape_one(url) for url in urls]
    return await asyncio.gather(*tasks)
```

### 2. Use Crawl Jobs for Large Sets

```python
# For > 100 URLs, use crawl jobs instead of individual scrapes

if len(urls) > 100:
    # Use crawl job
    job = firecrawl.start_crawl(url=base_url, limit=len(urls))
    # Wait for completion
    result = wait_for_crawl(job['jobId'])
else:
    # Individual scrapes OK
    results = [firecrawl.scrape(url) for url in urls]
```

### 3. Distribute Load Over Time

```python
# For non-urgent tasks, spread requests over time

def distributed_scrape(urls, hours=24):
    delay = (hours * 3600) / len(urls)  # seconds per request

    for url in urls:
        result = firecrawl.scrape(url)
        time.sleep(delay)

# Scrapes 1000 URLs over 24 hours
distributed_scrape(urls, hours=24)
```

## Increasing Rate Limits

### Contact Support

For higher limits:
- Email: help@firecrawl.com
- Provide:
  - Current plan
  - Use case description
  - Desired rate limits
  - Expected volume

### Upgrade Plan

Rate limits increase with plan tiers:

| Upgrade Path | Scrape Increase | Concurrent Increase |
|--------------|----------------|-------------------|
| Free → Hobby | 10x (10 → 100) | 2.5x (2 → 5) |
| Hobby → Standard | 5x (100 → 500) | 10x (5 → 50) |
| Standard → Growth | 10x (500 → 5000) | 2x (50 → 100) |

### Enterprise Plan

Custom rate limits available:
- Unlimited concurrent browsers
- Custom API rate limits
- Dedicated infrastructure
- No shared limits

## Monitoring and Alerts

### Track Usage

```python
class UsageTracker:
    def __init__(self):
        self.requests_made = 0
        self.start_time = time.time()

    def track(self):
        self.requests_made += 1
        elapsed = time.time() - self.start_time

        if elapsed >= 60:
            # Reset counter every minute
            print(f"Requests this minute: {self.requests_made}")
            self.requests_made = 0
            self.start_time = time.time()

tracker = UsageTracker()

for url in urls:
    result = firecrawl.scrape(url)
    tracker.track()
```

### Alert on Approaching Limits

```python
def scrape_with_alerts(url, limit=500, threshold=0.9):
    # Get current usage from headers
    response = requests.post(...)

    remaining = int(response.headers.get('X-RateLimit-Remaining', 0))
    limit_total = int(response.headers.get('X-RateLimit-Limit', 0))

    usage_percent = 1 - (remaining / limit_total)

    if usage_percent >= threshold:
        # Alert (email, Slack, etc.)
        print(f"WARNING: {usage_percent*100}% of rate limit used!")

    return response.json()
```

## Comparison: Rate Limits by Plan

### Free Plan
**Best for**: Testing, < 100 requests/day
- 10 scrape/min = 600/hour = 14,400/day
- 2 concurrent = slower crawls
- 1 search/min = very limited

### Hobby Plan
**Best for**: Personal projects, < 1000 requests/day
- 100 scrape/min = 6,000/hour = 144,000/day
- 5 concurrent = reasonable performance
- 15 search/min = usable

### Standard Plan
**Best for**: Production apps, < 10,000 requests/day
- 500 scrape/min = 30,000/hour = 720,000/day
- 50 concurrent = fast crawls
- 50 search/min = production-ready

### Growth Plan
**Best for**: High-volume, < 100,000 requests/day
- 5000 scrape/min = 300,000/hour = 7,200,000/day
- 100 concurrent = very fast
- 250 search/min = extensive usage

## For Bookmark Organizer

### Recommended Approach

**Small Collection (< 1000 bookmarks)**:
- Free or Hobby plan
- Sequential processing with rate limiting
- ~1-10 minutes total time

**Medium Collection (1000-10,000 bookmarks)**:
- Standard plan
- Batch processing
- ~20-60 minutes total time

**Large Collection (> 10,000 bookmarks)**:
- Growth plan OR self-hosting
- Async concurrent processing
- ~1-2 hours with API, unlimited with self-hosting

### Example Implementation

```python
def process_bookmarks(urls, plan='standard'):
    # Configure based on plan
    limits = {
        'free': {'rate': 10, 'concurrent': 2},
        'hobby': {'rate': 100, 'concurrent': 5},
        'standard': {'rate': 500, 'concurrent': 50},
        'growth': {'rate': 5000, 'concurrent': 100}
    }

    config = limits[plan]

    # Use appropriate method
    if len(urls) < 100:
        # Sequential with rate limiting
        return scrape_sequential(urls, config['rate'])
    else:
        # Concurrent async
        return asyncio.run(
            scrape_concurrent(urls, config['concurrent'])
        )
```

## Next Steps

- **Pricing**: See 02-pricing.md for plan costs
- **Python SDK**: See 05-python-sdk.md for implementation
- **API Reference**: See 03-api-scrape.md and 04-api-extract.md
