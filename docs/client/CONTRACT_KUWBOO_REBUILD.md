# Kuwboo Platform Rebuild — Contract

**Date:** 16 February 2026
**Version:** 1.0 (Draft for Review)

---

## 1. Project Overview

Full rebuild of the **Kuwboo** platform as a cross-platform mobile application (iOS + Android) using Flutter/Dart, with a companion website built in React. This replaces the existing codebase with a modern, maintainable architecture designed for scale.

---

## 2. Parties

| Role | Name | Entity |
|------|------|--------|
| **Client** | Neil Douglas | Guess This Ltd (UK) |
| **Contractor** | Philip Cutting | LionPro Dev |

---

## 3. Scope of Work

### 3.1 Platform Modules

The following modules are included in this contract:

| Module | Description |
|--------|-------------|
| **Video Making** | TikTok-style short video feed with creation, editing, filters, and social interactions |
| **Social (with Stumble)** | Social discovery feed, friend finding, activity stream, and random discovery feature |
| **Buy & Sell** | Marketplace with product listings, categories, auction/bidding, seller profiles |
| **YoYo** | Location-based nearby user discovery with distance-based list view and push notifications |
| **Sponsored Links** | Promoted content system for in-feed advertising and revenue generation |

### 3.2 Technical Deliverables

- Flutter mobile application (single codebase for iOS and Android)
- React website (responsive, mobile-first)
- Backend API and database
- Authentication and user management
- Push notification infrastructure
- Media handling (photo/video upload, processing, delivery)
- Admin panel for content and user management

---

## 4. Contract Value & Milestones

**Total Contract Value:** $60,000 USD

Structured as six (6) milestones, each valued at $10,000 USD. Compatible with Upwork fixed-price escrow.

**Note on early payments:** Some initial payments may be received in GBP equivalent via direct transfer ahead of Upwork milestone funding. These payments count toward the $60,000 total and will be reconciled against milestones as they are completed.

---

### Milestone 1: Design & Architecture — $10,000

**Target:** Months 1-2

**Deliverables:**
- Complete UI/UX design in Figma for all five modules
- Design system (typography, colors, spacing, components)
- Interactive prototypes for key user flows
- Technical architecture document (database schema, API structure, infrastructure plan)
- Client design review and sign-off

**Acceptance Criteria:**
- Client approves final Figma designs
- Architecture document reviewed and agreed

---

### Milestone 2: Backend Core & Authentication — $10,000

**Target:** Months 2-4

**Deliverables:**
- Backend API framework and database setup
- User registration, login, and profile management
- JWT authentication with refresh token rotation
- Media upload and processing pipeline (photos, videos)
- Push notification service integration
- Admin panel foundation

**Acceptance Criteria:**
- User can register, login, and manage profile
- Media upload and retrieval functional
- Push notifications deliverable to test devices

---

### Milestone 3: Video + Social Modules — $10,000

**Target:** Months 4-6

**Deliverables:**
- Video Making module: feed, creation, editing, filters, interactions
- Social module: discovery feed, friend management, activity stream
- Stumble feature: random discovery mechanism
- Per-module follow system
- Content reporting and moderation tools

**Acceptance Criteria:**
- Users can create and view videos in feed
- Social discovery and friend features functional
- Stumble feature operational
- Content moderation workflow in admin panel

---

### Milestone 4: Buy & Sell + Sponsored Links — $10,000

**Target:** Months 6-8

**Deliverables:**
- Buy & Sell module: listings, categories, search, seller profiles
- Auction/bidding functionality
- Messaging between buyers and sellers
- Sponsored Links module: promoted content creation and display
- Ad placement within feeds (non-intrusive)

**Acceptance Criteria:**
- Users can list, browse, and interact with marketplace items
- Bidding/auction flow functional
- Sponsored content visible in feeds
- Seller ratings and reviews operational

---

### Milestone 5: YoYo + Notifications — $10,000

**Target:** Months 8-10

**Deliverables:**
- YoYo module: location-based nearby discovery
- Distance-based list view with user profiles
- Background location and proximity notifications
- Cross-module notification system (push + in-app)
- React website: core pages and responsive design

**Acceptance Criteria:**
- Nearby users displayed with accurate distances
- Proximity notifications functional (foreground and background)
- Website responsive and functional on mobile/desktop
- Notification preferences configurable per module

