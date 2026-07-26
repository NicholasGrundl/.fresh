# Firecrawl Self-Hosting Guide

Complete guide for self-hosting Firecrawl on your own infrastructure.

**Official Docs**: https://docs.firecrawl.dev/contributing/self-host
**GitHub**: https://github.com/firecrawl/firecrawl/blob/main/SELF_HOST.md

## Overview

Firecrawl is open-source (AGPL-3.0 license) and can be self-hosted for:
- **Privacy**: Keep all data within your infrastructure
- **Compliance**: Meet regulatory requirements
- **Cost**: Unlimited usage without credit costs
- **Customization**: Modify and extend functionality
- **Control**: No dependency on external API

## When to Self-Host

### Good Reasons
- Processing > 100k pages/month (cost savings)
- Strict data privacy requirements
- Regulatory compliance needs
- Want to customize/extend functionality
- No internet dependency desired
- Long-term heavy usage

### Not Worth It
- Processing < 10k pages/month (hosted is cheaper)
- No technical infrastructure/expertise
- Quick prototyping or testing
- Temporary/short-term project

### Cost-Benefit Analysis

**Hosted API (Standard Plan)**:
- Cost: $83/month
- Credits: 100,000
- Setup: None
- Maintenance: None

**Self-Hosted**:
- Cost: Infrastructure only ($50-200/month depending on scale)
- Credits: Unlimited
- Setup: 2-4 hours initial
- Maintenance: 1-2 hours/month
- **Break-even**: ~100k-500k pages/month

## Requirements

### System Requirements

**Minimum** (Testing):
- 2 CPU cores
- 4 GB RAM
- 20 GB storage
- Docker installed

**Recommended** (Production):
- 4+ CPU cores
- 8+ GB RAM
- 50+ GB storage
- Docker + Docker Compose
- Reverse proxy (nginx/Caddy)

**Optimal** (High Volume):
- 8+ CPU cores
- 16+ GB RAM
- 100+ GB SSD storage
- Kubernetes cluster
- Load balancer

### Software Requirements

- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Git**: For cloning repository
- **Node.js**: 18+ (for development)
- **PostgreSQL**: 14+ (included in Docker setup)
- **Redis**: 6+ (included in Docker setup)

## Installation Methods

### Method 1: Docker Compose (Recommended)

Easiest method for most users.

#### Step 1: Clone Repository

```bash
git clone https://github.com/firecrawl/firecrawl.git
cd firecrawl
```

#### Step 2: Configure Environment

```bash
# Copy example environment file
cp apps/api/.env.example .env

# Edit .env file
nano .env
```

**Minimal .env Configuration**:
```bash
# Server
PORT=3002
HOST=0.0.0.0

# Authentication (set to false for basic setup)
USE_DB_AUTHENTICATION=false

# Redis (defaults work for Docker Compose)
REDIS_URL=redis://redis:6379

# PostgreSQL (defaults work for Docker Compose)
DATABASE_URL=postgresql://postgres:postgres@db:5432/firecrawl

# Optional: OpenAI for AI features
OPENAI_API_KEY=your_openai_key_here

# Optional: Proxy configuration
# HTTP_PROXY=http://proxy:port
# HTTPS_PROXY=https://proxy:port

# Optional: Search API (for /search endpoint)
# SERPER_API_KEY=your_serper_key
```

#### Step 3: Build and Start

```bash
# Build images
docker compose build

# Start services
docker compose up -d

# View logs
docker compose logs -f
```

#### Step 4: Verify Installation

```bash
# Check services are running
docker compose ps

# Test API
curl http://localhost:3002/health

# Expected response:
# {"status":"ok"}
```

#### Step 5: Test Scraping

```bash
# Test scrape endpoint
curl -X POST http://localhost:3002/v2/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com",
    "formats": ["markdown"]
  }'
```

### Method 2: Kubernetes

For production deployments at scale.

