# Firecrawl Documentation

Quick reference guide for Firecrawl - The Web Data API for AI.

## Overview

**Firecrawl** is a web scraping and data extraction service that converts websites into LLM-ready data. It transforms entire websites into clean markdown or structured information without requiring sitemaps.

- **GitHub Stars**: 68.1k+
- **License**: AGPL-3.0 (with MIT for some components)
- **Hosted Service**: https://www.firecrawl.dev/
- **Documentation**: https://docs.firecrawl.dev/
- **GitHub**: https://github.com/firecrawl/firecrawl

## Key Capabilities

- **Scrape**: Extract content from URLs in markdown, structured data, screenshots, or HTML
- **Crawl**: Process entire websites and all accessible subpages
- **Map**: Quickly identify all URLs on a website
- **Search**: Web search with full content retrieval
- **Extract**: AI-powered structured data extraction using schemas or prompts

## Why Firecrawl?

- Handles proxies, anti-bot mechanisms, dynamic content (JS-rendered)
- Processes PDFs, DOCX, images
- 96% web coverage including JS-heavy and protected pages
- Sub-second response times
- Smart waiting for content loading
- Optional caching

## Quick Start

### Installation
```bash
pip install firecrawl-py
```

### Basic Usage
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

# Scrape a page
result = firecrawl.scrape(
    'https://example.com',
    formats=['markdown', 'html']
)

print(result['markdown'])
```

## Pricing Summary

| Plan | Cost/Month | Credits | Concurrent | Extra Credits |
|------|-----------|---------|------------|---------------|
| Free | $0 | 500 | 2 | N/A |
| Hobby | $16 | 3,000 | 5 | $9/1k |
| Standard | $83 | 100,000 | 50 | $47/35k |
| Growth | $333 | 500,000 | 100 | $177/175k |
| Enterprise | Custom | Unlimited | Custom | N/A |

**Credit Costs:**
- Scrape: 1 credit/page
- Crawl: 1 credit/page
- Map: 1 credit/page
- Search: 2 credits/10 results
- Extract: Variable (15 tokens/credit)

## Use Cases for Bookmark Organizer

### Pros
- **LLM-ready output**: Perfect for extracting page content in markdown for analysis
- **JavaScript handling**: Works with dynamic sites that BeautifulSoup can't handle
- **Batch processing**: Can process multiple bookmarks simultaneously
- **Structured extraction**: AI-powered extraction of titles, descriptions, metadata
- **Low maintenance**: No need to manage browsers or proxies

### Cons
- **Cost**: Credits required for each page (500 free, then paid)
- **API dependency**: Requires internet connection and API key
- **Rate limits**: Free tier limited to 10 requests/minute for scrape
- **Overkill for simple cases**: BeautifulSoup might be sufficient for static bookmark files

## Documentation Files

1. **01-overview.md** - Core features and capabilities
2. **02-pricing.md** - Detailed pricing tiers and costs
3. **03-api-scrape.md** - Scrape endpoint documentation
4. **04-api-extract.md** - Extract endpoint for structured data
5. **05-python-sdk.md** - Python SDK reference
6. **06-rate-limits.md** - Rate limits and concurrency
7. **07-self-hosting.md** - Self-hosting guide
8. **08-comparisons.md** - vs BeautifulSoup, Playwright, etc.

## Decision Points for Bookmark Organizer

### When to use Firecrawl:
- Enriching bookmarks with page content/summaries
- Extracting structured data from bookmarked pages
- Dealing with JS-heavy sites
- Batch processing many URLs
- Want LLM-ready markdown output

### When to use BeautifulSoup:
- Parsing the bookmark HTML file itself
- Static page scraping
- No API dependency desired
- Cost-sensitive (free forever)

### Hybrid Approach:
- Use BeautifulSoup for parsing bookmark HTML files
- Use Firecrawl for enriching bookmark URLs with content
- Self-host Firecrawl if processing many bookmarks (avoid API costs)

## Quick Links

- [Official Docs](https://docs.firecrawl.dev/)
- [Python SDK](https://docs.firecrawl.dev/sdks/python)
- [Pricing](https://www.firecrawl.dev/pricing)
- [GitHub](https://github.com/firecrawl/firecrawl)
- [Self-Hosting Guide](https://docs.firecrawl.dev/contributing/self-host)
