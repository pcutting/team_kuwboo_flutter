> **DEPRECATED** — Superseded by client/FEATURE_ANALYSIS_MVP.md + CONTRACT_KUWBOO_REBUILD.md. Retained for historical context.

# Kuwboo MVP Scope & Feature Prioritization

**Created:** January 27, 2026
**Last Updated:** February 5, 2026
**Version:** 1.1

> **See Also:** [FEATURE_ANALYSIS_MVP.md](FEATURE_ANALYSIS_MVP.md) for analysis aligned with Neil's priority list (Video Making, Buy & Sell, Dating, Yoyo, Sponsored Links, Social)

---

## Executive Summary

This document analyzes the Kuwboo codebase to identify which features should be included in a Minimum Viable Product (MVP) versus deferred to later phases. The goal is to reduce complexity, accelerate time-to-market, and validate core assumptions before investing in secondary features.

### Key Recommendations

1. **Launch with ONE core module** - Either Video Making OR Buy & Sell, not both
2. **Remove or hide secondary modules** - Dating, Blog, VIP, Notice Board can wait
3. **Focus on core user journey** - Sign up → Create content → Discover content → Interact
4. **Fix critical issues first** - Security vulnerabilities and stability before features

> **Note:** This document recommends a single-module focus strategy. If Neil prefers a multi-module launch (all 6 priorities), see [FEATURE_ANALYSIS_MVP.md](FEATURE_ANALYSIS_MVP.md) for what's ready vs. needs work.

---

## Current Feature Inventory

### Core Modules (moduleKey)

| Module | Description | iOS Status | Android Status | Backend Status |
|--------|-------------|------------|----------------|----------------|
| **Video Making** | TikTok-like short video | Complete | Complete | Complete |
| **Buy & Sell** | Marketplace with auctions | Complete | Complete | Complete |
| **Social Stumble** | Social discovery feed | Complete | Complete | Complete |
| **Dating** | Matching profiles | Partial | Partial | Complete |

### Extended Modules (MediaTemp)

| Module | Description | iOS Status | Android Status | Backend Status |
|--------|-------------|------------|----------------|----------------|
| Blog | Long-form content | Complete | Partial | Complete |
| Notice Board | Announcements | Complete | Partial | Complete |
| VIP Pages | Brand/celebrity pages | Complete | Partial | Complete |
| Find Discount | Discount listings | Partial | Partial | Unknown |
| Lost & Found | Lost items | Partial | Partial | Unknown |
| Missing Person | Missing persons | Partial | Partial | Unknown |

---

## MVP Recommendation: Focus Strategy

### Option A: Video-First MVP (Recommended)

Launch as a **short-video social platform** similar to TikTok, focusing on:

| Feature | Included | Notes |
|---------|----------|-------|
| Video recording/editing | Yes | Core value proposition |
| Video feed/discovery | Yes | Primary engagement driver |
| User profiles | Yes | Essential |
| Follow/followers | Yes | Network effects |
| Likes/comments | Yes | Basic engagement |
| Search | Yes | Discovery |
| Push notifications | Yes | Retention |
| **Buy & Sell** | **No** | Defer to Phase 2 |
| **Social Stumble** | **No** | Defer to Phase 2 |
| **Dating** | **No** | Defer to Phase 3+ |
| **All extended modules** | **No** | Defer indefinitely |

**Rationale:**
- TikTok-style video is proven, high engagement
- Clear value proposition: "Short video platform"
- Single use case reduces complexity
- Easier to explain/market

**User Journey:**
1. Sign up via phone (OTP)
2. Browse video feed
3. Record/edit/post video
4. Follow creators
5. Engage (like/comment)

---

### Option B: Marketplace-First MVP

Launch as a **mobile marketplace** similar to Facebook Marketplace/eBay, focusing on:

| Feature | Included | Notes |
|---------|----------|-------|
| Product listings | Yes | Core value proposition |
| Browse/search | Yes | Discovery |
| Fixed price sales | Yes | Simplest transaction |
| Auctions/bidding | Yes | Differentiator |
| Messaging (product) | Yes | Buyer-seller communication |
| User profiles | Yes | Trust building |
| **Video Making** | **No** | Defer to Phase 2 |
| **Social Stumble** | **No** | Defer to Phase 2 |
| **Dating** | **No** | Defer to Phase 3+ |

**Rationale:**
- Marketplace has clearer monetization path
- Transactional value (people want to buy/sell)
- Network effects from inventory
- Easier retention (people return to shop)

**User Journey:**
1. Sign up via phone (OTP)
2. Browse listings near me
3. List an item for sale
4. Bid on auctions
5. Message sellers

