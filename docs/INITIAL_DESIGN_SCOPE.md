# Kuwboo Rebuild: Initial Design Scope

**Created:** February 15, 2026
**Last Updated:** February 15, 2026
**Version:** 1.0
**Purpose:** Define the screen inventory and scope of work for commissioning a UI/UX designer

**Related Documents:**
- [FEATURE_ANALYSIS_MVP.md](FEATURE_ANALYSIS_MVP.md) - Neil's priority list mapped to codebase state
- [MOBILE_STRATEGY_ANALYSIS.md](MOBILE_STRATEGY_ANALYSIS.md) - Flutter rebuild cost analysis ($48,000 total including design)
- [iOS_CODEBASE_AUDIT.md](iOS_CODEBASE_AUDIT.md) - Full iOS technical audit (1,881 Swift files)
- [MOBILE_CODEBASE_ASSESSMENT.md](MOBILE_CODEBASE_ASSESSMENT.md) - Cross-platform assessment

---

## Context

Neil has an existing iOS app with **3 fully functional modules** (Video Making, Buy & Sell, Social/Stumble) and a **4th module (Dating) scaffolded but not wired in**. We are rebuilding in Flutter with a modernised architecture and new design language. Before development begins, we need professional UI/UX design work. This document scopes what the designer needs to deliver.

### Strategy: Feature Parity First

**Phase 1 designs** cover Video + Shop + Social + shared screens (what works today in the iOS app). Dating and Yoyo are deferred to a second design phase. This gives Neil a functioning MVP that replaces his current app before we add new capabilities.

### Source of Truth: The iOS App

All screen inventories and feature assessments in this document are based on the **existing iOS app** at `mobile/ios/kuwboo/` (1,881 Swift files, MVVM + Router + RxSwift architecture). This is what users have today and what the designer must replace with modern equivalents.

### Separate Workstream: Our Design Explorations (NOT in designer scope)

We have 26 design explorations in a Flutter viewer at `new_douglas/design/viewer/`. These are **our internal explorations** for gathering user opinions on aesthetic direction (Neo-Brutalist, Soft Luxury, Calm Tech, etc.). They are entirely separate from the designer's scope of work -- they help **us** understand preferences, not brief the designer.

---

## Part 1: What Exists Today (iOS App)

### 3 Active Modules, Each with 5-Tab Navigation

The current app uses a **module selector** screen after login. The user picks one of three modules, each giving them a separate 5-tab bar experience. There is no way to cross between modules without going to Settings > Switch Module.

| Module | Tabs | Key Screens | Completeness |
|--------|------|-------------|--------------|
| **Video Making** | Home, Search, +Create, Profile, Settings | TikTok-style feed, video recorder/editor, comments, sound library, hashtag search, draft videos | Fully built (~20 screens) |
| **Buy & Sell** | Home, Categories, +Add, My Listings, Settings | Product grid, category browser, product detail with bidding, add product form, filters, location picker | Fully built (~15 screens) |
| **Social/Stumble** | Home, Search, +Post, Profile, Settings | Social feed, photo/text posts, tag people, friend requests, events, privacy settings | Fully built (~14 screens) |

### Shared Screens (used across all modules)

- **Auth flow:** Onboarding slides, Login, Signup, Reset Password, OTP verification
- **Chat:** Message inbox, 1:1 chat (Socket.IO real-time), media messages, message forwarding
- **Profile:** User profile, edit profile, followers list, block list
- **Settings:** Module-aware settings menu, notifications settings, privacy & security, CMS pages (Terms, Privacy, FAQ, About), support

### Not Active in iOS (scaffolded/storyboard exists, not navigable)

- **Dating** -- Storyboard exists, DatingStream protocol exists, but no tab bar or routing
- **Blog, VIP Pages, Notice Board, Find Discount, Lost & Found, Missing Person** -- Cells/models exist, storyboards exist, not wired into navigation

### Total Screen Count in Current iOS App: ~60 unique screens

