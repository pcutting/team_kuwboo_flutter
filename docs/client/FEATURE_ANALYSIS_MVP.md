# Kuwboo Feature Analysis & MVP Planning

**Created:** February 5, 2026
**Last Updated:** February 6, 2026
**Version:** 3.0
**Purpose:** Map Neil's priority list to actual codebase state

---

## Executive Summary

This document analyzes Kuwboo's features against **Neil's stated priority list** to identify what's ready for MVP and what needs work. Unlike the previous MVP_SCOPE.md (which recommends a single-module strategy), this document maps directly to the client's requirements.

### Quick Status

| Priority | Feature | Status | Action |
|----------|---------|--------|--------|
| #1 | Video Making | ✅ **MVP READY** | Ship it |
| #2 | Buy and Sell | ✅ **MVP READY** | Ship it |
| #3 | Dating | ⚠️ **NEEDS WORK** | Mobile UI incomplete |
| #4 | Yoyo | 🔨 **NEEDS DEV** | Proximity discovery (3-4 weeks) |
| #5 | Sponsored Links | 🔨 **NEEDS BACKEND** | Build from scratch |
| #6 | Social | ✅ **MVP READY** | Ship it |

> **Yoyo Clarified:** Proximity-based social discovery feature (like Happn/Bumble BFF). Users activate Yoyo, set profile with interests (dating/coffee/social/friends), and discover nearby users. Existing location infrastructure (Haversine, lat/long, Google Maps) can be leveraged.

---

## Neil's Priority List vs Current State

| # | Neil's Priority | Maps To | Backend | iOS | Android | MVP Ready? |
|---|-----------------|---------|---------|-----|---------|------------|
| 1 | Video Making | `video_making` | **Complete** | **Complete** | **Complete** | **YES** |
| 2 | Buy and Sell | `buy_sell` | **Complete** | **Complete** | **Complete** | **YES** |
| 3 | Dating | `dating` | **Complete** | Partial | Partial | Needs Work |
| 4 | Yoyo | `yoyo` (new) | **Needs Build** | **Needs Build** | **Needs Build** | Needs Dev |
| 5 | Sponsored Links | `advertisements` | **Missing** | Unknown | Partial UI | Needs Backend |
| 6 | Social | `social_stumble` | **Complete** | **Complete** | **Complete** | **YES** |

---

## 1. VIDEO MAKING (TikTok-like) ✅ MVP READY

### Full Feature List

| Feature | Backend | iOS | Android |
|---------|---------|-----|---------|
| Video recording (60 sec) | ✅ | ✅ | ✅ |
| Video editing/trimming | ✅ | ✅ | ✅ |
| Audio tracks/music library | ✅ | ✅ | ✅ |
| Filters and effects | ✅ | ✅ | ✅ |
| Draft video storage | ✅ | ✅ | ✅ |
| Feed discovery (For You, Following, Trending) | ✅ | ✅ | ✅ |
| Like/comment/share | ✅ | ✅ | ✅ |
| Hashtags and search | ✅ | ✅ | ✅ |
| User profiles | ✅ | ✅ | ✅ |
| Followers/following | ✅ | ✅ | ✅ |
| Push notifications | ✅ | ✅ | ✅ |
| Content moderation | ✅ | ✅ | ✅ |
| 27 video categories | ✅ | ✅ | ✅ |

### Database Tables (15 tables)

- `feeds`, `feed_comments`, `feed_likes`, `feed_shares`, `feed_views`
- `feed_tags`, `feed_collections`, `audio_tracks`, `albums`, `artists`
- `categories` (27 predefined)

### API Endpoints: 40+

Core: `/feed`, `/user/feed`, `/feed-comment`, `/audio-track`, `/album`, `/collection`

### MVP Segment

**Everything is MVP-ready.** Core video creation, discovery, and social features complete.

**Nice-to-have (post-MVP):**
- Video duets/reactions
- Live streaming
- Creator monetization

---

## 2. BUY & SELL (Marketplace) ✅ MVP READY

### Full Feature List