---

### Option C: Multi-Module MVP (Not Recommended)

Launch with Video Making + Buy & Sell + Social Stumble:

**Problems:**
- Confusing user experience
- "What is this app for?"
- Higher complexity = more bugs
- Harder to market
- Diluted engagement

**Verdict:** Avoid unless there's a specific business reason requiring all modules.

---

## Feature Prioritization Matrix

### Must Have (MVP)

| Feature | Module | Technical Effort | Business Value |
|---------|--------|------------------|----------------|
| Phone OTP authentication | Core | Done | Critical |
| User registration/profile | Core | Done | Critical |
| Video recording | Video | Done | Critical |
| Video editing (trim, music) | Video | Done | High |
| Video feed (For You) | Video | Done | Critical |
| Like/comment | Video | Done | High |
| Follow users | Core | Done | High |
| User search | Core | Done | Medium |
| Push notifications | Core | Done | High |
| Basic settings | Core | Done | Medium |

### Should Have (Phase 2)

| Feature | Module | Technical Effort | Business Value |
|---------|--------|------------------|----------------|
| Hashtag discovery | Video | Low | Medium |
| Share video externally | Video | Low | Medium |
| Video duets/reactions | Video | Medium | Medium |
| Product listing creation | Buy&Sell | Done | High |
| Product browsing | Buy&Sell | Done | High |
| Bidding system | Buy&Sell | Done | Medium |
| In-app messaging | Core | Done | High |
| Report content | Core | Low | Medium |

### Could Have (Phase 3+)

| Feature | Module | Technical Effort | Business Value |
|---------|--------|------------------|----------------|
| Social Stumble feed | Social | Done | Medium |
| Friend requests | Social | Done | Medium |
| Events | Social | Done | Low |
| Blog posts | Blog | Done | Low |
| VIP pages | VIP | Done | Low |
| Notice board | Notice | Done | Low |
| Dating profiles | Dating | Partial | Low |
| Lost & Found | Extended | Partial | Low |

### Won't Have (Remove)

| Feature | Reason |
|---------|--------|
| Find Discount module | Incomplete, unclear use case |
| Missing Person module | Legal/liability concerns, incomplete |
| Instagram auth | API deprecated |
| Twitter auth | API changes, low value |

---

## Technical Simplification

### Code to Remove/Disable

If launching Video-First MVP:

| iOS Files to Disable | Count | Notes |
|---------------------|-------|-------|
| `BuySell/` storyboards & VCs | 67 | Hide UI, keep API |
| `SocialStumble/` views | 51 | Hide UI |
| `Dating/` module | All | Remove entirely |
| `Blog/` module | All | Remove entirely |
| `NoticeBoard/` | All | Remove entirely |
| `VIP/` | All | Remove entirely |
| `FindDiscount/` | All | Remove entirely |
| `LostAndFound/` | All | Remove entirely |
| `MissingPerson/` | All | Remove entirely |

**Estimated code reduction:** ~40-50% of UI code

### Backend Simplification

| Endpoint Group | Action |
|---------------|--------|
| `/buy-sell/*` | Keep but don't expose |
| `/dating/*` | Disable |
| `/blog/*` | Disable |
| `/notice-board/*` | Disable |
| `/vip/*` | Disable |

### Database Impact

No schema changes required - just don't populate unused tables.

---

## MVP Feature Specifications

### Authentication

| Feature | Specification |
|---------|--------------|
| **Phone OTP** | Primary auth method |
| **Facebook Login** | Optional social auth |
| **Google Login** | Optional social auth |
| **Email/Password** | Admin only |

### Video Making Features

| Feature | Specification |
|---------|--------------|
| **Recording** | Max 60 seconds |
| **Editing** | Trim, filters, music |
| **Music Library** | Storyblocks integration |
| **Upload** | From gallery or camera |
| **Thumbnails** | Auto-generated |
| **Privacy** | Public/private toggle |

### Feed Features

| Feature | Specification |
|---------|--------------|
| **For You** | Algorithm-based discovery |
| **Following** | Videos from followed users |
| **Trending** | Popular hashtags |
| **Search** | Users and hashtags |

### Engagement Features

| Feature | Specification |
|---------|--------------|
| **Like** | Single tap |
| **Comment** | Text only |
| **Share** | External share links |
| **Follow** | Follow users |
| **Profile Views** | View other profiles |

### Notifications

| Feature | Specification |
|---------|--------------|
| **Push Types** | New follower, likes, comments |
| **In-App** | Notification center |
| **Badges** | Unread count |

---

