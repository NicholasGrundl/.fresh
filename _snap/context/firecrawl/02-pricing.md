# Firecrawl Pricing

Comprehensive pricing information for Firecrawl's hosted API service.

**Official Pricing Page**: https://www.firecrawl.dev/pricing

## Pricing Model

Firecrawl uses a **credit-based system** where:
- Each API operation consumes a specific number of credits
- Under standard conditions, **1 page = 1 credit**
- Credits cover all infrastructure costs (proxies, bandwidth, compute)
- **Failed requests do not charge credits**

## Pricing Tiers

### Free Plan
- **Cost**: $0/month
- **Credits**: 500
- **Concurrent Browsers**: 2
- **Rate Limits**:
  - Scrape: 10 req/min
  - Map: 10 req/min
  - Search: 1 req/min
  - Crawl: 5 req/min
  - Extract: 10 req/min
- **Support**: Community
- **Requirements**: No credit card required

**Good for**: Testing, small personal projects, proof-of-concept

### Hobby Plan
- **Cost**: $16/month (billed yearly with 2 months free)
- **Credits**: 3,000
- **Concurrent Browsers**: 5
- **Rate Limits**:
  - Scrape: 100 req/min
  - Map: 100 req/min
  - Search: 15 req/min
  - Crawl: 50 req/min
  - Extract: 100 req/min
- **Extra Credits**: $9 per 1,000 credits
- **Support**: Basic

**Cost per page**: ~$0.005 (half a cent per page)
**Good for**: Small projects, individual developers, side projects

### Standard Plan (Most Popular)
- **Cost**: $83/month (billed yearly with 2 months free)
- **Credits**: 100,000
- **Concurrent Browsers**: 50
- **Rate Limits**:
  - Scrape: 500 req/min
  - Map: 500 req/min
  - Search: 50 req/min
  - Crawl: 250 req/min
  - Extract: 500 req/min
- **Extra Credits**: $47 per 35,000 credits
- **Support**: Standard

**Cost per page**: ~$0.0008 (less than 1/10th of a cent)
**Good for**: Production applications, startups, regular usage

### Growth Plan
- **Cost**: $333/month (billed yearly with 2 months free)
- **Credits**: 500,000
- **Concurrent Browsers**: 100
- **Rate Limits**:
  - Scrape: 5,000 req/min
  - Map: 5,000 req/min
  - Search: 250 req/min
  - Crawl: 2,500 req/min
  - Extract: 1,000 req/min
- **Extra Credits**: $177 per 175,000 credits
- **Support**: Priority

**Cost per page**: ~$0.0007
**Good for**: High-volume applications, teams, enterprise use

### Enterprise Plan
- **Cost**: Custom pricing
- **Credits**: Unlimited
- **Concurrent Browsers**: Custom
- **Rate Limits**: Custom
- **Support**: Dedicated
- **Additional Features**:
  - Dedicated infrastructure
  - Service Level Agreements (SLAs)
  - Custom integrations
  - White-glove support

**Contact**: sales@firecrawl.dev
**Good for**: Large enterprises, mission-critical applications, custom requirements

## Extract Plans (AI-Powered Extraction)

Separate pricing tier for the Extract endpoint with LLM-powered structured data extraction.

### Extract Starter
- **Cost**: $89/month
- **Tokens**: Variable
- **Use case**: Basic structured extraction

### Extract Explorer
- **Cost**: $359/month
- **Tokens**: Higher volume
- **Use case**: Medium-scale extraction projects

### Extract Pro
- **Cost**: $719/month
- **Tokens**: High volume
- **Use case**: Production-scale structured extraction

**Note**: Extract uses a token-based system where **1 credit = 15 tokens**

## Credit Costs by Feature

| Feature | Credits | Notes |
|---------|---------|-------|
| Scrape | 1 credit/page | Standard page scraping |
| Crawl | 1 credit/page | Each page in the crawl |
| Map | 1 credit/page | URL discovery |
| Search | 2 credits/10 results | Web search + content |
| Extract | Variable | Based on tokens (15 tokens/credit) |

## Extra Credits

All paid plans offer auto-recharge packs for additional credits:

| Plan | Pack Size | Cost | Cost per Credit |
|------|-----------|------|-----------------|
| Hobby | 1,000 | $9 | $0.009 |
| Standard | 35,000 | $47 | $0.00134 |
| Growth | 175,000 | $177 | $0.00101 |

## Annual Billing Discount

**2 Months Free** when billed annually
- Effectively 16.7% discount
- Available for all paid plans
- One-time annual charge

## Rate Limits Summary

Detailed rate limits by plan (requests per minute):

| Plan | /scrape | /map | /search | /crawl | /extract | /crawl/status |
|------|---------|------|---------|--------|----------|---------------|
| Free | 10 | 10 | 1 | 5 | 10 | 1500 |
| Hobby | 100 | 100 | 15 | 50 | 100 | 1500 |
| Standard | 500 | 500 | 50 | 250 | 500 | 1500 |
| Growth | 5000 | 5000 | 250 | 2500 | 1000 | 25000 |

**Special Limits**:
- FIRE-1 Agent: 10 req/min for both /scrape and /extract
- Batch endpoints follow /crawl rate limits
- Status endpoints have higher limits for polling

## Concurrent Browser Limits