| Feature | Backend | iOS | Android |
|---------|---------|-----|---------|
| Fixed-price listings | ✅ | ✅ | ✅ |
| Auction/bidding | ✅ | ✅ | ✅ |
| 54 hierarchical categories | ✅ | ✅ | ✅ |
| Product images (multiple) | ✅ | ✅ | ✅ |
| Product search/filter | ✅ | ✅ | ✅ |
| Location-based search | ✅ | ✅ | ✅ |
| Favorites/watchlist | ✅ | ✅ | ✅ |
| In-app messaging for products | ✅ | ✅ | ✅ |
| Bid history | ✅ | ✅ | ✅ |
| My listings management | ✅ | ✅ | ✅ |
| Item conditions (new/used/etc) | ✅ | ✅ | ✅ |
| User addresses | ✅ | ✅ | ✅ |

### Database Tables (10 tables)

- `buy_sell_products`, `buy_sell_product_images`, `buy_sell_categories`
- `bids`, `buy_sell_favorite_products`, `product_messages`
- `buy_sell_conditions`, `buy_sell_consents`

### API Endpoints: 25+

Core: `/buy-sell-product`, `/buy-sell-category`, `/product-bid`, `/product-message`

### MVP Segment

**Everything is MVP-ready.** Full marketplace with fixed-price and auction support.

**Nice-to-have (post-MVP):**
- In-app payments (Stripe/PayPal)
- Shipping integration
- Escrow/buyer protection
- Seller verification badges

---

## 3. DATING ⚠️ NEEDS WORK

### Full Feature List

| Feature | Backend | iOS | Android |
|---------|---------|-----|---------|
| Dating profiles | ✅ | ⚠️ Partial | ⚠️ Partial |
| User matching (swipe) | ✅ | ⚠️ | ⚠️ |
| Match/unmatch | ✅ | ⚠️ | ⚠️ |
| Dating chat | ✅ | ⚠️ | ⚠️ |
| Profile photos gallery | ✅ | ⚠️ | ⚠️ |
| Interests/hobbies | ✅ | ? | ? |

### Database Tables (4 tables)

- `user_match_profiles` - matching records
- `dating_unmatch_profiles` - unmatch history
- `user_image_galleries` - profile photos
- `user_interests`, `user_hobbies`

### API Endpoints: 8

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/dating/user-profile` | PUT | Setup dating profile |
| `/dating/user` | GET | Browse profiles |
| `/dating/match/user-profile` | POST | Swipe/like a user |
| `/dating/match/user` | GET | View matches |
| `/dating/user/chat/unmatch` | POST | Unmatch a user |

### What's Missing

1. **Mobile UI incomplete** - Profile setup, matching UI, discovery feed
2. **No location-based matching** - Need to add distance filters
3. **No preference filters** - Age range, gender preferences not exposed in UI

### MVP Segment (Minimum to Launch Dating)

| MVP Feature | Status | Work Needed |
|-------------|--------|-------------|
| Profile creation | Backend ✅ | Mobile UI |
| Profile photos | Backend ✅ | Mobile UI |
| Browse/discover users | Backend ✅ | Mobile UI |
| Swipe to like | Backend ✅ | Mobile UI |
| Match notification | Backend ✅ | Mobile UI |
| Chat with matches | Backend ✅ | Uses shared chat |

**Estimated mobile work:** 2-3 weeks per platform

---

## 4. YOYO 🔨 NEEDS DEVELOPMENT (Proximity Social Discovery)

### Feature Definition (from Neil)

Yoyo is a **proximity-based social connection feature** where users opt-in to discover nearby users. Similar to Happn, Bumble BFF, or WeChat "People Nearby".

**Core Concept:**
- User activates Yoyo mode (opt-in toggle)
- Pre-defined profile: photo, video, introduction text
- Interest categories: dating, coffee, social, friendship, networking
- Gender/preference filters: men seeking women, men seeking friends, women seeking women, etc.
- When two Yoyo-enabled users are physically close, they can see each other's profiles
- Available across ALL feature modules (Video, Buy & Sell, Dating, Social)

### Existing Infrastructure ✅ (Reusable)

| Component | Location | Status |
|-----------|----------|--------|
| User lat/long columns | `users` table | ✅ Already exists |
| Haversine distance formula | `User.js` model | ✅ Already implemented |
| City/State/Country tables | Database | ✅ 60K+ cities indexed |
| Google Maps SDK | iOS Podfile (8.4.0) | ✅ Already integrated |
| Module key pattern | Thread/Chat system | ✅ Can add `yoyo` moduleKey |
| Chat/messaging | Shared infrastructure | ✅ Reuse for connections |

### What Needs Building

**Database (new tables):**

```sql
CREATE TABLE yoyo_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    photo_url VARCHAR(500),
    video_url VARCHAR(500),
    introduction TEXT,
    is_active BOOLEAN DEFAULT FALSE,
    interests JSON,  -- ["dating", "coffee", "social", "friends"]
    seeking JSON,    -- {"gender": "women", "purpose": ["dating", "friends"]}
    last_location_update DATETIME,
    visibility_radius_miles INT DEFAULT 5,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE yoyo_discoveries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    discoverer_user_id INT NOT NULL,
    discovered_user_id INT NOT NULL,
    distance_miles DECIMAL(5,2),
    discovered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    module_context ENUM('video_making', 'buy_sell', 'dating', 'social_stumble'),
    status ENUM('discovered', 'viewed', 'connected', 'dismissed'),
    FOREIGN KEY (discoverer_user_id) REFERENCES users(id),
    FOREIGN KEY (discovered_user_id) REFERENCES users(id)
);