---

## Part 2: What We've Planned for the Rebuild

### Architecture Changes

- **No module selector** -- all features accessible from one 4-tab bar
- **4 main tabs**: Video (purple), Dating (rose), Social (blue), Shop (green)
- **Header icons**: Profile avatar (left), Inbox badge, Yoyo nearby badge (right)
- **Contextual FAB**: Changes action per tab (Record/Spark/Post/List) with long-press secondary options
- **Yoyo** woven throughout (not a separate module)

### What's Already Designed (Flutter rebuild)

| Component | Status |
|-----------|--------|
| Login screen (phone + email + Google + Apple SSO) | Complete |
| OTP verification screen | Complete |
| Onboarding/profile setup screen | Complete |
| App shell (header + 4-tab bottom nav) | Complete |
| Contextual FAB with progressive disclosure | Complete |
| Theme system (light + dark, Poppins font, tab accent colours) | Complete |
| Route architecture (12 routes defined) | Complete |
| Auth state management (Riverpod) | Complete |
| API client with token refresh | Complete |

### What's Placeholder Only (route exists, screen is "Coming Soon" text)

Video feed, Dating, Social feed, Shop, Yoyo map, Inbox, Profile, Settings

---

## Part 3: Design Work Scope (Feature Parity First)

### Design Approach: Replace Current, Then Extend

**Initial design commission (this scope):** Design screens to replace Video + Shop + Social + shared screens. This is what the designer delivers first.

**Future design commission (deferred):** Dating module, Yoyo proximity features, Sponsored Links. Documented here for planning but NOT included in the initial design budget.

---

### Tier 1: Core Navigation & Patterns (Designer Must Start Here)

These establish the visual language everything else builds on.

| Deliverable | Description | Screens |
|-------------|-------------|---------|
| **Design System** | Colour palette, typography scale, spacing grid, elevation system, icon style guide, component library (buttons, inputs, cards, chips, avatars, badges) | 1 system doc |
| **Navigation Pattern** | 4-tab bar with active states, header bar with profile/inbox/yoyo, contextual FAB states per tab, transition animations spec | 4 tab states |
| **Empty/Loading/Error States** | Skeleton loaders, empty state illustrations, error state patterns, pull-to-refresh | 1 pattern sheet |

**Estimated effort: 2-3 days**

---

### Tier 2: Feature-Parity Screens (Replace What Exists)

These replace the current iOS app's 3 active modules. Every screen the user can reach today needs a redesigned equivalent.

#### 2A. Video Module (replaces Video Making)

| Screen | Current iOS Equivalent | Notes |
|--------|----------------------|-------|
| Video feed (full-screen vertical scroll) | HomeVC | For You / Following toggle, like/comment/share/save overlay |
| Video player overlay (comments, share sheet) | CommentsVC, ShareVC | Bottom sheet comments, sub-comments |
| Video creation (camera) | CreatePostVC | Record button, timer, speed, flip camera, filters, stickers |
| Video editing | EditPostVC | Trim, filters, text overlay, audio sync |
| Video posting | PostVideoVC | Caption, hashtags, mentions, privacy toggle, draft save |
| Draft videos | DraftVideosVC | Grid of saved drafts |
| Sound/audio library | SoundMasterVC | Browse, search, favourites |
| Search (videos, users, hashtags, audio) | SearchDetailVC | Tabbed search results |
| Hashtag detail | HashDetailVC | Hashtag feed with stats |
| Audio detail | AudioDetailVC | Audio info + videos using it |

**Screen count: ~12 unique screens**
**Estimated design effort: 3-4 days**

#### 2B. Shop Module (replaces Buy & Sell)

