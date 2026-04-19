# Admin Dashboard Audit — 2026-04-19

End-to-end verification of the Kuwboo admin dashboard at https://admin.kuwboo.com (production, greenfield rebuild). Performed after PRs #164–#167 shipped email+password login earlier today.

**Signed in as:** `phil_admin` / `cuttingphilip@gmail.com` (SUPER_ADMIN)
**Backend:** https://api.kuwboo.com (NestJS on EC2 `i-0766e373b3147a2aa`, eu-west-2)
**Frontend build hash observed:** `assets/index-DvZ4GjwG.js`
**Tooling:** Playwright MCP (navigation, snapshot, network, console)

Legend: **✅** works end-to-end · **🟡** loads but data/feature incomplete · **❌** broken

---

## Public routes

### `/` — LandingPage ✅
Renders marketing hero (heading, subhead, App Store/Google Play buttons, four feature cards). Footer links (Privacy, Terms, Contact) all point to `#` — placeholder only. No console errors. Network: none.

### `/login` — LoginPage ✅
Email+password form (Email tab selected by default), Phone tab available, Forgot-password link, Show/Hide password toggle, disabled Sign In button until both fields filled. `POST /auth/email/login` returns 200 and redirects to `/dashboard`. Clean.

### `/forgot-password`, `/reset-password` — ForgotPasswordPage / ResetPasswordPage
Not exercised in this session (out-of-band email flow required). Spot-checked that routes exist in `App.tsx` as public.

---

## Protected routes (`/dashboard/*`)

### `/dashboard` — DashboardPage ✅
Loads Platform card (Total Users 25, Active Users 25, Media Items 0, Notifications 0) and Agent Bots card (all zero). Calls `GET /admin/stats` 200, `GET /admin/bots/stats` 200. Zero console errors. Works end-to-end.

### `/dashboard/users` — UsersPage ✅
`GET /admin/users?page=1&limit=20` 200. Renders a table of 20 users (paginated, "Page 1 of 2", Next enabled, Previous correctly disabled). Filter tabs (all / humans / bots), search box, and pagination all render. Finding: clicking a user row navigates to the broken `/dashboard/users/:id` (see below).

### `/dashboard/users/:id` — UserDetailPage ❌
**Crashes with a TypeError and leaves a blank page.** Both API calls succeed (`GET /admin/users/{id}/detail` 200, `GET /admin/users/{id}/content?page=1&limit=10` 200) but the page throws:

```
TypeError: Cannot read properties of undefined (reading 'charAt')
```

Root cause: `apps/admin/src/pages/UserDetailPage.tsx:235` reads `user.name.charAt(0)` without a null guard. The `/admin/users/{id}/detail` response returns the user but `name` is undefined for users who only have a phone number (no display name populated). There is no React error boundary to catch it, so the whole page is blank. **User-facing impact: the entire user detail view is unusable for any phone-only user (majority of seeded users).**

### `/dashboard/content` — ContentPage 🟡
`GET /admin/content?page=1&limit=20` 200. Renders a 20-row table ("44 items", "Page 1 of 3"). Filter tabs (All / Active / Flagged / Hidden / Removed) render. Hide / Remove action buttons present but not exercised. Finding: **the Creator column is blank for every row** — row text is `PRODUCT ACTIVE 0 likes · 0 comments · 0 views …` with no creator identifier. Either the API response omits creator name/handle or the page doesn't render the field. Zero console errors.