CREATE TABLE yoyo_connections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_a_id INT NOT NULL,
    user_b_id INT NOT NULL,
    connected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    connection_type ENUM('dating', 'coffee', 'social', 'friends', 'networking'),
    thread_id INT,  -- Links to chat thread
    FOREIGN KEY (user_a_id) REFERENCES users(id),
    FOREIGN KEY (user_b_id) REFERENCES users(id),
    FOREIGN KEY (thread_id) REFERENCES threads(id)
);
```

**Backend API (new endpoints):**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/yoyo/profile` | PUT | Create/update Yoyo profile |
| `/yoyo/profile` | GET | Get current user's Yoyo profile |
| `/yoyo/activate` | POST | Toggle Yoyo discovery on/off |
| `/yoyo/nearby` | GET | Get nearby Yoyo users (uses Haversine) |
| `/yoyo/discover/:userId` | POST | Mark user as discovered |
| `/yoyo/connect/:userId` | POST | Request connection |
| `/yoyo/connections` | GET | List active connections |
| `/yoyo/location` | PUT | Update user's current location |

**Mobile Work:**

| Platform | Work Required |
|----------|---------------|
| iOS | Yoyo profile setup UI, nearby discovery feed, location permissions, background location updates |
| Android | Same as iOS |

### MVP Segment (Minimum to Launch Yoyo)

| Feature | Priority | Effort |
|---------|----------|--------|
| Yoyo profile setup (photo, intro, interests) | High | 1 week |
| Activate/deactivate toggle | High | 2 days |
| Nearby users discovery list | High | 1 week |
| View discovered user profile | High | 3 days |
| Connect/dismiss actions | High | 3 days |
| Chat with connections | Medium | Reuse existing |
| Location permission handling | High | 2 days |
| Background location updates | Medium | 1 week |

**Estimated total work:** 3-4 weeks (backend + mobile per platform)

### Nice-to-have (post-MVP)

- Push notification when match is nearby
- "Crossed paths" history (like Happn)
- Proximity badges on user profiles
- Event-based Yoyo (activate at conferences, parties)

---

## 5. SPONSORED LINKS ⚠️ NEEDS BACKEND

### Current State

| Component | Status |
|-----------|--------|
| Backend API | **Missing** - No endpoints |
| Database | **Missing** - No tables |
| Android UI | Partial - Ad types defined, UI shells exist |
| iOS UI | Unknown |

### Android Code Found

```kotlin
// AdConstants.kt
object AdConstants {
    val CLICKABLE_AD: Int = 1
    val PRODUCT_PROMOTION_AD = 2
    val REGULAR_AD: Int = 3
    val TRU_VIEW_AD: Int = 4
}

// AdvertisementBean.kt - Data model exists
data class AdvertisementBean(
    var adId: String?,
    var adType: String?,
    var adUrl: String?,
    var adDuration: String?,
    var points: String?,  // Rewards for watching?
)
```

### What Needs Building

**Database Tables (new):**