Simultaneous page processing capacity:

| Plan | Concurrent Browsers |
|------|-------------------|
| Free | 2 |
| Hobby | 5 |
| Standard | 50 |
| Growth | 100 |
| Scale/Enterprise | 150+ |

**What this means**: Number of pages that can be processed simultaneously during crawling operations.

## Pricing Calculator Examples

### Example 1: Small Blog Enrichment
- **Scenario**: 100 bookmarks, scrape each for content
- **Credits needed**: 100 (1 credit per page)
- **Plan**: Free (500 credits)
- **Cost**: $0

### Example 2: Regular Bookmark Processing
- **Scenario**: 1,000 bookmarks/month
- **Credits needed**: 1,000
- **Plan**: Hobby (3,000 credits)
- **Cost**: $16/month
- **Per-bookmark cost**: $0.016

### Example 3: Large Catalog Scraping
- **Scenario**: 50,000 pages/month
- **Credits needed**: 50,000
- **Plan**: Standard (100,000 credits)
- **Cost**: $83/month
- **Per-page cost**: $0.0017 (using only 50% of plan)

### Example 4: Massive Web Crawling
- **Scenario**: 500,000 pages/month
- **Credits needed**: 500,000
- **Plan**: Growth (500,000 credits)
- **Cost**: $333/month
- **Per-page cost**: $0.00067

### Example 5: Over Budget
- **Scenario**: 120,000 pages on Standard plan
- **Base credits**: 100,000 (included)
- **Extra needed**: 20,000
- **Extra pack**: $47 for 35,000 credits (closest option)
- **Total cost**: $83 + $47 = $130/month

## Cost Comparison: Hosted vs Self-Hosted

### Hosted (Standard Plan)
- **Cost**: $83/month
- **Credits**: 100,000
- **Infrastructure**: Managed
- **Maintenance**: None
- **Scaling**: Automatic
- **Best for**: < 100k pages/month

### Self-Hosted (Open Source)
- **Cost**: Infrastructure only (servers, bandwidth)
- **Credits**: Unlimited
- **Infrastructure**: You manage
- **Maintenance**: Required
- **Scaling**: Manual
- **Best for**: > 100k pages/month, data privacy, compliance

**Break-even point**: Approximately 100k-500k pages/month depending on infrastructure costs.

## Payment & Billing

### Accepted Payment Methods
- Credit/debit cards
- Annual billing available

### Billing Cycle
- Monthly or annual
- Usage-based auto-recharge for extra credits
- Credits roll over (typically expire after 12 months)

### Refund Policy
- Contact support for refund inquiries
- Self-service cancellation available

## Cost Optimization Tips

### 1. Use Caching
- Set appropriate `maxAge` values
- Avoid re-scraping unchanged content
- Can reduce credit usage by 30-70%

### 2. Batch Operations
- Use batch endpoints for multiple URLs
- More efficient than individual requests
- Better rate limit utilization

### 3. Map Before Crawl
- Use `/map` to discover URLs first
- Filter what you actually need
- Avoid crawling unnecessary pages

### 4. Right-Size Your Plan
- Monitor usage patterns
- Don't over-provision
- Consider annual billing for 16.7% savings

### 5. Self-Host for High Volume
- Break-even around 100k-500k pages/month
- One-time setup effort
- Ongoing maintenance required

### 6. Combine with Traditional Tools
- Use BeautifulSoup for simple static pages
- Use Firecrawl only for complex/JS-heavy sites
- Hybrid approach can save 50-80% on costs

## Enterprise Considerations

### When to Contact Sales
- Need > 500k credits/month
- Require dedicated infrastructure
- Need SLAs and guaranteed uptime
- Custom integration requirements
- White-label solutions
- Multi-tenant deployments

### Enterprise Benefits
- Unlimited credits
- Custom rate limits
- Dedicated support
- Volume discounts
- Custom contracts
- Training and onboarding

## Frequently Asked Questions

### Q: What happens if I run out of credits?
A: API requests will fail with a 429 error. You can purchase extra credit packs or upgrade your plan.

### Q: Do credits expire?
A: Typically credits expire after 12 months, but this may vary by plan.

### Q: Can I downgrade my plan?
A: Yes, you can change plans at any time. Changes take effect at the next billing cycle.

### Q: Are failed requests charged?
A: No, failed requests do not consume credits.

### Q: Can I get a refund?
A: Contact support@firecrawl.dev for refund inquiries.

### Q: Is there a discount for non-profits/education?
A: Contact sales@firecrawl.dev to inquire about special pricing.

## Conclusion

### Best Value
- **Free**: Testing and small projects
- **Hobby**: Personal projects, < 3k pages/month
- **Standard**: Production apps, < 100k pages/month (best cost/credit ratio)
- **Growth**: High-volume apps, < 500k pages/month
- **Self-Host**: > 100k pages/month with technical capability

### Key Takeaway
Firecrawl pricing is transparent and predictable:
- 1 page = 1 credit (standard)
- Failed requests don't count
- All infrastructure included
- Scale as needed with extra credit packs

For the **Bookmark Organizer** project:
- Start with **Free plan** (500 credits)
- If processing < 3k bookmarks/month: **Hobby plan** ($16)
- If processing > 3k bookmarks: Consider **self-hosting** (free, unlimited)
