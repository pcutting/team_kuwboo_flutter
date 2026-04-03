# Kuwboo: Infrastructure Documentation

**Created:** March 9, 2026
**Version:** 1.1
**Purpose:** Deployment architecture, monitoring, scaling strategy, CI/CD, operational runbooks
**Audience:** Phil Cutting (LionPro Dev) — operations guide
**Status:** Greenfield rebuild — legacy services hibernated, new VPC created, pending service deployment

**Companion Documents:**
- [TECHNICAL_DESIGN.md](./TECHNICAL_DESIGN.md) — 32-entity schema, ORM evaluation, feed architecture
- [REALTIME_ARCHITECTURE.md](./REALTIME_ARCHITECTURE.md) — Stack overview, Socket.io, BullMQ, AWS infrastructure (Section 9)
- [TRUST_ENGINE.md](./TRUST_ENGINE.md) — trust scoring, visibility tiers (adds BullMQ queues)
- [SAFETY_PIPELINE.md](./SAFETY_PIPELINE.md) — behavior monitoring, ban evasion (adds BullMQ queues)

---

## How to Read This Document

REALTIME_ARCHITECTURE.md Section 9 covers AWS service selection and sizing rationale. This document covers **how those services are deployed, monitored, and operated**. It answers:

- **What** infrastructure exists and how it's connected (Sections 1-2)
- **How** code gets from git to production (Section 3)
- **How** the database is managed (Section 4)
- **How** we know when something is wrong (Section 5)
- **How** SSL and domains are managed (Section 6)
- **How** we scale when needed (Section 7)
- **How** we stay secure (Section 8)
- **How** we recover from failures (Section 9)
- **What** to do when things break (Section 10)

---

## Table of Contents