```sql
CREATE TABLE advertisements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    advertiser_user_id INT,
    ad_type ENUM('clickable', 'product_promotion', 'regular', 'truview'),
    title VARCHAR(255),
    media_url VARCHAR(500),
    click_url VARCHAR(500),
    duration_seconds INT,
    points_reward INT,
    target_module ENUM('video_making', 'buy_sell', 'social_stumble'),
    status ENUM('active', 'inactive', 'pending'),
    start_date DATETIME,
    end_date DATETIME,
    budget DECIMAL(10,2),
    impressions_count INT DEFAULT 0,
    clicks_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE advertisement_impressions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ad_id INT,
    user_id INT,
    watched_duration_seconds INT,
    clicked BOOLEAN DEFAULT FALSE,
    points_awarded INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ad_id) REFERENCES advertisements(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**Backend API (new):**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/advertisements` | GET | Get ads for user (with targeting) |
| `/advertisements` | POST | Create ad (admin/advertiser) |
| `/advertisement/impression` | POST | Track view/click |
| `/advertisement/reward` | POST | Award points for watching |

### MVP Segment (Minimum to Launch Ads)

| MVP Feature | Priority |
|-------------|----------|
| Display ads in video feed | High |
| Track impressions | High |
| Admin create/manage ads | High |
| Click-through tracking | Medium |
| User rewards for watching | Low (post-MVP) |

**Estimated work:** 2-3 weeks backend + mobile integration

---

## 6. SOCIAL (Social Stumble) ✅ MVP READY

### Full Feature List

| Feature | Backend | iOS | Android |
|---------|---------|-----|---------|
| Create posts (text/photo) | ✅ | ✅ | ✅ |
| Feed browsing | ✅ | ✅ | ✅ |
| Like/dislike | ✅ | ✅ | ✅ |
| Comments | ✅ | ✅ | ✅ |
| Photo albums | ✅ | ✅ | ✅ |
| User tagging | ✅ | ✅ | ✅ |
| Friend requests | ✅ | ✅ | ✅ |
| Events | ✅ | ✅ | ✅ |
| Saved posts | ✅ | ✅ | ✅ |
| User search | ✅ | ✅ | ✅ |

### Database Tables (11 tables)

- `social_stumbles`, `social_stumble_comments`, `social_stumble_like_dislikes`
- `social_stumble_albums`, `social_stumble_album_galleries`
- `social_stumble_events`, `social_stumble_saved_posts`
- `social_stumble_tags`, `social_stumble_user_tags`

### API Endpoints: 30+

Core: `/social-stumble`, `/social-stumble-comment`, `/social-stumble-album`, `/social-stumble-event`

### MVP Segment

**Everything is MVP-ready.** Full social networking features complete.

---

## Extended Modules (Not in Neil's Priority List)

These exist but weren't mentioned by Neil - **defer unless specifically requested**:

| Module | Backend | iOS | Android | Notes |
|--------|---------|-----|---------|-------|
| Blog | ✅ | ✅ | ⚠️ | Long-form content |
| VIP Pages | ✅ | ✅ | ⚠️ | Brand/celebrity pages |
| Notice Board | ✅ | ✅ | ⚠️ | Community announcements |
| Find Discount | ✅ | ⚠️ | ⚠️ | Deals/coupons |
| Lost & Found | ✅ | ⚠️ | ⚠️ | Lost/stolen items |
| Missing Person | ✅ | ⚠️ | ⚠️ | Missing person reports (legal concerns) |

> **Recommendation:** Focus on Neil's 6 priorities first. These extended modules can be enabled later with minimal work since backend is complete.

---

## 7. Micro-Interactions

> *"The small things make it magical"* — Neil Douglas

Micro-interactions are the small, purposeful animations and feedback moments that make Kuwboo feel alive. They happen in response to user actions — a swipe, a tap, a hold — and give the user confidence that the app heard them. Below, each interaction is described twice: once for Neil (what the user experiences) and once for the developer (what to build).

**Full interaction specs** (trigger, behaviour, feedback, timing, curves) → [INTERACTION_DESIGN_MAP.md](INTERACTION_DESIGN_MAP.md) Section 13

---

### 7a. Gesture Interactions

