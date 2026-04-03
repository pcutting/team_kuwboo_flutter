# Neil Douglas Call Notes — 16 February 2026

**Duration:** ~2.5 hours
**Participants:** Phil Cutting (LionPro Dev), Neil Douglas (Guess This Ltd)
**Format:** Video call with screen sharing (design walkthrough)

---

## 1. Project Decision

Neil confirmed a **full rebuild from scratch** rather than fixing the existing Codiant codebase.

- **Total budget:** $60,000 USD
- **Timeline:** ~12 months
- **Mobile:** Flutter (cross-platform iOS + Android)
- **Website:** React
- **Backend:** New architecture (not patching Codiant's Express/Sequelize)

Neil's reasoning: the existing codebase has too many structural issues, patching it would cost more long-term than rebuilding properly. He wants it done right this time.

---

## 2. Payment Structure

Mixed payment approach to accommodate trust-building and Upwork's escrow system:

| Payment | Amount | Timing | Method |
|---------|--------|--------|--------|
| Initial deposit | 5-7k GBP | Week 1 | Direct transfer |
| Second payment | 15k GBP | ~3 months in | Direct transfer |
| Remainder | Balance to $60k USD total | Per milestones | Upwork fixed-price contract |

**Notes:**
- Early direct payments build momentum before Upwork contract is fully structured
- GBP amounts will be equivalent to USD at time of transfer
- Upwork contract structured as 6 milestones at $10k USD each
- Direct payments count toward the $60k total

---

## 3. Confirmed Modules

| Module | Priority | Notes |
|--------|----------|-------|
| **Video Making** | Core | TikTok-style short video feed, creation tools |
| **Social (with Stumble)** | Core | Social discovery feed, friend finding |
| **Buy & Sell** | Core | Marketplace, listings, bidding/auctions |
| **YoYo** | Core | Location-based nearby discovery |
| **Sponsored Links** | Core | Revenue model, promoted content |

**Not in initial scope (may add later):**
- Dating module (discussed but deferred for MVP)
- Blog, Notice Board, VIP Pages
- Lost & Found, Missing Person

---

## 4. Design Preferences

Neil was very specific about aesthetic direction during the wireframe walkthrough:

### Loves
- **"Street" style** — Clean, urban feel, targets 22-32 age range, "not invasive"
- **"Organic" style** — Calm, modern, 25-40 age range, "settles into you"
- Combination of Street's clean boxes/tabs with Organic's modern warmth

### Hates
- **Retro Digital** — Too dated
- **Anti-Establishment** — Too aggressive
- Anything "childish" or cartoon-like
- Large text overlapping faces
- Oversized badges or boxes that feel heavy

### Key Aesthetic Words
- Modern, intelligent, not invasive
- Pleasant on the eye, not scary
- Comfortable — "I'm not going to struggle with this"
- Fun to use and play

---

## 5. Navigation Architecture

### Bottom Navigation
- Module-specific bottom nav bar
- Center FAB/action button that changes function per module
- Icon-only preferred (no text labels — "heavy on the eye")
- Labels learned through use, not forced

### Top Bar
- **YoYo** — Top-left position
- **Profile** — Top-right position
- Symmetrical sizing between the two
- **Messages** — Badge count on profile icon + separate icon on larger screens

### Module Switching
- Bottom nav handles intra-module navigation
- Module selection likely via a separate mechanism (hamburger, module switcher, or home screen)

---

## 6. Feature Detail Notes

### Video Making
- TikTok-style vertical feed
- Video creation/editing tools
- Filters, music overlay
- Like, comment, share interactions
- Follow creators per-module

### Social / Stumble
- Friend discovery feed
- "Stumble" feature for random discovery
- Social graph separate from other modules
- Activity feed of friends' actions

### Buy & Sell
- Product listings with photos
- Category browsing
- Auction/bidding capability
- Seller profiles and ratings
- Transaction flow (in-app or redirect)

### YoYo (Nearby)
- Location-based user discovery
- List layout with distances (NOT grid tiles)
- Coarse location notifications (Neil accepts battery trade-off)
- Push notifications even when app is closed
- "Nearby" as a live, ambient feature

### Sponsored Links
- Promoted content within feeds
- Revenue model for the platform
- Non-intrusive placement (fits naturally in feed)

---

## 7. Previous Developer Issues

### Codiant / Vikrant Situation
- Previous dev team (Codiant, contact: Vikrant, info@codiant.com) delivered a codebase with significant structural issues
- Neil expressed frustration with quality and communication
- Credential rotation needed — Codiant still has access to production systems
- Database dumps and Lambda functions have been retrieved for reference
- The rebuild decision is partly a trust reset — Neil wants a fresh start with someone he trusts

### What to Preserve
- Existing user data and database schema understanding
- AWS infrastructure knowledge (eu-west-2)
- Domain and SSL configuration
- Understanding of what modules exist (even if implementation was poor)

---

## 8. Action Items

### Phil (Immediate)
- [ ] Draft and send contract document for review
- [ ] Set up Upwork fixed-price contract with milestone structure
- [ ] Begin design phase — Figma mockups based on Street + Organic direction
- [ ] Rotate production credentials (DB, AWS, JWT, Twilio, SMTP)
- [ ] Document module-by-module feature requirements in detail

### Phil (Design Phase)
- [ ] Create dating card mockups with Neil's feedback applied
- [ ] Design bottom nav with center FAB concept
- [ ] Design YoYo nearby screen (list layout, not grid)
- [ ] Prototype micro-interactions (photo swipe, bounce-back)
- [ ] Present 2-3 options for module switching UX

### Neil
- [ ] Review and approve contract document
- [ ] Process initial deposit (5-7k GBP)
- [ ] Provide any brand assets, logos, or color preferences
- [ ] Confirm priority ordering if timeline pressure arises
- [ ] Set up Upwork account/profile if not already done

---

## Key Takeaways

1. Neil is investing significant money and needs to see steady progress to maintain confidence
2. Design quality is paramount — he'll judge the entire project by how the first screens feel
3. Micro-interactions and polish matter more to him than feature count
4. He's been burned before and values transparency and communication
5. The "Street + Organic" combination is the north star for all visual design decisions