| Screen | Current iOS Equivalent | Notes |
|--------|----------------------|-------|
| Shop home (product grid) | BuySellHomeVC | Location filter, category chips |
| Category browser | CategoryVC | Hierarchical category navigation |
| Product listing (grid/list) | ProductListVC | Sort, filter, pagination |
| Product detail | ProductDetailVC | Image carousel, price, bid/offer/buy buttons, seller info, chat |
| Product filter | ProductFilterVC | Price range, condition, location radius, category |
| Add product (fixed price) | AddProductVC | Photos, title, description, price, category, condition, location |
| Add product (auction) | AddProductVC | Same + start price, reserve, duration |
| My listings (active/sold/expired) | MyListingVC | Tabs: fixed vs auction |
| My bids | MyBidsRouter | Bid history, status |
| Bidding detail | BiddingDetailsRouter | Bid timeline, current price |
| Location picker | LocationVC | Map + search (Google Places) |

**Screen count: ~12 unique screens**
**Estimated design effort: 3-4 days**

#### 2C. Social Module (replaces Social/Stumble)

| Screen | Current iOS Equivalent | Notes |
|--------|----------------------|-------|
| Social feed | SocialStumbleHomeVC | Photo/text posts, likes, comments |
| Create post (photo/text) | SocialStumbleCreatePostVC | Photo picker, text, tag people, location |
| Post detail | SocialStumblePostDetailVC | Full post with comments |
| Tag people picker | TagPeopleListVC | Search + select users to tag |
| Social profile (own) | SocialStumbleMyProfileVC | Posts, gallery, tagged, friends tabs |
| Social profile (other user) | SocialStumbleOtherUserProfileVC | Follow/friend/message actions |
| Friend requests (received/sent) | SocialStumbleFriendRequestsVC | Accept/decline actions |
| Events | SocialStumbleEventVC | Event listing and detail |
| Privacy settings | SocialStumblePrivacySettingVC | Who can see/message/tag |

**Screen count: ~10 unique screens**
**Estimated design effort: 2-3 days**

---

### Tier 3: New Feature Screens (Build What Doesn't Exist Yet)

These are features Neil wants that don't have complete UI in the current app.

> **Note:** Tier 3 is documented for planning but is NOT part of the initial design commission. It will be a separate future commission once the feature-parity screens are complete.

#### 3A. Dating Module (NEW -- backend exists, no iOS UI)