| Pattern | What Neil Sees | What Dev Builds |
|---------|---------------|-----------------|
| Card swipe dismiss | Swipe a profile card left to pass or right to like — the card spins off the edge of the screen and the next one lifts up behind it | `UIPanGestureRecognizer` (iOS) / Jetpack Compose `Draggable` (Android) with rotation transform proportional to velocity; threshold-based commit/cancel; spring-animated bounce-back on cancel |
| Card swipe-up super | Swipe a profile card upward to super-like — a burst of golden stars explodes from the card | Vertical pan gesture with separate threshold from horizontal dismiss; triggers star particle system at card center on commit |
| Double-tap to like | Double-tap a video or post and a heart pops up right where you tapped, then little hearts scatter outward | Touch-point detection on double-tap; spawn heart view at touch coordinates, scale 0→1.3→0 with 8–12 child particle views using gravity physics |
| Long-press context menu | Hold down on a post, comment, or message to get quick options (report, copy, reply) | 500ms press-and-hold timer; present bottom sheet or contextual popover with dim overlay; light haptic on trigger |
| Long-press FAB speed dial | Hold the center button to reveal extra options that fan out above it | 400ms hold on center FAB; staggered animation (50ms per item) fans options upward; heavy haptic; dim overlay behind |
| Pull to refresh | Pull down at the top of any feed to reload — the Kuwboo logo spins while loading | Custom refresh control with branded animation (not the platform default spinner); rubber-band overscroll physics |
| 3D photo flip | Swipe across someone's photos and they flip like a card turning over, showing the next photo on the other side | `CATransform3D` rotation around Y-axis (iOS) / `graphicsLayer { rotationY }` (Android); perspective set for depth; 300ms easeOutBack |
| Swipe to archive/delete | Swipe left on a chat or match to reveal Archive/Delete buttons underneath | Swipeable row with `UISwipeActionsConfiguration` (iOS) / `SwipeToDismiss` (Android); revealed buttons slide in with coloured background |
| Tap to toggle | Tap a heart, bookmark, or follow button and it bounces briefly as it switches between on and off | Scale pulse animation 1.0→1.3→1.0 over 300ms on state toggle; light haptic; counter value animates smoothly (not instant jump) |
| Hold to record | Hold the record button and a ring fills up around it showing how much time is left | Circular progress ring (CAShapeLayer / Canvas arc) that fills clockwise proportional to hold duration; release ends recording |
| Drag to reorder | Hold a photo, then drag it to rearrange the order — the other photos slide out of the way | Long-press activates drag; lifted item scales 1.05 with shadow; sibling items animate to fill gap; drop triggers layout recalculation |
| Interest chip tap | Tap an interest tag (like "Travel" or "Music") and it bounces lightly to show it's selected | Scale bounce 1.0→1.15→1.0 over 200ms; fill colour transition; selection counter updates |
| Bottom sheet drag dismiss | Grab the handle at the top of a pop-up sheet and drag it down to close it | Pan gesture on sheet handle; sheet follows finger with rubber-band resistance; commits dismiss past 40% threshold |
| Card bounce-back | If you don't swipe a card far enough, it bounces back to the center like a rubber band | Spring animation with damping ratio ~0.7; card returns to identity transform; next card settles back to peek scale |
| Pinch to zoom | Pinch outward on a photo to zoom in for a closer look | Pinch gesture recognizer; image scales from gesture center point; max 3x; release → spring back to fit |
| Story tap navigation | Tap the left or right side of a story to go back or forward | Touch region detection (left third / right third); progress bar jumps; story content cross-fades |
| Story hold to pause | Hold anywhere on a story to pause it — lift to continue | Touch-down pauses timer and playback; touch-up resumes; intentionally no haptic feedback |

---

### 7b. Visual Feedback