```bash
# Instructions in repository
cd firecrawl/examples/kubernetes/cluster-install

# Follow README.md in that directory
# Includes:
# - Deployment manifests
# - Service definitions
# - ConfigMaps
# - Persistent volume claims
```

### Method 3: Firecrawl Simple

Simplified fork optimized for self-hosting.

**GitHub**: https://github.com/devflowinc/firecrawl-simple

**Key Differences**:
- Uses puppeteer instead of Playwright (lighter)
- Fewer dependencies
- Easier to deploy
- Supports main /scrape and /crawl endpoints
- No Extract endpoint (yet)

```bash
git clone https://github.com/devflowinc/firecrawl-simple.git
cd firecrawl-simple
cp .env.example .env
docker compose up -d
```

## Configuration

### Essential Environment Variables

```bash
# Server Configuration
PORT=3002                    # API port
HOST=0.0.0.0                # Bind to all interfaces

# Database
DATABASE_URL=postgresql://user:pass@host:5432/firecrawl
REDIS_URL=redis://redis:6379

# Authentication
USE_DB_AUTHENTICATION=false  # Disable for simple setup
# Or enable with:
USE_DB_AUTHENTICATION=true
JWT_SECRET=your_secret_here

# Resource Limits
MAX_CONCURRENT_BROWSERS=50   # Concurrent page processing
CPU_THRESHOLD=90             # CPU limit percentage
RAM_THRESHOLD=90             # RAM limit percentage
```

### Optional Features

#### OpenAI Integration (for Extract endpoint)
```bash
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4           # or gpt-3.5-turbo
```

#### Proxy Configuration
```bash
HTTP_PROXY=http://proxy:8080
HTTPS_PROXY=https://proxy:8443
NO_PROXY=localhost,127.0.0.1
```

#### Search API (Serper)
```bash
SERPER_API_KEY=your_key
```

#### Logging
```bash
LOG_LEVEL=info              # debug, info, warn, error
LOG_FORMAT=json             # json or pretty
```

### Docker Compose Services

The docker-compose.yml includes:

```yaml
services:
  api:
    # Main API server
    ports:
      - "3002:3002"

  playwright-service:
    # Browser automation
    # Or use playwright-service-ts for TypeScript version

  db:
    # PostgreSQL database
    ports:
      - "5432:5432"

  redis:
    # Redis for job queues
    ports:
      - "6379:6379"

  bull-board:
    # Queue management UI
    ports:
      - "3000:3000"
```

## Production Setup

### 1. Use Reverse Proxy

#### Nginx Configuration

```nginx
server {
    listen 80;
    server_name firecrawl.yourdomain.com;

    location / {
        proxy_pass http://localhost:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Increase timeout for long-running crawls
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
```

#### Add SSL with Certbot

```bash
sudo certbot --nginx -d firecrawl.yourdomain.com
```

### 2. Enable Authentication

```bash
# In .env
USE_DB_AUTHENTICATION=true
JWT_SECRET=$(openssl rand -base64 32)
```

Create API keys in PostgreSQL:
```sql
INSERT INTO api_keys (key, user_id, created_at)
VALUES ('your_api_key', 'user_id', NOW());
```

### 3. Resource Management

```bash
# In .env
MAX_CONCURRENT_BROWSERS=100
CPU_THRESHOLD=85
RAM_THRESHOLD=85

# Monitor with
docker stats
```

### 4. Persistent Storage

```yaml
# In docker-compose.yml
volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

services:
  db:
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    volumes:
      - redis_data:/data
```

### 5. Backup Strategy

```bash
#!/bin/bash
# backup.sh

# Backup PostgreSQL
docker exec firecrawl-db pg_dump -U postgres firecrawl > backup_$(date +%Y%m%d).sql

# Backup Redis
docker exec firecrawl-redis redis-cli SAVE
docker cp firecrawl-redis:/data/dump.rdb redis_backup_$(date +%Y%m%d).rdb

# Compress
tar -czf firecrawl_backup_$(date +%Y%m%d).tar.gz backup_*.sql redis_backup_*.rdb

# Upload to S3/backup location
# aws s3 cp firecrawl_backup_$(date +%Y%m%d).tar.gz s3://your-bucket/
```