---

### Milestone 6: Testing, Polish & Launch — $10,000

**Target:** Months 10-12

**Deliverables:**
- Comprehensive testing (unit, integration, UAT)
- Performance optimization (load times, media delivery)
- Micro-interaction polish and animation refinement
- App Store and Google Play submission preparation
- App Store submission assistance
- Bug fixes identified during testing
- Final client walkthrough and sign-off

**Acceptance Criteria:**
- All modules functional and tested
- App accepted by App Store and Google Play (or submission-ready)
- Performance targets met (defined during M1)
- Client sign-off on final build

---

## 5. Design Process

- All design work produced in **Figma** with client access
- Design reviews at each milestone
- **Major direction changes** (e.g., switching aesthetic style, restructuring navigation) after design sign-off in Milestone 1 may incur additional cost, estimated and agreed before work begins
- **Minor tweaks** (color adjustments, spacing, icon swaps, copy changes) are included throughout the project
- The agreed design direction is "Street + Organic" — clean, modern, urban feel with calm, intelligent aesthetics

---

## 6. Timeline

**Target duration:** 12 months from contract start date

| Phase | Months | Milestones |
|-------|--------|------------|
| Design & Foundation | 1-4 | M1, M2 |
| Core Features | 4-8 | M3, M4 |
| Completion & Launch | 8-12 | M5, M6 |

Timeline is estimated. Delays caused by client feedback turnaround or scope additions are not counted against the contractor's timeline. Both parties agree to communicate promptly if delays are anticipated.

---

## 7. Platforms

| Platform | Technology | Notes |
|----------|------------|-------|
| iOS | Flutter / Dart | Requires Apple Developer account |
| Android | Flutter / Dart | Requires Google Play developer account |
| Web | React | Responsive, mobile-first |

---

## 8. IP & Ownership

- **Source code and design assets** transfer to the client incrementally as each milestone is **paid and approved**
- Upon full payment of the $60,000 contract, all intellectual property rights transfer to the client (Guess This Ltd)
- The contractor retains the right to reference the project in portfolio materials (screenshots, general description) unless otherwise agreed
- Third-party libraries and frameworks retain their respective licenses

---

## 9. Change Management

- Scope additions or changes beyond what is described in this contract will be estimated separately
- The contractor will provide a written estimate (time and cost) for any proposed changes
- Work on changes will not begin until the client approves the estimate in writing
- Minor clarifications and refinements within the spirit of the original scope are included at no extra cost

---

## 10. What's Included

- UI/UX design (Figma)
- Mobile app development (Flutter — iOS + Android)
- Website development (React)
- Backend API development
- Database design and implementation
- Testing (unit, integration, user acceptance)
- App Store and Google Play submission assistance
- 30 days of post-launch bug fixes (defects in delivered functionality)
- Regular progress updates and communication

---

## 11. What's NOT Included

The following are explicitly excluded from this contract:

| Exclusion | Responsibility |
|-----------|---------------|
| Apple Developer Program fee ($99/year) | Client |
| Google Play developer fee ($25 one-time) | Client |
| Hosting and infrastructure costs (AWS, servers) | Client |
| Third-party API costs (maps, SMS, email services) | Client |
| Domain name registration and renewal | Client |
| SSL certificates (if not using free Let's Encrypt) | Client |
| Content creation and copywriting | Client |
| Marketing, SEO, and user acquisition | Client |
| Ongoing maintenance beyond 30-day post-launch period | Separate agreement |
| Legal compliance review (GDPR, age verification) | Client's legal counsel |
| Payment processing integration fees (Stripe, etc.) | Client |

---

## 12. Communication

- Regular progress updates (weekly or bi-weekly, to be agreed)
- Access to project management tool for milestone tracking
- Direct communication channel (to be agreed — e.g., WhatsApp, email)
- Design reviews via Figma with comment functionality

---

## 13. Signatures

This document serves as the basis for the Upwork fixed-price contract. The formal agreement will be executed through Upwork's contract system with milestones matching those described above.

| | Client | Contractor |
|---|--------|------------|
| **Name** | Neil Douglas | Philip Cutting |
| **Entity** | Guess This Ltd | LionPro Dev |
| **Date** | _________________ | _________________ |
| **Signature** | _________________ | _________________ |