| Pattern | What Neil Sees | What Dev Builds |
|---------|---------------|-----------------|
| Heart burst | Hearts scatter outward when you double-tap or like something | Particle emitter spawning 8–12 heart shapes from interaction point; gravity-affected; 600ms lifetime |
| Star burst | Golden stars explode when you super-like someone | Particle system with gold/blue colour scheme; radial emission; star scales 1.0→2.0→0 with cascading sparkles |
| Confetti | Colourful confetti rains down when you match with someone | Full-screen particle system with multi-coloured rectangles; gravity + rotation physics; 2s duration |
| Ghost particles | Ethereal particles drift upward when you turn on ghost mode | Low-opacity (0.3→0.0) particles rising from avatar position over 400ms; creates vanishing effect |
| Follow button morph | The Follow button smoothly transforms into "Following" when you tap it | Width animation + text cross-fade + background colour transition; single coordinated animation group |
| FAB icon cross-fade | The center button's icon changes smoothly when you switch between modules | Icon cross-fade (200ms); no positional change; both icons briefly visible during overlap period |
| Auction timer urgency | The countdown timer turns red and starts pulsing when time is almost up | Colour transition to red at 5-minute threshold; pulse animation with increasing frequency (2s→1s→0.5s) |
| Success toast | A small green bar slides up confirming your action (saved, posted, sent) | Non-blocking toast that slides in from bottom (300ms), holds 4s, slides out (200ms); dismissible with swipe |
| Error shake | The form field shakes side-to-side when something's wrong (bad code, username taken) | Horizontal oscillation (3 cycles, ±8px, 400ms); red border flash; error message fades in below field |
| Ripple effect | A subtle ripple spreads from where you tap any button | Material-design ripple: circle expanding from touch point, fading as it reaches element bounds; 350ms |
| Story ring gradient | An animated rainbow ring glows around story avatars that have new content | Rotating gradient ring (brand colours) around avatar; solid grey ring replaces it once all segments viewed |
| Unread dot pulse | A small dot gently pulses on chats and notifications you haven't opened yet | Dot bounce-in on appear; gentle scale pulse (1.0→1.2→1.0) on 2s loop; fade-out on read |
| Photo indicator dots | Little dots at the bottom of a photo show which photo you're viewing and how many there are | Horizontal dot row at photo bottom; active dot filled, others outline; smooth transition on swipe/flip |

---

### 7c. Loading States

| Pattern | What Neil Sees | What Dev Builds |
|---------|---------------|-----------------|
| Skeleton shimmer | Grey shapes that look like the content layout shimmer while the real content loads — feels alive, not stuck | Placeholder views matching content structure; linear gradient sweep animation (left→right loop); fade-in to real content |
| Pull-to-refresh indicator | The Kuwboo logo spins at the top when you pull down to reload a feed | Custom refresh view with branded animation; rubber-band overscroll physics; dismisses when data arrives |
| Progress ring | A ring fills up around the record button while you're recording, or around an upload | Circular CAShapeLayer (iOS) / Canvas arc (Android); strokeEnd animated from 0→1 proportional to progress |
| Story progress bar | A thin bar fills across the top of each story showing how long it has left | Horizontal bar with linear fill over segment duration (default 5s); pausable; resets per segment |
| Upload progress overlay | A semi-transparent overlay shows upload percentage while your video or listing is being sent | Modal overlay with circular progress + percentage text; non-dismissible; followed by success toast on completion |
| Infinite scroll loader | A small spinner appears at the bottom of the feed when more items are loading | Spinner positioned below last item; triggered when scroll reaches within 3 items of end; new items fade in |
| Image lazy-load fade-in | Photos gently fade in as they load rather than popping in all at once | Opacity transition 0→1 over 300ms on image load completion; placeholder maintains aspect ratio to prevent layout shift |
| Real-time bid update | The current bid number rolls upward like a counter as new bids come in live | Digit-by-digit scroll animation: old number scrolls up and out, new number scrolls up and in; triggered by WebSocket |

---

### 7d. Notifications & Status

| Pattern | What Neil Sees | What Dev Builds |
|---------|---------------|-----------------|
| Badge bounce-in | A notification number bounces in on the top bar when something new arrives | Badge view animate from scale 0→1.3→1.0 (bounce overshoot); increment existing badge without re-bounce |
| Typing indicator | Three animated dots show when someone is writing you a message | Sequential opacity pulse across 3 dots (left→right loop); appears above input bar; hides on send/stop |
| Read receipts | Single tick when sent, double tick when delivered, blue ticks when they've read it | Tick icon states: single (sent) → double (delivered) → blue double (read); subtle colour/opacity transition between states |
| Online status indicator | A green dot means someone's online now, yellow means recently, grey means away | Coloured dot next to avatar; smooth colour transition between states; 🟢→🟡 after 15m inactive, 🟡→⚪ after configured period |
| Wave sent confirmation | The Wave button changes to "Waved" after you tap it so you know it went through | Button label morph animation + colour desaturation; disabled state prevents double-send; success haptic |
| Match notification badge | A golden ring pulses around new match avatars until you look at them | Animated gold ring (stroke animation) around match avatar; gentle pulse until tapped; bounce-in badge |
| Learning hint tooltip | A helpful "Hold for more options" tip appears above the center button when you're new | Tooltip bubble with downward arrow; auto-dismisses after 3s; shown for first 15 FAB taps only; counter tracked in local storage |
| Outbid notification | A banner slides down telling you someone outbid you, with the item photo and new price | In-app notification banner sliding from top (300ms); shows thumbnail + amount; tap navigates to auction; auto-dismisses after 4s |
| Nearby user arrival | A new person slides into your nearby list when they come within range | Card slides in from top of list with fade-in animation (350ms easeOutBack); list count increments; subtle haptic |