## Accessing the API

### With Docker (default)

```bash
# No authentication
curl -X POST http://localhost:3002/v2/scrape \
  -H 'Content-Type: application/json' \
  -d '{"url": "https://example.com"}'
```

### With Authentication

```bash
# With API key
curl -X POST http://localhost:3002/v2/scrape \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"url": "https://example.com"}'
```

### Python SDK with Self-Hosted

```python
from firecrawl import Firecrawl

# Point to self-hosted instance
firecrawl = Firecrawl(
    api_key="your_api_key",  # If authentication enabled
    base_url="http://localhost:3002"
)

result = firecrawl.scrape('https://example.com')
print(result['markdown'])
```

## Management Tools

### Bull Queue Dashboard

Monitor job queues:

```bash
# Access at http://localhost:3002/admin/@/queues

# Or separate Bull Board:
# http://localhost:3000
```

Features:
- View active/completed/failed jobs
- Retry failed jobs
- Clear queues
- Monitor performance

### Health Check

```bash
curl http://localhost:3002/health
```

Response:
```json
{
  "status": "ok",
  "uptime": 123456,
  "database": "connected",
  "redis": "connected"
}
```

## Monitoring

### Resource Monitoring

```bash
# Docker stats
docker stats

# Specific service
docker stats firecrawl-api

# Logs
docker compose logs -f api
docker compose logs -f playwright-service
```

### Prometheus + Grafana (Optional)

Add to docker-compose.yml:

```yaml
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

## Troubleshooting

### Common Issues

#### 1. Services Won't Start

```bash
# Check logs
docker compose logs

# Common causes:
# - Port conflicts (3002, 5432, 6379 already in use)
# - Insufficient resources
# - .env misconfiguration

# Solutions:
# Change ports in docker-compose.yml
docker compose down
docker compose up -d
```

#### 2. Scraping Fails

```bash
# Check playwright service
docker compose logs playwright-service

# Restart playwright
docker compose restart playwright-service
```

#### 3. Out of Memory

```bash
# Check Docker resources
docker stats

# Increase Docker memory limit (Docker Desktop)
# Settings > Resources > Memory > 8GB+

# Or reduce concurrent browsers
# In .env:
MAX_CONCURRENT_BROWSERS=20
```

#### 4. Database Connection Errors

```bash
# Check PostgreSQL
docker compose exec db psql -U postgres -c "SELECT 1"

# Reset database
docker compose down -v
docker compose up -d
```

### Logs and Debugging

```bash
# All logs
docker compose logs

# Specific service
docker compose logs api
docker compose logs playwright-service

# Follow logs
docker compose logs -f

# Last 100 lines
docker compose logs --tail=100
```

## Updating

### Docker Compose Method

```bash
# Pull latest changes
git pull

# Rebuild images
docker compose build

# Restart services
docker compose down
docker compose up -d

# Verify update
curl http://localhost:3002/health
```

### Zero-Downtime Update (Advanced)

```bash
# Build new images
docker compose build

# Start new containers
docker compose up -d --no-deps --build api

# Old containers automatically replaced
```

## Scaling

### Horizontal Scaling

```yaml
# docker-compose.yml
services:
  api:
    deploy:
      replicas: 3

  playwright-service:
    deploy:
      replicas: 5
```

### Load Balancing

Use nginx or HAProxy:

```nginx
upstream firecrawl {
    server localhost:3002;
    server localhost:3003;
    server localhost:3004;
}

server {
    location / {
        proxy_pass http://firecrawl;
    }
}
```

## Security

### 1. Enable Authentication

```bash
USE_DB_AUTHENTICATION=true
JWT_SECRET=$(openssl rand -base64 32)
```

### 2. Use HTTPS

```bash
# With Caddy (automatic HTTPS)
caddy reverse-proxy --from firecrawl.yourdomain.com --to localhost:3002
```

### 3. Network Isolation

```yaml
# docker-compose.yml
networks:
  internal:
    internal: true
  external:

services:
  api:
    networks:
      - external
      - internal

  db:
    networks:
      - internal  # Not exposed externally
```

### 4. Rate Limiting

Use nginx:

```nginx
limit_req_zone $binary_remote_addr zone=firecrawl:10m rate=100r/m;

location / {
    limit_req zone=firecrawl burst=10;
    proxy_pass http://localhost:3002;
}
```

## Cost Comparison

### Infrastructure Costs

**VPS/VM Options**:
- DigitalOcean Droplet (4GB): $24/month
- Linode (4GB): $24/month
- AWS EC2 t3.medium: ~$30/month
- Hetzner Cloud (4GB): ~$7/month (Europe)

**Kubernetes Options**:
- DigitalOcean Kubernetes: $40+/month
- AWS EKS: $72+/month
- GCP GKE: $75+/month

### Total Cost of Ownership

**Small Scale (< 50k pages/month)**:
- Hosted API: $16-83/month
- Self-Hosted: $24-50/month + 2-4 hours setup
- **Verdict**: Hosted is easier

**Medium Scale (50k-500k pages/month)**:
- Hosted API: $83-333/month
- Self-Hosted: $50-100/month + maintenance
- **Verdict**: Self-hosted saves money

**Large Scale (> 500k pages/month)**:
- Hosted API: $333+/month
- Self-Hosted: $100-200/month + maintenance
- **Verdict**: Self-hosted is much cheaper

## For Bookmark Organizer

### Recommendation

**If you have**:
- < 5,000 bookmarks: Use hosted API (Free/Hobby)
- 5,000-50,000 bookmarks: Use hosted API (Standard)
- > 50,000 bookmarks: Consider self-hosting

### Example Self-Hosted Setup

```bash
# 1. Clone and configure
git clone https://github.com/firecrawl/firecrawl.git
cd firecrawl
cp apps/api/.env.example .env

# 2. Minimal config
cat > .env << EOF
PORT=3002
HOST=0.0.0.0
USE_DB_AUTHENTICATION=false
REDIS_URL=redis://redis:6379
DATABASE_URL=postgresql://postgres:postgres@db:5432/firecrawl
MAX_CONCURRENT_BROWSERS=50
EOF

# 3. Start
docker compose up -d

# 4. Use in bookmark organizer
# In your Python code:
from firecrawl import Firecrawl

firecrawl = Firecrawl(base_url="http://localhost:3002")

# Process unlimited bookmarks for free!
for bookmark in bookmarks:
    result = firecrawl.scrape(bookmark['url'])
    # No credit costs!
```

## Advanced Topics

### Custom Modifications

Firecrawl is open-source, so you can:
- Add custom parsers
- Modify scraping logic
- Add new endpoints
- Integrate with other tools

Example locations to modify:
- `apps/api/src/` - API endpoints
- `apps/playwright-service/` - Browser automation
- `apps/api/src/scraper/` - Scraping logic

### Integration with Other Tools

```yaml
# docker-compose.yml - Add your services
services:
  firecrawl-api:
    # ... existing config

  your-app:
    build: .
    environment:
      - FIRECRAWL_URL=http://firecrawl-api:3002
```

## Resources

- **Official Docs**: https://docs.firecrawl.dev/contributing/self-host
- **GitHub Issues**: https://github.com/firecrawl/firecrawl/issues
- **Discord Community**: https://discord.gg/firecrawl
- **Self-Host Guide**: https://github.com/firecrawl/firecrawl/blob/main/SELF_HOST.md
- **Firecrawl Simple**: https://github.com/devflowinc/firecrawl-simple

## Next Steps

- **Overview**: See 01-overview.md for Firecrawl features
- **Pricing**: See 02-pricing.md to compare costs
- **Python SDK**: See 05-python-sdk.md for implementation
- **Comparisons**: See 08-comparisons.md for alternatives
