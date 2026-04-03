# Kuwboo Interaction Design Map — Set C (Service Switcher FAB)

**Created:** February 17, 2026
**Last Updated:** February 21, 2026
**Version:** 2.0 — Set C Navigation Pattern
**Purpose:** Definitive reference for every screen, state, gesture, button, and FAB action across all modules
**Supersedes:** Set B (Notched Center FAB) pattern from v1.0

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
| Navigation pattern | **Set C: Service Switcher FAB** — bottom-right FAB opens vertical popup of 5 services; bottom nav shows 4 sub-feature tabs per active service | Evolution from Set B testing |
| Top bar layout | **YoYo icon LEFT, Profile avatar RIGHT** | Neil's preference (call 16 Feb) |
| Chat location | **Integrated into Profile** area; also beside YoYo icon if space allows | Phil's clarification |
| Dating scope | **Full wireframes** included (deferred from MVP build, but designed now) | Phil's choice |
| Module switching | **Side FAB popup** (tap FAB → choose Video / Dating / YoYo / Social / Market) | Set C pattern |
| Intra-module navigation | **Bottom nav tabs** (4 sub-feature tabs, change per active service) | Set C pattern |
| Badges/indicators | **Small, subtle, bottom-positioned** | Neil's feedback |
| Navigation labels | **Icons + small labels** in bottom nav sub-feature tabs; **Icons + labels** in FAB popup | Set C pattern |

---

## Set B → Set C: What Changed and Why

| Aspect | Set B (Notched Center FAB) | Set C (Service Switcher FAB) |
|--------|---------------------------|------------------------------|
| **Module switching** | Bottom nav tabs (Video \| Dating \| Social \| Shop) | Side FAB popup (Video \| Dating \| YoYo \| Social \| Market) |
| **Bottom nav purpose** | Switch between modules | Navigate sub-features within the active module |
| **Center FAB** | Docked in semicircular notch; contextual primary action per module (Record, Spark, Post, List) | Removed — no center FAB |
| **Side FAB** | Not present | Bottom-right circular FAB; opens vertical service selector popup |
| **Primary actions** | Center FAB tap (e.g., Record Video) | Moved into bottom nav sub-feature tabs (e.g., "Create" tab in Video) |
| **Speed dial** | Long-press center FAB → 3 secondary options per module | Replaced by service popup (5 service bubbles fanning upward) |
| **YoYo access** | Via top-left icon only (not in bottom nav) | Full module in FAB popup; also accessible via top-left icon |
| **Sub-feature tabs** | Not present (tab bars within individual screens only) | 4 tabs per service always visible in bottom nav |
| **FAB position** | Center of bottom nav, in notch | Bottom-right corner, overlapping right edge of bottom nav |
| **FAB icon** | Changed per module (Record → Spark → Post → List) | Shows current service icon (play → heart → compass → people → shop); changes to ✕ when expanded |

### Why Set C

1. **Clearer mental model** — Bottom nav = "what can I do here?", FAB = "where can I go?"
2. **More discoverable features** — Sub-feature tabs expose secondary screens that were previously hidden behind long-press speed dials
3. **YoYo as first-class module** — YoYo now has its own sub-feature tabs instead of being accessible only via the top bar icon
4. **Reduced learning curve** — No long-press education needed (the "hold for more options" tooltip from Set B is eliminated)
5. **Consistent interaction model** — Every service has exactly 4 sub-feature tabs; the FAB always does the same thing (switch services)

---

## 1. Legend & Notation

Standard symbols used in all wireframes throughout this document:

```
Phone frame:    +---------------------------------+ (33 chars wide)
                |                                 |
                +---------------------------------+

Symbols:
  [Button]       Tappable button
  (FAB)          Service Switcher FAB (bottom-right)
  *tab*          Active sub-feature tab (filled icon)
  _tab_          Inactive sub-feature tab (outline icon)
  <-  ->         Swipe gesture direction
  ^  v           Scroll / swipe up-down
  +              Add / create action
  heart / HEART  Like (empty / filled)
  chat           Comment / chat
  share          Share
  menu           Menu / hamburger
  dots           More options (vertical dots)
  ---            Divider line
  ~~~            Placeholder / loading area
  ###            Image / media area
  oo..           Dot indicators (2 of 4)
```

---

## 2. Global Navigation

### 2a. Top Bar (all screens)

```
+---------------------------------+
| (YoYo)  [Module Title]    (Av) |  <- YoYo LEFT, Profile RIGHT
|   n                       chat  |  <- badges: nearby count, unread msgs
+---------------------------------+
```

| Element | Position | Tap | Badge |
|---------|----------|-----|-------|
| YoYo icon | Top-left | Quick-jump to YoYo Nearby screen | Nearby user count |
| Module title | Center | — (label only, shows current service name) | — |
| Chat icon | Right of title (if width > 375pt) | Opens Chat Inbox | Unread message count |
| Profile avatar | Top-right | Opens Profile screen | Notification count |

### 2b. Bottom Nav Bar (Set C — Sub-Feature Tabs + Service Switcher FAB)

```
+---------------------------------+
| *Tab1* _Tab2_ _Tab3_ _Tab4_ (F)|  <- 4 sub-feature tabs + FAB at right
+---------------------------------+
```

The bottom nav shows **4 sub-feature tabs specific to the active service**. The right side is padded to make room for the circular FAB, which overlaps the bottom nav's right edge.

#### Sub-Feature Tabs Per Service

| Active Service | Tab 1 | Tab 2 | Tab 3 | Tab 4 |
|----------------|-------|-------|-------|-------|
| **Video** | For You (`smart_display`) | Following (`people`) | Discover (`travel_explore`) | Create (`add_circle`) |
| **Dating** | Discover (`travel_explore`) | Matches (`handshake`) | Likes (`thumb_up`) | Chat (`chat_bubble`) |
| **YoYo** | Nearby (`near_me`) | Connect (`link`) | Wave (`waving_hand`) | Chat (`chat`) |
| **Social** | Stumble (`shuffle`) | Friends (`group`) | Events (`event`) | Post (`create`) |
| **Market** | Browse (`shopping_bag`) | Deals (`local_offer`) | Sell (`sell`) | Messages (`forum`) |

| Element | Tap | Active state |
|---------|-----|--------------|
| Sub-feature tab | Switch to that sub-feature within the current service | Filled icon + bold label |
| Inactive tab | Same | Outline/stroke icon + regular weight label |
| Service Switcher FAB | Opens vertical popup with 5 service options | FAB rotates, shows close icon |

- 4 sub-feature tabs: **icon + small label** (labels are 8-9pt, minimal weight)
- Tabs are left-aligned in the bar, right side padded for FAB clearance
- Active tab: filled icon, bold label, primary colour
- Inactive tab: outline icon, regular label, secondary colour
- **No notch** — the bottom bar is a flat rectangle
- Bottom bar has a subtle top border (1px, primary colour at 10% opacity)

### 2c. Service Switcher FAB (bottom-right)

```
                              [Video   (play)]
                              [Dating (heart)]
                              [Yoyo (compass)]
                              [Social (people)]
                              [Market  (shop)]
+---------------------------------+
| *Tab1* _Tab2_ _Tab3_ _Tab4_ (X)|  <- FAB shows X when expanded
+---------------------------------+
```

**Closed state:**
- Circular button (50pt diameter) positioned at bottom-right, vertically centered on the bottom nav bar
- Shows the icon of the currently active service (play, heart, compass, people, storefront)
- Branded accent colour with subtle glow shadow (colour at 30% opacity)
- Right margin: 16pt

**Expanded state (tap to open):**
- FAB icon rotates 0.75 radians and changes to close (X) icon
- 5 service options fan upward from the FAB position with staggered animation (50ms delay between items)
- Each option: text label (left) + circular icon bubble (44pt, right-aligned with FAB center)
- Current service: filled icon bubble in FAB colour, bold label
- Other services: outlined icon bubble with border, regular label
- Scrim overlay (black at 30% opacity) covers content behind the popup
- Tap any service: switches to that service (bottom nav tabs update), popup collapses
- Tap scrim: dismisses popup without switching
- Tap FAB (X icon): dismisses popup without switching

**Animation spec:**
- Expand: 250ms, `easeOutBack` curve
- Items stagger: each delayed by `i * 0.12` of the animation duration
- Items enter via scale (0 -> 1) + fade (0 -> 1)
- FAB rotation: simultaneous with expand, same duration and curve
- Collapse: reverse of expand

---

## 3. Video Module

### Sub-Feature Tabs (bottom nav when Video is active)

| Tab | Icon | Screen |
|-----|------|--------|
| **For You** | `smart_display` | Main video feed (default) |
| **Following** | `people` | Videos from followed creators |
| **Discover** | `travel_explore` | Search/trending grid |
| **Create** | `add_circle` | Opens camera/recording screen |

### Feature -> Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Play/pause video | Tap center of video | Full-screen | Playing <-> Paused |
| Like | Double-tap video OR tap heart | Center / right column | empty -> filled toggle |
| Comment | Tap comment icon | Right column | Opens bottom sheet |
| Share | Tap share icon | Right column | Opens share sheet |
| Save/bookmark | Tap bookmark icon | Right column | Toggle |
| Follow creator | Tap avatar + badge | Right column top | Follow -> Following |
| Next video | Swipe up | Full-screen | Loads next |
| Previous video | Swipe down | Full-screen | Loads previous |
| Creator profile | Tap username | Bottom overlay | Navigate |
| Sound/music | Tap music ticker | Bottom-right | Opens sound page |
| Record video | Tap "Create" tab | Bottom nav | Opens camera |
| Upload video | Via Create tab -> Upload option | Create flow | Opens gallery |
| Search/discover | Tap "Discover" tab | Bottom nav | Shows trending grid |
| Report content | Long-press video -> Report | Context menu | Opens report flow |
| Mute/unmute | Tap speaker icon | Top-right overlay | Toggle |

