# Sponsored Content & Payments Research — 2026

**Last Updated:** March 2026
**Purpose:** Payment architecture research for Kuwboo sponsored content and marketplace

---

## Executive Summary

Kuwboo's revenue model has two payment-sensitive streams:

1. **Sponsored content** — businesses pay to promote content in feeds
2. **Buy & Sell marketplace** — buyers pay sellers for physical goods

The optimal architecture separates these: sponsored content payments happen via a **web-based advertiser portal** (zero app store commission), while marketplace transactions use **Stripe Connect** with platform fees.

---

## App Store Commission Rules

| Revenue Stream | Commission | Rationale |
|---|---|---|
| Physical goods (Buy & Sell) | **0%** | Apple & Google explicitly exempt physical goods from IAP |
| Sponsored content via **web portal** | **0%** | B2B web transaction — same model as TikTok, Meta, X |
| In-app "Boost" button triggering payment | **15–30%** | Apple Guideline 3.1.1 — ads displayed in same app = digital good |
| Premium subscriptions (if added) | 15–30% (IAP) | Digital good |

### Critical Rule

**Do NOT add in-app "boost" or "promote" buttons that trigger payment.** This triggers Apple's IAP requirement and 15–30% commission. Every major platform (TikTok, Instagram, X, Facebook) sells advertising through web dashboards and processes payments via Stripe/PayPal on the web. The mobile app only *displays* sponsored content.

---

## Regulatory Landscape (2026)

### United States (Post-Epic v Apple)
- Apps can link to external payment methods
- Final commission on external purchases pending court determination
- Google Play alternative billing effective Jan 28, 2026

### European Union (DMA)
- Alternative payment processing available since June 2025
- Combined Apple fees up to ~20% (vs 30% standard)
- Single entitlement covers all non-IAP options

### United Kingdom
- CMA investigating Apple/Google app store practices
- No mandated alternative billing yet
- Standard 15–30% commission on digital goods via IAP

---

## Recommended Architecture

### Sponsored Content: Web Portal + Stripe

**Model:** Self-serve advertiser dashboard at `advertise.kuwboo.com`

```
Advertiser → Web Dashboard → Create Campaign → Stripe Checkout → Campaign Live
                                                    ↓
Mobile App ← API Fetch Active Campaigns → Display in Feed → Report Impressions
```

**Why web:**
- Zero app store commission (100% revenue retained minus Stripe fees)
- Industry standard (TikTok Ads, Meta Business Suite, X Ads all work this way)
- B2B advertising is explicitly exempt from IAP requirements
- Easier to iterate on campaign creation UX via web

**Stripe fees (UK platform):**

| Card Type | Fee |
|---|---|
| UK domestic | 1.5% + 20p |
| EU cards | 2.5% + 20p |
| International | 3.25% + 20p |

### Marketplace (Buy & Sell): Stripe Connect

**Recommended: Express accounts + destination charges**

- Stripe handles KYC/identity verification for sellers
- Platform controls payment flow and takes commission
- Automatic payouts to seller bank accounts
- Supports UK + international payouts

**Fee structure:**
- Stripe processing: 1.5% + 20p (UK domestic)
- Connect payout: 0.25% (capped at £25)
- Platform commission: configurable (e.g. 5–10% on top)

---

## Sponsored Content — Ad Types

| Ad Type | Placement | Format |
|---|---|---|
| Promoted Post | Social feed | Native post card with "Sponsored" badge |
| Video Ad | Video feed | Sponsored video between organic content |
| Product Spotlight | Shop browse | Promoted listing in product grid |
| Banner Ad | Cross-module | Top/bottom banner in any feed |

### Pricing Models

| Model | Description | Best For |
|---|---|---|
| CPM (Cost per Mille) | Pay per 1,000 impressions | Brand awareness |
| CPC (Cost per Click) | Pay per click/tap | Traffic driving |
| CPV (Cost per View) | Pay per video view (3+ seconds) | Video campaigns |

---

## Targeting Capabilities

Campaigns can target by:
- **Module:** video_making, social_stumble, buy_sell, dating
- **Location:** Country, city, radius
- **Demographics:** Age range, gender
- **Interests:** Based on user activity/categories
- **Device:** iOS, Android

---

## Implementation Phases

### Phase 1: Flutter Prototype (Current)
- Design the advertiser UX in the prototype
- All screens are mock/demo data
- Validates the flow before backend work

### Phase 2: Backend API
- `advertisements` table with campaign data
- `advertisement_impressions` table for tracking
- REST endpoints: `/api/sponsored/*`
- Budget management and scheduling

### Phase 3: Web Advertiser Portal
- Next.js or React web app
- Stripe Checkout integration
- Campaign creation wizard
- Performance dashboard
- Same auth system as mobile app

### Phase 4: Mobile Integration
- API integration for fetching active campaigns
- Impression/click tracking
- Frequency capping per user

---

## Database Schema (Proposed)

```sql
CREATE TABLE advertisements (
  id UUID PRIMARY KEY,
  advertiser_id UUID REFERENCES users(id),
  ad_type ENUM('promoted_post', 'video_ad', 'product_spotlight', 'banner'),
  title VARCHAR(100),
  description TEXT,
  media_url VARCHAR(500),
  cta_text VARCHAR(50),
  cta_url VARCHAR(500),
  target_modules TEXT[], -- ['video_making', 'social_stumble']
  target_locations JSONB,
  target_age_min INT,
  target_age_max INT,
  budget_total DECIMAL(10,2),
  budget_daily DECIMAL(10,2),
  bid_type ENUM('cpm', 'cpc', 'cpv'),
  bid_amount DECIMAL(10,4),
  status ENUM('draft', 'pending', 'active', 'paused', 'completed', 'rejected'),
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE advertisement_impressions (
  id UUID PRIMARY KEY,
  ad_id UUID REFERENCES advertisements(id),
  user_id UUID REFERENCES users(id),
  event_type ENUM('impression', 'click', 'view', 'dismiss'),
  module_context VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## Competitive Reference

| Platform | Ad Sales Channel | Payment | App Store Fee |
|---|---|---|---|
| TikTok | ads.tiktok.com (web) | Stripe/PayPal | 0% |
| Instagram/Facebook | Meta Business Suite (web) | Stripe | 0% |
| X (Twitter) | ads.x.com (web) | Stripe | 0% |
| Snapchat | ads.snapchat.com (web) | Stripe | 0% |
| YouTube | Google Ads (web) | Google Pay | 0% |

All major platforms use the same pattern: web-based ad dashboards with direct payment processing.
