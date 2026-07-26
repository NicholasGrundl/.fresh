# Firecrawl Overview

## What is Firecrawl?

Firecrawl is a web scraping and data extraction service designed to convert websites into LLM-ready data. It's available as both a hosted API service and open-source software that can be self-hosted.

**Official Website**: https://www.firecrawl.dev/
**Documentation**: https://docs.firecrawl.dev/
**GitHub**: https://github.com/firecrawl/firecrawl

## Key Statistics

- **GitHub Stars**: 68.1k+
- **Companies Using**: 5,000+
- **License**: AGPL-3.0 (primary), MIT (some components)
- **Web Coverage**: 96% of the web including JS-heavy and protected pages
- **Response Time**: Sub-second (under 1 second for most requests)

## Core Features

### 1. Scrape
Extract data from websites in multiple formats:
- **Markdown** - Clean text conversion ideal for LLMs
- **HTML** - Standard and raw HTML variants
- **JSON** - Structured data extraction
- **Screenshots** - Visual captures with fullPage option
- **Summary** - Condensed content
- **Links** - URL extraction
- **Images** - Image URL collection
- **Branding** - Brand identity (colors, fonts, typography, components)

### 2. Crawl
Systematically gather data from all pages on a website:
- Recursive crawling with configurable depth
- Rate limiting and concurrency control
- Progress tracking via job IDs
- Batch processing support

### 3. Map
Index and explore website structures:
- Quickly identify all URLs on a website
- Optional search filtering
- Subdomain exclusion options
- Sitemap utilization

### 4. Search
Web search with full content retrieval:
- Search the web and get full content from results
- Combines search + scraping in one operation
- Returns 10 results per 2 credits

### 5. Extract
AI-powered structured data extraction:
- Define schemas (Pydantic/Zod/JSON) or use natural language prompts
- Single or multiple URL processing
- Wildcard patterns for domain-wide extraction
- Optional web search enhancement

## What Makes Firecrawl Different?

### Traditional Scrapers (BeautifulSoup, Scrapy)
- Require brittle CSS/XPath selectors
- Break when websites change structure
- Struggle with JavaScript-rendered content
- Manual handling of proxies, rate limits, anti-bot measures

### Firecrawl Approach
- **LLM-powered extraction**: Describe what you want in plain English
- **Adaptive parsing**: Handles website changes automatically
- **Managed infrastructure**: Proxies, caching, rate limits handled automatically
- **JavaScript support**: Native handling of dynamic content
- **Document parsing**: PDFs, DOCX, images automatically processed

## Technical Capabilities

### Complexity Management
Handles automatically:
- Proxies and IP rotation
- Anti-bot mechanisms
- Caching (optional, configurable)
- Rate limiting
- JS-blocked content

### Dynamic Content
- JavaScript-rendered sites
- Dynamic websites with AJAX
- Single Page Applications (SPAs)
- Pages with lazy loading

### Document Processing
- PDFs
- DOCX files
- Images
- Other web-hosted documents

### Advanced Features
- **Custom headers** for authentication
- **Configurable crawl depths**
- **Action support**: click, scroll, input, wait
- **Batch processing** for multiple URLs
- **Change tracking** for monitoring updates
- **Smart waiting** for content loading
- **Stealth mode** for advanced anti-bot protection

## Architecture

### Hosted Service
- Fully managed API at api.firecrawl.dev
- No infrastructure setup required
- Automatic scaling
- Global CDN and proxies

### Self-Hosted
- Open-source under AGPL-3.0
- Docker Compose deployment
- Kubernetes support
- Full control over data and infrastructure

## Use Cases

### AI & LLM Applications
- Convert websites to LLM-ready markdown
- Extract structured data for RAG systems
- Build knowledge bases from web content
- Data enrichment for AI assistants

### Business Intelligence
- Lead enrichment
- Competitive intelligence
- Market research
- Price monitoring

### Content Operations
- SEO analysis
- Content aggregation
- Website monitoring
- Change detection

### Development
- API integration
- Automated testing
- Documentation generation
- Data pipeline construction

## Integration Ecosystem

### SDKs
- Python (`firecrawl-py`)
- Node.js (`@mendable/firecrawl-js`)
- Go (community)
- Rust (community)

### Framework Support
- LangChain
- Llama Index
- Crew.ai
- Haystack
- DSPy

### Low-Code Platforms
- Dify
- Langflow
- Flowise AI
- n8n

### IDE Integration
- Claude Desktop (MCP)
- Cursor
- Windsurf

## Performance Characteristics

### Speed
- Sub-second response times for most requests
- Parallel processing support
- Async operations available

### Reliability
- 96% web coverage
- Automatic retry logic
- Graceful degradation
- Error handling built-in

### Scalability
- Concurrent browser limits based on plan
- Rate limits by tier
- Auto-pagination support
- Job queuing for large crawls

## Limitations & Considerations

### Current Limitations
- Large-scale site coverage (entire product catalogs) can be challenging
- Complex temporal queries may be inconsistent
- Dynamic sites may show slight variations across runs
- Self-hosted version lacks some advanced anti-bot features

### Cost Considerations
- Credit-based pricing (see 02-pricing.md)
- Failed requests don't consume credits
- Can be expensive at scale without self-hosting
- Free tier sufficient for testing (500 credits)

### Technical Constraints
- API dependency for hosted service
- Rate limits on free/lower tiers
- Internet connection required (hosted)
- Learning curve for advanced features

## When to Use Firecrawl

### Good Fit
- JavaScript-heavy websites
- LLM/AI applications requiring markdown
- Structured data extraction with schemas
- Batch processing of URLs
- When you need reliability over control
- Rapid prototyping

### Not the Best Fit
- Simple static HTML parsing (BeautifulSoup is simpler)
- Very high volume with budget constraints (self-host or use traditional tools)
- Real-time scraping of single pages repeatedly (cache won't help)
- When you need to scrape without internet dependency

## Getting Started

### 1. Sign Up
Visit https://www.firecrawl.dev/ and create an account

### 2. Get API Key
Generate an API key from the dashboard

### 3. Install SDK
```bash
pip install firecrawl-py
```

### 4. First Scrape
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")
result = firecrawl.scrape('https://example.com', formats=['markdown'])
print(result['markdown'])
```

## Next Steps

- **Pricing Details**: See 02-pricing.md for detailed cost breakdown
- **Scrape API**: See 03-api-scrape.md for scraping documentation
- **Extract API**: See 04-api-extract.md for structured data extraction
- **Python SDK**: See 05-python-sdk.md for complete SDK reference
- **Self-Hosting**: See 07-self-hosting.md for deployment guide
- **Comparisons**: See 08-comparisons.md for tool comparison