---

### 7e. Transitions

| Pattern | What Neil Sees | What Dev Builds |
|---------|---------------|-----------------|
| Bottom sheet slide | Pop-up panels slide up smoothly from the bottom for things like comments, filters, and offers | UISheetPresentationController (iOS 15+) / BottomSheetBehavior (Android); dim overlay; drag handle for resize/dismiss |
| Speed dial fan | Extra options fan out above the center button when you hold it | Staggered scale-up animation (50ms delay per item) from FAB position; reverse animation on dismiss; dim overlay |
| Card stack parallax | The next card is always visible behind the current one, slightly smaller, creating a depth effect | Z-layered card views; back card at 95% scale + slight Y offset; follows front card movement with dampened parallax |
| Page push/pop | Screens slide in from the right when you go forward, and slide back to reveal the previous screen when you go back | Standard navigation push (slide from right, 300ms) and pop (slide to right, 250ms); iOS edge-swipe gesture for back |
| Match overlay reveal | Both your photos slide in from opposite sides and meet in the middle when you match | Full-screen overlay; left avatar slides from x=-100% to center, right from x=+100% to center; confetti triggers after meet |
| Logo entrance | The Kuwboo logo smoothly fades and scales in when you open the app | Scale 0.5→1.0 + opacity 0→1; tagline fades in 200ms after logo settles; smooth feel, not bouncy |
| Comment sheet resize | Drag the comment panel handle to make it half-screen or full-screen — it snaps into place | Sheet with two detent positions (50% and 100% height); snaps to nearest on drag release; content scrollable within |
| Tab cross-fade | Content fades smoothly between tabs instead of sliding — keeps you grounded in the same place | Simultaneous fade-out of old content + fade-in of new content (200ms); tab indicator slides horizontally to new position |
| Filter apply transition | Applying filters refreshes the content with a smooth fade — no jarring reload | Current content fades out; skeleton shimmer if data fetch needed; new content fades in; filter chip state updates |
| Swipe between story users | Swipe left to skip to the next person's stories — their stories slide in from the right | Horizontal page transition; progress bars reset for new user; avatar/name cross-fades in header |

---

### 7f. Haptic Feedback (Quick Reference)

| Level | When It's Used | What It Feels Like |
|-------|---------------|---------------------|
| Light tap | Tapping hearts, chips, toggle buttons | A subtle click — confirms your tap registered |
| Medium tap | FAB tap, pull-to-refresh release, story navigation | A firm click — something meaningful happened |
| Heavy tap | FAB long-press, context menu trigger, record start | A strong thud — you triggered a power action |
| Success | Saving profile, completing recording, wave sent | A satisfied "done" feeling — your action worked |
| Warning | Auction timer urgency, outbid notification | An alert nudge — pay attention |
| Error | Form validation failure, rejected action | A sharp buzz — something went wrong |
| Celebration | Match confetti, match overlay | A festive rumble — something exciting happened |
| None (intentional) | Story pause, skeleton loading, page transitions | Silence is the feedback — the visual change is enough |

---

## Summary: MVP Launch Readiness

### Ready Now ✅