### `/dashboard/interests` — InterestsPage ❌
`GET /admin/interests` returns **500 Internal Server Error**. Page renders a visible "Internal server error" banner with Dismiss button plus "No interests found" empty row — graceful degradation, but the feature is non-functional. Server-side bug (likely in the `InterestsController` — the migration PR #165 renamed `content_interest_tags` but the endpoint may still reference the old schema).

### `/dashboard/bots` — BotsPage ✅
`GET /admin/bots?page=1&limit=20` 200. Renders "0 bots configured" with filter tabs (All / Running / Paused / Idle / Error) and "No bots found" empty state. No bots seeded yet, so behaviour is correct. No errors.

### `/dashboard/bots/:id` — BotDetailPage 🟡
When visiting with a non-bot UUID (`f3e59eba-…` — the seeded "Bot Marley" user who is not registered in the bots table), `GET /admin/bots/{id}` and `GET /admin/bots/{id}/activity/stats` both return 404. The page handles this gracefully with a breadcrumb and "Bot profile not found" message. However, `GET /admin/bots/{id}/activity` returns 200 even for a non-existent bot — an inconsistency worth tidying server-side. Page itself does not crash.

### `/dashboard/reports` — ReportsPage ✅
`GET /reports?page=1&limit=20` 200 (note: endpoint is `/reports`, not `/admin/reports` — inconsistent with the rest of the admin API). Table + filter controls render, empty state. No errors.

### `/dashboard/marketplace` — MarketplacePage ✅
`GET /admin/marketplace/products?page=1&limit=20` 200. Tabs (All / Pending / Active / Hidden / Removed) render, empty table. No errors.

### `/dashboard/sponsored` — SponsoredPage ✅
`GET /admin/sponsored/campaigns?page=1&limit=20` 200. Empty table renders. No errors.

### `/dashboard/audit-log` — AuditLogPage ✅
`GET /admin/audit-log?page=1&limit=20` 200. Table + action-type combobox render. Empty state. No errors.

### `/dashboard/analytics` — AnalyticsPage ✅
All four calls 200: `/admin/analytics/engagement`, `/admin/analytics/growth?days=30`, `/admin/analytics/content`, `/admin/analytics/active-users?days=30`. Renders Active Users (DAU 11), Engagement, Content Breakdown, Growth (30-day signups) sections. No errors.

### `/dashboard/sessions` — SessionsPage ✅
`GET /admin/sessions/stats` 200. No console errors. Stats render.

### `/dashboard/broadcast` — BroadcastPage ✅
Form-only page (title, body, role-filter); Send Notification button disabled until filled. No network on load (intended). No errors.

### `/dashboard/system` — SystemHealthPage ❌
**Crashes with a TypeError and leaves a blank page.** `GET /admin/system/health` returns 200 but the page throws:

```
TypeError: Cannot read properties of undefined (reading 'rss')
```

Root cause: `apps/admin/src/pages/SystemHealthPage.tsx:121` reads `health.memory.rss` but the API response does not include a `memory` object (or shape has drifted). No null guard, no error boundary — whole page is blank. **User-facing impact: the primary SUPER_ADMIN ops dashboard is unusable.**

---

## Cross-cutting observations

- **No React error boundary.** Both of the ❌ crashes (UserDetailPage, SystemHealthPage) render a fully blank page rather than a "Something went wrong" fallback. A single top-level `<ErrorBoundary>` inside `AdminLayout` would soften the blast radius of any future undefined-access bug.
- **Endpoint path inconsistency.** Every admin endpoint is under `/admin/*` except Reports, which uses `/reports`. Likely a forgotten prefix on the NestJS controller.
- **Landing-page footer links are all `#`.** Privacy, Terms, Contact — either wire them up or remove them before public release.
- **Login form UX** is clean: disabled-until-valid Sign In, show/hide password toggle, forgot-password link, email/phone tabs. No complaints.
- **ProtectedRoute** works — navigating without a session sends you to `/login` (implicit, observed on the initial navigation).
- **No CSP/CORS errors, no mixed content, no 4xx on static assets.** Deploy is healthy.

---

## Top 5 issues to fix first (ranked by user-facing impact)

1. **❌ UserDetailPage crashes on any user without a `name`** (`apps/admin/src/pages/UserDetailPage.tsx:235`). Blocks all user inspection for phone-only users — the majority. Fix: `(user.name ?? user.email ?? user.phone ?? 'U').charAt(0).toUpperCase()` and render a sensible display name fallback throughout the page.
2. **❌ SystemHealthPage crashes because `health.memory` is undefined** (`SystemHealthPage.tsx:121`). The SUPER_ADMIN ops view is completely blank. Fix: add optional chaining (`health.memory?.rss`) and an empty-state, and align the API response shape (`/admin/system/health`) with what the page expects — or update the page to consume the real shape.
3. **❌ `/admin/interests` returns 500.** Interests admin is non-functional. Likely a stale reference to the renamed `content_interest_tags` table after PR #165, or a missing seed. Investigate the NestJS InterestsController and apply the outstanding migration on prod RDS.
4. **🟡 Add a top-level React error boundary to `AdminLayout`.** Two of the three ❌ bugs above would be contained (page shows an error card instead of going blank) with a ~20-line component. Net win in perceived stability until the underlying bugs are fixed.
5. **🟡 ContentPage Creator column is empty for every row.** The moderation surface is materially less useful without knowing who created a flagged item. Either (a) include `author` / `user` in the `/admin/content` response or (b) render the field that the API already returns.

Minor follow-ups (not in the top 5 but worth logging): normalize Reports endpoint to `/admin/reports`, wire landing-page footer links, tighten `/admin/bots/:id/activity` to 404 when the bot itself 404s, and verify `/forgot-password` / `/reset-password` flows with a real email.
