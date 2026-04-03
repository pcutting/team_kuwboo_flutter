# Kuwboo Interaction Design Map

**Created:** February 17, 2026
**Last Updated:** February 17, 2026
**Version:** 1.0
**Purpose:** Definitive reference for every screen, state, gesture, button, and FAB action across all modules

**Related Documents:**
- [FEATURE_ANALYSIS_MVP.md](FEATURE_ANALYSIS_MVP.md) — Feature readiness and priority mapping
- [INITIAL_DESIGN_SCOPE.md](INITIAL_DESIGN_SCOPE.md) — Screen inventory and designer briefing
- [DESIGN_REVIEW_NEIL_FEEDBACK.md](DESIGN_REVIEW_NEIL_FEEDBACK.md) — Neil's aesthetic and interaction preferences
- [NEIL_CALL_NOTES_2026-02-16.md](NEIL_CALL_NOTES_2026-02-16.md) — Confirmed modules and design direction
- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) — Backend tables and `moduleKey` architecture

---

## Key Decisions

| Decision | Choice | Source |
|----------|--------|--------|
| Bottom nav pattern | **Set B: Notched contextual FAB** — 4 module tabs + center FAB that changes per active module | Phil's choice |
| Top bar layout | **YoYo icon LEFT, Profile avatar RIGHT** | Neil's preference (call 16 Feb) |
| Chat location | **Integrated into Profile** area; also beside YoYo icon if space allows | Phil's clarification |
| Dating scope | **Full wireframes** included (deferred from MVP build, but designed now) | Phil's choice |
| Module switching | **Bottom nav tabs** (Video \| Dating \| [YoYo] \| Social \| Shop) | Set B pattern |
| Badges/indicators | **Small, subtle, bottom-positioned** | Neil's feedback |
| Navigation labels | **Icons only** — no text labels in bottom nav | Neil's preference |

---

## 1. Legend & Notation

Standard symbols used in all wireframes throughout this document:

```
Phone frame:    ┌─────────────────────────────┐ (31 chars wide)
                │                             │
                └─────────────────────────────┘

Symbols:
  [Button]       Tappable button
  (●)            Center FAB (changes per module)
  ◉              Active tab / selected state
  ○              Inactive tab
  ←  →           Swipe gesture direction
  ↑  ↓           Scroll / swipe up-down
  ⊕              Add / create action
  ♡ / ♥          Like (empty / filled)
  💬             Comment / chat
  ↗              Share
  ≡              Menu / hamburger
  ⋮              More options (vertical dots)
  ───            Divider line
  ░░░            Placeholder / loading area
  ▓▓▓            Image / media area
  ●●○○           Dot indicators (2 of 4)
```

---

## 2. Global Navigation

### 2a. Top Bar (all screens)

```
┌─────────────────────────────┐
│ (YoYo)  [Module Title] (👤)│  ← YoYo LEFT, Profile RIGHT
│  ⁿ                    💬ⁿ  │  ← badges: nearby count, unread msgs
└─────────────────────────────┘
```

| Element | Position | Tap | Badge |
|---------|----------|-----|-------|
| YoYo icon | Top-left | → YoYo Nearby screen | Nearby user count |
| Module title | Center | — (label only) | — |
| Chat icon | Right of title (if width > 375pt) | → Chat Inbox | Unread message count |
| Profile avatar | Top-right | → Profile screen | Notification count |

### 2b. Bottom Nav Bar (Set B — Notched, Contextual Center FAB)

```
┌─────────────────────────────┐
│ ◉Vid  ○Date  (●Rec)  ○Soc  ○Shop │
│                ●             │  ← Docked FAB in notch (changes per module)
└─────────────────────────────┘
```

The center FAB changes its icon and action based on the active module:

| Active module | Center FAB | Tap | Long-press options |
|---------------|------------|-----|--------------------|
| Video | `(●Rec)` | Record video | Photo, Audio, Upload |
| Dating | `(●Spark)` | Super like / send spark | Boost, Filters, Shuffle |
| Social | `(●Post)` | Create text post | Photo, Video, Event |
| Shop | `(●List)` | Create listing | Sell, Wanted, Auction |
| YoYo Nearby | `(●Wave)` | Wave at nearby users | Ghost Mode, Range |
| Non-module screens | `(●)` | Retains last active module's action | Same as last module |

| Element | Tap | Long-press | Active state |
|---------|-----|------------|--------------|
| Video tab | Switch to Video module | — | Filled icon |
| Dating tab | Switch to Dating module | — | Filled icon |
| Center FAB | Module-specific primary action (see table above) | Speed dial with module-specific options | Elevated in notch |
| Social tab | Switch to Social module | — | Filled icon |
| Shop tab | Switch to Shop module | — | Filled icon |

- 4 module tabs: icon-only, no text labels
- Inactive tabs: outline/stroke icon
- Active tab: filled/solid icon
- Center FAB sits in semicircular notch, always accessible
- FAB icon transitions with a brief cross-fade when switching modules
- **Learning hint:** "Hold for more options" tooltip shown for first 15 taps
- **Haptic feedback:** Medium on tap, heavy on long-press

---

## 3. Video Module

### Feature → Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Play/pause video | Tap center of video | Full-screen | Playing ↔ Paused |
| Like | Double-tap video OR tap heart | Center / right column | ♡ → ♥ toggle |
| Comment | Tap comment icon | Right column | Opens bottom sheet |
| Share | Tap share icon | Right column | Opens share sheet |
| Save/bookmark | Tap bookmark icon | Right column | Toggle |
| Follow creator | Tap avatar + badge | Right column top | Follow → Following |
| Next video | Swipe up | Full-screen | Loads next |
| Previous video | Swipe down | Full-screen | Loads previous |
| Creator profile | Tap username | Bottom overlay | Navigate |
| Sound/music | Tap music ticker | Bottom-right | Opens sound page |
| Record video | Tap center FAB (●Rec) | Center notch | Opens camera |
| Upload video | Long-press center FAB → Upload | Center notch | Opens gallery |
| Search/discover | Tab or swipe | Top tabs | For You / Following / Discover |
| Report content | Long-press video → Report | Context menu | Opens report flow |
| Mute/unmute | Tap speaker icon | Top-right overlay | Toggle |

### Screens

#### 3a. Video Feed (default — For You)