## Implementation Roadmap

### Pre-MVP (Weeks 1-2)

| Task | Priority | Effort |
|------|----------|--------|
| Fix SQL injection vulnerability | Critical | 2h |
| Fix hardcoded test OTP | Critical | 30m |
| Update jsonwebtoken to 9.x | Critical | 4h |
| Complete App Store age rating | Critical | 30m |
| Rotate all credentials | High | 4h |

### MVP Phase (Weeks 3-6)

| Task | Priority | Effort |
|------|----------|--------|
| Hide non-video modules in UI | High | 8h |
| Remove module selection screen | High | 2h |
| Test video upload flow end-to-end | High | 4h |
| Fix any video recording bugs | High | Variable |
| Update iOS deployment targets | Medium | 2h |
| Upgrade GoogleSignIn to 7.x | Medium | 8h |
| TestFlight build & testing | High | 4h |

### Post-MVP Phase 2 (Weeks 7-12)

| Task | Priority | Effort |
|------|----------|--------|
| Re-enable Buy & Sell module | Medium | 8h |
| Add in-app messaging | Medium | 4h |
| Implement reporting system | Medium | 8h |
| Performance optimization | Medium | 16h |
| Add analytics events | Medium | 8h |

---

## Success Metrics

### MVP Launch Criteria

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Crash-free rate** | > 99% | Firebase Crashlytics |
| **Video upload success** | > 95% | Backend logs |
| **Feed load time** | < 2s | Client metrics |
| **Auth success rate** | > 98% | Backend logs |
| **0 critical bugs** | 0 | QA testing |

### Post-Launch KPIs

| Metric | Target (30 days) | Notes |
|--------|------------------|-------|
| Daily Active Users | 500 | From TestFlight cohort |
| Videos uploaded/day | 50 | Content creation |
| Avg. session duration | > 5 min | Engagement |
| D1 retention | > 40% | Return rate |
| D7 retention | > 20% | Stickiness |

---

## Risk Assessment

### MVP Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Video processing failures | Medium | High | Thorough testing, error handling |
| Feed algorithm poor engagement | Medium | High | Simple chronological fallback |
| Auth issues (OTP delivery) | Low | Critical | Multiple SMS providers |
| App Store rejection | Low | High | Follow guidelines, pre-review |

### Deferred Feature Risks

| Risk | Impact | Notes |
|------|--------|-------|
| Users want marketplace | Medium | Monitor feedback |
| Competition has more features | Medium | Focus on quality over quantity |
| Missed monetization | Low | Video ads viable |

---

## Appendix: Feature Comparison to Competitors

### Video-First Comparison

| Feature | Kuwboo MVP | TikTok | Instagram Reels |
|---------|------------|--------|-----------------|
| Short video | Yes | Yes | Yes |
| Music/sounds | Yes | Yes | Yes |
| Filters | Yes | Yes | Yes |
| For You feed | Yes | Yes | Yes |
| Stories | No | No | Yes |
| E-commerce | No (Phase 2) | Yes | Yes |
| Messaging | No (Phase 2) | Yes | Yes |

### Marketplace Comparison

| Feature | Kuwboo (Phase 2) | FB Marketplace | eBay |
|---------|------------------|----------------|------|
| Product listings | Yes | Yes | Yes |
| Auctions | Yes | No | Yes |
| Categories | Yes | Yes | Yes |
| Messaging | Yes | Yes | Yes |
| Payment integration | No | No | Yes |
| Shipping labels | No | No | Yes |

---

## Decision Matrix

| Factor | Video-First | Marketplace-First | Multi-Module |
|--------|-------------|-------------------|--------------|
| Time to MVP | 4-6 weeks | 4-6 weeks | 8-10 weeks |
| Technical complexity | Low | Low | High |
| Marketing clarity | High | High | Low |
| User acquisition | Medium | Medium | Low |
| Engagement potential | High | Medium | Diluted |
| Monetization path | Ads, premium | Transaction fees | Unclear |
| Competition | High | High | N/A |
| **Recommendation** | **Yes** | Possible | No |

---

## Conclusion

**Recommended MVP Strategy: Video-First**

1. Launch with Video Making module only
2. Hide/disable all other modules
3. Focus on video creation and discovery
4. Fix critical security issues before launch
5. Target TestFlight release in 4-6 weeks
6. Evaluate user feedback before enabling Buy & Sell

This approach reduces complexity by ~50%, clarifies the product's value proposition, and allows for faster iteration based on real user feedback.

---

**Document Version:** 1.0
**Next Review:** After MVP Launch
**Decision Required By:** Project Stakeholder