| Screen | Description | Complexity |
|--------|-------------|------------|
| Dating card stack (swipe interface) | Tinder-style card stack with swipe left/right/up(super-like), photo carousel per card | High |
| Dating profile view (expanded) | Full profile: photos, bio, interests, distance, age, prompts | Medium |
| Match screen (it's a match!) | Celebration animation, message/keep swiping options | Medium |
| Matches list | Grid/list of mutual matches with last message preview | Medium |
| Dating profile editor | Own dating profile: photos (min 2), bio, prompts, preferences | High |
| Dating preferences | Age range slider, distance radius, gender preference, dealbreakers | Medium |
| Spark/boost screens | Premium action confirmations | Low |

**Screen count: ~8 unique screens**
**Estimated design effort: 3-4 days** (swipe card interaction needs careful UX)

#### 3B. Yoyo -- Proximity Discovery (NEW -- nothing exists)

| Screen | Description | Complexity |
|--------|-------------|------------|
| Yoyo map view | Map showing nearby users as avatars/pins, real-time updates | High |
| Yoyo list view | Nearby users sorted by distance, with module context (what they're doing) | Medium |
| Yoyo user card (quick view) | Tap a pin/avatar to see mini profile + action buttons | Medium |
| Yoyo settings | Location precision (Exact/Area/Nearby/Hidden), visibility toggles, per-module overrides | Medium |
| Yoyo badge integration | Header badge showing nearby count, notification when someone's near | Low (pattern only) |

**Screen count: ~5 unique screens**
**Estimated design effort: 2-3 days**

---

### Tier 4: Shared Screens (Used Across All Features)

These are module-agnostic screens that appear throughout the app.

| Screen | Current iOS Equivalent | Notes |
|--------|----------------------|-------|
| Unified user profile | UserProfileVC | Tabs per module: videos, products, posts, dating |
| Edit profile | EditProfileVC | Avatar, name, username, bio, links |
| Chat inbox | MessageInboxVC | Threaded conversations, unread badges, module context |
| Chat conversation | ChatVC | Real-time messaging, media, replies, read receipts |
| Media message viewer | MediaMessageChatVC | Full-screen image/video in chat |
| Notifications | NotificationsVC | Grouped by type, actionable |
| Settings | SettingVC | Single unified settings (not per-module) |
| Notification preferences | NotificationSettingVC | Per-type toggles |
| Privacy & security | PrivacySecurityVC | Account privacy, data, 2FA |
| Blocked users | BlockUserVC | List with unblock option |
| Followers/following | UserFollowersVC | Tabs: followers, following, per-module option |
| Report/flag flow | (new) | Report user/content with reason picker |
| CMS pages (Terms, Privacy, FAQ) | CMSVC, FAQVC | Markdown/HTML rendering |
| Delete account flow | (in SettingVC) | Confirmation + data deletion info |

**Screen count: ~14 unique screens**
**Estimated design effort: 3-4 days**

---

### Tier 5: Auth & Onboarding (Already Designed -- Review Only)

These are already implemented in the Flutter app. Designer should **review and refine** rather than design from scratch.

| Screen | Status |
|--------|--------|
| Login (phone + email + social) | Built -- needs design review |
| OTP verification | Built -- needs design review |
| Onboarding / profile setup | Built -- needs design review |

**Estimated design effort: 0.5 days (review/polish only)**

---

## Part 4: Design Scope Summary

### Initial Commission: Feature Parity (what we're commissioning now)

| Tier | Category | Screens | Days |
|------|----------|---------|------|
| 1 | Design System & Patterns | System docs + patterns | 2-3 |
| 2A | Video Module | ~12 | 3-4 |
| 2B | Shop Module | ~12 | 3-4 |
| 2C | Social Module | ~10 | 2-3 |
| 4 | Shared Screens (chat, profile, settings, etc.) | ~14 | 3-4 |
| 5 | Auth Review (already built, polish only) | 3 (review) | 0.5 |
| | **INITIAL TOTAL** | **~48 screens + system** | **12-18 designer days** |

### Future Commission: New Features (deferred, documented for planning)

| Tier | Category | Screens | Days |
|------|----------|---------|------|
| 3A | Dating Module | ~8 | 3-4 |
| 3B | Yoyo Proximity | ~5 | 2-3 |
| -- | Sponsored Links | ~3 | 1-2 |
| | **FUTURE TOTAL** | **~16 screens** | **6-9 designer days** |

### Delivery Schedule (Initial Commission Only)

**Week 1: Foundation + Video**
- Tier 1 (design system) + Tier 2A (video) + Tier 5 (auth review)
- Deliverable: Design system + ~12 video screens + auth polish
- Estimated: 5.5-7.5 designer days
- Why first: Design system establishes all patterns; video is the hero module

**Week 2: Shop + Social**
- Tier 2B (shop) + Tier 2C (social)
- Deliverable: ~22 screens
- Estimated: 5-7 designer days
- Why second: These reuse the design system from Week 1, so faster

**Week 3: Shared Screens + Revisions**
- Tier 4 (shared) + revision rounds on Weeks 1-2
- Deliverable: ~14 screens + revisions
- Estimated: 3-4 designer days + revision buffer
- Why last: Shared screens (chat, profile, settings) benefit from seeing all module screens first

---

## Part 5: What the Designer Needs From Us

### Before Starting

1. **This scope document** (screen inventory based on the iOS app)
2. **Access to current iOS app** (TestFlight build or screen recordings/screenshots of every screen)
3. **iOS screen map** -- annotated screenshots showing every screen, flow, and transition in the current app
4. **Neil's reference apps**: WhatsApp, Snapchat, Instagram, Facebook (he wants that level of polish)
5. **Navigation architecture brief**: 4-tab unified nav (Video, Dating, Social, Shop) replacing the current module-selector pattern
6. **Brand assets** from Neil (logo, any colour/font preferences he has)

### Deliverables We Need Back

1. **Figma file** with all screens organised by feature module
2. **Component library** in Figma (buttons, cards, inputs, chips, avatars, badges)
3. **Interaction specs** for complex flows (video creation, auction bidding, search)
4. **Light + dark mode** for every screen
5. **Phone-only layouts** (defer tablet until later)

---

## Part 6: Budget Estimate for Design Work

### Initial Commission (Feature Parity -- ~48 screens)

Based on 12-18 designer days:

| Rate Assumption | Low (12 days) | Mid (15 days) | High (18 days) |
|----------------|--------------|--------------|----------------|
| Junior ($300/day) | $3,600 | $4,500 | $5,400 |
| Mid-level ($500/day) | $6,000 | $7,500 | $9,000 |
| Senior ($700/day) | $8,400 | $10,500 | $12,600 |

**Recommended budget to present to Neil: $6,000-$9,000** (mid-level designer, 12-18 days)

This aligns with our previous estimate of $6,000-$8,000 in [MOBILE_STRATEGY_ANALYSIS.md](MOBILE_STRATEGY_ANALYSIS.md).

### Future Commission (Dating + Yoyo + Sponsored Links -- ~16 screens)

Based on 6-9 designer days, add **$3,000-$4,500** at mid-rate when ready.

### What Reduces Cost

- **Clear scope** -- the iOS app is fully built, so the designer isn't inventing features, just redesigning known screens
- **Reference app precedent** -- Video (TikTok), Shop (Facebook Marketplace), Social (Instagram) patterns are well-established
- **Auth screens** need review/polish only, not design from scratch

### What Could Increase Cost

- Neil wanting **significant revisions** (budget 1-2 revision rounds per phase)
- **Interaction prototypes** for video creation or bidding flows (animated Figma)
- **Custom illustrations** for empty states, onboarding, or branding
- **Deviating from established patterns** -- if Neil wants novel UX rather than polished versions of TikTok/Marketplace/Instagram conventions

---

## Part 7: Pre-Design Checklist (Actions Before Commissioning)

### For Us (Phil)

- [ ] Record/screenshot every screen in the current iOS app for the designer's reference
- [ ] Create an annotated screen map showing all flows and transitions in the iOS app
- [ ] Write a brief for the designer covering this scope + Neil's preferences
- [ ] Confirm with Neil: extended modules (Blog, VIP, Notice Board, etc.) are ALL deferred
- [ ] Separately: continue our own design explorations (viewer) to gather user preferences -- this is our workstream, not the designer's

### For Neil

- [ ] Confirm: Video + Shop + Social first, Dating + Yoyo later
- [ ] Provide any brand assets (logo files, colour preferences, font preferences)
- [ ] Confirm: phone-only for now, tablet deferred
- [ ] Identify specific screens from reference apps (WhatsApp, Snap, Insta, FB) he wants to emulate
- [ ] Approve design budget range ($6,000-$9,000 for initial commission)

---

## Part 8: Summary for Neil

**What we're doing:** Hiring a designer to create all the screens for the new Kuwboo app. The new app will replace everything your current app does (videos, marketplace, social) with a modern, polished design -- like the apps you admire (WhatsApp, Instagram, Snapchat).

**What you'll get:** ~48 professionally designed screens in Figma, covering every part of the app your users can reach today, plus a complete design system (colours, fonts, components) that ensures consistency.

**What it costs:** $6,000-$9,000 for the initial design work (~3 weeks of designer time).

**What comes later:** Once the initial app is built, we commission a second round of designs for Dating, Yoyo (nearby discovery), and Sponsored Links -- estimated at an additional $3,000-$4,500.

**Total design investment across both phases:** $9,000-$13,500.
