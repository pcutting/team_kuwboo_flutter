# Admin Dashboard & AWS Deployment Plan

**Date:** 2026-04-08
**Status:** Planning
**Scope:** Full admin dashboard build + production deployment

---

## Part 1: AWS Deployment Plan

### Current Infrastructure

| Resource | Details |
|----------|---------|
| EC2 | `i-0766e373b3147a2aa` — t3.medium, Ubuntu 22.04, eu-west-2a |
| Elastic IP | `35.177.230.139` |
| RDS | `kuwboo-greenfield-db` — PostgreSQL 16, db.t3.micro |
| Redis | Local on EC2, port 6379 |
| Domain | `kuwboo-api.codiantdev.com` (SSL via Let's Encrypt) |
| Nginx | Reverse proxy on EC2, ports 80/443 → :3000 (API), :8080 (design preview) |
| PM2 | Process manager for NestJS |

### Deployment Strategy for Admin App

The React admin app (`apps/admin/`) is a static build (HTML/CSS/JS). Two deployment options:

#### Option A: Serve from existing EC2 via Nginx (Recommended for now)

**Rationale:** Zero additional cost, uses existing infrastructure, simple.

**Steps:**
1. Build admin app: `cd apps/admin && npm run build` → produces `dist/`
2. Copy `dist/` to EC2: `scp -r dist/ ec2-user@35.177.230.139:/var/www/admin/`
3. Add Nginx server block for admin subdomain
4. SSL cert via certbot for `admin.kuwboo.com` (or `kuwboo-admin.codiantdev.com` for staging)

**Nginx config to add:**
```nginx
server {
    listen 443 ssl http2;
    server_name admin.kuwboo.com;

    ssl_certificate /etc/letsencrypt/live/admin.kuwboo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/admin.kuwboo.com/privkey.pem;

    root /var/www/admin;
    index index.html;

    # SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API calls
    location /api/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**DNS:** Add A record `admin.kuwboo.com → 35.177.230.139` in Route 53

**Cost:** $0 additional

#### Option B: CloudFront + S3 (Future — when scaling)

- Upload `dist/` to S3 bucket `kuwboo-admin-{env}`
- CloudFront distribution with `admin.kuwboo.com` CNAME
- Origin Access Control for S3
- API calls go directly to `api.kuwboo.com` (update CORS)
- ACM certificate for SSL

**When to switch:** When you need global CDN caching or want to separate admin from API server.

### Deployment Steps (Option A)

```bash
# 1. On dev machine — build
cd apps/admin
VITE_API_URL=https://admin.kuwboo.com/api npm run build

# 2. SSH to EC2 and prepare
ssh -i kuwboo-eu-west-2-key.pem ubuntu@35.177.230.139
sudo mkdir -p /var/www/admin

# 3. Copy build (from dev machine)
scp -i kuwboo-eu-west-2-key.pem -r dist/* ubuntu@35.177.230.139:/var/www/admin/

# 4. On EC2 — add Nginx config
sudo nano /etc/nginx/sites-available/admin
# (paste the server block above)
sudo ln -s /etc/nginx/sites-available/admin /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 5. SSL certificate
sudo certbot --nginx -d admin.kuwboo.com

# 6. Deploy API updates (bot system)
cd /home/ubuntu/team_kuwboo
git pull origin main
cd apps/api
npm ci
npx mikro-orm migration:up
npm run build
pm2 restart kuwboo-api

# 7. Update CORS origins in .env
# CORS_ORIGINS=https://kuwboo.com,https://admin.kuwboo.com

# 8. Verify
curl -I https://admin.kuwboo.com
curl https://admin.kuwboo.com/api/health
```

### API CORS Update

Add `admin.kuwboo.com` to allowed origins in `apps/api/src/main.ts` or `.env`:
```
CORS_ORIGINS=https://kuwboo.com,https://admin.kuwboo.com
```

### Environment Variables for Admin App

Create `apps/admin/.env.production`:
```
VITE_API_URL=https://admin.kuwboo.com/api
```

---

## Part 2: Full Admin Dashboard — Feature Plan

### Current State

The admin dashboard today has:
- Landing page (public)
- Admin login (phone OTP)
- Dashboard with platform stats + bot stats
- Users list with human/bot filtering
- Bots list with status filtering

### What's Needed for Professional Platform Management

---

### Module 1: Content Moderation

**Why:** Platform liability. User-generated content requires review capability.

**Backend additions needed:**
- `PATCH /admin/content/:id/status` — Admin can set any content status (ACTIVE, HIDDEN, FLAGGED, REMOVED)
- `GET /admin/content` — List all content with filtering (status, type, creator, date range)
- `GET /admin/content/flagged` — Queue of flagged/reported content
- `POST /admin/content/:id/restore` — Restore removed content

**Frontend pages:**
- **Content Queue** — Filterable list of all content with inline moderation actions (hide, remove, approve)
- **Flagged Content** — Priority queue from user reports, sortable by report count
- **Content Detail** — Full view with media, comments, engagement stats, report history

---

### Module 2: Comment Moderation

**Backend additions needed:**
- `GET /admin/comments` — List comments with filtering
- `DELETE /admin/comments/:id` — Admin delete comment
- `GET /admin/comments/flagged` — Reported comments queue

**Frontend:**
- **Comments tab** within content detail view
- **Flagged Comments** queue

---

### Module 3: Report Management

**Why:** Reports exist but have no enforcement tie-in.

**Backend additions needed:**
- `GET /admin/reports` — Already exists but needs better filtering (by target type, reason, status, date range)
- `POST /admin/reports/:id/action` — Take enforcement action (remove content, warn user, suspend user) linked to report resolution
- `GET /admin/reports/stats` — Report volume trends

**Frontend pages:**
- **Reports Queue** — Prioritized by severity, count, and age
- **Report Detail** — Full context: reported content/user, reporter history, previous reports on same target
- **Enforcement Actions** — Dropdown to take action directly from report (remove content + warn user in one flow)

---

### Module 4: User Management (Enhanced)

**Backend additions needed:**
- `GET /admin/users/:id/detail` — Full user profile with engagement stats, content count, report history, sessions, devices
- `POST /admin/users/:id/suspend` — Suspend with reason, duration, notification
- `POST /admin/users/:id/warn` — Issue warning (creates notification + audit record)
- `DELETE /admin/users/:id/sessions` — Force logout (revoke all sessions)
- `GET /admin/users/:id/content` — All content by user
- `GET /admin/users/:id/reports` — Reports filed against user
- `POST /admin/users/search` — Full-text search by name, phone, email

**Frontend pages:**
- **User Detail** — Profile info, engagement metrics, content list, report history, session list, moderation history
- **User Search** — Search bar with auto-complete
- **Suspension Dialog** — Reason, duration, notification preview

---

### Module 5: Bot Management (Enhanced)

**Backend additions needed:**
- `POST /admin/bots/:id/reset` — Clear error state and restart
- `GET /admin/bots/:id/activity/stats` — Aggregated activity stats (actions per hour, success rate, action type breakdown)

**Frontend enhancements:**
- **Bot Detail Page** — Full profile, behavior config editor, activity log timeline, action stats charts
- **Bot Create Dialog** — Form with persona picker, location map, config preview
- **Bulk Actions** — Select multiple bots, start/stop/delete
- **Activity Timeline** — Visual timeline of bot actions with success/failure coloring

---

### Module 6: Analytics Dashboard

**Why:** Every professional platform needs growth/health metrics.

**Backend additions needed:**
- `GET /admin/analytics/growth` — New users per day/week/month, retention
- `GET /admin/analytics/engagement` — DAU/MAU, posts per day, likes per day, comments per day
- `GET /admin/analytics/content` — Content created per type, top content, content status breakdown
- `GET /admin/analytics/yoyo` — Waves sent/accepted, nearby encounters
- `GET /admin/analytics/marketplace` — Products listed, auctions active, bids placed

**Frontend pages:**
- **Analytics Overview** — Key metrics with sparkline charts
- **Growth** — User signup graph, retention cohorts
- **Engagement** — DAU/MAU ratio, actions per user, session duration
- **Content** — Posts/videos created, moderation actions taken

---

### Module 7: Admin Audit Trail

**Why:** Accountability. Know who did what and when.

**Backend additions needed:**
- New entity: `AdminAuditLog` — admin user, action type, target type, target ID, details (JSONB), IP address, timestamp
- Middleware/interceptor to auto-log all admin actions
- `GET /admin/audit-log` — Paginated, filterable audit log

**Frontend:**
- **Audit Log** page — Table with filters by admin user, action type, date range

---

### Module 8: Session & Security Management

**Backend additions needed:**
- `GET /admin/sessions` — Active sessions across all users with device/IP info
- `GET /admin/sessions/stats` — Concurrent users, sessions by device type, geographic distribution

**Frontend:**
- **Active Sessions** — List of currently active sessions
- **Security Alerts** — Token reuse detections, suspicious logins

---

### Module 9: Marketplace Moderation

**Backend additions needed:**
- `GET /admin/marketplace/products` — All products with filtering
- `PATCH /admin/marketplace/products/:id/status` — Approve/reject/remove products
- `GET /admin/marketplace/auctions` — Active auctions with admin controls
- `POST /admin/marketplace/auctions/:id/cancel` — Cancel auction

**Frontend:**
- **Products Queue** — Review and moderate product listings
- **Active Auctions** — Monitor and intervene if needed

---

### Module 10: Sponsored Content Management

**Backend additions needed:**
- `GET /admin/sponsored/campaigns` — All campaigns across all users
- `PATCH /admin/sponsored/campaigns/:id/approve` — Approve/reject campaigns
- `GET /admin/sponsored/revenue` — Revenue metrics

**Frontend:**
- **Campaign Review** — Approve/reject queue
- **Campaign Performance** — Metrics dashboard

---

### Module 11: System Health & Notifications

**Backend additions needed:**
- `POST /admin/notifications/broadcast` — Send notification to all users or segments
- `GET /admin/system/health` — Detailed health (DB pool, Redis, queue depths, memory, uptime)
- `GET /admin/system/queues` — BullMQ queue status (waiting, active, completed, failed counts)

**Frontend:**
- **System Health** — Real-time health dashboard (DB connections, Redis memory, queue depths)
- **Broadcast** — Send announcement notifications to user segments
- **Queue Monitor** — BullMQ job status and error inspection

---

## Implementation Priority

### Phase 1 — Core Admin (Critical Path)
| # | Feature | Backend Work | Frontend Work |
|---|---------|-------------|---------------|
| 1 | Content Moderation | New admin endpoints | Content queue page |
| 2 | Report Management (enhanced) | Enforcement action endpoint | Reports queue page |
| 3 | User Management (enhanced) | Detail, suspend, warn, search | User detail page |
| 4 | Admin Audit Trail | New entity + interceptor | Audit log page |

### Phase 2 — Operations
| # | Feature | Backend Work | Frontend Work |
|---|---------|-------------|---------------|
| 5 | Analytics Dashboard | New analytics service | Charts/metrics pages |
| 6 | Bot Management (enhanced) | Stats endpoint, reset | Bot detail page, create dialog |
| 7 | Comment Moderation | Admin delete endpoint | Comments in content detail |
| 8 | Session Management | Admin sessions endpoint | Sessions page |

### Phase 3 — Business
| # | Feature | Backend Work | Frontend Work |
|---|---------|-------------|---------------|
| 9 | Marketplace Moderation | Product/auction admin endpoints | Products queue |
| 10 | Sponsored Content Management | Campaign approval endpoints | Campaign review page |
| 11 | System Health & Notifications | Health detail, broadcast endpoints | Health dashboard |

---

## Admin Dashboard Route Map (Full)

```
/                          Landing page (public)
/login                     Admin sign-in (public)
/dashboard                 Overview stats
/dashboard/users           User list + search
/dashboard/users/:id       User detail
/dashboard/bots            Bot list
/dashboard/bots/:id        Bot detail
/dashboard/bots/create     Bot creation
/dashboard/content         Content moderation queue
/dashboard/content/:id     Content detail
/dashboard/reports         Reports queue
/dashboard/reports/:id     Report detail
/dashboard/comments        Comment moderation
/dashboard/analytics       Analytics overview
/dashboard/analytics/growth    Growth metrics
/dashboard/analytics/engagement Engagement metrics
/dashboard/marketplace     Marketplace moderation
/dashboard/sponsored       Campaign review
/dashboard/audit-log       Admin audit trail
/dashboard/sessions        Active sessions
/dashboard/system          System health
/dashboard/system/queues   Queue monitor
/dashboard/notifications   Broadcast notifications
```

---

## Tech Stack (Admin App)

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | React 19 + TypeScript | Contract specifies React |
| Build | Vite 6 | Fast builds, HMR |
| Styling | Tailwind CSS v4 | Rapid UI, consistent design |
| Routing | React Router v7 | Standard |
| State | React Context + fetch | Simple, no Redux needed yet |
| Charts | Recharts or lightweight SVG | Analytics pages |
| Tables | Custom with pagination | Already built |
| Forms | React Hook Form (add when needed) | Validation |
| Date handling | date-fns (add when needed) | Lightweight |

---

## Estimated Scope

| Phase | New Backend Endpoints | New Frontend Pages | Estimated Files |
|-------|----------------------|-------------------|----------------|
| Phase 1 | ~15 | ~8 | ~25 |
| Phase 2 | ~10 | ~6 | ~20 |
| Phase 3 | ~10 | ~5 | ~15 |
| **Total** | **~35** | **~19** | **~60** |
