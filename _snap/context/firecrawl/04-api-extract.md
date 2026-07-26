# Firecrawl Extract API

Complete documentation for the Firecrawl `/extract` endpoint - AI-powered structured data extraction.

**Official Docs**: https://docs.firecrawl.dev/features/extract

## Overview

The `/extract` endpoint enables developers to gather structured data from single or multiple URLs using LLM-powered parsing. It's designed for extracting specific information at scale without writing brittle selectors.

**Key Features**:
- Extract from single pages or entire domains (wildcard support)
- Natural language prompts OR predefined JSON schemas
- Batch processing of multiple URLs
- Web search enhancement for related content
- AI agent for complex navigation (FIRE-1)

## Endpoint

```
POST https://api.firecrawl.dev/v2/extract
```

## Authentication

```bash
Authorization: Bearer YOUR_API_KEY
```

## Core Concepts

### Schema vs Prompt

#### Schema-Based Extraction
Define exact structure you want:
```json
{
  "urls": ["https://example.com"],
  "schema": {
    "type": "object",
    "properties": {
      "title": {"type": "string"},
      "price": {"type": "number"},
      "features": {
        "type": "array",
        "items": {"type": "string"}
      }
    }
  }
}
```

#### Prompt-Based Extraction
Let AI choose the structure:
```json
{
  "urls": ["https://example.com"],
  "prompt": "Extract all product information including name, price, and features"
}
```

#### Combined Approach
Guide AI with both:
```json
{
  "urls": ["https://example.com"],
  "prompt": "Extract pricing information for all plans",
  "schema": {
    "type": "object",
    "properties": {
      "plans": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "name": {"type": "string"},
            "price": {"type": "number"},
            "features": {"type": "array"}
          }
        }
      }
    }
  }
}
```

## Request Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `urls` | array | List of URLs to extract from (or wildcard patterns) |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prompt` | string | - | Natural language description of data to extract |
| `schema` | object | - | JSON schema defining structure |
| `enableWebSearch` | boolean | `false` | Search and include related pages |
| `limit` | integer | `100` | Max pages to process (with wildcards) |
| `allowExternalLinks` | boolean | `false` | Follow links outside domain |
| `timeout` | integer | `30000` | Request timeout in milliseconds |

### Note on Schema vs Prompt
- **Schema only**: Extract exactly what's defined
- **Prompt only**: AI chooses structure based on description
- **Both**: Schema structure with prompt guidance
- **Neither**: Error - at least one required

## Basic Usage

### cURL Example
```bash
curl -X POST https://api.firecrawl.dev/v2/extract \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "urls": ["https://firecrawl.dev/pricing"],
    "prompt": "Extract all pricing plans with their features"
  }'
```

### Python Example
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

result = firecrawl.extract(
    urls=['https://example.com/products'],
    prompt='Extract all product names and prices'
)

print(result['data'])
```

### With Pydantic Schema
```python
from pydantic import BaseModel, Field
from firecrawl import Firecrawl

class Product(BaseModel):
    name: str = Field(description="Product name")
    price: float = Field(description="Product price in USD")
    description: str = Field(description="Product description")
    in_stock: bool = Field(description="Whether product is in stock")

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

result = firecrawl.extract(
    urls=['https://example.com/products'],
    schema=Product.model_json_schema()
)

# Result is validated against schema
for product in result['data']:
    print(f"{product['name']}: ${product['price']}")