1. **Video Making** - Complete (Neil's #1)
2. **Buy & Sell** - Complete (Neil's #2)
3. **Social (Stumble)** - Complete (Neil's #6)

### Needs Mobile Work ⚠️

4. **Dating** - Backend ready, mobile UI incomplete (~2-3 weeks per platform)

### Needs Backend + Mobile 🔨

5. **Sponsored Links** - No backend, partial Android UI (~2-3 weeks total)
6. **Yoyo** - Proximity discovery, existing location infra helps (~3-4 weeks total)

---

## Recommended MVP Strategy

### Phase 1: Launch Ready (Neil's priorities 1, 2, 6)

These can ship immediately with minimal work:

| Feature | Status | Effort to Ship |
|---------|--------|----------------|
| Video Making | ✅ Complete | Testing only |
| Buy & Sell | ✅ Complete | Testing only |
| Social Stumble | ✅ Complete | Testing only |

### Phase 2: Build Out (Neil's priorities 3, 5)

| Feature | Status | Estimated Effort |
|---------|--------|------------------|
| Dating | Backend ready | 2-3 weeks mobile UI per platform |
| Sponsored Links | Needs backend | 2-3 weeks total |

### Phase 3: Yoyo (Neil's priority 4)

| Feature | Status | Estimated Effort |
|---------|--------|------------------|
| Yoyo | Needs full build | 3-4 weeks total |

**Yoyo leverages existing infrastructure:**
- Haversine formula already in `User.js` model
- User lat/long columns exist in database
- Google Maps SDK integrated in iOS (8.4.0)
- 60K+ cities already indexed

**New work required:**
- 3 database tables (`yoyo_profiles`, `yoyo_discoveries`, `yoyo_connections`)
- 8 API endpoints
- Mobile UI for profile setup + discovery feed

---

## Action Items

### Immediate

- [x] Feature analysis complete (this document)
- [x] Yoyo feature clarified by Neil (proximity-based discovery)

### For Dating (Priority #3)

| Task | Platform | Effort |
|------|----------|--------|
| Dating profile setup UI | iOS | 1 week |
| Dating profile setup UI | Android | 1 week |
| Swipe/match UI | iOS | 1 week |
| Swipe/match UI | Android | 1 week |
| Integration testing | Both | 3 days |

### For Yoyo (Priority #4)

| Task | Component | Effort |
|------|-----------|--------|
| Create database tables | Backend | 2 hours |
| Create Sequelize models | Backend | 4 hours |
| Yoyo API endpoints (8) | Backend | 1 week |
| Profile setup UI | iOS | 3 days |
| Profile setup UI | Android | 3 days |
| Nearby discovery feed | iOS | 1 week |
| Nearby discovery feed | Android | 1 week |
| Location permissions | Both | 2 days |
| Background location updates | Both | 1 week |
| Integration testing | All | 3 days |

**Reuse existing:** Haversine formula (User.js), lat/long columns, Google Maps SDK, chat infrastructure

### For Sponsored Links (Priority #5)

| Task | Component | Effort |
|------|-----------|--------|
| Create database tables | Backend | 2 hours |
| Create API endpoints | Backend | 1 week |
| Sequelize models | Backend | 4 hours |
| Admin ad management | Backend | 3 days |
| Feed ad integration | iOS | 3 days |
| Feed ad integration | Android | 3 days |
| Impression tracking | All | 2 days |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [MVP_SCOPE.md](MVP_SCOPE.md) | Previous MVP analysis (single-module recommendation) |
| [FEATURE_COMPARISON.md](FEATURE_COMPARISON.md) | iOS vs Android feature parity |
| [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) | Full database documentation |
| [BACKEND_ASSESSMENT.md](BACKEND_ASSESSMENT.md) | Backend API analysis |

---

## Appendix: Module Key Architecture

Kuwboo uses a **shared infrastructure pattern** where core systems serve multiple modules via `moduleKey`:

```
Thread.moduleKey:
├── video_making    → TikTok-like feed
├── buy_sell        → Marketplace
├── dating          → Matching
├── social_stumble  → Social discovery
└── yoyo            → Proximity discovery (NEW)

MediaTemp types:
├── blog            → Long-form content
├── notice-board    → Announcements
├── vip-page        → Brand pages
├── find-discount   → Deals
├── lost-and-found  → Lost items
└── missing-person  → Missing persons
```

This shared approach means:
- Chat/messaging serves all modules (including Yoyo connections)
- Followers can be per-module
- Categories are module-specific
- Yoyo can leverage existing location infrastructure (Haversine, lat/long)

---

**Document Version:** 3.0
**Last Updated:** February 6, 2026
**Next Review:** After development phase selection
**Status:** Yoyo clarified, ready for phase planning