### Screens

#### 3a. Video Feed (default -- For You tab)

```
+---------------------------------+
| (YoYo)   Video          (Av ch)|
+---------------------------------+
|                                 |
|       #################         |
|       # FULL-SCREEN   #         |
|       #   VIDEO       #    (Av) |  <- creator avatar
|       #               #    (H)  |  <- like (12.5k)
|       #               #    (Ch) |  <- comment (342)
|       #               #    (Sh) |  <- share (89)
|       #               #    (Bk) |  <- save
|       #################         |
| @creator . caption text...      |
| m Original Sound -- creator     |
+---------------------------------+
| *ForYou* _Follow_ _Disc_ _Cre_ (F)|
+---------------------------------+
```

**Interactions:**
- Vertical swipe: scroll between videos (snap to full-screen)
- Tap video center: toggle play/pause
- Double-tap: like with heart burst animation
- Right column icons: vertical action bar
- Bottom text: tap username -> creator profile; tap sound -> sound page
- Bottom nav: tap tabs to switch between For You / Following / Discover / Create
- Service FAB (F): tap to open service switcher popup

#### 3b. Video -- Comment Sheet (bottom sheet overlay)

```
+---------------------------------+
|         Comments (342)          |
| --------------------------------|
| Av user1 . 2h                   |
|   Great video! H 24             |
| Av user2 . 5h                   |
|   Love this H 12                |
| ...                             |
| --------------------------------|
| [Add a comment...]  [Send]      |
+---------------------------------+
```

**Interactions:**
- Drag handle to resize (half -> full screen)
- Tap heart on comment to like
- Long-press comment -> Reply, Report, Copy
- Swipe down on handle to dismiss

#### 3c. Video -- Recording Screen (via Create tab)

```
+---------------------------------+
| [X]              [Flip] [Flash] |
+---------------------------------+
|                                 |
|       #################         |
|       #  CAMERA       #         |
|       #  PREVIEW      #         |
|       #               #         |
|       #################         |
|                                 |
|  [Filters] [Effects] [Timer]    |
|          (o REC)                |  <- hold to record, tap for photo
|  [Gallery]    [Music]           |
+---------------------------------+
|     15s   30s   60s   3m        |  <- duration picker
+---------------------------------+
```

**Interactions:**
- Hold record button: records video (progress ring fills)
- Tap record button: captures photo
- Flip: toggle front/back camera
- Flash: cycle off/on/auto
- Duration picker: horizontal scroll, tap to select
- Gallery: opens device gallery for upload
- Music: opens sound picker (pre-record)
- X: discard and return (confirm dialog)
- **No bottom nav or FAB visible** on camera screen (full-screen takeover)

#### 3d. Video -- Edit/Post Screen

```
+---------------------------------+
| [Back]    Edit     [Next]       |
+---------------------------------+
|       #################         |
|       #  VIDEO       #          |
|       #  PREVIEW     #          |
|       #################         |
|  |||||||||||||||||||||           |  <- timeline scrubber
|                                 |
| [Trim] [Text] [Sticker]        |
| [Filter] [Music] [Speed]       |
+---------------------------------+
| Caption: [                    ] |
| Tags:    [#tag1 #tag2         ] |
| Visibility: [Everyone  v]      |
|         [Post Video]            |
+---------------------------------+
```

**Interactions:**
- Timeline: drag handles to trim start/end
- Text: tap to position text overlay, long-press to edit
- Sticker: opens sticker picker, drag to position
- Filter: horizontal scroll through filter previews
- Music: add/replace audio track
- Speed: 0.5x / 1x / 2x / 3x
- Visibility dropdown: Everyone, Friends Only, Private
- **No bottom nav or FAB visible** (creation flow)

#### 3e. Video -- Creator Profile

```
+---------------------------------+
| [<-]   @creator           [dots]|
+---------------------------------+
|         (Av large)              |
|       Creator Name              |
|    123 Following . 45k Fans     |
|    Bio text here...             |
|   [Follow]  [Message]           |
| --------------------------------|
|  Videos  Liked  Saved           |  <- tabs
| +------+ +------+ +------+     |
| | ###  | | ###  | | ###  |     |  <- 3-column video grid
| | ###  | | ###  | | ###  |     |
| +------+ +------+ +------+     |
| +------+ +------+ +------+     |
| | ###  | | ###  | | ###  |     |
| +------+ +------+ +------+     |
+---------------------------------+
| *ForYou* _Follow_ _Disc_ _Cre_ (F)|
+---------------------------------+
```

**Interactions:**
- Follow/Following: toggle button (confirm on unfollow)
- Message: opens direct chat thread
- Video grid: tap any thumbnail -> full-screen video player
- Tabs: tap or swipe to switch between Videos / Liked / Saved
- dots menu: Report, Block, Copy Link

#### 3f. Video -- Discover/Search (Discover tab)

```
+---------------------------------+
| [Search videos...]              |
+---------------------------------+
| Trending  Music  Comedy  ...    |  <- category chips (scroll)
| --------------------------------|
| +------+ +------+ +------+     |
| | ###  | | ###  | | ###  |     |  <- trending grid
| |>12k  | |>8k   | |>45k  |     |
| +------+ +------+ +------+     |
| +------+ +------+ +------+     |
| | ###  | | ###  | | ###  |     |
| +------+ +------+ +------+     |
+---------------------------------+
| *ForYou* _Follow_ *Disc* _Cre_ (F)|
+---------------------------------+
```

**Interactions:**
- Search bar: tap to focus, shows recent searches + suggestions
- Category chips: horizontal scroll, tap to filter
- Grid thumbnails: tap -> full-screen video playback
- View count overlay on each thumbnail
- Pull to refresh

#### 3g. Video -- Sound/Music Page

```
+---------------------------------+
| [<-]   Sound Detail             |
+---------------------------------+
|  m "Song Title"                 |
|  Artist Name . 1.2M videos     |
|  [Use Sound]  [Save]           |
| --------------------------------|
| +------+ +------+ +------+     |  <- videos using this sound
| | ###  | | ###  | | ###  |     |
| +------+ +------+ +------+     |
+---------------------------------+
| *ForYou* _Follow_ _Disc_ _Cre_ (F)|
+---------------------------------+
```

**Interactions:**
- Use Sound: opens recording screen with this sound pre-loaded
- Save: bookmarks sound to personal library
- Video grid: tap -> play video with this sound
- Audio preview plays automatically on entry (tap to pause)

---

## 4. Dating Module

> **Note:** Dating is deferred from MVP build but fully designed here for future implementation. Card and profile patterns also inform YoYo and Social discovery screens.

### Sub-Feature Tabs (bottom nav when Dating is active)

| Tab | Icon | Screen |
|-----|------|--------|
| **Discover** | `travel_explore` | Card stack (default) |
| **Matches** | `handshake` | Matches list / conversations |
| **Likes** | `thumb_up` | People who liked you |
| **Chat** | `chat_bubble` | Dating-specific conversations |

### Feature -> Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Like profile | Swipe right OR tap heart | Card / button | Card flies right |
| Pass profile | Swipe left OR tap X | Card / button | Card flies left |
| Super like | Swipe up OR tap star | Card / button | Star animation |
| View photos | Swipe left/right on photo | Photo area | 3D flip transition |
| Return to card | Swipe down on enlarged photo | Full-screen | Bounce-back |
| View full profile | Tap card info area | Below photo | Expand card |
| Open chat (match) | Tap match card | Matches tab | Opens chat |
| Boost profile | Via profile settings or in-app prompt | Profile area | 30-min boost |
| Apply filters | Filter icon on Discover tab | Top area | Opens filter sheet |
| Report profile | Long-press card -> Report | Context menu | Report flow |
| Undo last action | Tap undo icon | Top bar area | Restores last card |

### Screens

#### 4a. Dating -- Card Stack (default -- Discover tab)

```
+---------------------------------+
| (YoYo)   Dating          (Av ch)|
+---------------------------------+
| +---------------------------+   |
| | ####################### |   |
| | #   FULL PHOTO          # |   |  <- swipe L/R on photo: flip
| | #                       # |   |  <- swipe L on card: pass
| | #                       # |   |  <- swipe R on card: like
| | ####################### |   |  <- swipe up on card: super
| |         oo...            |   |  <- photo dot indicators (BOTTOM)
| | Sarah, 28           3 mi|   |
| | "Bio text here..."      |   |
| |        check             |   |  <- small red verified badge
| +---------------------------+   |
|    (X)    (Star)    (Heart)     |  <- pass / super like / like
+---------------------------------+
| *Disc* _Match_ _Likes_ _Chat_ (F)|
+---------------------------------+
```