```

## Response Structure

### Success Response
```json
{
  "success": true,
  "jobId": "job_123456",
  "data": [
    {
      "url": "https://example.com",
      "extract": {
        "title": "Example Product",
        "price": 99.99,
        "features": ["Feature 1", "Feature 2"]
      }
    }
  ],
  "metadata": {
    "total_pages": 1,
    "successful_pages": 1,
    "failed_pages": 0
  }
}
```

### Job-Based Response (Async)
```json
{
  "success": true,
  "jobId": "job_123456",
  "message": "Extraction job started"
}
```

Poll for results:
```python
status = firecrawl.get_extract_status(job_id='job_123456')
```

## Advanced Features

### 1. Wildcard Patterns

Extract from entire domains or URL patterns:

#### Single Page
```python
result = firecrawl.extract(
    urls=['https://example.com/product/123'],
    prompt='Extract product details'
)
```

#### All Products
```python
result = firecrawl.extract(
    urls=['https://example.com/products/*'],
    prompt='Extract product details',
    limit=100  # Max 100 products
)
```

#### Entire Domain
```python
result = firecrawl.extract(
    urls=['https://blog.example.com/*'],
    prompt='Extract article titles, authors, and dates',
    limit=500
)
```

### 2. Complex Schemas

#### Nested Objects
```python
from pydantic import BaseModel

class Author(BaseModel):
    name: str
    bio: str
    twitter: str | None

class Article(BaseModel):
    title: str
    published_date: str
    author: Author
    content: str
    tags: list[str]

class Blog(BaseModel):
    articles: list[Article]

result = firecrawl.extract(
    urls=['https://blog.example.com/*'],
    schema=Blog.model_json_schema()
)
```

#### Multiple Item Types
```python
class ProductPrice(BaseModel):
    plan_name: str
    monthly_price: float
    annual_price: float
    features: list[str]

class PricingPage(BaseModel):
    company_name: str
    pricing_plans: list[ProductPrice]
    free_trial_available: bool

result = firecrawl.extract(
    urls=['https://saas-companies.com/*/pricing'],
    schema=PricingPage.model_json_schema(),
    limit=50
)
```

### 3. Web Search Enhancement

Expand extraction beyond specified URLs:

```python
result = firecrawl.extract(
    urls=['https://company.com/about'],
    prompt='Extract company mission, founding year, and key executives',
    enableWebSearch=True  # Searches for related info
)
```

Benefits:
- Finds related pages automatically
- Enriches data with additional context
- Useful for research and comprehensive extraction

Note: Uses additional credits for searched pages.

### 4. FIRE-1 AI Agent

For complex navigation and multi-page extraction:

```python
result = firecrawl.extract(
    urls=['https://forum.example.com/thread/123'],
    prompt='Extract all comments from this forum thread, including replies',
    agent='fire-1'
)
```

FIRE-1 capabilities:
- Navigate complex page structures
- Follow pagination automatically
- Handle dynamic loading
- Interact with JavaScript elements

Note: FIRE-1 has separate rate limits (10 req/min).

### 5. URL-Free Extraction (Alpha)

Extract using only a prompt (no specific URLs):

```python
result = firecrawl.extract(
    prompt='Find and extract information about Python web scraping libraries',
    enableWebSearch=True
)
```

Useful for:
- Research without knowing URLs
- Discovering and extracting in one step
- Broad information gathering

Note: Alpha feature, may be less consistent.

## Schema Examples

### E-commerce Product
```python
class Product(BaseModel):
    name: str = Field(description="Product name")
    sku: str = Field(description="Product SKU/ID")
    price: float = Field(description="Current price")
    original_price: float | None = Field(description="Original price if on sale")
    currency: str = Field(description="Currency code (USD, EUR, etc)")
    availability: str = Field(description="In stock, out of stock, etc")
    rating: float | None = Field(description="Average rating out of 5")
    review_count: int | None = Field(description="Number of reviews")
    images: list[str] = Field(description="Product image URLs")
    description: str = Field(description="Product description")
    specifications: dict[str, str] = Field(description="Technical specifications")
```

### Blog Article
```python
class BlogPost(BaseModel):
    title: str
    author: str
    published_date: str
    updated_date: str | None
    reading_time: int  # minutes
    summary: str
    content: str
    tags: list[str]
    category: str
    featured_image: str | None
    related_articles: list[str]  # URLs