```
┌─────────────────────────────┐
│ (YoYo)   Video       (👤💬)│
├─────────────────────────────┤
│ ForYou  Following  Discover │  ← swipeable tabs
├─────────────────────────────┤
│                             │
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │
│       ▓ FULL-SCREEN ▓       │
│       ▓   VIDEO     ▓       │  ← tap: pause/play
│       ▓             ▓  (👤) │  ← creator avatar
│       ▓             ▓  (♥)  │  ← like (12.5k)
│       ▓             ▓  (💬) │  ← comment (342)
│       ▓             ▓  (↗)  │  ← share (89)
│       ▓             ▓  (🔖) │  ← save
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │
│ @creator · caption text...  │
│ ♪ Original Sound — creator  │
├─────────────────────────────┤
│ ◉Vid  ○Date (●Rec) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Vertical swipe: scroll between videos (snap to full-screen)
- Tap video center: toggle play/pause
- Double-tap: like with heart burst animation
- Right column icons: vertical action bar
- Bottom text: tap username → creator profile; tap sound → sound page
- Top tabs: swipe horizontally or tap to switch feed

#### 3b. Video — Comment Sheet (bottom sheet overlay)

```
┌─────────────────────────────┐
│         Comments (342)      │
│ ─────────────────────────── │
│ 👤 user1 · 2h              │
│   Great video! ♡ 24        │
│ 👤 user2 · 5h              │
│   Love this ♡ 12           │
│ ...                         │
│ ─────────────────────────── │
│ [Add a comment...]  [Send]  │
└─────────────────────────────┘
```

**Interactions:**
- Drag handle to resize (half → full screen)
- Tap heart on comment to like
- Long-press comment → Reply, Report, Copy
- Swipe down on handle to dismiss

#### 3c. Video — Recording Screen

```
┌─────────────────────────────┐
│ [✕]              [Flip] [⚡]│
├─────────────────────────────┤
│                             │
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │
│       ▓  CAMERA    ▓       │
│       ▓  PREVIEW   ▓       │
│       ▓             ▓       │
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │
│                             │
│  [Filters] [Effects] [Timer]│
│          (◉ REC)            │  ← hold to record, tap for photo
│  [Gallery]    [Music]       │
├─────────────────────────────┤
│     15s   30s   60s   3m    │  ← duration picker
└─────────────────────────────┘
```

**Interactions:**
- Hold record button: records video (progress ring fills)
- Tap record button: captures photo
- Flip: toggle front/back camera
- Flash: cycle off/on/auto
- Duration picker: horizontal scroll, tap to select
- Gallery: opens device gallery for upload
- Music: opens sound picker (pre-record)
- ✕: discard and return (confirm dialog)

#### 3d. Video — Edit/Post Screen

```
┌─────────────────────────────┐
│ [Back]    Edit     [Next]   │
├─────────────────────────────┤
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │
│       ▓  VIDEO     ▓       │
│       ▓  PREVIEW   ▓       │
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │
│  ▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊       │  ← timeline scrubber
│                             │
│ [Trim] [Text] [Sticker]    │
│ [Filter] [Music] [Speed]   │
├─────────────────────────────┤
│ Caption: [                ] │
│ Tags:    [#tag1 #tag2     ] │
│ Visibility: [Everyone  ▾]  │
│         [Post Video]        │
└─────────────────────────────┘
```

**Interactions:**
- Timeline: drag handles to trim start/end
- Text: tap to position text overlay, long-press to edit
- Sticker: opens sticker picker, drag to position
- Filter: horizontal scroll through filter previews
- Music: add/replace audio track
- Speed: 0.5x / 1x / 2x / 3x
- Visibility dropdown: Everyone, Friends Only, Private

#### 3e. Video — Creator Profile

```
┌─────────────────────────────┐
│ [←]   @creator       [⋮]   │
├─────────────────────────────┤
│         (👤 large)          │
│       Creator Name          │
│    123 Following · 45k Fans │
│    Bio text here...         │
│   [Follow]  [Message]       │
│ ─────────────────────────── │
│  Videos  Liked  Saved       │  ← tabs
│ ┌────┐ ┌────┐ ┌────┐       │
│ │ ▓▓ │ │ ▓▓ │ │ ▓▓ │       │  ← 3-column video grid
│ │ ▓▓ │ │ ▓▓ │ │ ▓▓ │       │
│ └────┘ └────┘ └────┘       │
│ ┌────┐ ┌────┐ ┌────┐       │
│ │ ▓▓ │ │ ▓▓ │ │ ▓▓ │       │
│ └────┘ └────┘ └────┘       │
├─────────────────────────────┤
│ ◉Vid  ○Date (●Rec) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Follow/Following: toggle button (confirm on unfollow)
- Message: opens direct chat thread
- Video grid: tap any thumbnail → full-screen video player
- Tabs: tap or swipe to switch between Videos / Liked / Saved
- ⋮ menu: Report, Block, Copy Link

#### 3f. Video — Discover/Search

```
┌─────────────────────────────┐
│ [🔍 Search videos...]      │
├─────────────────────────────┤
│ Trending  Music  Comedy  ...│  ← category chips (scroll)
│ ─────────────────────────── │
│ ┌────┐ ┌────┐ ┌────┐       │
│ │ ▓▓ │ │ ▓▓ │ │ ▓▓ │       │  ← trending grid
│ │▶12k│ │▶8k │ │▶45k│       │
│ └────┘ └────┘ └────┘       │
│ ┌────┐ ┌────┐ ┌────┐       │
│ │ ▓▓ │ │ ▓▓ │ │ ▓▓ │       │
│ └────┘ └────┘ └────┘       │
├─────────────────────────────┤
│ ◉Vid  ○Date (●Rec) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Search bar: tap to focus, shows recent searches + suggestions
- Category chips: horizontal scroll, tap to filter
- Grid thumbnails: tap → full-screen video playback
- View count overlay on each thumbnail
- Pull to refresh

#### 3g. Video — Sound/Music Page

```
┌─────────────────────────────┐
│ [←]   Sound Detail          │
├─────────────────────────────┤
│  ♪ "Song Title"             │
│  Artist Name · 1.2M videos  │
│  [Use Sound]  [Save]        │
│ ─────────────────────────── │
│ ┌────┐ ┌────┐ ┌────┐       │  ← videos using this sound
│ │ ▓▓ │ │ ▓▓ │ │ ▓▓ │       │
│ └────┘ └────┘ └────┘       │
├─────────────────────────────┤
│ ◉Vid  ○Date (●Rec) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Use Sound: opens recording screen with this sound pre-loaded
- Save: bookmarks sound to personal library
- Video grid: tap → play video with this sound
- Audio preview plays automatically on entry (tap to pause)

---

## 4. Dating Module

> **Note:** Dating is deferred from MVP build but fully designed here for future implementation. Card and profile patterns also inform YoYo and Social discovery screens.

### Feature → Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Like profile | Swipe right OR tap heart | Card / button | Card flies right |
| Pass profile | Swipe left OR tap X | Card / button | Card flies left |
| Super like | Swipe up OR tap star | Card / button | Star animation |
| View photos | Swipe left/right on photo | Photo area | 3D flip transition |
| Return to card | Swipe down on enlarged photo | Full-screen | Bounce-back |
| View full profile | Tap card info area | Below photo | Expand card |
| Open chat (match) | Tap match card | Matches list | Opens chat |
| Boost profile | Long-press center FAB → Boost | Center notch | 30-min boost |
| Apply filters | Long-press center FAB → Filters | Center notch | Opens filter sheet |
| Shuffle deck | Long-press center FAB → Shuffle | Center notch | Re-randomise |
| Report profile | Long-press card → Report | Context menu | Report flow |
| Undo last action | Tap undo icon | Top bar area | Restores last card |

### Screens

#### 4a. Dating — Card Stack (default)

```
┌─────────────────────────────┐
│ (YoYo)   Dating      (👤💬)│
├─────────────────────────────┤
│ ┌───────────────────────┐   │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │   │
│ │ ▓   FULL PHOTO      ▓ │   │  ← swipe L/R on photo: flip
│ │ ▓                    ▓ │   │  ← swipe L on card: pass
│ │ ▓                    ▓ │   │  ← swipe R on card: like
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │   │  ← swipe up on card: super
│ │         ●●○○○         │   │  ← photo dot indicators (BOTTOM)
│ │ Sarah, 28        3 mi │   │
│ │ "Bio text here..."    │   │
│ │        ✓ˢᵐ           │   │  ← small red verified badge
│ └───────────────────────┘   │
│    (✕)    (★)    (♥)       │  ← pass / super like / like
├─────────────────────────────┤
│ ○Vid  ◉Date (●Spark) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Card swipe right: like (card flies off-screen right with rotation)
- Card swipe left: pass (card flies off-screen left with rotation)
- Card swipe up: super like (star burst animation)
- Photo swipe L/R: 3D flip between photos (NOT card dismiss)
- Tap info area: expand to full profile (4b)
- Photo dots at BOTTOM of photo (Neil's preference — not top)
- Verified badge: small, red, bottom-positioned
- Next card peeks behind current card (parallax depth)

#### 4b. Dating — Expanded Profile

```
┌─────────────────────────────┐
│ [←]   Profile         [⋮]  │
├─────────────────────────────┤
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │  ← full-width photo
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│         ●●○○○               │
│ Sarah, 28 · 3 mi · ✓       │
│ ─────────────────────────── │
│ About: Bio paragraph...     │
│ ─────────────────────────── │
│ Interests: [Travel] [Music] │
│ Height: 5'7" · Job: Design  │
│ ─────────────────────────── │
│ Match: 87%                  │
│    (✕)    (★)    (♥)       │
├─────────────────────────────┤
│ ○Vid  ◉Date (●Spark) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Scrollable content below photo
- Photo area: swipe L/R for 3D flip between photos
- Interest chips: tappable (shows shared interests highlighted)
- Match percentage: small, subtle (Neil's preference)
- Action buttons: same swipe/tap behavior as card stack
- ← back: returns to card stack with bounce-back animation

#### 4c. Dating — It's a Match!

```
┌─────────────────────────────┐
│                             │
│       ✨ It's a Match! ✨   │
│                             │
│    (👤)    ♥    (👤)       │  ← both avatars
│   You      &    Sarah       │
│                             │
│   [Send Message]            │
│   [Keep Swiping]            │
│                             │
└─────────────────────────────┘
```

**Interactions:**
- Full-screen overlay with confetti/particle animation
- Send Message: opens chat with match
- Keep Swiping: dismisses overlay, returns to card stack
- Tap outside: same as Keep Swiping
- Avatars animate in from sides and meet in center

#### 4d. Dating — Matches List

```
┌─────────────────────────────┐
│ (YoYo)   Matches     (👤💬)│
├─────────────────────────────┤
│ New Matches                 │
│ (👤)(👤)(👤)(👤)→          │  ← horizontal scroll
│ ─────────────────────────── │
│ Messages                    │
│ ┌───────────────────────┐   │
│ │ 👤 Sarah · 2h ago     │   │
│ │   Hey! How are you?   │   │
│ ├───────────────────────┤   │
│ │ 👤 Emma · 1d ago      │   │
│ │   That's awesome!     │   │
│ ├───────────────────────┤   │
│ │ 👤 Lisa · 3d ago      │   │
│ │   Let's meet up!      │   │
│ └───────────────────────┘   │
├─────────────────────────────┤
│ ○Vid  ◉Date (●Spark) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- New matches row: horizontal scroll, tap avatar → chat
- New match avatar: gold ring if unread
- Message list: tap row → opens conversation (same Chat UI as 8b)
- Swipe left on row: unmatch (with confirmation)
- Pull to refresh

#### 4e. Dating — Filters Sheet

```
┌─────────────────────────────┐
│       Filters        [Done] │
│ ─────────────────────────── │
│ Distance:  ──●────── 25 mi  │
│ Age Range: ──●──●─── 22-35  │
│ Gender:    [Women ▾]        │
│ ─────────────────────────── │
│ Interests:                  │
│ [✓Music] [✓Travel] [○Art]  │
│ [○Sport] [✓Food] [○Books]  │
│ ─────────────────────────── │
│ Show verified only: [○]     │
│         [Apply Filters]     │
└─────────────────────────────┘
```

**Interactions:**
- Bottom sheet overlay (slides up from bottom)
- Sliders: drag thumb for distance and age range
- Interest chips: tap to toggle
- Apply: closes sheet and refreshes deck
- Done: same as Apply
- Drag handle at top to dismiss without applying

---

## 5. Social Module

### Feature → Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Like post | Tap heart / double-tap image | Below post / on image | ♡ → ♥ |
| Comment | Tap comment icon | Below post | Opens comments |
| Share | Tap share icon | Below post | Share sheet |
| Create text post | Tap center FAB (●Post) | Center notch | Opens composer |
| Create photo post | Long-press center FAB → Photo | Center notch | Opens camera/gallery |
| Create video post | Long-press center FAB → Video | Center notch | Opens video capture |
| Create event | Long-press center FAB → Event | Center notch | Opens event form |
| Stumble (discover) | Pull to refresh / tab | Stumble tab | Loads random profiles |
| View stories | Tap story avatar | Stories row | Full-screen story |
| Add story | Tap + avatar | Stories row first | Camera/gallery |
| Follow user | Tap Follow button | Profile/post | Follow → Following |
| View profile | Tap avatar/username | Anywhere | Navigate to profile |
| Report post | Long-press post → Report | Context menu | Report flow |
| Hide post | Long-press post → Hide | Context menu | Removes from feed |
| Scroll feed | Vertical scroll | Feed area | Loads more at bottom |

### Screens

#### 5a. Social — Feed (default)

```
┌─────────────────────────────┐
│ (YoYo)   Social      (👤💬)│
├─────────────────────────────┤
│ (⊕)(👤)(👤)(👤)(👤)→      │  ← stories row
│ ─────────────────────────── │
│ 👤 Alex · 2h ago      [⋮]  │
│ Just had an amazing hike!   │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │  ← photo
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ♡ 234   💬 18   ↗ 5        │
│ ─────────────────────────── │
│ 👤 Jordan · 5h ago    [⋮]  │
│ Anyone up for coffee?       │
│ ♡ 56    💬 8    ↗ 2        │
│ ─────────────────────────── │
├─────────────────────────────┤
│ ○Vid  ○Date (●Post) ◉Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Stories row: scroll horizontal, tap avatar → full-screen story viewer
- ⊕ (first in row): add your own story (camera/gallery picker)
- Story avatar ring: gradient ring = unwatched, grey = watched
- Post: double-tap image → like animation
- Post action bar: ♡ like, 💬 comment (opens sheet), ↗ share
- ⋮ menu: Save, Report, Hide, Copy Link
- Vertical scroll: infinite scroll with loading indicator at bottom

#### 5b. Social — Stumble (discovery)

```
┌─────────────────────────────┐
│ (YoYo)   Stumble     (👤💬)│
├─────────────────────────────┤
│ ┌───────────────────────┐   │
│ │ (👤 large)            │   │
│ │ Alex, 27              │   │
│ │ "Adventure seeker"    │   │
│ │ 12 mutual friends     │   │
│ │ 5 mi away             │   │
│ │  [Wave 👋]  [Skip →] │   │
│ └───────────────────────┘   │
│                             │
│ ┌───────────────────────┐   │  ← next card peek
│ │ (👤)                  │   │
│ └───────────────────────┘   │
├─────────────────────────────┤
│ ○Vid  ○Date (●Post) ◉Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Card-based discovery (similar to Dating but for friend finding)
- Wave: sends a friend request / interest signal
- Skip: dismisses card (slides away)
- Tap card: expand to full profile
- Mutual friends: tap count → shows shared connections
- Pull to refresh: loads new batch of profiles

#### 5c. Social — Post Composer

```
┌─────────────────────────────┐
│ [Cancel]  New Post   [Post] │
├─────────────────────────────┤
│ 👤 What's on your mind?    │
│                             │
│ [                          ]│  ← text area (auto-expand)
│                             │
│ ─────────────────────────── │
│ ▓▓▓▓▓▓ ▓▓▓▓▓▓              │  ← attached media preview
│ [✕]    [✕]                  │
│ ─────────────────────────── │
│ [📷 Photo] [🎥 Video]      │
│ [📍 Location] [👥 Tag]     │
│ [🔒 Privacy: Friends ▾]    │
├─────────────────────────────┤
│ Post type: [Normal ▾]       │  ← Normal / Notice / Alert
└─────────────────────────────┘
```

**Interactions:**
- Text area: auto-expanding, supports @mentions and #hashtags
- Photo/Video: opens picker (multiple selection)
- Attached media: tap to preview full-size, ✕ to remove
- Location: opens map/location search
- Tag: opens friend selector for tagging
- Privacy: Everyone / Friends / Only Me
- Post type: Normal / Notice / Alert (maps to `social_stumble` moduleKey variants)
- Post button: disabled until text or media added

#### 5d. Social — Story Viewer

```
┌─────────────────────────────┐
│ ▊▊▊▊▊░░░░░░░░░░░░░░░░░░░░ │  ← progress bars (story 1/5)
│ 👤 Alex · 4h ago           │
├─────────────────────────────┤
│                             │
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │
│       ▓  FULL-SCREEN ▓      │
│       ▓  STORY       ▓      │  ← tap left: prev
│       ▓  CONTENT     ▓      │  ← tap right: next
│       ▓              ▓      │  ← hold: pause
│       ▓▓▓▓▓▓▓▓▓▓▓▓▓       │  ← swipe up: reply
│                             │
├─────────────────────────────┤
│ [Reply to Alex...]   [↗]   │
└─────────────────────────────┘
```

**Interactions:**
- Progress bars: one per story segment, linear fill (5s default)
- Tap left third: previous story
- Tap right third: next story
- Hold: pause timer and story
- Swipe up: open reply input
- Swipe left: skip to next user's stories
- Swipe down: close story viewer (bounce-back to feed)
- Reply input: sends direct message to story author

#### 5e. Social — Friends List

```
┌─────────────────────────────┐
│ (YoYo)   Friends     (👤💬)│
├─────────────────────────────┤
│ [🔍 Search friends...]     │
│ ─────────────────────────── │
│ Online Now                  │
│ 👤 Sarah · Active now       │
│ 👤 Mike · Active now        │
│ ─────────────────────────── │
│ All Friends (234)           │
│ 👤 Alex · Last seen 2h      │
│ 👤 Jordan · Last seen 1d    │
│ 👤 Emma · Last seen 3d      │
│ ...                         │
├─────────────────────────────┤
│ ○Vid  ○Date (●Post) ◉Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Search: filter friends by name
- Online section: sorted by most recently active
- Tap friend row: opens their profile
- Long-press row: Quick actions (Message, Remove, Block)
- Green dot: online now indicator

#### 5f. Social — Events

```
┌─────────────────────────────┐
│ (YoYo)   Events      (👤💬)│
├─────────────────────────────┤
│ Upcoming                    │
│ ┌───────────────────────┐   │
│ │ ▓▓▓▓ Saturday BBQ     │   │
│ │ ▓▓▓▓ Mar 15 · 4 PM   │   │
│ │      12 going · 3 mi  │   │
│ │      [Interested] [Go]│   │
│ └───────────────────────┘   │
│ ┌───────────────────────┐   │
│ │ ▓▓▓▓ Music Night      │   │
│ │ ▓▓▓▓ Mar 20 · 8 PM   │   │
│ │      45 going · 8 mi  │   │
│ └───────────────────────┘   │
├─────────────────────────────┤
│ ○Vid  ○Date (●Post) ◉Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Event cards: tap to expand full detail
- Interested: adds to your events, notifies before start
- Going: confirms attendance, adds to calendar
- Thumbnail: event cover image
- Distance shown for location-based events
- Attendee count: tap → see who's going

---

## 6. Shop (Buy & Sell) Module

### Feature → Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Browse products | Scroll grid | Main area | 2-column grid |
| Search | Tap search bar | Top | Opens search |
| Filter categories | Tap chip / filter icon | Below search | Active chip highlighted |
| View product | Tap product card | Grid | Navigate to detail |
| Save/wishlist | Tap heart on card | Product card corner | ♡ → ♥ |
| Buy now | Tap Buy button | Product detail | Opens checkout |
| Make offer | Tap Make Offer | Product detail | Opens offer sheet |
| Bid (auction) | Tap Place Bid | Auction detail | Opens bid entry |
| Message seller | Tap Message | Product detail | Opens chat |
| List item | Tap center FAB (●List) | Center notch | Opens listing form |
| Create auction | Long-press center FAB → Auction | Center notch | Opens auction form |
| Post wanted ad | Long-press center FAB → Wanted | Center notch | Opens wanted form |
| Share listing | Tap share icon | Product detail | Share sheet |
| Report listing | Long-press → Report | Context menu | Report flow |
| View seller | Tap seller name/avatar | Product detail | Seller profile |
| Pull to refresh | Pull down | Grid | Refreshes listings |

### Screens

#### 6a. Shop — Browse (default)

```
┌─────────────────────────────┐
│ (YoYo)    Shop       (👤💬)│
├─────────────────────────────┤
│ [🔍 Search products...]    │
│ All  Vintage  Fashion  Tech │  ← category chips (scroll)
│ ─────────────────────────── │
│ ┌──────────┐ ┌──────────┐  │
│ │ ▓▓▓▓▓▓▓▓ │ │ ▓▓▓▓▓▓▓▓ │  │  ← 2-col product grid
│ │ Vintage  │ │ Sneakers │  │
│ │ Lamp     │ │ Nike Air │  │
│ │ £35   ♡  │ │ £120  ♡  │  │
│ │ 👤 2 mi  │ │ 👤 5 mi  │  │
│ └──────────┘ └──────────┘  │
│ ┌──────────┐ ┌──────────┐  │
│ │ ▓▓▓▓▓▓▓▓ │ │ ▓▓▓▓▓▓▓▓ │  │
│ │ Guitar   │ │ Jacket   │  │
│ │ £250  ♡  │ │ £45   ♡  │  │
│ └──────────┘ └──────────┘  │
├─────────────────────────────┤
│ ○Vid  ○Date (●List) ○Soc ◉Sh│
└─────────────────────────────┘
```

**Interactions:**
- 2-column masonry grid (images vary in height)
- Category chips: horizontal scroll, active chip filled
- Product card: tap → product detail (6b)
- Heart icon: tap to save/unsave
- Seller avatar + distance: tap → seller profile
- Pull to refresh
- Infinite scroll at bottom

#### 6b. Shop — Product Detail

```
┌─────────────────────────────┐
│ [←]   Product        [↗][♡]│
├─────────────────────────────┤
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │  ← swipeable photo gallery
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│           ●●○○○             │
│ ─────────────────────────── │
│ Vintage Lamp               │
│ £35.00  · Condition: Good  │
│ ─────────────────────────── │
│ 👤 Seller Name · ★ 4.8     │
│    2 mi away · 23 listings  │
│ ─────────────────────────── │
│ Description text here...    │
│ Category: Home & Garden     │
│ Posted: 2 days ago          │
│ ─────────────────────────── │
│ [Message Seller] [Buy £35]  │
│          OR                 │
│     [Make an Offer]         │
├─────────────────────────────┤
│ ○Vid  ○Date (●List) ○Soc ◉Sh│
└─────────────────────────────┘
```

**Interactions:**
- Photo gallery: horizontal swipe, tap to view full-screen
- Dot indicators below gallery
- Share (↗): opens platform share sheet
- Heart (♡): toggle wishlist
- Seller row: tap → seller profile (6e)
- Message Seller: opens chat thread (tagged with listing context)
- Buy: opens payment/checkout flow
- Make an Offer: opens bottom sheet with price input
- Scrollable content

#### 6c. Shop — Auction Detail

```
┌─────────────────────────────┐
│ [←]   Auction        [↗][♡]│
├─────────────────────────────┤
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│           ●●○○              │
│ ─────────────────────────── │
│ Signed Football Jersey      │
│ Current bid: £180           │
│ ⏱ Ends in: 2h 34m          │  ← live countdown timer
│ 12 bids · 45 watchers      │
│ ─────────────────────────── │
│ 👤 Seller · ★ 4.9          │
│ ─────────────────────────── │
│ Bid History:                │
│  £180 · user3 · 10m ago    │
│  £165 · user7 · 25m ago    │
│  £150 · user1 · 1h ago     │
│ ─────────────────────────── │
│ [Place Bid: £185+]          │
├─────────────────────────────┤
│ ○Vid  ○Date (●List) ○Soc ◉Sh│
└─────────────────────────────┘
```

**Interactions:**
- Live countdown timer: updates every second, highlights red when < 5 min
- Place Bid: opens bottom sheet with bid amount input (minimum = current + increment)
- Bid history: scrollable list, tap username → profile
- Watcher count: tap → see who's watching
- Real-time bid updates via WebSocket
- Notification when outbid

#### 6d. Shop — Create Listing

```
┌─────────────────────────────┐
│ [Cancel] New Listing [Post] │
├─────────────────────────────┤
│ [📷 Add Photos (0/10)]     │
│ ─────────────────────────── │
│ Title: [                  ] │
│ Price: [£        ]          │
│ Condition: [New ▾]          │
│ Category: [Select ▾]        │
│ ─────────────────────────── │
│ Description:                │
│ [                          ]│
│ [                          ]│
│ ─────────────────────────── │
│ Listing type:               │
│ (●) Fixed Price             │
│ (○) Auction                 │
│ (○) Wanted                  │
│ ─────────────────────────── │
│ Location: [📍 Use current]  │
│ Delivery: [✓ Collection]    │
│           [✓ Shipping]      │
├─────────────────────────────┤
│         [List Item]         │
└─────────────────────────────┘
```

**Interactions:**
- Add Photos: opens gallery (multi-select up to 10), drag to reorder
- Photo strip: horizontal scroll of added photos, tap ✕ to remove, first photo = cover
- Condition dropdown: New / Like New / Good / Fair / For Parts
- Category: opens full category browser
- Listing type radio: changes form fields (Auction adds start price, duration, reserve)
- Location: pre-fills with current location, tap to change on map
- Delivery: checkboxes (at least one required)
- Post/List Item: validates all required fields, shows progress overlay

#### 6e. Shop — Seller Profile

```
┌─────────────────────────────┐
│ [←]   Seller          [⋮]  │
├─────────────────────────────┤
│         (👤 large)          │
│       Seller Name           │
│    ★ 4.8 · 23 listings      │
│    Member since Jan 2025    │
│   [Message]  [Follow]       │
│ ─────────────────────────── │
│  Active   Sold   Reviews    │  ← tabs
│ ┌──────────┐ ┌──────────┐  │
│ │ ▓▓▓▓▓▓▓▓ │ │ ▓▓▓▓▓▓▓▓ │  │
│ │ Item 1   │ │ Item 2   │  │
│ │ £35      │ │ £120     │  │
│ └──────────┘ └──────────┘  │
├─────────────────────────────┤
│ ○Vid  ○Date (●List) ○Soc ◉Sh│
└─────────────────────────────┘
```

**Interactions:**
- Tabs: Active listings / Sold items / Reviews
- Active grid: same 2-column layout as browse, tap → product detail
- Sold: greyed-out listings with sold price
- Reviews: star rating + text reviews from buyers
- Message: opens chat thread
- Follow: get notified of new listings from this seller
- ⋮ menu: Report, Block, Copy Link

---

## 7. YoYo (Nearby)

### Feature → Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| View nearby list | Scroll list | Main area | Vertical list (NOT grid) |
| View profile | Tap user card | List item | Opens profile |
| Wave at user | Tap Wave button or tap center FAB (●Wave) | Card / center notch | Sends wave notification |
| Ghost mode | Long-press center FAB (●Wave) → Ghost | Center notch speed dial | Hides from nearby |
| Set range | Long-press center FAB (●Wave) → Range | Center notch speed dial | Opens range slider |
| Sort by distance | Default sort | List | Closest first |
| Filter nearby | Tap filter icon | Top-right | Opens filter sheet |
| Refresh | Pull to refresh | List | Re-scans nearby |

> **Neil's requirement:** List view, NOT grid. "Grid looks like the back of a T-shirt in a pound shop." Clean cards with space, not cramped tiles.

### Screens

#### 7a. YoYo — Nearby List (default)

```
┌─────────────────────────────┐
│ (YoYo)   Nearby      (👤💬)│
├─────────────────────────────┤
│ 12 people nearby     [⚙]   │  ← count + filter/settings
│ ─────────────────────────── │
│ ┌───────────────────────┐   │
│ │ (👤) Sarah, 28        │   │
│ │      "Adventure time" │   │
│ │      0.3 mi · 🟢 now  │   │  ← online: green
│ │               [Wave👋]│   │
│ └───────────────────────┘   │
│ ┌───────────────────────┐   │
│ │ (👤) Mike, 31         │   │
│ │      "Coffee lover"   │   │
│ │      0.8 mi · 🟡 5m   │   │  ← recently: yellow
│ │               [Wave👋]│   │
│ └───────────────────────┘   │
│ ┌───────────────────────┐   │
│ │ (👤) Emma, 25         │   │
│ │      1.2 mi · ⚪ 1h   │   │  ← inactive: grey
│ │               [Wave👋]│   │
│ └───────────────────────┘   │
├─────────────────────────────┤
│ ○Vid  ○Date (●Wave) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Vertical list (NOT grid) — one card per row with generous spacing
- Sorted by distance (closest first)
- Online indicators: 🟢 active now, 🟡 active within 15m, ⚪ last seen time
- Wave button: sends push notification to that user
- Tap card: opens user profile (7c)
- Pull to refresh: re-scans nearby users
- Settings icon (⚙): opens range/filter controls
- List updates in real-time as users move

#### 7b. YoYo — Speed Dial (center FAB expanded)

```
┌─────────────────────────────┐
│                             │
│              [Range 📍]     │  ← fan upward from center
│            [Ghost 👻]       │
│          [Wave 👋]          │
│                             │
├─────────────────────────────┤
│ ○Vid  ○Date (●Wave) ○Soc ○Sh│  ← FAB expanded
└─────────────────────────────┘
```

**Interactions:**
- Triggered by long-press on center FAB (●Wave)
- Options fan outward/upward with staggered animation
- Wave: broadcasts wave to all nearby users within range
- Ghost: toggles ghost mode (hides you from others' nearby lists)
- Range: opens slider to adjust discovery radius (0.5mi–25mi)
- Tap outside or tap FAB again: collapse with reverse animation
- Dim overlay behind speed dial options

#### 7c. YoYo — User Profile (from nearby)

```
┌─────────────────────────────┐
│ [←]   Sarah           [⋮]  │
├─────────────────────────────┤
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │  ← swipe for photos (3D flip)
│           ●●○○              │
│ Sarah, 28 · 0.3 mi · ✓     │
│ "Adventure seeker & ..."    │
│ ─────────────────────────── │
│ Interests: [Travel] [Music] │
│ ─────────────────────────── │
│ [Wave 👋]    [Message 💬]  │
├─────────────────────────────┤
│ ○Vid  ○Date (●Wave) ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Photo area: swipe L/R with 3D flip transition (Neil's requirement)
- Photo dots: bottom of photo area
- Wave: sends notification (button changes to "Waved" after tap)
- Message: opens direct chat thread
- Interest chips: tappable (shows if you share them)
- ⋮ menu: Report, Block
- Verified badge (✓): small, red, bottom-positioned
- ← back: returns to nearby list with slide transition

---

## 8. Chat

Chat is integrated — accessible from Profile area, message badge on top bar, and within Dating matches. All chat threads are unified regardless of module origin.

### Feature → Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Open inbox | Tap chat icon / profile badge | Top bar | Navigate to inbox |
| Open conversation | Tap conversation | Inbox list | Opens thread |
| Send message | Type + tap Send | Input bar | Message sent |
| Send photo | Tap camera icon | Input bar | Opens camera/gallery |
| Send voice | Hold mic icon | Input bar | Records voice note |
| React to message | Long-press message | Message bubble | Emoji picker |
| Delete message | Long-press → Delete | Context menu | Removes message |
| Block user | Tap ⋮ → Block | Chat header | Blocks + removes |
| Video call | Tap video icon | Chat header | Opens call |
| Voice call | Tap phone icon | Chat header | Opens call |

### Screens

#### 8a. Chat — Inbox

```
┌─────────────────────────────┐
│ [←]   Messages              │
├─────────────────────────────┤
│ [🔍 Search conversations...]│
│ ─────────────────────────── │
│ 👤 Sarah · 2m ago     [●]  │  ← unread dot
│   Hey! How's it going?      │
│ ─────────────────────────── │
│ 👤 Mike · 1h ago            │
│   Thanks for the wave!      │  ← YoYo context
│ ─────────────────────────── │
│ 👤 Alex · 3h ago            │
│   Is the lamp still avail?  │  ← Shop context
│ ─────────────────────────── │
│ 👤 Emma · 1d ago            │
│   See you at the event!     │  ← Social context
│ ─────────────────────────── │
├─────────────────────────────┤
│ ○Vid  ○Date  (●)  ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Conversations sorted by most recent message
- Unread indicator: blue dot on right
- Tap row: opens conversation (8b)
- Swipe left on row: Archive, Mute, Delete
- Search: filters conversations by contact name or message content
- Context tag: subtle indicator showing which module originated the thread

#### 8b. Chat — Conversation

```
┌─────────────────────────────┐
│ [←] 👤 Sarah  [📞][📹][⋮] │
├─────────────────────────────┤
│        Today                │
│                             │
│ ┌──────────────┐            │
│ │ Hey! How's   │            │  ← their message (left-aligned)
│ │ it going?    │  2:30 PM   │
│ └──────────────┘            │
│                             │
│            ┌──────────────┐ │
│  3:15 PM   │ Great! Just  │ │  ← your message (right-aligned)
│            │ got back from│ │
│            │ a hike       │ │
│            └──────────────┘ │
│                             │
│ ┌──────────────┐            │
│ │ That sounds  │            │
│ │ amazing!     │  3:16 PM   │
│ └──────────────┘            │
│                             │
├─────────────────────────────┤
│ [📷] [Type message...] [▶] │
└─────────────────────────────┘
```

**Interactions:**
- Messages: left-aligned (theirs), right-aligned (yours)
- Long-press message: React (emoji), Reply, Copy, Delete
- Input bar: text input with auto-growing height
- Camera icon: opens camera/gallery for photo/video message
- Hold mic icon (replaces send when input empty): records voice note
- Send (▶): sends message, scrolls to bottom
- 📞 Voice call, 📹 Video call
- ⋮ menu: Mute, Block, Clear History, View Profile
- Typing indicator: "Sarah is typing..." shown above input
- Read receipts: double-tick on sent messages

---

## 9. Profile & Settings

### Screens

#### 9a. Profile — My Profile

```
┌─────────────────────────────┐
│ [←]   My Profile     [Edit]│
├─────────────────────────────┤
│         (👤 large)          │
│       Your Name             │
│    @username · ✓ Verified   │
│ ─────────────────────────── │
│ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │ 234 │ │ 567 │ │ 89  │   │
│ │Posts │ │Foll.│ │Foll.│   │
│ └─────┘ └─────┘ └─────┘   │
│ ─────────────────────────── │
│ [💬 Messages]          12  │  ← chat home
│ [🛍 My Listings]        5  │
│ [♥ Saved Items]        23  │
│ [📊 Activity]               │
│ [⚙ Settings]               │
│ [❓ Help]                   │
├─────────────────────────────┤
│ ○Vid  ○Date  (●)  ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Stats row: tap any counter → opens respective list (Posts, Followers, Following)
- Messages: → Chat Inbox (8a)
- My Listings: → filtered Shop view (your items only)
- Saved Items: → saved/wishlisted items and bookmarks across all modules
- Activity: → notification history (likes, comments, followers, waves)
- Settings: → Settings screen (9c)
- Edit: → Edit Profile (9b)
- Profile avatar: tap to view full-size, long-press to change photo

#### 9b. Profile — Edit Profile

```
┌─────────────────────────────┐
│ [Cancel] Edit Profile [Save]│
├─────────────────────────────┤
│     (👤 large) [Change]     │
│ ─────────────────────────── │
│ Name:    [Your Name       ] │
│ Username:[yourname        ] │
│ Bio:     [Bio text...     ] │
│ ─────────────────────────── │
│ Photos:                     │
│ ┌────┐ ┌────┐ ┌────┐ [+]  │
│ │ ▓▓ │ │ ▓▓ │ │ ▓▓ │      │
│ └────┘ └────┘ └────┘       │
│ ─────────────────────────── │
│ Interests: [Edit]           │
│ [Travel] [Music] [Food]    │
│ ─────────────────────────── │
│ Location: London, UK [📍]   │
│ Date of Birth: [01/01/1995] │
├─────────────────────────────┤
│ ○Vid  ○Date  (●)  ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Change avatar: tap → camera/gallery picker
- Photos: drag to reorder, tap ✕ to remove, [+] to add (up to 6)
- First photo = primary (used in Dating cards and YoYo list)
- Interests: tap Edit → opens interest selector (same as onboarding 10c)
- Location: tap 📍 → location picker/map
- Bio: 300 char limit with counter
- Username: validates availability in real-time
- Save: validates all fields, shows toast on success
- Cancel: discards changes (confirm dialog if unsaved changes)

#### 9c. Profile — Settings

```
┌─────────────────────────────┐
│ [←]   Settings              │
├─────────────────────────────┤
│ Account                     │
│  Email · Phone · Password   │
│ ─────────────────────────── │
│ Privacy                     │
│  Who can see me: [Everyone▾]│
│  Location sharing: [On]     │
│  Online status: [On]        │
│ ─────────────────────────── │
│ Notifications               │
│  Push: [On]   Email: [Off]  │
│  YoYo nearby: [On]         │
│  Messages: [On]             │
│ ─────────────────────────── │
│ Content                     │
│  Blocked users              │
│  Content filters            │
│ ─────────────────────────── │
│ [Log Out]                   │
│ [Delete Account]            │
├─────────────────────────────┤
│ ○Vid  ○Date  (●)  ○Soc ○Sh│
└─────────────────────────────┘
```

**Interactions:**
- Grouped list with section headers
- Account items: tap → individual edit screens with OTP verification
- Privacy toggles: switch widgets, changes apply immediately
- Notification toggles: switch widgets
- Blocked users: tap → list with unblock option
- Content filters: tap → age-appropriate content settings
- Log Out: confirmation dialog, clears session
- Delete Account: multi-step confirmation (type "DELETE" to confirm), 30-day recovery window

---

## 10. Auth Screens

#### 10a. Welcome / Splash

```
┌─────────────────────────────┐
│                             │
│                             │
│         (KUWBOO LOGO)       │
│                             │
│    Connect. Discover. Play. │
│                             │
│                             │
│      [Sign Up]              │
│      [Log In]               │
│                             │
│  By continuing you agree to │
│  Terms & Privacy Policy     │
└─────────────────────────────┘
```

**Interactions:**
- Logo: animated entrance (scale + fade)
- Sign Up: → Sign Up flow (10b)
- Log In: → Log In screen (phone + OTP)
- Terms / Privacy Policy: tappable links → in-app webview
- No bottom nav bar on auth screens

#### 10b. Sign Up

```
┌─────────────────────────────┐
│ [←]   Sign Up               │
├─────────────────────────────┤
│ Phone: [+44            ]    │
│        [Send OTP]           │
│ ─────────────────────────── │
│ OTP:   [_ _ _ _]           │
│ ─────────────────────────── │
│ Name:  [               ]    │
│ DOB:   [DD/MM/YYYY     ]   │
│ ─────────────────────────── │
│ Photo: [📷 Add Profile Pic] │
│ ─────────────────────────── │
│        [Continue →]         │
│                             │
│ Already have an account?    │
│ [Log In]                    │
└─────────────────────────────┘
```

**Interactions:**
- Phone: country code picker + number input
- Send OTP: validates number format, sends SMS
- OTP: 4-digit auto-advance input (auto-fills from SMS on iOS/Android)
- Name: required field
- DOB: date picker (enforces 18+ minimum)
- Photo: optional but encouraged (camera/gallery)
- Continue: → Onboarding interests (10c)
- Log In link: → existing user login screen

> **Dev note:** All OTPs default to `4444` in development mode (`NODE_ENV=development`)

#### 10c. Onboarding — Interests

```
┌─────────────────────────────┐
│ [←]  Pick Your Interests    │
├─────────────────────────────┤
│ Choose 3 or more:           │
│                             │
│ [Travel✓] [Music✓] [Food]  │
│ [Sport]  [Art]    [Books✓] │
│ [Film]   [Gaming] [Nature] │
│ [Tech]   [Fashion][Pets]   │
│ [Comedy] [Dance]  [Fitness]│
│                             │
│ ─────────────────────────── │
│ Selected: 3/15              │
│                             │
│      [Get Started →]        │
└─────────────────────────────┘
```

**Interactions:**
- Chip grid: tap to toggle selection (with subtle scale animation)
- Selected chips: filled/highlighted state
- Counter: updates in real-time
- Get Started: enabled when 3+ selected
- ← back: keeps selections (not destructive)
- After completion: navigates to Video feed (default home module)

---

## 11. Sponsored Content

Sponsored content is non-intrusive and blends into native feeds. Uses the same visual patterns as organic content with a subtle sponsor label.

```
┌─────────────────────────────┐
│ Sponsored · [Ad]            │  ← subtle label
│ 👤 Brand Name               │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ Ad copy text here...        │
│ [Learn More]  [Hide Ad]     │
│ ─────────────────────────── │
```

**Placement rules:**

| Feed | Position | Format |
|------|----------|--------|
| Video feed | Between videos (every 5-8 items) | Full-screen video ad |
| Social feed | Between posts (every 4-6 items) | Image/text post format |
| Shop grid | In grid as promoted listing (every 8-12 items) | Product card with "Promoted" badge |
| Dating | Occasional prompt between cards | "Boost your profile" CTA |

**Interactions:**
- Learn More: opens advertiser URL in in-app browser
- Hide Ad: removes ad, shows "Why?" feedback options
- Report Ad: flags inappropriate content
- Sponsored label: always visible, never obscured

---

## 12. Animation & Transition Spec

| Interaction | Animation | Duration | Curve |
|-------------|-----------|----------|-------|
| Photo swipe (Dating/YoYo) | 3D flip / rotation | 300ms | easeOutBack |
| Card dismiss (Dating) | Fly off-screen + rotate | 250ms | easeIn |
| Bounce-back (end of content) | Elastic overshoot | 400ms | elasticOut |
| FAB expand (speed dial) | Scale up + fan | 300ms | easeOutBack |
| FAB collapse | Scale down + converge | 200ms | easeIn |
| Tab switch | Cross-fade | 200ms | easeInOut |
| Bottom sheet open | Slide up + dim overlay | 250ms | easeOutCubic |
| Bottom sheet close | Slide down | 200ms | easeIn |
| Like (heart) | Scale pulse 1.0→1.3→1.0 | 300ms | easeOutBack |
| Pull to refresh | Rubber-band stretch | physics | spring |
| Page navigate | Slide from right | 300ms | easeOutCubic |
| Page dismiss | Slide to right | 250ms | easeIn |
| Story progress | Linear fill | 5s/story | linear |
| Notification badge | Bounce in | 400ms | bounceOut |
| Double-tap like | Heart burst particles | 600ms | easeOut |
| Card stack (Dating) | Parallax depth on next card | — | spring |
| Speed dial options | Staggered fan (50ms per item) | 300ms total | easeOutBack |
| Ghost mode toggle | Fade + ghost particles | 400ms | easeInOut |
| Match overlay | Avatars slide in from edges | 500ms | easeOutBack |
| Confetti (Match!) | Particle burst | 2000ms | gravity |
| Success toast | Slide in + fade | 300ms in, 200ms out | easeOutCubic / easeIn |
| Error shake | Horizontal oscillation (3 cycles) | 400ms | easeInOut |
| Ripple effect | Expanding circle from touch point | 350ms | easeOut |
| Image lazy-load | Fade in from 0→1 opacity | 300ms | easeOut |
| Number roll (bid update) | Digit counter scroll | 400ms | easeOutCubic |
| Nearby card arrival | Slide in from top + fade | 350ms | easeOutBack |
| In-app notification banner | Slide down from top + auto-dismiss | 300ms in, 4s hold, 200ms out | easeOutCubic / easeIn |

### Animation Principles (from Neil)

- "The small things make it magical" — micro-interactions are a priority
- Physics-based movement, never mechanical
- Transparent/semi-transparent buttons layered over images
- Nothing should feel jarring or abrupt
- Loading states should feel alive (pulsing placeholders, not just spinners)
- Transitions between screens should feel connected, not like page loads

---

## 13. Micro-Interactions Catalogue

> *"The small things make it magical"* — Neil Douglas

This catalogue consolidates every micro-interaction across all modules into a single canonical reference. Section 12 defines the **timing constants** (duration, curve); this section defines the **interaction patterns** (trigger, behaviour, feedback, and where they're used). Together they form the complete interaction specification for designers and developers.

**Pattern IDs:** G = Gesture, V = Visual Feedback, L = Loading & Progress, N = Notification & Status, T = Transition & Reveal

---

### 13a. Gesture-Based Interactions (17 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| G1 | Card swipe dismiss | Pan gesture on card (horizontal) | Card translates + rotates proportional to drag distance; commits when velocity threshold met, else elastic return | Card flies off-screen with rotation; next card scales up from behind | Card dismiss (Dating) | Dating card stack (4a), Social stumble (5b) |
| G2 | Card swipe-up super action | Pan gesture on card (upward) | Card lifts vertically with slight scale-up | Star burst particle animation at card center | — (uses Double-tap like particle system) | Dating card stack (4a) |
| G3 | Double-tap to like | Two taps within 300ms on content area | Heart icon spawns at tap point, scales up, then fades with particles | Heart burst particles radiate outward; like counter increments | Double-tap like | Video feed (3a), Social feed (5a) |
| G4 | Long-press context menu | Press and hold ≥ 500ms on content item | Dim overlay fades in; menu slides up from bottom or appears at touch point | Light haptic on menu appearance; background blur | Bottom sheet open | Video (3a, 3b), Social (5a), Chat (8b), Shop (6b) |
| G5 | Long-press FAB speed dial | Press and hold ≥ 400ms on center FAB | Options fan outward/upward from FAB with staggered delay (50ms per item) | Heavy haptic on trigger; dim overlay behind options | FAB expand, Speed dial options | All modules via center FAB (2b), YoYo (7b) |
| G6 | Pull to refresh | Drag down past threshold at scroll top | Branded loader animates (Kuwboo logo spin, not generic spinner); rubber-band stretch physics | Content fades in from top as new data loads | Pull to refresh | Video discover (3f), Dating matches (4d), Shop browse (6a), YoYo nearby (7a), Social stumble (5b) |
| G7 | 3D photo flip | Horizontal swipe on photo area within a card/profile | Photo rotates around Y-axis revealing next photo; perspective transform gives depth | Next photo resolves during flip; dot indicators update | Photo swipe (Dating/YoYo) | Dating card (4a), Dating profile (4b), YoYo user profile (7c) |
| G8 | Swipe to archive/delete | Horizontal swipe on list row (left) | Row slides to reveal action buttons (Archive, Mute, Delete) | Red/orange background reveals behind row; icons slide in | — | Chat inbox (8a), Dating matches (4d) |
| G9 | Tap to toggle (like/save/follow) | Single tap on action icon | Icon swaps state (outline → filled) with scale pulse 1.0→1.3→1.0 | Light haptic; counter increments/decrements smoothly | Like (heart) | Video feed (3a), Social feed (5a), Shop product (6b), Shop browse (6a) |
| G10 | Hold to record | Press and hold record button | Progress ring fills around button proportional to hold duration; camera active | Release ends recording; ring completes with success haptic | — | Video recording (3c) |
| G11 | Drag to reorder | Long-press then drag on item in list/grid | Item lifts (scale 1.05, shadow increases); other items shift to make room | Drop shadow follows finger; items animate to new positions on release | — | Shop create listing photos (6d), Profile edit photos (9b) |
| G12 | Interest chip tap | Single tap on chip in grid/row | Chip toggles selected state with scale bounce (1.0→1.15→1.0) | Fill colour changes; selection counter updates | — | Dating filters (4e), Dating profile (4b), Onboarding (10c), Profile edit (9b), YoYo profile (7c) |
| G13 | Bottom sheet drag dismiss | Drag down on sheet handle when sheet is open | Sheet follows finger with resistance; commits dismiss past 40% threshold | Sheet slides down and overlay fades; content behind un-dims | Bottom sheet close | Video comments (3b), Dating filters (4e), Shop offer input, Chat context menus |
| G14 | Card bounce-back | Incomplete swipe (below velocity/distance threshold) on card | Card returns to center position with elastic overshoot | Spring physics; next card settles back to peek position | Bounce-back | Dating card stack (4a), Dating profile back (4b) |
| G15 | Pinch to zoom | Two-finger pinch outward on photo | Photo scales from pinch center; max 3x; translates to follow gesture center | Release snaps back to fit with spring animation | — | Shop product photos (6b), Profile photos, Chat photo messages |
| G16 | Story tap navigate | Tap on left/right third of story viewer | Left tap: previous story segment; right tap: next segment | Progress bar jumps; story content cross-fades | Story progress | Social story viewer (5d) |
| G17 | Story hold to pause | Press and hold on story content | Progress bar pauses; playback freezes | Release resumes from same point; no haptic (intentionally silent) | Story progress | Social story viewer (5d) |

---

### 13b. Visual Feedback (14 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| V1 | Heart burst | Double-tap on content OR tap heart icon | Heart icon scales up at interaction point; 8–12 smaller hearts radiate outward with gravity | Particles fade after 600ms; hearts drift and rotate as they fall | Double-tap like | Video feed (3a), Social feed (5a) |
| V2 | Star burst | Swipe up on dating card OR tap star button | Star icon expands from card center; golden sparkle particles radiate in all directions | Star scales 1.0→2.0→0 while particles cascade; blue/gold colour scheme | — | Dating card stack (4a) |
| V3 | Confetti | Match detected between two users | Full-screen particle burst: multi-coloured confetti rectangles fall with gravity and rotation | Particles obey gravity physics; duration 2s; fades gradually | Confetti (Match!) | Dating match overlay (4c) |
| V4 | Ghost particles | Ghost mode toggled on | Semi-transparent particles drift upward from user avatar, fading as they rise | Opacity 0.3→0.0 over 400ms; creates ethereal "vanishing" effect | Ghost mode toggle | YoYo speed dial (7b), YoYo nearby list (7a) |
| V5 | Follow button morph | Tap Follow/Following button | Button label cross-fades; width animates to fit new text; colour transitions | "Follow" (outline) → "Following" (filled) with smooth morph | — | Video creator profile (3e), Social profiles, Shop seller (6e), YoYo profile (7c) |
| V6 | FAB icon cross-fade | Module tab switch changes center FAB context | Current icon fades out while new icon fades in; 200ms overlap | No position change; icon morphs in place within notch | Tab switch | Bottom nav FAB (2b) — all module switches |
| V7 | Auction timer urgency | Timer drops below 5 minutes remaining | Timer text transitions from default colour to red; pulse animation begins | Pulse rate increases as time decreases: 2s→1s→0.5s intervals | — | Shop auction detail (6c) |
| V8 | Chip selection scale | Interest/category chip tapped | Chip scales 1.0→1.15→1.0 over 200ms; fill colour transitions | Bouncy scale gives tactile feel without haptics | — | Dating filters (4e), Onboarding (10c), Video discover chips (3f), Shop category chips (6a) |
| V9 | Success toast | Action completed successfully (save, post, send) | Toast slides in from bottom, holds 4s, slides out; green accent | Non-blocking; dismissible with swipe; stacks if multiple | Success toast | Profile save (9b), Shop listing posted (6d), Post published (5c) |
| V10 | Error shake | Validation failure or rejected action | Element shakes horizontally (3 cycles, ±8px) over 400ms | Red border flash on affected field; error message fades in below | Error shake | Auth OTP (10b), Shop bid too low (6c), Profile username taken (9b) |
| V11 | Ripple effect | Tap on any button or interactive surface | Circle expands from touch point outward, fading as it grows | Material-style ripple; colour matches element theme | Ripple effect | All tappable surfaces (global) |
| V12 | Story ring gradient | Story avatar has unwatched content | Animated gradient ring rotates around avatar (rainbow/brand colours) | Ring changes to solid grey after all segments viewed | — | Social stories row (5a), Social story viewer (5d) |
| V13 | Unread dot pulse | New unread message or notification | Small dot appears with bounce-in; gentle pulse (scale 1.0→1.2→1.0, 2s loop) | Dot disappears when content is read; no abrupt removal (fade out) | Notification badge | Chat inbox (8a), Top bar badges (2a), Dating matches (4d) |
| V14 | Photo indicator dots | Multiple photos in a gallery/card | Dots at BOTTOM of photo area; active dot filled, others hollow | Dots transition smoothly as photos change (slide or flip) | — | Dating card (4a), Dating profile (4b), Shop product (6b), YoYo profile (7c) |

---

### 13c. Loading & Progress (8 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| L1 | Skeleton shimmer | Content area loading (initial or navigation) | Grey placeholder shapes match content layout; shimmer gradient sweeps left→right continuously | Shapes resolve into real content with fade-in; shimmer stops | — | All feeds (3a, 5a, 6a), Chat inbox (8a), Profile (9a) |
| L2 | Pull-to-refresh indicator | User drags past scroll-top threshold | Branded loader appears (Kuwboo logo rotation, not a generic spinner); rubber-band physics on overscroll | Loader dismisses when data arrives; content slides in from top | Pull to refresh | Video discover (3f), Dating matches (4d), Shop browse (6a), YoYo nearby (7a), Social feed (5a) |
| L3 | Progress ring | Hold-to-record or upload in progress | Circular ring fills clockwise around trigger element; stroke width 3pt | Completes to full circle on finish; incomplete if cancelled mid-way | — | Video recording (3c), Profile photo upload (9b) |
| L4 | Story progress bar | Story segment playing | Thin horizontal bar fills left→right over segment duration (default 5s) | Bar completes → next segment bar begins; pauses on hold (G17) | Story progress | Social story viewer (5d) |
| L5 | Upload progress overlay | Media upload in progress (photo, video, listing) | Semi-transparent overlay on content with circular progress indicator and percentage text | Overlay dismisses on completion; success toast (V9) follows | — | Video edit/post (3d), Shop create listing (6d), Social composer (5c) |
| L6 | Infinite scroll loader | User scrolls near bottom of feed (within 3 items of end) | Small loading spinner appears below last item; next batch appends when ready | Spinner dismisses; new items fade in from below | — | Video feed (3a), Social feed (5a), Shop browse (6a), Chat inbox (8a) |
| L7 | Image lazy-load fade-in | Image enters viewport during scroll | Image fades from transparent→opaque over 300ms once loaded | Prevents layout shift; placeholder maintains aspect ratio | Image lazy-load | All image grids (3f, 5a, 6a), Profile galleries |
| L8 | Real-time bid update (number roll) | New bid received via WebSocket | Current bid number scrolls upward like a counter; new number scrolls in from below | Bid count increments; watcher count may also update | Number roll (bid update) | Shop auction detail (6c) |

---

### 13d. Notification & Status (9 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| N1 | Badge bounce-in | New notification/message received while in app | Badge number appears with overshoot bounce (scale 0→1.3→1.0) | Number increments if badge already visible; no bounce on increment | Notification badge | Top bar (2a), Bottom nav tabs (2b), Dating matches (4d) |
| N2 | Typing indicator | Other user is composing a message | Three dots animate in sequence (opacity pulse left→right, looping) | Appears above input bar; dismisses when user stops typing or sends | — | Chat conversation (8b) |
| N3 | Read receipts | Sent message has been read by recipient | Single tick (sent) → double tick (delivered) → blue double tick (read) | Tick transition is subtle fade/colour change, not abrupt swap | — | Chat conversation (8b) |
| N4 | Online status indicator | User is currently active in the app | Green dot next to avatar; 🟢 online, 🟡 recent (within 15m), ⚪ inactive | Dot transitions smoothly between states (colour fade) | — | YoYo nearby (7a), Social friends (5e), Chat inbox (8a) |
| N5 | Wave sent confirmation | User taps Wave button on nearby user card | Button text morphs "Wave 👋" → "Waved ✓"; button becomes disabled state | Light haptic on send; button colour desaturates | — | YoYo nearby (7a), YoYo profile (7c) |
| N6 | Match notification badge | New dating match detected | Gold ring animates around match avatar in matches row; badge bounces in | Ring pulses gently until tapped; dismisses after viewing | Notification badge | Dating matches (4d) |
| N7 | Learning hint tooltip | User's first 15 interactions with center FAB (tap only, no long-press yet) | Tooltip bubble appears above FAB: "Hold for more options" with arrow pointing down | Tooltip auto-dismisses after 3s; counter decrements; stops after 15 | — | Bottom nav FAB (2b) — first use education |
| N8 | Outbid notification | Another user places higher bid on watched auction | In-app banner slides down from top; push notification if backgrounded | Banner shows item thumbnail + new bid amount; tap → auction detail (6c) | In-app notification banner | Shop auction (6c) |
| N9 | Nearby user arrival | New user enters proximity range while YoYo active | Card slides into nearby list from top with fade-in | Gentle haptic; list count increments; new card highlighted briefly | Nearby card arrival | YoYo nearby (7a) |

---

### 13e. Transition & Reveal (10 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| T1 | Bottom sheet slide | Action requiring modal input (comments, filters, offers, bids) | Sheet slides up from bottom edge; dim overlay fades in behind; respects safe areas | Drag handle visible at top for resize/dismiss; content scrollable | Bottom sheet open / close | Video comments (3b), Dating filters (4e), Shop bid/offer, Chat actions |
| T2 | Speed dial fan | Long-press on center FAB | Options emerge from FAB position, fanning upward with 50ms stagger per item | Dim overlay; each option has icon + label; reverse animation on collapse | FAB expand / collapse, Speed dial options | All modules via center FAB (2b), YoYo (7b) |
| T3 | Card stack parallax | Viewing top card in stack (Dating, Stumble) | Next card visible behind current at ~95% scale + slight Y offset; tracks current card movement | Creates depth perception; next card "breathes" as current card moves | Card stack (Dating) | Dating card stack (4a), Social stumble (5b) |
| T4 | Page push/pop | Navigate forward to new screen / tap back | Push: new screen slides in from right (300ms); Pop: current screen slides right to reveal previous | iOS-standard gesture: edge-swipe from left to pop | Page navigate / Page dismiss | All screen transitions (global) |
| T5 | Match overlay reveal | Two users match (mutual like) | Full-screen overlay fades in; both avatars slide in from left and right edges, meeting in center | Confetti burst (V3) triggers after avatars meet; overlay is dismissible | Match overlay | Dating match (4c) |
| T6 | Logo entrance | App launch / welcome screen | Logo scales from 0.5→1.0 with fade from 0→1; tagline fades in 200ms after logo settles | Smooth, not bouncy — first impression should feel polished, not playful | — | Welcome/splash (10a) |
| T7 | Comment sheet resize | Drag handle on open comment sheet | Sheet resizes between half-screen and full-screen positions; snaps to nearest position | Content scrolls within sheet; pull past top → full-screen; pull down → dismiss | Bottom sheet open / close | Video comments (3b) |
| T8 | Tab cross-fade | Tap module tab in bottom nav or content tabs within a screen | Old content fades out while new content fades in simultaneously; 200ms | No sliding; keeps spatial context stable; tab indicator slides to new position | Tab switch | Bottom nav (2b), Video feed tabs (3a), Creator profile tabs (3e), Shop seller tabs (6e) |
| T9 | Filter apply transition | Apply filters in Dating or Shop | Current content fades out; new filtered content fades in; filter chip updates | Brief skeleton shimmer (L1) may appear if data fetch needed | — | Dating filters (4e), Shop category chips (6a), Video discover (3f) |
| T10 | Swipe-between-users (stories) | Swipe left on story viewer to skip to next user | Current user's stories slide left; next user's stories slide in from right | Progress bars reset for new user; avatar and name update | — | Social story viewer (5d) |

---

### 13f. Haptic Feedback Summary

Haptic feedback reinforces gesture results without requiring visual attention. Each level maps to platform-specific APIs.

| Haptic Level | iOS API | Android API | Patterns Using This Level |
|-------------|---------|-------------|---------------------------|
| **Light** | `UIImpactFeedbackGenerator(.light)` | `HapticFeedbackConstants.KEYBOARD_TAP` | G9 (tap to toggle), G12 (chip tap), N5 (wave sent), V11 (ripple on tap) |
| **Medium** | `UIImpactFeedbackGenerator(.medium)` | `HapticFeedbackConstants.CONTEXT_CLICK` | G5 (FAB tap — medium), G6 (pull-to-refresh release), G16 (story tap navigate) |
| **Heavy** | `UIImpactFeedbackGenerator(.heavy)` | `HapticFeedbackConstants.LONG_PRESS` | G5 (FAB long-press — heavy), G4 (context menu trigger), G10 (record start) |
| **Success** | `UINotificationFeedbackGenerator(.success)` | `HapticFeedbackConstants.CONFIRM` | V9 (success toast), G10 (recording complete), N5 (wave sent confirmation) |
| **Warning** | `UINotificationFeedbackGenerator(.warning)` | `HapticFeedbackConstants.REJECT` | V7 (auction timer urgency), N8 (outbid notification) |
| **Error** | `UINotificationFeedbackGenerator(.error)` | `HapticFeedbackConstants.REJECT` | V10 (error shake), failed action attempts |
| **Celebration** | Custom: rapid light→medium→heavy sequence | Custom: `VibrationEffect.createWaveform` | V3 (confetti on match), T5 (match overlay reveal) |
| **None (intentional)** | — | — | G17 (story hold to pause — silence is the feedback), L1 (skeleton shimmer), T4 (page push/pop — visual-only) |

> **Implementation note:** Android haptic names vary by API level. Use `HapticFeedbackConstants` for API 30+ and `VibrationEffect` patterns for earlier versions. iOS haptic generators should be prepared in advance (call `prepare()` before the expected trigger) to avoid latency.

---

## Screen Count Summary

| Module | Screens | Notes |
|--------|---------|-------|
| Video | 7 | Feed, Comments, Record, Edit/Post, Creator Profile, Discover, Sound |
| Dating | 5 | Card Stack, Expanded Profile, Match!, Matches List, Filters |
| Social | 6 | Feed, Stumble, Composer, Story Viewer, Friends, Events |
| Shop | 5 | Browse, Product Detail, Auction, Create Listing, Seller Profile |
| YoYo | 3 | Nearby List, Speed Dial, User Profile |
| Chat | 2 | Inbox, Conversation |
| Profile | 3 | My Profile, Edit Profile, Settings |
| Auth | 3 | Welcome, Sign Up, Onboarding |
| Sponsored | 1 | Inline template (reused per feed) |
| **Total** | **35** | |

---

## Cross-Reference Verification

| Requirement | Status | Source |
|-------------|--------|--------|
| Every feature from `FEATURE_ANALYSIS_MVP.md` mapped to an affordance | ✅ | Feature tables per module |
| All screens from `INITIAL_DESIGN_SCOPE.md` represented | ✅ | 35 screens covering all modules |
| Neil's icon-only nav preference applied | ✅ | Section 2b — no text labels |
| Neil's small/subtle badges applied | ✅ | Dating card (4a), all badge callouts |
| Neil's list layout for YoYo (NOT grid) | ✅ | Section 7a — vertical list with quote |
| Neil's 3D photo flip requirement | ✅ | Dating (4a), YoYo (7c), Animation spec |
| Set B navigation pattern (notched contextual center FAB) | ✅ | Section 2b |
| Top bar: YoYo LEFT, Profile RIGHT | ✅ | Section 2a |
| Chat accessible from Profile and top bar badge | ✅ | Section 2a, 9a |
| Photo indicators at BOTTOM (not top) | ✅ | Dating card (4a), all photo galleries |
| Center FAB changes per module | ✅ | Section 2b — contextual FAB table |
| `moduleKey` architecture respected | ✅ | Chat contexts (8a), post types (5c) |
| All micro-interactions catalogued with trigger, behaviour, feedback, and locations | ✅ | Section 13 — 58 patterns across 5 categories + haptic summary |