**Interactions:**
- Card swipe right: like (card flies off-screen right with rotation)
- Card swipe left: pass (card flies off-screen left with rotation)
- Card swipe up: super like (star burst animation)
- Photo swipe L/R: 3D flip between photos (NOT card dismiss)
- Tap info area: expand to full profile (4b)
- Photo dots at BOTTOM of photo (Neil's preference -- not top)
- Verified badge: small, red, bottom-positioned
- Next card peeks behind current card (parallax depth)

#### 4b. Dating -- Expanded Profile

```
+---------------------------------+
| [<-]   Profile           [dots]|
+---------------------------------+
| ######################### |  <- full-width photo
| ######################### |
|         oo...              |
| Sarah, 28 . 3 mi . check  |
| --------------------------------|
| About: Bio paragraph...        |
| --------------------------------|
| Interests: [Travel] [Music]    |
| Height: 5'7" . Job: Design     |
| --------------------------------|
| Match: 87%                      |
|    (X)    (Star)    (Heart)     |
+---------------------------------+
| *Disc* _Match_ _Likes_ _Chat_ (F)|
+---------------------------------+
```

**Interactions:**
- Scrollable content below photo
- Photo area: swipe L/R for 3D flip between photos
- Interest chips: tappable (shows shared interests highlighted)
- Match percentage: small, subtle (Neil's preference)
- Action buttons: same swipe/tap behavior as card stack
- <- back: returns to card stack with bounce-back animation

#### 4c. Dating -- It's a Match!

```
+---------------------------------+
|                                 |
|       ** It's a Match! **       |
|                                 |
|    (Av)    Heart    (Av)        |  <- both avatars
|   You       &      Sarah        |
|                                 |
|   [Send Message]                |
|   [Keep Swiping]                |
|                                 |
+---------------------------------+
```

**Interactions:**
- Full-screen overlay with confetti/particle animation
- Send Message: opens chat with match
- Keep Swiping: dismisses overlay, returns to card stack
- Tap outside: same as Keep Swiping
- Avatars animate in from sides and meet in center

#### 4d. Dating -- Matches List (Matches tab)

```
+---------------------------------+
| (YoYo)   Matches         (Av ch)|
+---------------------------------+
| New Matches                     |
| (Av)(Av)(Av)(Av)->              |  <- horizontal scroll
| --------------------------------|
| Messages                        |
| +---------------------------+   |
| | Av Sarah . 2h ago         |   |
| |   Hey! How are you?       |   |
| +---------------------------+   |
| | Av Emma . 1d ago          |   |
| |   That's awesome!         |   |
| +---------------------------+   |
| | Av Lisa . 3d ago          |   |
| |   Let's meet up!          |   |
| +---------------------------+   |
+---------------------------------+
| _Disc_ *Match* _Likes_ _Chat_ (F)|
+---------------------------------+
```

**Interactions:**
- New matches row: horizontal scroll, tap avatar -> chat
- New match avatar: gold ring if unread
- Message list: tap row -> opens conversation (same Chat UI as 8b)
- Swipe left on row: unmatch (with confirmation)
- Pull to refresh

#### 4e. Dating -- Filters Sheet

```
+---------------------------------+
|       Filters        [Done]     |
| --------------------------------|
| Distance:  --o------ 25 mi     |
| Age Range: --o--o--- 22-35     |
| Gender:    [Women v]            |
| --------------------------------|
| Interests:                      |
| [xMusic] [xTravel] [_Art]      |
| [_Sport] [xFood] [_Books]      |
| --------------------------------|
| Show verified only: [_]         |
|         [Apply Filters]         |
+---------------------------------+
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

### Sub-Feature Tabs (bottom nav when Social is active)

| Tab | Icon | Screen |
|-----|------|--------|
| **Stumble** | `shuffle` | Friend discovery feed (default) |
| **Friends** | `group` | Friends list |
| **Events** | `event` | Local events |
| **Post** | `create` | Opens post composer |

### Feature -> Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Like post | Tap heart / double-tap image | Below post / on image | empty -> filled |
| Comment | Tap comment icon | Below post | Opens comments |
| Share | Tap share icon | Below post | Share sheet |
| Create text post | Tap "Post" tab | Bottom nav | Opens composer |
| Create photo post | Via Post tab -> add photo | Composer | Camera/gallery |
| Create video post | Via Post tab -> add video | Composer | Video capture |
| Create event | Via Events tab -> create | Events screen | Event form |
| Stumble (discover) | Default tab / pull to refresh | Stumble tab | Loads random profiles |
| View stories | Tap story avatar | Stories row | Full-screen story |
| Add story | Tap + avatar | Stories row first | Camera/gallery |
| Follow user | Tap Follow button | Profile/post | Follow -> Following |
| View profile | Tap avatar/username | Anywhere | Navigate to profile |
| Report post | Long-press post -> Report | Context menu | Report flow |
| Hide post | Long-press post -> Hide | Context menu | Removes from feed |
| Scroll feed | Vertical scroll | Feed area | Loads more at bottom |

### Screens

#### 5a. Social -- Stumble Feed (default -- Stumble tab)

```
+---------------------------------+
| (YoYo)   Social          (Av ch)|
+---------------------------------+
| (+)(Av)(Av)(Av)(Av)->           |  <- stories row
| --------------------------------|
| Av Alex . 2h ago          [dots]|
| Just had an amazing hike!       |
| ######################### |  <- photo
| ######################### |
| H 234   Ch 18   Sh 5           |
| --------------------------------|
| Av Jordan . 5h ago        [dots]|
| Anyone up for coffee?           |
| H 56    Ch 8    Sh 2           |
| --------------------------------|
+---------------------------------+
| *Stumb* _Friend_ _Event_ _Post_ (F)|
+---------------------------------+
```

**Interactions:**
- Stories row: scroll horizontal, tap avatar -> full-screen story viewer
- (+) (first in row): add your own story (camera/gallery picker)
- Story avatar ring: gradient ring = unwatched, grey = watched
- Post: double-tap image -> like animation
- Post action bar: H like, Ch comment (opens sheet), Sh share
- dots menu: Save, Report, Hide, Copy Link
- Vertical scroll: infinite scroll with loading indicator at bottom

#### 5b. Social -- Stumble Discovery Cards

```
+---------------------------------+
| (YoYo)   Stumble          (Av ch)|
+---------------------------------+
| +---------------------------+   |
| | (Av large)                |   |
| | Alex, 27                  |   |
| | "Adventure seeker"        |   |
| | 12 mutual friends         |   |
| | 5 mi away                 |   |
| |  [Wave]       [Skip ->]  |   |
| +---------------------------+   |
|                                 |
| +---------------------------+   |  <- next card peek
| | (Av)                      |   |
| +---------------------------+   |
+---------------------------------+
| *Stumb* _Friend_ _Event_ _Post_ (F)|
+---------------------------------+
```

**Interactions:**
- Card-based discovery (similar to Dating but for friend finding)
- Wave: sends a friend request / interest signal
- Skip: dismisses card (slides away)
- Tap card: expand to full profile
- Mutual friends: tap count -> shows shared connections
- Pull to refresh: loads new batch of profiles

#### 5c. Social -- Post Composer (via Post tab)

```
+---------------------------------+
| [Cancel]  New Post       [Post] |
+---------------------------------+
| Av What's on your mind?        |
|                                 |
| [                              ]|  <- text area (auto-expand)
|                                 |
| --------------------------------|
| ###### ######                   |  <- attached media preview
| [X]    [X]                      |
| --------------------------------|
| [Photo] [Video]                 |
| [Location] [Tag]                |
| [Privacy: Friends v]            |
+---------------------------------+
| Post type: [Normal v]           |  <- Normal / Notice / Alert
+---------------------------------+
```

**Interactions:**
- Text area: auto-expanding, supports @mentions and #hashtags
- Photo/Video: opens picker (multiple selection)
- Attached media: tap to preview full-size, X to remove
- Location: opens map/location search
- Tag: opens friend selector for tagging
- Privacy: Everyone / Friends / Only Me
- Post type: Normal / Notice / Alert (maps to `social_stumble` moduleKey variants)
- Post button: disabled until text or media added
- **No bottom nav or FAB visible** (creation flow, like Video Create)

#### 5d. Social -- Story Viewer

```
+---------------------------------+
| ||||___________________________  |  <- progress bars (story 1/5)
| Av Alex . 4h ago               |
+---------------------------------+
|                                 |
|       #################         |
|       #  FULL-SCREEN  #         |
|       #  STORY        #         |  <- tap left: prev
|       #  CONTENT      #         |  <- tap right: next
|       #               #         |  <- hold: pause
|       #################         |  <- swipe up: reply
|                                 |
+---------------------------------+
| [Reply to Alex...]        [Sh] |
+---------------------------------+
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

#### 5e. Social -- Friends List (Friends tab)

```
+---------------------------------+
| (YoYo)   Friends         (Av ch)|
+---------------------------------+
| [Search friends...]             |
| --------------------------------|
| Online Now                      |
| Av Sarah . Active now           |
| Av Mike . Active now            |
| --------------------------------|
| All Friends (234)               |
| Av Alex . Last seen 2h         |
| Av Jordan . Last seen 1d       |
| Av Emma . Last seen 3d         |
| ...                             |
+---------------------------------+
| _Stumb_ *Friend* _Event_ _Post_ (F)|
+---------------------------------+
```

**Interactions:**
- Search: filter friends by name
- Online section: sorted by most recently active
- Tap friend row: opens their profile
- Long-press row: Quick actions (Message, Remove, Block)
- Green dot: online now indicator

#### 5f. Social -- Events (Events tab)

```
+---------------------------------+
| (YoYo)   Events          (Av ch)|
+---------------------------------+
| Upcoming                        |
| +---------------------------+   |
| | #### Saturday BBQ         |   |
| | #### Mar 15 . 4 PM       |   |
| |      12 going . 3 mi     |   |
| |      [Interested] [Go]   |   |
| +---------------------------+   |
| +---------------------------+   |
| | #### Music Night          |   |
| | #### Mar 20 . 8 PM       |   |
| |      45 going . 8 mi     |   |
| +---------------------------+   |
+---------------------------------+
| _Stumb_ _Friend_ *Event* _Post_ (F)|
+---------------------------------+
```

**Interactions:**
- Event cards: tap to expand full detail
- Interested: adds to your events, notifies before start
- Going: confirms attendance, adds to calendar
- Thumbnail: event cover image
- Distance shown for location-based events
- Attendee count: tap -> see who's going

---

## 6. Shop (Buy & Sell) Module

### Sub-Feature Tabs (bottom nav when Market is active)

| Tab | Icon | Screen |
|-----|------|--------|
| **Browse** | `shopping_bag` | Product grid (default) |
| **Deals** | `local_offer` | Discounts/promoted items |
| **Sell** | `sell` | Opens listing creation form |
| **Messages** | `forum` | Shop-specific conversations |

### Feature -> Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Browse products | Scroll grid | Main area | 2-column grid |
| Search | Tap search bar | Top | Opens search |
| Filter categories | Tap chip / filter icon | Below search | Active chip highlighted |
| View product | Tap product card | Grid | Navigate to detail |
| Save/wishlist | Tap heart on card | Product card corner | empty -> filled |
| Buy now | Tap Buy button | Product detail | Opens checkout |
| Make offer | Tap Make Offer | Product detail | Opens offer sheet |
| Bid (auction) | Tap Place Bid | Auction detail | Opens bid entry |
| Message seller | Tap Message | Product detail | Opens chat |
| List item | Tap "Sell" tab | Bottom nav | Opens listing form |
| Share listing | Tap share icon | Product detail | Share sheet |
| Report listing | Long-press -> Report | Context menu | Report flow |
| View seller | Tap seller name/avatar | Product detail | Seller profile |
| Pull to refresh | Pull down | Grid | Refreshes listings |

### Screens

#### 6a. Shop -- Browse (default -- Browse tab)

```
+---------------------------------+
| (YoYo)    Shop           (Av ch)|
+---------------------------------+
| [Search products...]            |
| All  Vintage  Fashion  Tech     |  <- category chips (scroll)
| --------------------------------|
| +----------+ +----------+      |
| | ########| | ########|      |  <- 2-col product grid
| | Vintage  | | Sneakers |      |
| | Lamp     | | Nike Air |      |
| | L35   H  | | L120  H  |      |
| | Av 2 mi  | | Av 5 mi  |      |
| +----------+ +----------+      |
| +----------+ +----------+      |
| | ########| | ########|      |
| | Guitar   | | Jacket   |      |
| | L250  H  | | L45   H  |      |
| +----------+ +----------+      |
+---------------------------------+
| *Browse* _Deals_ _Sell_ _Msgs_ (F)|
+---------------------------------+
```

**Interactions:**
- 2-column masonry grid (images vary in height)
- Category chips: horizontal scroll, active chip filled
- Product card: tap -> product detail (6b)
- Heart icon: tap to save/unsave
- Seller avatar + distance: tap -> seller profile
- Pull to refresh
- Infinite scroll at bottom

#### 6b. Shop -- Product Detail

```
+---------------------------------+
| [<-]   Product        [Sh][H]  |
+---------------------------------+
| ######################### |  <- swipeable photo gallery
| ######################### |
| ######################### |
|           oo...            |
| --------------------------------|
| Vintage Lamp                    |
| L35.00  . Condition: Good      |
| --------------------------------|
| Av Seller Name . Star 4.8      |
|    2 mi away . 23 listings     |
| --------------------------------|
| Description text here...        |
| Category: Home & Garden         |
| Posted: 2 days ago              |
| --------------------------------|
| [Message Seller] [Buy L35]     |
|          OR                     |
|     [Make an Offer]             |
+---------------------------------+
| *Browse* _Deals_ _Sell_ _Msgs_ (F)|
+---------------------------------+
```

**Interactions:**
- Photo gallery: horizontal swipe, tap to view full-screen
- Dot indicators below gallery
- Share: opens platform share sheet
- Heart: toggle wishlist
- Seller row: tap -> seller profile (6e)
- Message Seller: opens chat thread (tagged with listing context)
- Buy: opens payment/checkout flow
- Make an Offer: opens bottom sheet with price input
- Scrollable content

#### 6c. Shop -- Auction Detail

```
+---------------------------------+
| [<-]   Auction        [Sh][H]  |
+---------------------------------+
| ######################### |
|           oo..             |
| --------------------------------|
| Signed Football Jersey          |
| Current bid: L180               |
| Timer Ends in: 2h 34m          |  <- live countdown timer
| 12 bids . 45 watchers          |
| --------------------------------|
| Av Seller . Star 4.9           |
| --------------------------------|
| Bid History:                    |
|  L180 . user3 . 10m ago        |
|  L165 . user7 . 25m ago        |
|  L150 . user1 . 1h ago         |
| --------------------------------|
| [Place Bid: L185+]             |
+---------------------------------+
| *Browse* _Deals_ _Sell_ _Msgs_ (F)|
+---------------------------------+
```

**Interactions:**
- Live countdown timer: updates every second, highlights red when < 5 min
- Place Bid: opens bottom sheet with bid amount input (minimum = current + increment)
- Bid history: scrollable list, tap username -> profile
- Watcher count: tap -> see who's watching
- Real-time bid updates via WebSocket
- Notification when outbid

#### 6d. Shop -- Create Listing (via Sell tab)

```
+---------------------------------+
| [Cancel] New Listing     [Post] |
+---------------------------------+
| [Camera Add Photos (0/10)]     |
| --------------------------------|
| Title: [                      ] |
| Price: [L        ]              |
| Condition: [New v]              |
| Category: [Select v]            |
| --------------------------------|
| Description:                    |
| [                              ]|
| [                              ]|
| --------------------------------|
| Listing type:                   |
| (o) Fixed Price                 |
| ( ) Auction                     |
| ( ) Wanted                      |
| --------------------------------|
| Location: [Pin Use current]     |
| Delivery: [x Collection]        |
|           [x Shipping]          |
+---------------------------------+
|         [List Item]             |
+---------------------------------+
```

**Interactions:**
- Add Photos: opens gallery (multi-select up to 10), drag to reorder
- Photo strip: horizontal scroll of added photos, tap X to remove, first photo = cover
- Condition dropdown: New / Like New / Good / Fair / For Parts
- Category: opens full category browser
- Listing type radio: changes form fields (Auction adds start price, duration, reserve)
- Location: pre-fills with current location, tap to change on map
- Delivery: checkboxes (at least one required)
- Post/List Item: validates all required fields, shows progress overlay
- **No bottom nav or FAB visible** (creation flow)

#### 6e. Shop -- Seller Profile

```
+---------------------------------+
| [<-]   Seller            [dots]|
+---------------------------------+
|         (Av large)              |
|       Seller Name               |
|    Star 4.8 . 23 listings      |
|    Member since Jan 2025        |
|   [Message]  [Follow]           |
| --------------------------------|
|  Active   Sold   Reviews        |  <- tabs
| +----------+ +----------+      |
| | ########| | ########|      |
| | Item 1   | | Item 2   |      |
| | L35      | | L120     |      |
| +----------+ +----------+      |
+---------------------------------+
| *Browse* _Deals_ _Sell_ _Msgs_ (F)|
+---------------------------------+
```

**Interactions:**
- Tabs: Active listings / Sold items / Reviews
- Active grid: same 2-column layout as browse, tap -> product detail
- Sold: greyed-out listings with sold price
- Reviews: star rating + text reviews from buyers
- Message: opens chat thread
- Follow: get notified of new listings from this seller
- dots menu: Report, Block, Copy Link

---

## 7. YoYo (Nearby)

### Sub-Feature Tabs (bottom nav when YoYo is active)

| Tab | Icon | Screen |
|-----|------|--------|
| **Nearby** | `near_me` | Nearby user list (default) |
| **Connect** | `link` | Pending connections / requests |
| **Wave** | `waving_hand` | Broadcast wave to nearby users |
| **Chat** | `chat` | YoYo-specific conversations |

> **Promotion from Set B:** In Set B, YoYo was only accessible via the top-left icon. In Set C, YoYo is a full first-class service with its own 4 sub-feature tabs and appears in the service switcher FAB popup.

### Feature -> Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| View nearby list | Scroll list | Main area | Vertical list (NOT grid) |
| View profile | Tap user card | List item | Opens profile |
| Wave at user | Tap Wave button on card | Card action | Sends wave notification |
| Broadcast wave | Tap "Wave" tab | Bottom nav | Sends wave to all nearby |
| Ghost mode | Via settings (gear icon) | Top area | Hides from nearby |
| Set range | Via settings (gear icon) | Top area | Opens range slider |
| Sort by distance | Default sort | List | Closest first |
| Filter nearby | Tap filter icon | Top-right | Opens filter sheet |
| Refresh | Pull to refresh | List | Re-scans nearby |

> **Neil's requirement:** List view, NOT grid. "Grid looks like the back of a T-shirt in a pound shop." Clean cards with space, not cramped tiles.

### Screens

#### 7a. YoYo -- Nearby List (default -- Nearby tab)

```
+---------------------------------+
| (YoYo)   Nearby          (Av ch)|
+---------------------------------+
| 12 people nearby          [Gear]|  <- count + filter/settings
| --------------------------------|
| +---------------------------+   |
| | (Av) Sarah, 28            |   |
| |      "Adventure time"     |   |
| |      0.3 mi . Green now   |   |  <- online: green
| |               [Wave]      |   |
| +---------------------------+   |
| +---------------------------+   |
| | (Av) Mike, 31             |   |
| |      "Coffee lover"       |   |
| |      0.8 mi . Yellow 5m   |   |  <- recently: yellow
| |               [Wave]      |   |
| +---------------------------+   |
| +---------------------------+   |
| | (Av) Emma, 25             |   |
| |      1.2 mi . Grey 1h    |   |  <- inactive: grey
| |               [Wave]      |   |
| +---------------------------+   |
+---------------------------------+
| *Near* _Conn_ _Wave_ _Chat_ (F)|
+---------------------------------+
```

**Interactions:**
- Vertical list (NOT grid) -- one card per row with generous spacing
- Sorted by distance (closest first)
- Online indicators: Green active now, Yellow active within 15m, Grey last seen time
- Wave button: sends push notification to that user
- Tap card: opens user profile (7c)
- Pull to refresh: re-scans nearby users
- Settings icon (Gear): opens range/filter controls and ghost mode toggle
- List updates in real-time as users move

#### 7b. YoYo -- Settings/Controls (via Gear icon)

```
+---------------------------------+
|       YoYo Settings      [Done]|
| --------------------------------|
| Ghost Mode:    [Off]            |  <- toggle: hides you from others
| --------------------------------|
| Discovery Range:                |
| --o---------- 5 mi             |  <- slider: 0.5mi - 25mi
| --------------------------------|
| Show:                           |
| [x] Everyone                    |
| [_] Friends only                |
| [_] Same interests              |
| --------------------------------|
|         [Save Settings]         |
+---------------------------------+
```

**Interactions:**
- Bottom sheet overlay
- Ghost mode toggle: hides you from nearby lists, ghost particle animation on enable
- Range slider: adjust discovery radius (0.5mi - 25mi)
- Show filters: radio or multi-select for who appears in nearby list
- Done/Save: closes sheet, applies settings immediately

#### 7c. YoYo -- User Profile (from nearby)

```
+---------------------------------+
| [<-]   Sarah             [dots]|
+---------------------------------+
| ######################### |
| ######################### |  <- swipe for photos (3D flip)
|         oo..               |
| Sarah, 28 . 0.3 mi . check|
| "Adventure seeker & ..."   |
| --------------------------------|
| Interests: [Travel] [Music]    |
| --------------------------------|
| [Wave]          [Message]      |
+---------------------------------+
| *Near* _Conn_ _Wave_ _Chat_ (F)|
+---------------------------------+
```

**Interactions:**
- Photo area: swipe L/R with 3D flip transition (Neil's requirement)
- Photo dots: bottom of photo area
- Wave: sends notification (button changes to "Waved" after tap)
- Message: opens direct chat thread
- Interest chips: tappable (shows if you share them)
- dots menu: Report, Block
- Verified badge (check): small, red, bottom-positioned
- <- back: returns to nearby list with slide transition

---

## 8. Chat

Chat is integrated -- accessible from Profile area, message badge on top bar, and within Dating/YoYo/Market sub-feature tabs. All chat threads are unified regardless of module origin but can also be accessed per-service via their "Chat" or "Messages" sub-feature tab.

### Feature -> Affordance Table

| Feature | Affordance | Location | State |
|---------|-----------|----------|-------|
| Open inbox | Tap chat icon / profile badge | Top bar | Navigate to inbox |
| Open conversation | Tap conversation | Inbox list | Opens thread |
| Send message | Type + tap Send | Input bar | Message sent |
| Send photo | Tap camera icon | Input bar | Opens camera/gallery |
| Send voice | Hold mic icon | Input bar | Records voice note |
| React to message | Long-press message | Message bubble | Emoji picker |
| Delete message | Long-press -> Delete | Context menu | Removes message |
| Block user | Tap dots -> Block | Chat header | Blocks + removes |
| Video call | Tap video icon | Chat header | Opens call |
| Voice call | Tap phone icon | Chat header | Opens call |

### Screens

#### 8a. Chat -- Inbox

```
+---------------------------------+
| [<-]   Messages                 |
+---------------------------------+
| [Search conversations...]       |
| --------------------------------|
| Av Sarah . 2m ago         [dot]|  <- unread dot
|   Hey! How's it going?          |
| --------------------------------|
| Av Mike . 1h ago                |
|   Thanks for the wave!          |  <- YoYo context
| --------------------------------|
| Av Alex . 3h ago                |
|   Is the lamp still avail?      |  <- Shop context
| --------------------------------|
| Av Emma . 1d ago                |
|   See you at the event!         |  <- Social context
| --------------------------------|
+---------------------------------+
```

**Interactions:**
- Conversations sorted by most recent message
- Unread indicator: blue dot on right
- Tap row: opens conversation (8b)
- Swipe left on row: Archive, Mute, Delete
- Search: filters conversations by contact name or message content
- Context tag: subtle indicator showing which module originated the thread
- **Note:** The Chat Inbox is a standalone screen without bottom nav (push from profile or top bar). Per-service chat tabs (Dating Chat, YoYo Chat, Market Messages) show filtered views of the same inbox with bottom nav visible.

#### 8b. Chat -- Conversation

```
+---------------------------------+
| [<-] Av Sarah  [Phone][Vid][dots]|
+---------------------------------+
|        Today                    |
|                                 |
| +----------------+              |
| | Hey! How's     |              |  <- their message (left-aligned)
| | it going?      |  2:30 PM    |
| +----------------+              |
|                                 |
|            +----------------+   |
|  3:15 PM   | Great! Just    |   |  <- your message (right-aligned)
|            | got back from  |   |
|            | a hike         |   |
|            +----------------+   |
|                                 |
| +----------------+              |
| | That sounds    |              |
| | amazing!       |  3:16 PM    |
| +----------------+              |
|                                 |
+---------------------------------+
| [Camera] [Type message...] [>] |
+---------------------------------+
```

**Interactions:**
- Messages: left-aligned (theirs), right-aligned (yours)
- Long-press message: React (emoji), Reply, Copy, Delete
- Input bar: text input with auto-growing height
- Camera icon: opens camera/gallery for photo/video message
- Hold mic icon (replaces send when input empty): records voice note
- Send (>): sends message, scrolls to bottom
- Phone = Voice call, Vid = Video call
- dots menu: Mute, Block, Clear History, View Profile
- Typing indicator: "Sarah is typing..." shown above input
- Read receipts: double-tick on sent messages

---

## 9. Profile & Settings

### Screens

#### 9a. Profile -- My Profile

```
+---------------------------------+
| [<-]   My Profile        [Edit]|
+---------------------------------+
|         (Av large)              |
|       Your Name                 |
|    @username . check Verified   |
| --------------------------------|
| +-----+ +-----+ +-----+       |
| | 234  | | 567  | | 89  |      |
| |Posts | |Foll.| |Foll.|      |
| +-----+ +-----+ +-----+       |
| --------------------------------|
| [Chat Messages]            12   |  <- chat home
| [Shop My Listings]          5   |
| [Heart Saved Items]        23   |
| [Activity]                      |
| [Gear Settings]                 |
| [? Help]                        |
+---------------------------------+
```

**Interactions:**
- Stats row: tap any counter -> opens respective list (Posts, Followers, Following)
- Messages: -> Chat Inbox (8a)
- My Listings: -> filtered Shop view (your items only)
- Saved Items: -> saved/wishlisted items and bookmarks across all modules
- Activity: -> notification history (likes, comments, followers, waves)
- Settings: -> Settings screen (9c)
- Edit: -> Edit Profile (9b)
- Profile avatar: tap to view full-size, long-press to change photo
- **No bottom nav or FAB** on profile screen (push navigation)

#### 9b. Profile -- Edit Profile

```
+---------------------------------+
| [Cancel] Edit Profile    [Save]|
+---------------------------------+
|     (Av large) [Change]        |
| --------------------------------|
| Name:    [Your Name           ] |
| Username:[yourname            ] |
| Bio:     [Bio text...         ] |
| --------------------------------|
| Photos:                         |
| +----+ +----+ +----+ [+]      |
| | ## | | ## | | ## |           |
| +----+ +----+ +----+           |
| --------------------------------|
| Interests: [Edit]               |
| [Travel] [Music] [Food]        |
| --------------------------------|
| Location: London, UK [Pin]     |
| Date of Birth: [01/01/1995]    |
+---------------------------------+
```

**Interactions:**
- Change avatar: tap -> camera/gallery picker
- Photos: drag to reorder, tap X to remove, [+] to add (up to 6)
- First photo = primary (used in Dating cards and YoYo list)
- Interests: tap Edit -> opens interest selector (same as onboarding 10c)
- Location: tap Pin -> location picker/map
- Bio: 300 char limit with counter
- Username: validates availability in real-time
- Save: validates all fields, shows toast on success
- Cancel: discards changes (confirm dialog if unsaved changes)

#### 9c. Profile -- Settings

```
+---------------------------------+
| [<-]   Settings                 |
+---------------------------------+
| Account                         |
|  Email . Phone . Password       |
| --------------------------------|
| Privacy                         |
|  Who can see me: [Everyone v]   |
|  Location sharing: [On]         |
|  Online status: [On]            |
| --------------------------------|
| Notifications                   |
|  Push: [On]   Email: [Off]     |
|  YoYo nearby: [On]             |
|  Messages: [On]                 |
| --------------------------------|
| Content                         |
|  Blocked users                  |
|  Content filters                |
| --------------------------------|
| [Log Out]                       |
| [Delete Account]                |
+---------------------------------+
```

**Interactions:**
- Grouped list with section headers
- Account items: tap -> individual edit screens with OTP verification
- Privacy toggles: switch widgets, changes apply immediately
- Notification toggles: switch widgets
- Blocked users: tap -> list with unblock option
- Content filters: tap -> age-appropriate content settings
- Log Out: confirmation dialog, clears session
- Delete Account: multi-step confirmation (type "DELETE" to confirm), 30-day recovery window

---

## 10. Auth Screens

#### 10a. Welcome / Splash

```
+---------------------------------+
|                                 |
|                                 |
|         (KUWBOO LOGO)           |
|                                 |
|    Connect. Discover. Play.     |
|                                 |
|                                 |
|      [Sign Up]                  |
|      [Log In]                   |
|                                 |
|  By continuing you agree to     |
|  Terms & Privacy Policy         |
+---------------------------------+
```

**Interactions:**
- Logo: animated entrance (scale + fade)
- Sign Up: -> Sign Up flow (10b)
- Log In: -> Log In screen (phone + OTP)
- Terms / Privacy Policy: tappable links -> in-app webview
- No bottom nav bar or FAB on auth screens

#### 10b. Sign Up

```
+---------------------------------+
| [<-]   Sign Up                  |
+---------------------------------+
| Phone: [+44                ]    |
|        [Send OTP]               |
| --------------------------------|
| OTP:   [_ _ _ _]               |
| --------------------------------|
| Name:  [                   ]    |
| DOB:   [DD/MM/YYYY        ]    |
| --------------------------------|
| Photo: [Camera Add Profile Pic] |
| --------------------------------|
|        [Continue ->]            |
|                                 |
| Already have an account?        |
| [Log In]                        |
+---------------------------------+
```

**Interactions:**
- Phone: country code picker + number input
- Send OTP: validates number format, sends SMS
- OTP: 4-digit auto-advance input (auto-fills from SMS on iOS/Android)
- Name: required field
- DOB: date picker (enforces 18+ minimum)
- Photo: optional but encouraged (camera/gallery)
- Continue: -> Onboarding interests (10c)
- Log In link: -> existing user login screen

> **Dev note:** All OTPs default to `4444` in development mode (`NODE_ENV=development`)

#### 10c. Onboarding -- Interests

```
+---------------------------------+
| [<-]  Pick Your Interests       |
+---------------------------------+
| Choose 3 or more:               |
|                                 |
| [xTravel] [xMusic] [_Food]     |
| [_Sport]  [_Art]    [xBooks]   |
| [_Film]   [_Gaming] [_Nature]  |
| [_Tech]   [_Fashion][_Pets]    |
| [_Comedy] [_Dance]  [_Fitness] |
|                                 |
| --------------------------------|
| Selected: 3/15                  |
|                                 |
|      [Get Started ->]           |
+---------------------------------+
```

**Interactions:**
- Chip grid: tap to toggle selection (with subtle scale animation)
- Selected chips: filled/highlighted state
- Counter: updates in real-time
- Get Started: enabled when 3+ selected
- <- back: keeps selections (not destructive)
- After completion: navigates to Video feed (default home service)

---

## 11. Sponsored Content

Sponsored content is non-intrusive and blends into native feeds. Uses the same visual patterns as organic content with a subtle sponsor label.

```
+---------------------------------+
| Sponsored . [Ad]                |  <- subtle label
| Av Brand Name                   |
| ######################### |
| Ad copy text here...            |
| [Learn More]  [Hide Ad]        |
| --------------------------------|
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
| **FAB expand (service popup)** | **Scale up + staggered fan** | **250ms** | **easeOutBack** |
| **FAB collapse** | **Scale down + converge** | **250ms (reverse)** | **easeOutBack (reverse)** |
| **FAB icon rotation** | **Rotate 0.75 rad** | **250ms** | **easeOutBack** |
| **Service popup item enter** | **Scale 0->1 + fade 0->1** | **250ms (staggered 0.12 per item)** | **easeOutBack** |
| Tab switch (bottom nav) | Cross-fade | 200ms | easeInOut |
| Bottom sheet open | Slide up + dim overlay | 250ms | easeOutCubic |
| Bottom sheet close | Slide down | 200ms | easeIn |
| Like (heart) | Scale pulse 1.0->1.3->1.0 | 300ms | easeOutBack |
| Pull to refresh | Rubber-band stretch | physics | spring |
| Page navigate | Slide from right | 300ms | easeOutCubic |
| Page dismiss | Slide to right | 250ms | easeIn |
| Story progress | Linear fill | 5s/story | linear |
| Notification badge | Bounce in | 400ms | bounceOut |
| Double-tap like | Heart burst particles | 600ms | easeOut |
| Card stack (Dating) | Parallax depth on next card | -- | spring |
| Ghost mode toggle | Fade + ghost particles | 400ms | easeInOut |
| Match overlay | Avatars slide in from edges | 500ms | easeOutBack |
| Confetti (Match!) | Particle burst | 2000ms | gravity |
| Success toast | Slide in + fade | 300ms in, 200ms out | easeOutCubic / easeIn |
| Error shake | Horizontal oscillation (3 cycles) | 400ms | easeInOut |
| Ripple effect | Expanding circle from touch point | 350ms | easeOut |
| Image lazy-load | Fade in from 0->1 opacity | 300ms | easeOut |
| Number roll (bid update) | Digit counter scroll | 400ms | easeOutCubic |
| Nearby card arrival | Slide in from top + fade | 350ms | easeOutBack |
| In-app notification banner | Slide down from top + auto-dismiss | 300ms in, 4s hold, 200ms out | easeOutCubic / easeIn |
| **Scrim overlay (FAB popup)** | **Fade in black 30% opacity** | **250ms** | **easeInOut** |

### Animation Principles (from Neil)

- "The small things make it magical" -- micro-interactions are a priority
- Physics-based movement, never mechanical
- Transparent/semi-transparent buttons layered over images
- Nothing should feel jarring or abrupt
- Loading states should feel alive (pulsing placeholders, not just spinners)
- Transitions between screens should feel connected, not like page loads

---

## 13. Micro-Interactions Catalogue

> *"The small things make it magical"* -- Neil Douglas

This catalogue consolidates every micro-interaction across all modules into a single canonical reference. Section 12 defines the **timing constants** (duration, curve); this section defines the **interaction patterns** (trigger, behaviour, feedback, and where they're used). Together they form the complete interaction specification for designers and developers.

**Pattern IDs:** G = Gesture, V = Visual Feedback, L = Loading & Progress, N = Notification & Status, T = Transition & Reveal

---

### 13a. Gesture-Based Interactions (17 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| G1 | Card swipe dismiss | Pan gesture on card (horizontal) | Card translates + rotates proportional to drag distance; commits when velocity threshold met, else elastic return | Card flies off-screen with rotation; next card scales up from behind | Card dismiss (Dating) | Dating card stack (4a), Social stumble (5b) |
| G2 | Card swipe-up super action | Pan gesture on card (upward) | Card lifts vertically with slight scale-up | Star burst particle animation at card center | -- (uses Double-tap like particle system) | Dating card stack (4a) |
| G3 | Double-tap to like | Two taps within 300ms on content area | Heart icon spawns at tap point, scales up, then fades with particles | Heart burst particles radiate outward; like counter increments | Double-tap like | Video feed (3a), Social feed (5a) |
| G4 | Long-press context menu | Press and hold >=500ms on content item | Dim overlay fades in; menu slides up from bottom or appears at touch point | Light haptic on menu appearance; background blur | Bottom sheet open | Video (3a, 3b), Social (5a), Chat (8b), Shop (6b) |
| G5 | **Tap FAB to expand services** | **Single tap on service switcher FAB** | **5 service options fan upward with staggered animation (50ms per item); scrim overlay fades in** | **FAB rotates 0.75 rad; icon changes to close (X)** | **FAB expand, Service popup items** | **All screens with bottom nav (2c)** |
| G6 | Pull to refresh | Drag down past threshold at scroll top | Branded loader animates (Kuwboo logo spin, not generic spinner); rubber-band stretch physics | Content fades in from top as new data loads | Pull to refresh | Video discover (3f), Dating matches (4d), Shop browse (6a), YoYo nearby (7a), Social stumble (5b) |
| G7 | 3D photo flip | Horizontal swipe on photo area within a card/profile | Photo rotates around Y-axis revealing next photo; perspective transform gives depth | Next photo resolves during flip; dot indicators update | Photo swipe (Dating/YoYo) | Dating card (4a), Dating profile (4b), YoYo user profile (7c) |
| G8 | Swipe to archive/delete | Horizontal swipe on list row (left) | Row slides to reveal action buttons (Archive, Mute, Delete) | Red/orange background reveals behind row; icons slide in | -- | Chat inbox (8a), Dating matches (4d) |
| G9 | Tap to toggle (like/save/follow) | Single tap on action icon | Icon swaps state (outline -> filled) with scale pulse 1.0->1.3->1.0 | Light haptic; counter increments/decrements smoothly | Like (heart) | Video feed (3a), Social feed (5a), Shop product (6b), Shop browse (6a) |
| G10 | Hold to record | Press and hold record button | Progress ring fills around button proportional to hold duration; camera active | Release ends recording; ring completes with success haptic | -- | Video recording (3c) |
| G11 | Drag to reorder | Long-press then drag on item in list/grid | Item lifts (scale 1.05, shadow increases); other items shift to make room | Drop shadow follows finger; items animate to new positions on release | -- | Shop create listing photos (6d), Profile edit photos (9b) |
| G12 | Interest chip tap | Single tap on chip in grid/row | Chip toggles selected state with scale bounce (1.0->1.15->1.0) | Fill colour changes; selection counter updates | -- | Dating filters (4e), Dating profile (4b), Onboarding (10c), Profile edit (9b), YoYo profile (7c) |
| G13 | Bottom sheet drag dismiss | Drag down on sheet handle when sheet is open | Sheet follows finger with resistance; commits dismiss past 40% threshold | Sheet slides down and overlay fades; content behind un-dims | Bottom sheet close | Video comments (3b), Dating filters (4e), Shop offer input, Chat context menus |
| G14 | Card bounce-back | Incomplete swipe (below velocity/distance threshold) on card | Card returns to center position with elastic overshoot | Spring physics; next card settles back to peek position | Bounce-back | Dating card stack (4a), Dating profile back (4b) |
| G15 | Pinch to zoom | Two-finger pinch outward on photo | Photo scales from pinch center; max 3x; translates to follow gesture center | Release snaps back to fit with spring animation | -- | Shop product photos (6b), Profile photos, Chat photo messages |
| G16 | Story tap navigate | Tap on left/right third of story viewer | Left tap: previous story segment; right tap: next segment | Progress bar jumps; story content cross-fades | Story progress | Social story viewer (5d) |
| G17 | Story hold to pause | Press and hold on story content | Progress bar pauses; playback freezes | Release resumes from same point; no haptic (intentionally silent) | Story progress | Social story viewer (5d) |

**Set C changes from Set B:**
- **G5 replaced:** Was "Long-press FAB speed dial" -> Now "Tap FAB to expand services". Trigger changed from long-press to single tap. Behaviour changed from 3 module-specific speed dial options to 5 service bubbles. No longer requires learning hint tooltip.
- **Removed:** Learning hint tooltip pattern (N7 in Set B) -- no longer needed since the FAB is a simple tap, not long-press

---

### 13b. Visual Feedback (14 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| V1 | Heart burst | Double-tap on content OR tap heart icon | Heart icon scales up at interaction point; 8-12 smaller hearts radiate outward with gravity | Particles fade after 600ms; hearts drift and rotate as they fall | Double-tap like | Video feed (3a), Social feed (5a) |
| V2 | Star burst | Swipe up on dating card OR tap star button | Star icon expands from card center; golden sparkle particles radiate in all directions | Star scales 1.0->2.0->0 while particles cascade; blue/gold colour scheme | -- | Dating card stack (4a) |
| V3 | Confetti | Match detected between two users | Full-screen particle burst: multi-coloured confetti rectangles fall with gravity and rotation | Particles obey gravity physics; duration 2s; fades gradually | Confetti (Match!) | Dating match overlay (4c) |
| V4 | Ghost particles | Ghost mode toggled on | Semi-transparent particles drift upward from user avatar, fading as they rise | Opacity 0.3->0.0 over 400ms; creates ethereal "vanishing" effect | Ghost mode toggle | YoYo settings (7b), YoYo nearby list (7a) |
| V5 | Follow button morph | Tap Follow/Following button | Button label cross-fades; width animates to fit new text; colour transitions | "Follow" (outline) -> "Following" (filled) with smooth morph | -- | Video creator profile (3e), Social profiles, Shop seller (6e), YoYo profile (7c) |
| V6 | **FAB service icon cross-fade** | **Service switch via FAB popup** | **Current FAB icon fades out while new service icon fades in; 200ms overlap** | **No position change; icon morphs in place; bottom nav tabs update simultaneously** | **Tab switch** | **Service switcher FAB (2c) -- all service switches** |
| V7 | Auction timer urgency | Timer drops below 5 minutes remaining | Timer text transitions from default colour to red; pulse animation begins | Pulse rate increases as time decreases: 2s->1s->0.5s intervals | -- | Shop auction detail (6c) |
| V8 | Chip selection scale | Interest/category chip tapped | Chip scales 1.0->1.15->1.0 over 200ms; fill colour transitions | Bouncy scale gives tactile feel without haptics | -- | Dating filters (4e), Onboarding (10c), Video discover chips (3f), Shop category chips (6a) |
| V9 | Success toast | Action completed successfully (save, post, send) | Toast slides in from bottom, holds 4s, slides out; green accent | Non-blocking; dismissible with swipe; stacks if multiple | Success toast | Profile save (9b), Shop listing posted (6d), Post published (5c) |
| V10 | Error shake | Validation failure or rejected action | Element shakes horizontally (3 cycles, +/-8px) over 400ms | Red border flash on affected field; error message fades in below | Error shake | Auth OTP (10b), Shop bid too low (6c), Profile username taken (9b) |
| V11 | Ripple effect | Tap on any button or interactive surface | Circle expands from touch point outward, fading as it grows | Material-style ripple; colour matches element theme | Ripple effect | All tappable surfaces (global) |
| V12 | Story ring gradient | Story avatar has unwatched content | Animated gradient ring rotates around avatar (rainbow/brand colours) | Ring changes to solid grey after all segments viewed | -- | Social stories row (5a), Social story viewer (5d) |
| V13 | Unread dot pulse | New unread message or notification | Small dot appears with bounce-in; gentle pulse (scale 1.0->1.2->1.0, 2s loop) | Dot disappears when content is read; no abrupt removal (fade out) | Notification badge | Chat inbox (8a), Top bar badges (2a), Dating matches (4d) |
| V14 | Photo indicator dots | Multiple photos in a gallery/card | Dots at BOTTOM of photo area; active dot filled, others hollow | Dots transition smoothly as photos change (slide or flip) | -- | Dating card (4a), Dating profile (4b), Shop product (6b), YoYo profile (7c) |

---

### 13c. Loading & Progress (8 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| L1 | Skeleton shimmer | Content area loading (initial or navigation) | Grey placeholder shapes match content layout; shimmer gradient sweeps left->right continuously | Shapes resolve into real content with fade-in; shimmer stops | -- | All feeds (3a, 5a, 6a), Chat inbox (8a), Profile (9a) |
| L2 | Pull-to-refresh indicator | User drags past scroll-top threshold | Branded loader appears (Kuwboo logo rotation, not a generic spinner); rubber-band physics on overscroll | Loader dismisses when data arrives; content slides in from top | Pull to refresh | Video discover (3f), Dating matches (4d), Shop browse (6a), YoYo nearby (7a), Social feed (5a) |
| L3 | Progress ring | Hold-to-record or upload in progress | Circular ring fills clockwise around trigger element; stroke width 3pt | Completes to full circle on finish; incomplete if cancelled mid-way | -- | Video recording (3c), Profile photo upload (9b) |
| L4 | Story progress bar | Story segment playing | Thin horizontal bar fills left->right over segment duration (default 5s) | Bar completes -> next segment bar begins; pauses on hold (G17) | Story progress | Social story viewer (5d) |
| L5 | Upload progress overlay | Media upload in progress (photo, video, listing) | Semi-transparent overlay on content with circular progress indicator and percentage text | Overlay dismisses on completion; success toast (V9) follows | -- | Video edit/post (3d), Shop create listing (6d), Social composer (5c) |
| L6 | Infinite scroll loader | User scrolls near bottom of feed (within 3 items of end) | Small loading spinner appears below last item; next batch appends when ready | Spinner dismisses; new items fade in from below | -- | Video feed (3a), Social feed (5a), Shop browse (6a), Chat inbox (8a) |
| L7 | Image lazy-load fade-in | Image enters viewport during scroll | Image fades from transparent->opaque over 300ms once loaded | Prevents layout shift; placeholder maintains aspect ratio | Image lazy-load | All image grids (3f, 5a, 6a), Profile galleries |
| L8 | Real-time bid update (number roll) | New bid received via WebSocket | Current bid number scrolls upward like a counter; new number scrolls in from below | Bid count increments; watcher count may also update | Number roll (bid update) | Shop auction detail (6c) |

---

### 13d. Notification & Status (8 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| N1 | Badge bounce-in | New notification/message received while in app | Badge number appears with overshoot bounce (scale 0->1.3->1.0) | Number increments if badge already visible; no bounce on increment | Notification badge | Top bar (2a), Sub-feature tabs (2b), Dating matches (4d) |
| N2 | Typing indicator | Other user is composing a message | Three dots animate in sequence (opacity pulse left->right, looping) | Appears above input bar; dismisses when user stops typing or sends | -- | Chat conversation (8b) |
| N3 | Read receipts | Sent message has been read by recipient | Single tick (sent) -> double tick (delivered) -> blue double tick (read) | Tick transition is subtle fade/colour change, not abrupt swap | -- | Chat conversation (8b) |
| N4 | Online status indicator | User is currently active in the app | Green dot next to avatar; Green online, Yellow recent (within 15m), Grey inactive | Dot transitions smoothly between states (colour fade) | -- | YoYo nearby (7a), Social friends (5e), Chat inbox (8a) |
| N5 | Wave sent confirmation | User taps Wave button on nearby user card | Button text morphs "Wave" -> "Waved"; button becomes disabled state | Light haptic on send; button colour desaturates | -- | YoYo nearby (7a), YoYo profile (7c) |
| N6 | Match notification badge | New dating match detected | Gold ring animates around match avatar in matches row; badge bounces in | Ring pulses gently until tapped; dismisses after viewing | Notification badge | Dating matches (4d) |
| N7 | Outbid notification | Another user places higher bid on watched auction | In-app banner slides down from top; push notification if backgrounded | Banner shows item thumbnail + new bid amount; tap -> auction detail (6c) | In-app notification banner | Shop auction (6c) |
| N8 | Nearby user arrival | New user enters proximity range while YoYo active | Card slides into nearby list from top with fade-in | Gentle haptic; list count increments; new card highlighted briefly | Nearby card arrival | YoYo nearby (7a) |

**Set C changes from Set B:**
- **N7 removed (was Learning hint tooltip):** The "Hold for more options" tooltip for the center FAB's long-press is no longer needed. The FAB in Set C uses a simple tap, which is self-explanatory.
- **Renumbered:** N8 (Outbid) and N9 (Nearby arrival) from Set B become N7 and N8.

---

### 13e. Transition & Reveal (10 patterns)

| ID | Pattern | Trigger | Behaviour | Feedback | Sec 12 Ref | Used In |
|----|---------|---------|-----------|----------|------------|---------|
| T1 | Bottom sheet slide | Action requiring modal input (comments, filters, offers, bids) | Sheet slides up from bottom edge; dim overlay fades in behind; respects safe areas | Drag handle visible at top for resize/dismiss; content scrollable | Bottom sheet open / close | Video comments (3b), Dating filters (4e), Shop bid/offer, Chat actions |
| T2 | **Service popup fan** | **Tap on service switcher FAB** | **5 service options emerge from FAB position, fanning upward with 50ms stagger per item; scrim overlay fades in** | **Dim scrim overlay; each option has label + icon bubble; reverse animation on collapse** | **FAB expand / collapse, Service popup items** | **Service switcher FAB (2c)** |
| T3 | Card stack parallax | Viewing top card in stack (Dating, Stumble) | Next card visible behind current at ~95% scale + slight Y offset; tracks current card movement | Creates depth perception; next card "breathes" as current card moves | Card stack (Dating) | Dating card stack (4a), Social stumble (5b) |
| T4 | Page push/pop | Navigate forward to new screen / tap back | Push: new screen slides in from right (300ms); Pop: current screen slides right to reveal previous | iOS-standard gesture: edge-swipe from left to pop | Page navigate / Page dismiss | All screen transitions (global) |
| T5 | Match overlay reveal | Two users match (mutual like) | Full-screen overlay fades in; both avatars slide in from left and right edges, meeting in center | Confetti burst (V3) triggers after avatars meet; overlay is dismissible | Match overlay | Dating match (4c) |
| T6 | Logo entrance | App launch / welcome screen | Logo scales from 0.5->1.0 with fade from 0->1; tagline fades in 200ms after logo settles | Smooth, not bouncy -- first impression should feel polished, not playful | -- | Welcome/splash (10a) |
| T7 | Comment sheet resize | Drag handle on open comment sheet | Sheet resizes between half-screen and full-screen positions; snaps to nearest position | Content scrolls within sheet; pull past top -> full-screen; pull down -> dismiss | Bottom sheet open / close | Video comments (3b) |
| T8 | Tab cross-fade | Tap sub-feature tab in bottom nav or content tabs within a screen | Old content fades out while new content fades in simultaneously; 200ms | No sliding; keeps spatial context stable; tab indicator slides to new position | Tab switch | Bottom nav sub-feature tabs (2b), Video feed tabs (3a), Creator profile tabs (3e), Shop seller tabs (6e) |
| T9 | Filter apply transition | Apply filters in Dating or Shop | Current content fades out; new filtered content fades in; filter chip updates | Brief skeleton shimmer (L1) may appear if data fetch needed | -- | Dating filters (4e), Shop category chips (6a), Video discover (3f) |
| T10 | Swipe-between-users (stories) | Swipe left on story viewer to skip to next user | Current user's stories slide left; next user's stories slide in from right | Progress bars reset for new user; avatar and name update | -- | Social story viewer (5d) |

**Set C changes from Set B:**
- **T2 renamed:** Was "Speed dial fan" (long-press FAB, 3 options per module) -> Now "Service popup fan" (tap FAB, 5 universal service options)

---

### 13f. Haptic Feedback Summary

Haptic feedback reinforces gesture results without requiring visual attention. Each level maps to platform-specific APIs.

| Haptic Level | iOS API | Android API | Patterns Using This Level |
|-------------|---------|-------------|---------------------------|
| **Light** | `UIImpactFeedbackGenerator(.light)` | `HapticFeedbackConstants.KEYBOARD_TAP` | G9 (tap to toggle), G12 (chip tap), N5 (wave sent), V11 (ripple on tap) |
| **Medium** | `UIImpactFeedbackGenerator(.medium)` | `HapticFeedbackConstants.CONTEXT_CLICK` | **G5 (FAB tap)**, G6 (pull-to-refresh release), G16 (story tap navigate) |
| **Heavy** | `UIImpactFeedbackGenerator(.heavy)` | `HapticFeedbackConstants.LONG_PRESS` | G4 (context menu trigger), G10 (record start) |
| **Success** | `UINotificationFeedbackGenerator(.success)` | `HapticFeedbackConstants.CONFIRM` | V9 (success toast), G10 (recording complete), N5 (wave sent confirmation) |
| **Warning** | `UINotificationFeedbackGenerator(.warning)` | `HapticFeedbackConstants.REJECT` | V7 (auction timer urgency), N7 (outbid notification) |
| **Error** | `UINotificationFeedbackGenerator(.error)` | `HapticFeedbackConstants.REJECT` | V10 (error shake), failed action attempts |
| **Celebration** | Custom: rapid light->medium->heavy sequence | Custom: `VibrationEffect.createWaveform` | V3 (confetti on match), T5 (match overlay reveal) |
| **None (intentional)** | -- | -- | G17 (story hold to pause -- silence is the feedback), L1 (skeleton shimmer), T4 (page push/pop -- visual-only) |

**Set C changes from Set B:**
- G5 haptic changed from "Medium on tap, Heavy on long-press" to just "Medium on tap" -- the long-press interaction no longer exists

> **Implementation note:** Android haptic names vary by API level. Use `HapticFeedbackConstants` for API 30+ and `VibrationEffect` patterns for earlier versions. iOS haptic generators should be prepared in advance (call `prepare()` before the expected trigger) to avoid latency.

---

## Screen Count Summary

| Module | Screens | Notes |
|--------|---------|-------|
| Video | 7 | Feed (For You), Following, Record, Edit/Post, Creator Profile, Discover, Sound |
| Dating | 5 | Card Stack, Expanded Profile, Match!, Matches List, Filters |
| Social | 6 | Stumble Feed, Stumble Cards, Composer, Story Viewer, Friends, Events |
| Shop | 5 | Browse, Product Detail, Auction, Create Listing, Seller Profile |
| YoYo | 3 | Nearby List, Settings/Controls, User Profile |
| Chat | 2 | Inbox, Conversation |
| Profile | 3 | My Profile, Edit Profile, Settings |
| Auth | 3 | Welcome, Sign Up, Onboarding |
| Sponsored | 1 | Inline template (reused per feed) |
| **Total** | **35** | |

---

## Cross-Reference Verification

| Requirement | Status | Source |
|-------------|--------|--------|
| Every feature from `FEATURE_ANALYSIS_MVP.md` mapped to an affordance | Yes | Feature tables per module |
| All screens from `INITIAL_DESIGN_SCOPE.md` represented | Yes | 35 screens covering all modules |
| Neil's icon-only nav preference applied | Adapted | Section 2b -- icons + minimal labels (8-9pt) for sub-feature tabs; labels help distinguish features within a service |
| Neil's small/subtle badges applied | Yes | Dating card (4a), all badge callouts |
| Neil's list layout for YoYo (NOT grid) | Yes | Section 7a -- vertical list with quote |
| Neil's 3D photo flip requirement | Yes | Dating (4a), YoYo (7c), Animation spec |
| **Set C navigation pattern (service switcher FAB)** | **Yes** | **Section 2b, 2c** |
| Top bar: YoYo LEFT, Profile RIGHT | Yes | Section 2a |
| Chat accessible from Profile and top bar badge | Yes | Section 2a, 9a |
| Photo indicators at BOTTOM (not top) | Yes | Dating card (4a), all photo galleries |
| **Service FAB changes icon per active service** | **Yes** | **Section 2c -- icon matches current service** |
| **Sub-feature tabs change per active service** | **Yes** | **Section 2b -- 4 tabs per service** |
| **YoYo promoted to first-class service** | **Yes** | **Section 7 -- own sub-feature tabs, in FAB popup** |
| `moduleKey` architecture respected | Yes | Chat contexts (8a), post types (5c) |
| All micro-interactions catalogued with trigger, behaviour, feedback, and locations | Yes | Section 13 -- 57 patterns across 5 categories + haptic summary |

---

## Migration Notes (Set B -> Set C)

For teams transitioning from the Set B document:

1. **Remove center notch** from all bottom nav bar implementations
2. **Remove long-press speed dial** from center FAB -- replace with service popup on tap
3. **Add sub-feature tabs** to bottom nav for each service (4 tabs per service, defined in section 2b)
4. **Move primary actions** (Record, Spark, Post, List) into sub-feature tabs (Create tab, Post tab, Sell tab)
5. **Add service switcher FAB** at bottom-right (50pt circle, 16pt right margin)
6. **Remove N7 learning hint tooltip** -- no longer needed (simple tap vs long-press)
7. **Promote YoYo** from top-bar-only access to a full service with sub-feature tabs
8. **Update all wireframes** to show new bottom nav pattern with sub-feature tabs + FAB