```

### Job Listing
```python
class JobPosting(BaseModel):
    title: str
    company: str
    location: str
    remote_options: str  # "Remote", "Hybrid", "On-site"
    salary_min: int | None
    salary_max: int | None
    salary_currency: str
    employment_type: str  # "Full-time", "Part-time", "Contract"
    experience_level: str  # "Entry", "Mid", "Senior"
    skills_required: list[str]
    description: str
    benefits: list[str]
    application_url: str
    posted_date: str
```

### Real Estate Listing
```python
class Property(BaseModel):
    address: str
    city: str
    state: str
    zip_code: str
    price: float
    bedrooms: int
    bathrooms: float
    square_feet: int
    lot_size: float | None
    year_built: int
    property_type: str  # "House", "Condo", "Apartment"
    description: str
    features: list[str]
    images: list[str]
    agent_name: str
    agent_phone: str
```

### Bookmark Metadata
```python
class BookmarkContent(BaseModel):
    url: str
    title: str
    description: str
    main_topic: str = Field(description="Primary subject/topic")
    category: str = Field(description="General category (tech, news, education, etc)")
    keywords: list[str] = Field(description="Relevant keywords")
    content_type: str = Field(description="Article, documentation, tutorial, tool, etc")
    reading_time: int | None = Field(description="Estimated reading time in minutes")
    publication_date: str | None
    author: str | None
    language: str = Field(description="Content language (en, es, fr, etc)")
    quality_score: int = Field(description="Content quality 1-10")
    summary: str = Field(description="Brief 2-3 sentence summary")
```

## Job Management

### Asynchronous Extraction

For large extractions, use job-based processing:

```python
# Start extraction job
job = firecrawl.extract(
    urls=['https://example.com/products/*'],
    schema=Product.model_json_schema(),
    limit=1000
)

job_id = job['jobId']

# Poll for status
import time

while True:
    status = firecrawl.get_extract_status(job_id=job_id)

    if status['status'] == 'completed':
        results = status['data']
        break
    elif status['status'] == 'failed':
        print(f"Job failed: {status['error']}")
        break
    else:
        print(f"Status: {status['status']}, Progress: {status['progress']}%")
        time.sleep(5)
```

### Job Data Retention

- Job data persists for **24 hours**
- After 24 hours, data is deleted
- Download results promptly

## Error Handling

### Python Error Handling
```python
from firecrawl import Firecrawl
from firecrawl.exceptions import FirecrawlError

firecrawl = Firecrawl(api_key="fc-YOUR_API_KEY")

try:
    result = firecrawl.extract(
        urls=['https://example.com'],
        prompt='Extract product info'
    )
except FirecrawlError as e:
    print(f"Extraction failed: {e.message}")
    print(f"Status code: {e.status_code}")
except Exception as e:
    print(f"Unexpected error: {e}")
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Schema validation fails | Extracted data doesn't match schema | Make schema more flexible or adjust prompt |
| Inconsistent results | Dynamic content varies | Use more specific selectors or prompts |
| Partial extraction | Timeout or rate limit | Reduce limit, increase timeout, or batch |
| Empty results | Wrong URL pattern or content not found | Verify URLs, test with single page first |

## Known Limitations

Based on official documentation:

1. **Large-scale coverage**: Entire product catalogs may be challenging
2. **Temporal queries**: Complex date-based queries may be inconsistent
3. **Dynamic sites**: May show slight variations across runs
4. **Extraction accuracy**: LLM-based, not 100% guaranteed

## Best Practices

### 1. Start Small, Scale Up
```python
# Test with single URL first
test_result = firecrawl.extract(
    urls=['https://example.com/products/1'],
    schema=Product.model_json_schema()
)

# Validate schema works
if test_result['success']:
    # Now scale to wildcard
    full_result = firecrawl.extract(
        urls=['https://example.com/products/*'],
        schema=Product.model_json_schema(),
        limit=100
    )
```