- [Section 1: Architecture Overview](#section-1-architecture-overview)
- [Section 2: AWS Resource Inventory](#section-2-aws-resource-inventory)
- [Section 3: Deployment Pipeline](#section-3-deployment-pipeline)
- [Section 4: Database Operations](#section-4-database-operations)
- [Section 5: Monitoring and Alerting](#section-5-monitoring-and-alerting)
- [Section 6: SSL and Domain Management](#section-6-ssl-and-domain-management)
- [Section 7: Scaling Strategy](#section-7-scaling-strategy)
- [Section 8: Security](#section-8-security)
- [Section 9: Disaster Recovery](#section-9-disaster-recovery)
- [Section 10: Operational Runbooks](#section-10-operational-runbooks)

---

## Legacy Infrastructure (Hibernated)

As of March 9, 2026, the legacy Codiant infrastructure has been hibernated to reduce costs. All resources are preserved and can be restored.

### Hibernated Resources

| Resource | ID | Status | Notes |
|----------|-----|--------|-------|
| Legacy API EC2 | `i-00ba3186d66389f31` | **stopped** | t3.medium, EBS 30 GB preserved |
| Design Preview EC2 | `i-0497480054b780615` | **stopped** | t3.micro, migrated to new VPC EC2 port 8080 |
| Aurora MySQL cluster | `kuwboo-db-staging` | **stopped** | Auto-re-stop Lambda handles 7-day restart |
| Pre-hibernate snapshot | `kuwboo-db-staging-pre-hibernate-2026-03` | available | Safety net backup |
| CloudFront (frontend) | `E1TD7B7X99R9G8` | **disabled** | Config preserved |
| CloudFront (dev CDN) | `E3LHR54EJZW4VC` | **disabled** | Config preserved |
| Elastic IP | `eipalloc-02a13f797a34066cd` → `35.177.230.139` | **reserved** | Stays associated with stopped EC2 |
| Lambda (media convert) | `kuwboo-media-converter-dev` | dormant | $0 when idle |
| Lambda (job complete) | `kuwboo-media-convert-on-job-complete-dev` | dormant | $0 when idle |
| S3 (3 buckets) | `kuwboo-dev`, `kuwboo-dev-new`, `kuwboo-frontend-staging` | active | Minimal storage cost |

### Aurora Auto-Re-Stop Mechanism

Aurora clusters auto-restart after 7 days. An EventBridge rule + Lambda re-stops it automatically:

| Component | ID/Name |
|-----------|---------|
| Lambda | `kuwboo-aurora-auto-stop` (Node.js 20.x) |
| IAM Role | `kuwboo-aurora-auto-stop` |
| EventBridge Rule | `kuwboo-aurora-auto-stop-rule` |
| Trigger | `RDS-EVENT-0153` (cluster started) on `kuwboo-db-staging` |

To disable auto-re-stop (when you want Aurora running again):
```bash
aws events disable-rule --name kuwboo-aurora-auto-stop-rule --profile neil-douglas --region eu-west-2
aws rds start-db-cluster --db-cluster-identifier kuwboo-db-staging --profile neil-douglas --region eu-west-2
```

### Post-Hibernate Monthly Cost

| Item | Cost |
|------|------|
| Design preview EC2 (t3.micro) — stopped | $0 |
| EBS volumes (30 GB + 8 GB) | ~$3 |
| Elastic IP (moved to greenfield EC2) | $0 |
| Aurora storage (stopped) | ~$2-5 |
| S3 storage | ~$1-2 |
| **Total** | **~$6-10/mo** |

### Restoring Legacy Services

```bash
# Start API server
aws ec2 start-instances --instance-ids i-00ba3186d66389f31 --profile neil-douglas --region eu-west-2

# Start Aurora (disable auto-stop first)
aws events disable-rule --name kuwboo-aurora-auto-stop-rule --profile neil-douglas --region eu-west-2
aws rds start-db-cluster --db-cluster-identifier kuwboo-db-staging --profile neil-douglas --region eu-west-2

# Re-enable CloudFront (requires ETag-based config update — see Phase 1 notes)
```

---

## Greenfield VPC: kuwboo-greenfield

### VPC Overview

| Property | Value |
|----------|-------|
| VPC ID | `vpc-0e2f5a277bff17b1e` |
| CIDR | `10.0.0.0/16` |
| DNS Hostnames | Enabled |
| DNS Support | Enabled |
| Internet Gateway | `igw-05601bcf4231e42a4` |

### Subnets

| Name | Subnet ID | CIDR | AZ | Tier |
|------|-----------|------|-----|------|
| kuwboo-public-2a | `subnet-0e9f0f36e7568898d` | 10.0.1.0/24 | eu-west-2a | Public |
| kuwboo-public-2b | `subnet-064f85a3a151cac03` | 10.0.2.0/24 | eu-west-2b | Public |
| kuwboo-public-2c | `subnet-072cc2b1fc6e9cf6a` | 10.0.3.0/24 | eu-west-2c | Public |
| kuwboo-private-2a | `subnet-002052205cd44ded5` | 10.0.11.0/24 | eu-west-2a | Private |
| kuwboo-private-2b | `subnet-071f75471f6e89536` | 10.0.12.0/24 | eu-west-2b | Private |
| kuwboo-private-2c | `subnet-0ca7545dc1b1f9e3c` | 10.0.13.0/24 | eu-west-2c | Private |

### Route Tables

| Name | Route Table ID | Routes | Associated Subnets |
|------|---------------|--------|-------------------|
| kuwboo-public-rt | `rtb-07eaedf2ef0790a44` | `0.0.0.0/0 → igw-05601bcf4231e42a4` | All 3 public subnets |
| kuwboo-private-rt | `rtb-050f2b12656d6df59` | Local only (no internet) | All 3 private subnets |

### Security Groups

| Name | ID | Inbound Rules |
|------|-----|--------------|
| kuwboo-api-sg | `sg-0f11ea6b9312ad297` | HTTP (80), HTTPS (443) from 0.0.0.0/0; SSH (22) from admin IP |
| kuwboo-db-sg | `sg-0d9e1aac8fa45b104` | PostgreSQL (5432) from kuwboo-api-sg only |
| kuwboo-preview-sg | `sg-0a10c6c1d59f5449f` | HTTP (80), HTTPS (443) from 0.0.0.0/0; SSH (22) from admin IP |

### RDS Subnet Group

| Property | Value |
|----------|-------|
| Name | `kuwboo-greenfield-db` |
| Subnets | `subnet-002052205cd44ded5`, `subnet-071f75471f6e89536`, `subnet-0ca7545dc1b1f9e3c` |

### Deployed Services

#### EC2 (API Server)

| Property | Value |
|----------|-------|
| Instance ID | `i-0766e373b3147a2aa` |
| Type | t3.medium (2 vCPU, 4 GB RAM) |
| AMI | Ubuntu 22.04 LTS (`ami-090f0cf86291c77fa`) |
| Subnet | kuwboo-public-2a (`subnet-0e9f0f36e7568898d`) |
| Security Group | `sg-0f11ea6b9312ad297` (kuwboo-api-sg) |
| Public IP | `35.177.230.139` (EIP `eipalloc-02a13f797a34066cd`) |
| Private IP | `10.0.1.108` |
| Key Pair | `kuwboo-eu-west-2-key` |
| IAM Role | `kuwboo-ec2-role-staging` (SSM + S3 + SecretsManager) |
| EBS | 30 GB gp3 |

**Installed software:** Node.js 20.x, PM2, Redis 6.x, Nginx 1.18, certbot, psql, AWS CLI v2

#### RDS PostgreSQL 16

| Property | Value |
|----------|-------|
| Instance ID | `kuwboo-greenfield-db` |
| Engine | PostgreSQL 16.10 |
| Class | db.t3.micro |
| Storage | 20 GB gp3, auto-scaling to 100 GB |
| Multi-AZ | No |
| Publicly Accessible | No |
| Endpoint | `kuwboo-greenfield-db.cepsv4bfmn1r.eu-west-2.rds.amazonaws.com:5432` |
| Database | `kuwboo` |
| Username | `kuwboo_admin` |
| Password | Auto-managed in Secrets Manager (`rds!db-8f61fdd3-bc92-4705-b576-0593a8c2417a`) |
| Subnet Group | `kuwboo-greenfield-db` (3 private subnets) |
| Security Group | `sg-0d9e1aac8fa45b104` (kuwboo-db-sg) |
| Backup | 7-day retention, 03:00-04:00 UTC |
| Maintenance | Sunday 04:00-05:00 UTC |
| Deletion Protection | Enabled |
| Encryption | At rest (enabled) |

**Installed extensions:** uuid-ossp 1.1, pg_trgm 1.6, plpgsql 1.0

#### Secrets Manager

| Secret Path | Contents |
|-------------|----------|
| `rds!db-8f61fdd3-bc92-4705-b576-0593a8c2417a` | RDS master credentials (auto-managed) |
| `/kuwboo/database` | DB host, port, database, username, managed secret ARN |
| `/kuwboo/redis` | Redis host (127.0.0.1), port (6379) |
| `/kuwboo/jwt` | JWT secrets (placeholder — rotate before launch) |

#### Redis (Local on EC2)

| Property | Value |
|----------|-------|
| Bind | `127.0.0.1:6379` |
| Max Memory | 512 MB |
| Eviction | `allkeys-lru` |
| Persistence | RDB snapshots |

#### Design Preview (on same EC2)

| Property | Value |
|----------|-------|
| URL | `http://35.177.230.139:8080/` |
| Nginx | Port 8080, serving `/var/www/design-preview/` |
| Content | Flutter web build (44-screen prototype, 45 MB) |

### Pending

| Task | Notes |
|------|-------|
| SSL + domain setup | Certbot installed, needs domain DNS configured |
| JWT secret rotation | Generate real secrets, update `/kuwboo/jwt` in Secrets Manager |
| pgvector + PostGIS | Install when embedding/proximity features needed |
| Git repo for backend | Initialize repo, connect to GitHub, set up CI/CD |

---

## Section 1: Architecture Overview

### 1.1 Current State

```
┌──────────────────────────────────────────────────────────────────┐
│  EC2 Instance (t3.medium, eu-west-2, London)                     │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  Nginx (reverse proxy, SSL termination)                           │
│    ├── api.kuwboo.com/* → :3000 (NestJS backend)                 │
│    └── (future: web app routes)                                   │
│                                                                    │
│  PM2 Process Manager                                               │
│    └── kuwboo-api (backend/src/main.ts)                           │
│                                                                    │
│  Redis (local on EC2, bind 127.0.0.1:6379)                         │
│    ├── Socket.io adapter                                           │
│    ├── BullMQ job queues                                           │
│    ├── Presence tracking                                           │
│    └── Feed caching                                                │
│                                                                    │
└──────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌────────────┐    ┌───────────────┐    ┌──────────────────┐
│ RDS         │    │ S3 + CloudFront│    │ Secrets Manager   │
│ PostgreSQL  │    │ (media CDN)    │    │ (/kuwboo/*)       │
│ 16          │    │                │    │                    │
└────────────┘    └───────────────┘    └──────────────────┘
```

### 1.2 Monthly Cost Estimate

| Service | Configuration | Monthly Cost |
|---------|--------------|-------------|
| EC2 t3.medium | 2 vCPU, 4 GB RAM, eu-west-2 (includes Redis) | ~$30 |
| RDS PostgreSQL | db.t3.micro, 20 GB, single-AZ | ~$15-23 |
| Redis | Local on EC2 (no ElastiCache — saves ~$12/mo) | $0 |
| S3 | Media storage (estimated 50 GB first year) | ~$1-2 |
| CloudFront | CDN for media delivery | ~$1-5 |
| Secrets Manager | 5-10 secrets | ~$3 |
| Route 53 | Hosted zones + DNS queries | ~$2 |
| **Total** | | **~$52-65/mo** |

Note: Redis runs locally on the EC2 instance (bind 127.0.0.1, maxmemory 512MB). Move to ElastiCache when horizontal scaling requires shared Redis (100K+ users).

---

## Section 2: AWS Resource Inventory

### 2.1 EC2

| Property | Value |
|----------|-------|
| Instance ID | `i-0766e373b3147a2aa` |
| Type | t3.medium (2 vCPU, 4 GB RAM) |
| Region / AZ | eu-west-2 / eu-west-2a |
| AMI | Ubuntu 22.04 LTS |
| VPC | `vpc-0e2f5a277bff17b1e` (kuwboo-greenfield) |
| Subnet | `subnet-0e9f0f36e7568898d` (kuwboo-public-2a) |
| Security Group | `sg-0f11ea6b9312ad297` (kuwboo-api-sg) |
| Public IP | `13.40.5.103` |
| Key Pair | `kuwboo-eu-west-2-key` |
| IAM Role | `kuwboo-ec2-role-staging` (SSM + S3 + SecretsManager) |

### 2.2 RDS PostgreSQL

| Property | Value |
|----------|-------|
| Engine | PostgreSQL 16 |
| Instance Class | db.t3.micro (initial, scale as needed) |
| Storage | 20 GB gp3 (auto-scaling enabled to 100 GB) |
| Multi-AZ | No (single-AZ for cost, upgrade at scale — see Section 7) |
| Backup | Automated, 7-day retention |
| Maintenance Window | Sunday 03:00-04:00 UTC |
| Extensions Required | `pgvector`, `postgis`, `uuid-ossp` |
| Database Name | `kuwboo` |

### 2.3 Redis (Local on EC2)

| Property | Value |
|----------|-------|
| Engine | Redis 7.x (apt install redis-server) |
| Bind | `127.0.0.1` (localhost only — no network exposure) |
| Port | `6379` |
| Max Memory | `512mb` |
| Eviction Policy | `allkeys-lru` |
| Security | No SG needed — localhost only |
| Scale-up trigger | Move to ElastiCache when going multi-instance (100K+ users) |

### 2.4 S3 Buckets

| Bucket | Purpose | Lifecycle |
|--------|---------|-----------|
| `kuwboo-media-{env}` | User uploads (photos, videos, audio) | Move to Infrequent Access after 90 days |
| `kuwboo-backups-{env}` | Database backups, config snapshots | Delete after 90 days |

### 2.5 CloudFront

| Property | Value |
|----------|-------|
| Origin | `kuwboo-media-{env}.s3.eu-west-2.amazonaws.com` |
| Cache Policy | `CachingOptimized` for media |
| Price Class | `PriceClass_100` (US, Canada, Europe only — matches target market) |
| Signed URLs | Required for private media (DMs, sensitive content) |

### 2.6 Route 53

| Domain | Record Type | Target |
|--------|-------------|--------|
| `kuwboo-api.codiantdev.com` | A | EC2 public IP (current/legacy) |
| `api.kuwboo.com` | A / ALIAS | EC2 public IP (future) |
| (future domains) | — | — |

### 2.7 Secrets Manager

| Secret Path | Contents |
|-------------|----------|
| `/kuwboo/database` | DB host, port, username, password, database name |
| `/kuwboo/redis` | Redis host, port, auth token |
| `/kuwboo/jwt` | JWT secret, refresh secret, expiry config |
| `/kuwboo/twilio` | Account SID, auth token, phone numbers |
| `/kuwboo/firebase` | FCM server key, project ID |
| `/kuwboo/openai` | API key for embeddings |
| `/kuwboo/smtp` | SES/SMTP credentials |
| `/kuwboo/aws-services` | S3 bucket names, CloudFront distribution ID |

### 2.8 IAM

| Role/Policy | Purpose | Attached To |
|-------------|---------|-------------|
| `kuwboo-ec2-role` | EC2 instance role | EC2 instance profile |
| → `SecretsManagerReadOnly` | Read secrets at startup | EC2 role |
| → `S3PresignedUrlPolicy` | Generate presigned upload/download URLs | EC2 role |
| → `RekognitionModerationPolicy` | Content moderation, photo quality | EC2 role |
| → `CloudWatchAgentPolicy` | Push metrics and logs | EC2 role |
| `kuwboo-deploy-user` | CI/CD deployment | GitHub Actions OIDC |
| → `EC2DeployPolicy` | SSM commands for deployment | Deploy user |

---

## Section 3: Deployment Pipeline

### 3.1 Current Process (Manual)

The current deployment process is manual. This is acceptable during early development but must be automated before beta launch.

```
Developer Machine
      │
      ├── git push to feature branch
      ├── Create PR → review → merge to main
      │
      ▼
SSH/SSM into EC2
      │
      ├── cd /home/ubuntu/kuwboo-api
      ├── git pull origin main
      ├── npm ci
      ├── npx mikro-orm migration:up
      ├── npm run build
      └── pm2 restart kuwboo-api
```

**Problems with manual deployment:**
- Human error risk (forgetting migration, wrong branch)
- No rollback procedure beyond `git revert`
- No health check after deploy
- No deployment audit trail

### 3.2 Target: GitHub Actions CI/CD

**Pipeline stages:**

```
Push to main (or merge PR)
      │
      ▼
┌─────────────────────────────────────┐
│ Stage 1: Build + Test               │
│   ├── npm ci                         │
│   ├── npm run lint                   │
│   ├── npm run test                   │
│   ├── npm run build                  │
│   └── tsc --noEmit                   │
└──────────┬──────────────────────────┘
           │ (all pass)
           ▼
┌─────────────────────────────────────┐
│ Stage 2: Deploy                      │
│   ├── SSM RunCommand to EC2:         │
│   │   ├── git pull origin main       │
│   │   ├── npm ci --production        │
│   │   ├── npx mikro-orm migration:up │
│   │   ├── npm run build              │
│   │   └── pm2 restart kuwboo-api     │
│   │                                  │
│   └── Wait for PM2 online status     │
└──────────┬──────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│ Stage 3: Health Check                │
│   ├── curl https://api/health        │
│   ├── Verify 200 response            │
│   └── If fail → rollback             │
└─────────────────────────────────────┘
```

**GitHub Actions workflow (target):**

```yaml
name: Deploy

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'

permissions:
  id-token: write  # OIDC for AWS

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      - run: cd backend && npm ci
      - run: cd backend && npm run lint
      - run: cd backend && npm run test
      - run: cd backend && npm run build
      - run: cd backend && npx tsc --noEmit

  deploy:
    needs: build-test
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::166927554624:role/kuwboo-deploy-role
          aws-region: eu-west-2
      - name: Deploy via SSM
        run: |
          aws ssm send-command \
            --instance-ids i-00ba3186d66389f31 \
            --document-name "AWS-RunShellScript" \
            --parameters 'commands=[
              "cd /home/ubuntu/kuwboo-api",
              "git pull origin main",
              "npm ci --production",
              "npx mikro-orm migration:up",
              "npm run build",
              "pm2 restart kuwboo-api"
            ]' \
            --timeout-seconds 300
      - name: Health check
        run: |
          sleep 10
          curl -f https://api.kuwboo.com/health || exit 1
```

### 3.3 Rollback Procedure

If a deployment fails or causes issues:

```bash
# 1. SSH/SSM into EC2
aws ssm start-session --target i-00ba3186d66389f31 --profile neil-douglas

# 2. Revert to previous commit
cd /home/ubuntu/kuwboo-api
git log --oneline -5  # Find the previous good commit
git checkout <previous-commit-hash>

# 3. Rebuild and restart
npm ci --production
npm run build
pm2 restart kuwboo-api

# 4. Verify health
curl http://localhost:3000/health

# 5. If migration caused issues, rollback migration
npx mikro-orm migration:down
```

**Important:** Database migrations that drop columns or tables cannot be rolled back this way. Always ensure migrations are forward-compatible (add columns first, backfill, then drop in a later release).

---

## Section 4: Database Operations

### 4.1 Backup Strategy

| Type | Method | Frequency | Retention |
|------|--------|-----------|-----------|
| **Automated RDS snapshots** | AWS automated backup | Daily | 7 days |
| **Manual snapshots** | Before major deployments | Ad hoc | 30 days |
| **Point-in-time recovery** | RDS continuous backup (WAL archival) | Continuous (5-minute granularity) | 7 days |
| **Logical backup** | `pg_dump` to S3 | Weekly (cron) | 90 days |

### 4.2 Point-in-Time Recovery Procedure

If data corruption or accidental deletion occurs:

```bash
# 1. Identify the target time (before the incident)
# 2. Restore via AWS CLI
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier kuwboo-db \
  --target-db-instance-identifier kuwboo-db-recovery \
  --restore-time "2026-03-09T14:00:00Z" \
  --profile neil-douglas

# 3. Once restored, update the application's DB connection to point to the recovery instance
# 4. Verify data integrity
# 5. If good, rename instances (or update DNS/config)
```

### 4.3 Migration Strategy

MikroORM migrations manage schema changes. Key rules:

1. **Migrations are forward-only in production.** Never manually edit a migration that has been applied.
2. **Additive changes first.** Add new columns as nullable → backfill data → make non-null → drop old columns (if any) in a separate migration.
3. **Test migrations locally** against a copy of production schema before deploying.
4. **Lock timeout.** Set a statement timeout for migrations to prevent long-running locks:
   ```sql
   SET lock_timeout = '10s';
   SET statement_timeout = '30s';
   ```

**Commands:**

```bash
# Create a new migration
npx mikro-orm migration:create --name add-trust-score-columns

# Apply pending migrations
npx mikro-orm migration:up

# Rollback last migration (development only)
npx mikro-orm migration:down

# Check migration status
npx mikro-orm migration:pending
```

### 4.4 Connection Pooling

| Setting | Value | Rationale |
|---------|-------|-----------|
| Pool size | 20 | t3.medium has 2 vCPU; 20 connections is generous for a single process |
| Idle timeout | 10 seconds | Release unused connections quickly |
| Connection timeout | 5 seconds | Fail fast if pool is exhausted |
| Statement timeout | 30 seconds | Prevent runaway queries |

```typescript
// MikroORM config
const config: MikroORMOptions = {
  pool: {
    min: 5,
    max: 20,
    idleTimeoutMillis: 10000,
    acquireTimeoutMillis: 5000,
  },
};
```

### 4.5 Required PostgreSQL Extensions

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";    -- UUID generation
CREATE EXTENSION IF NOT EXISTS "vector";        -- pgvector for embeddings
CREATE EXTENSION IF NOT EXISTS "postgis";       -- PostGIS for proximity queries
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- Trigram similarity for fuzzy search
```

---

## Section 5: Monitoring and Alerting

### 5.1 CloudWatch Metrics

| Metric | Alarm Threshold | Action |
|--------|----------------|--------|
| **EC2 CPU** | >70% for 15 min | SNS alert → email |
| **EC2 Memory** | >80% | SNS alert → email |
| **EC2 Disk** | >80% | SNS alert → email |
| **RDS CPU** | >70% for 15 min | SNS alert → email |
| **RDS free storage** | <5 GB | SNS alert → email |
| **RDS connections** | >15 (75% of pool) | SNS alert → email |
| **ElastiCache memory** | >80% | SNS alert → email |
| **ElastiCache evictions** | >0 | SNS alert → investigate |

### 5.2 Application Health Checks

The NestJS application exposes health check endpoints:

```typescript
// GET /health — basic liveness
{
  "status": "ok",
  "uptime": 86400,
  "version": "1.0.0",
  "timestamp": "2026-03-09T12:00:00Z"
}

// GET /health/ready — full readiness (checks dependencies)
{
  "status": "ok",
  "database": "connected",
  "redis": "connected",
  "queues": {
    "push-notifications": { "failed": 0, "dlq": 0, "healthy": true },
    "behavior-analysis": { "failed": 0, "dlq": 0, "healthy": true },
    // ... all queues from RTA Section 7 + TRUST_ENGINE Section 9 + SAFETY_PIPELINE Section 8
  }
}
```

**Health check frequency:**
- CloudWatch synthetic canary: every 5 minutes → `/health`
- Load balancer health check (future): every 30 seconds → `/health`
- Internal BullMQ DLQ check: every 5 minutes → alert on DLQ depth > 0 for critical queues

### 5.3 PM2 Monitoring

PM2 provides process-level monitoring:

```bash
# Check process status
pm2 status

# View real-time logs
pm2 logs kuwboo-api --lines 100

# Monitor CPU/memory
pm2 monit

# View restart count (high restart count = crash loop)
pm2 describe kuwboo-api | grep "restart time"
```

**Alert on:** PM2 restart count increasing (indicates crash loop). Configure PM2 to send alerts via ecosystem.config.js:

```javascript
module.exports = {
  apps: [{
    name: 'kuwboo-api',
    script: 'dist/main.js',
    instances: 1,
    max_memory_restart: '3G',  // Restart if memory exceeds 3 GB (out of 4 GB)
    exp_backoff_restart_delay: 1000,  // Exponential backoff on crash
    max_restarts: 10,  // Stop trying after 10 crashes in a row
    min_uptime: '10s',  // Don't count a restart as stable if it crashes within 10s
  }],
};
```

### 5.4 Error Tracking

**Recommended:** Sentry for application error tracking.

| Feature | Configuration |
|---------|--------------|
| **Capture** | Unhandled exceptions, unhandled promise rejections |
| **Context** | User ID (anonymized), request path, error stack |
| **Sampling** | 100% for errors, 10% for performance traces |
| **Alerts** | New error type → Slack/email notification |

```typescript
// NestJS Sentry integration
import * as Sentry from '@sentry/nestjs';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,
});
```

### 5.5 Log Aggregation

| Layer | Log Destination | Format |
|-------|----------------|--------|
| **Nginx** | `/var/log/nginx/access.log`, `/var/log/nginx/error.log` | CLF + JSON |
| **NestJS (Pino)** | stdout → PM2 → CloudWatch Logs | JSON structured logging |
| **PostgreSQL** | RDS log exports to CloudWatch | Standard pg log format |
| **BullMQ** | Application logs (Pino) | JSON with job metadata |

**CloudWatch Logs retention:** 30 days for application logs, 90 days for access logs.

---

## Section 6: SSL and Domain Management

### 6.1 Current SSL Configuration

| Property | Value |
|----------|-------|
| Domain | `kuwboo-api.codiantdev.com` |
| Issuer | Let's Encrypt |
| Expires | Apr 27, 2026 |
| Auto-Renewal | Yes (certbot timer) |
| Cert Path | `/etc/letsencrypt/live/kuwboo-api.codiantdev.com/` |

### 6.2 Certbot Auto-Renewal

```bash
# Check certificate status
sudo certbot certificates

# Verify auto-renewal timer
sudo systemctl status certbot.timer

# Test renewal (dry run)
sudo certbot renew --dry-run

# Force renewal (if needed)
sudo certbot renew --force-renewal
```

The certbot timer runs twice daily. Certificates renew when they're within 30 days of expiry.

### 6.3 Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name kuwboo-api.codiantdev.com;

    ssl_certificate /etc/letsencrypt/live/kuwboo-api.codiantdev.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/kuwboo-api.codiantdev.com/privkey.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options DENY always;

    # WebSocket support for Socket.io
    location /socket.io/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Socket.io timeout settings
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }

    # API routes
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Request size limit (for file uploads, presigned URLs handle large files)
        client_max_body_size 10M;
    }
}

server {
    listen 80;
    server_name kuwboo-api.codiantdev.com;
    return 301 https://$host$request_uri;
}
```

### 6.4 Future Domain Plan

When transitioning to production domains:

1. Register `api.kuwboo.com` in Route 53
2. Issue new Let's Encrypt certificate for the new domain
3. Update Nginx config with new domain
4. Maintain old domain as redirect for transition period
5. Update mobile app API base URL in Flutter config

---

## Section 7: Scaling Strategy

### 7.1 Scale-Up Triggers

| Metric | Threshold | Action |
|--------|-----------|--------|
| EC2 CPU | Sustained >70% for 24 hours | Upgrade instance type |
| EC2 Memory | >80% sustained | Upgrade instance type |
| API p95 latency | >500ms | Investigate bottleneck, then scale |
| RDS CPU | Sustained >70% for 24 hours | Upgrade instance class |
| RDS connections | >80% of max | Increase pool size or upgrade |
| Redis memory | >80% | Upgrade node type |
| Concurrent WebSocket connections | >5,000 | Evaluate horizontal scaling |

### 7.2 Vertical Scaling Path

| Stage | EC2 | RDS | Redis | Est. Users |
|-------|-----|-----|-------|------------|
| **Launch** | t3.medium (4 GB) | db.t3.micro | cache.t3.micro | 0-5K |
| **Growth** | t3.large (8 GB) | db.t3.small | cache.t3.small | 5K-25K |
| **Scale** | t3.xlarge (16 GB) | db.t3.medium | cache.t3.medium | 25K-100K |
| **Break out** | ALB + ASG (2+ instances) | db.r6g.large + read replica | Redis cluster | 100K+ |

### 7.3 Horizontal Scaling (When Vertical Isn't Enough)

**Prerequisites for horizontal scaling:**
1. **Stateless application** — NestJS backend must not rely on in-memory state (already true: Socket.io uses Redis adapter, sessions in Redis)
2. **Sticky sessions for WebSocket** — ALB with WebSocket stickiness for Socket.io long-polling fallback
3. **Shared file system** — Not needed (media goes to S3)
4. **Database connection management** — Each instance gets its own pool; total connections must stay within RDS limits

**Architecture at scale:**

```
Route 53 → ALB (Application Load Balancer)
              ├── Target Group: EC2 instances (ASG, min 2, max 6)
              │     ├── Instance 1: NestJS + PM2
              │     ├── Instance 2: NestJS + PM2
              │     └── Instance N: NestJS + PM2
              │
              ├── WebSocket: Sticky sessions (cookie-based)
              └── Health check: /health every 30s
```

### 7.4 Database Scaling

| Approach | When | Cost Impact |
|----------|------|-------------|
| **Vertical** (larger instance) | RDS CPU >70% sustained | ~2x per step |
| **Read replicas** | Read-heavy workload (feeds, search) | +$15-50/mo per replica |
| **Connection pooling** (PgBouncer) | Connection count > 100 | Minimal (runs on EC2) |
| **Table partitioning** | Tables >100M rows (login_events, trust_signals) | None (schema change) |

### 7.5 When to Break the Monolith

The modular monolith (NestJS modules) is the right architecture until:

| Signal | Threshold | Extract Module |
|--------|-----------|---------------|
| Chat/messaging becomes bottleneck | >10K concurrent WebSocket connections | Extract chat as a separate service behind the same ALB |
| Media processing saturates CPU | Media jobs compete with API latency | Extract media processing to Lambda or dedicated worker instance |
| BullMQ queue depth grows unbounded | Feed/embedding jobs delay >5 minutes | Extract workers to dedicated instance |

Until these thresholds are reached, the monolith is simpler to operate, deploy, and debug.

---

## Section 8: Security

### 8.1 Network Security

**Security Group Rules:**

| Rule | Type | Port | Source | Purpose |
|------|------|------|--------|---------|
| Inbound | HTTPS | 443 | 0.0.0.0/0 | Public API access |
| Inbound | HTTP | 80 | 0.0.0.0/0 | Redirect to HTTPS |
| Inbound | SSH | 22 | Developer IP only | Emergency SSH (prefer SSM) |
| Outbound | All | All | 0.0.0.0/0 | API calls, package installs |

**RDS Security Group:**
- Inbound: PostgreSQL (5432) from EC2 security group only
- No public access

**ElastiCache Security Group:**
- Inbound: Redis (6379) from EC2 security group only
- No public access

### 8.2 Access Control

**Recommended: SSM Session Manager** (no SSH keys, no port 22 needed, full audit trail)

```bash
aws ssm start-session \
  --target i-00ba3186d66389f31 \
  --profile neil-douglas
```

**SSH via EC2 Instance Connect** (backup method):

```bash
aws ec2-instance-connect send-ssh-public-key \
  --instance-id i-00ba3186d66389f31 \
  --instance-os-user ubuntu \
  --ssh-public-key file://~/.ssh/lion.pub \
  --availability-zone eu-west-2c \
  --profile neil-douglas

ssh -i ~/.ssh/lion ubuntu@35.177.230.139
```

### 8.3 Credential Rotation

**Critical:** The previous developer (Codiant) had access to all credentials. Rotation schedule:

| Credential | Status | Rotation Priority |
|-----------|--------|-------------------|
| RDS master password | **Must rotate** | Immediate — before greenfield deployment |
| JWT secrets | **Must rotate** | Immediate |
| Twilio credentials | **Must rotate** | Before launch |
| AWS access keys | Rotate to IAM roles | Move to instance roles (no long-lived keys) |
| SMTP credentials | Rotate | Before launch |
| Firebase credentials | Verify access, rotate if shared | Before launch |

**Rotation procedure:**
1. Generate new credential
2. Store in Secrets Manager
3. Update application config to read from Secrets Manager
4. Restart application
5. Verify functionality
6. Revoke old credential

### 8.4 Application Security

| Measure | Implementation |
|---------|---------------|
| Rate limiting | NestJS `@nestjs/throttler` — 100 req/min per IP globally, stricter per endpoint |
| CORS | Whitelist specific origins (mobile app user-agent, admin dashboard domain) |
| Helmet | `@nestjs/helmet` — security headers (CSP, HSTS, X-Frame-Options) |
| Input validation | `class-validator` decorators on all DTOs |
| SQL injection | Prevented by MikroORM parameterized queries (never raw string interpolation) |
| JWT | Short-lived access tokens (15 min), long-lived refresh tokens (30 days), rotation on use |

### 8.5 DDoS Mitigation

**Current:** Nginx rate limiting + CloudFront (for media CDN)

**Future (if needed):** AWS WAF in front of ALB with rules for:
- Rate-based rules (throttle IPs exceeding 2,000 req/5min)
- Geographic restrictions (block regions with no users)
- Managed rule groups (AWS managed rules for common attacks)

---

## Section 9: Disaster Recovery

### 9.1 RTO/RPO Targets

| Scenario | RTO (Recovery Time) | RPO (Data Loss) |
|----------|---------------------|-----------------|
| **EC2 failure** | 30 minutes | 0 (stateless, data in RDS/Redis/S3) |
| **RDS failure** (single-AZ) | 4-6 hours (restore from snapshot) | Up to 24 hours (last automated backup) |
| **RDS failure** (multi-AZ, future) | <5 minutes (automatic failover) | 0 |
| **Redis failure** | 15 minutes (restart/replace) | Minutes (Redis data is reconstructable from DB) |
| **S3 data loss** | N/A | 0 (11 nines durability) |
| **Complete region failure** | 24+ hours (manual cross-region recovery) | Up to 24 hours |

### 9.2 Backup Verification

| Check | Frequency | Method |
|-------|-----------|--------|
| RDS automated backup exists | Daily (CloudWatch alarm) | Check RDS backup status |
| Logical backup (pg_dump) succeeded | Weekly | Check S3 bucket for latest backup file |
| Backup restore test | Monthly | Restore to a test instance, verify data integrity |

### 9.3 Cross-Region Recovery Plan

Not implemented initially (cost concern). When justified:

1. Enable RDS cross-region read replica in eu-west-1 (Ireland)
2. Replicate S3 bucket to eu-west-1
3. Prepare AMI/launch template in eu-west-1
4. Document DNS failover procedure (Route 53 health check + failover routing)

### 9.4 Data Export (GDPR Right to Portability)

> 📋 **Regulatory requirement:** See REGULATORY_REQUIREMENTS.md §2.3 for UK GDPR data portability obligations.

```bash
# Export user data as JSON (GDPR data subject access request)
# This should be implemented as an admin API endpoint
# GET /admin/users/:userId/export → JSON file with all user data

# Database-level export for compliance
pg_dump -h <rds-host> -U kuwboo -d kuwboo \
  --table=users --table=dating_profiles --table=content \
  --where="user_id = '<user-uuid>'" \
  -F c -f user_export.dump
```

---

## Section 10: Operational Runbooks

### 10.1 Server Restart

```bash
# 1. Connect via SSM
aws ssm start-session --target i-00ba3186d66389f31 --profile neil-douglas

# 2. Check current status
pm2 status
pm2 logs kuwboo-api --lines 20

# 3. Graceful restart
pm2 restart kuwboo-api

# 4. Verify
pm2 status
curl http://localhost:3000/health
```

### 10.2 Database Restore from Backup

```bash
# Option A: Point-in-time recovery (preferred)
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier kuwboo-db \
  --target-db-instance-identifier kuwboo-db-recovery \
  --restore-time "2026-03-09T14:00:00Z" \
  --db-instance-class db.t3.micro \
  --profile neil-douglas

# Option B: Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier kuwboo-db-recovery \
  --db-snapshot-identifier <snapshot-id> \
  --db-instance-class db.t3.micro \
  --profile neil-douglas

# Wait for instance to be available
aws rds wait db-instance-available \
  --db-instance-identifier kuwboo-db-recovery \
  --profile neil-douglas

# Update application config with new endpoint
# Restart application
```

### 10.3 SSL Certificate Emergency Renewal

```bash
# 1. Connect to EC2
aws ssm start-session --target i-00ba3186d66389f31 --profile neil-douglas

# 2. Check current certificate
sudo certbot certificates

# 3. Force renewal
sudo certbot renew --force-renewal

# 4. Reload Nginx (no downtime)
sudo nginx -s reload

# 5. Verify
openssl s_client -connect kuwboo-api.codiantdev.com:443 -servername kuwboo-api.codiantdev.com < /dev/null 2>/dev/null | openssl x509 -noout -dates
```

### 10.4 Redis Memory Emergency

```bash
# 1. Check Redis memory usage
redis-cli -h <redis-host> INFO memory

# 2. If memory is critical, flush non-essential caches
redis-cli -h <redis-host> --scan --pattern "behavior:*" | xargs redis-cli DEL  # Behavior windows (reconstructable)
redis-cli -h <redis-host> --scan --pattern "ratelimit:*" | xargs redis-cli DEL  # Rate limits (ephemeral)

# 3. Check BullMQ completed/failed jobs (can accumulate)
redis-cli -h <redis-host> --scan --pattern "bull:*:completed" | xargs redis-cli DEL
redis-cli -h <redis-host> --scan --pattern "bull:*:failed" | xargs redis-cli DEL

# 4. If still critical: upgrade ElastiCache node type
```

### 10.5 Incident Response Checklist

When an incident is detected:

1. **Assess severity**
   - [ ] Is the API responding? (`curl https://api/health`)
   - [ ] Is the database connected? (`curl https://api/health/ready`)
   - [ ] Are users affected? (check error tracking / Sentry)

2. **Contain**
   - [ ] If attack: block offending IPs via security group
   - [ ] If data breach: revoke compromised credentials immediately
   - [ ] If performance: scale up or restart

3. **Communicate**
   - [ ] Notify Phil (contractor)
   - [ ] Notify Neil (client) if user-facing impact
   - [ ] If data breach: 72-hour GDPR notification deadline starts now

4. **Resolve**
   - [ ] Fix root cause
   - [ ] Deploy fix
   - [ ] Verify fix via health check

5. **Post-mortem**
   - [ ] Document what happened, when, why
   - [ ] Identify prevention measures
   - [ ] Update runbooks if needed

### 10.6 Scheduled Maintenance Windows

| Task | Schedule | Duration | Impact |
|------|----------|----------|--------|
| RDS maintenance | Sunday 03:00-04:00 UTC | Up to 60 min | Brief DB restart during patching |
| OS security patches | Monthly, manual | 15 min | Brief API restart |
| Node.js version upgrade | Quarterly | 30 min | PM2 restart |
| Dependency audit + update | Monthly | CI/CD (no downtime) | None if tests pass |
| Log rotation | Daily (logrotate) | None | None |
| Redis backup | Daily (RDB snapshot) | None | Brief latency spike |