### 2. Use Field Descriptions
```python
class Article(BaseModel):
    title: str = Field(description="Article headline or title")
    author: str = Field(description="Author's full name")
    date: str = Field(description="Publication date in YYYY-MM-DD format")
    # Descriptions help LLM extract correctly
```

### 3. Provide Examples in Prompt
```python
result = firecrawl.extract(
    urls=['https://example.com'],
    prompt='''
    Extract product information including:
    - name: Product title (e.g., "iPhone 15 Pro")
    - price: Numeric price in USD (e.g., 999.99)
    - category: Product category (e.g., "Electronics")
    '''
)
```

### 4. Handle Partial Failures
```python
result = firecrawl.extract(
    urls=['https://example.com/products/*'],
    schema=Product.model_json_schema(),
    limit=100
)

successful = [r for r in result['data'] if r.get('extract')]
failed = [r for r in result['data'] if not r.get('extract')]

print(f"Successful: {len(successful)}, Failed: {len(failed)}")
```

### 5. Validate Extracted Data
```python
from pydantic import ValidationError

for item in result['data']:
    try:
        product = Product(**item['extract'])
        # Use validated product
        process_product(product)
    except ValidationError as e:
        print(f"Validation failed for {item['url']}: {e}")
        # Handle invalid data
```

## Pricing & Credits

### Credit Cost
- Extract uses token-based pricing
- **1 credit = 15 tokens**
- Actual cost varies by extraction complexity

### Estimating Costs
- Simple extractions: ~1-2 credits per page
- Complex schemas: ~5-10 credits per page
- With web search: Additional credits for searched pages

### See Pricing Documentation
For detailed pricing: See 02-pricing.md

## Use Cases for Bookmark Organizer

### 1. Enrich All Bookmarks
```python
class BookmarkEnrichment(BaseModel):
    title: str
    summary: str
    category: str
    keywords: list[str]
    content_type: str

def enrich_bookmarks(bookmark_urls):
    result = firecrawl.extract(
        urls=bookmark_urls,
        schema=BookmarkEnrichment.model_json_schema(),
        prompt='Analyze and categorize this bookmark'
    )
    return result['data']
```

### 2. Detect Duplicate Content
```python
class ContentFingerprint(BaseModel):
    main_topic: str
    key_points: list[str]
    content_hash: str

# Extract fingerprints for all bookmarks
fingerprints = firecrawl.extract(
    urls=all_bookmark_urls,
    schema=ContentFingerprint.model_json_schema()
)

# Compare fingerprints to find duplicates
```

### 3. Auto-Tag Bookmarks
```python
class BookmarkTags(BaseModel):
    primary_category: str
    sub_categories: list[str]
    technology_stack: list[str]
    difficulty_level: str
    content_format: str

tags = firecrawl.extract(
    urls=bookmark_urls,
    schema=BookmarkTags.model_json_schema()
)
```

### 4. Generate Bookmark Index
```python
class BookmarkIndex(BaseModel):
    title: str
    summary: str
    main_topics: list[str]
    related_concepts: list[str]
    useful_for: str

index = firecrawl.extract(
    urls=bookmark_urls,
    schema=BookmarkIndex.model_json_schema(),
    prompt='Create a searchable index entry for this bookmark'
)
```

## Rate Limits

See 06-rate-limits.md for detailed rate limit information.

**Quick Reference**:
- Free: 10 requests/minute
- Hobby: 100 requests/minute
- Standard: 500 requests/minute
- Growth: 1000 requests/minute
- FIRE-1 Agent: 10 requests/minute (all plans)

## Next Steps

- **Python SDK**: See 05-python-sdk.md for complete SDK reference
- **Scrape API**: See 03-api-scrape.md for basic scraping
- **Rate Limits**: See 06-rate-limits.md for limits and concurrency
- **Examples**: Check official docs for more examples
