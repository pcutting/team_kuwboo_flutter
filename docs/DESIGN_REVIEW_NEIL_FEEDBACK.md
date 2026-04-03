# Design Review — Neil Douglas Feedback

**Date:** 16 February 2026
**Context:** Wireframe and mockup walkthrough during video call
**Duration:** Design discussion was approximately 60-90 minutes of the 2.5-hour call

---

## 1. Style Preferences

### Loves

| Style | Why | Target Age |
|-------|-----|------------|
| **"Street"** | Clean, urban, structured boxes and tabs | 22-32 |
| **"Organic"** | Calm, modern, warmth, "settles into you" | 25-40 |

**Desired combination:** Street's clean structure (boxes, tabs, clear hierarchy) merged with Organic's modern warmth and calm feel.

### Hates

| Style | Why |
|-------|-----|
| **Retro Digital** | Too dated, feels old |
| **Anti-Establishment** | Too aggressive, off-putting |
| Anything "childish" | Cartoon-like elements feel cheap |
| Heavy/cluttered UI | Large text, oversized badges, overlapping elements |

### Design Direction Summary

The app should feel like a premium, modern product that a 25-35 year old would be comfortable using daily. Not trying too hard, not too minimal. Clean but warm.

---

## 2. Dating Card Feedback

> Note: Dating module is deferred from MVP scope, but these principles apply to all profile/card views across modules.

### What to Fix

| Element | Current Issue | What Neil Wants |
|---------|---------------|-----------------|
| Verified badge | Too large, covers face | Small, red, positioned at bottom |
| Match % badge | Too prominent | Small, subtle, still visible |
| Distance indicator | Competing with photo | Small text, doesn't dominate |
| Photo indicators | Dots/bars at top | Move to bottom of card |
| UI elements over photos | Covering faces | Layered transparent buttons on top of full-screen photo |

### Interaction Pattern

1. **Default view:** Full-screen photo with minimal transparent overlay
2. **Tap photo:** Enlarges to full view
3. **Swipe left/right:** Navigate between user's photos (with flip/rotation transition, not just slide)
4. **Swipe up:** Return to card/profile view
5. **Bounce-back animation** when dismissing or returning

### Badges & Indicators

- Verified badge: Small, red, bottom of card
- Match percentage: Small, subtle
- Distance: Small text
- Photo position indicators (bars): Bottom of photo, not top
- All badges shrunk significantly from current wireframe sizes

---

## 3. Navigation Feedback

### Bottom Navigation Bar

| Preference | Detail |
|------------|--------|
| Center FAB | Action button that changes function per module |
| Icon-only | No text labels — "heavy on the eye" |
| Clean | Minimal, not cluttered |
| Module-specific | Nav items change based on active module |

**Neil's reasoning:** Labels add visual noise. Icons should be intuitive enough that users learn them quickly. Text labels make the nav bar feel "heavy."

### Top Bar

| Position | Element | Notes |
|----------|---------|-------|
| Top-left | YoYo icon | Consistent across all modules |
| Top-right | Profile icon | Symmetrical sizing with YoYo |
| Top-right area | Message badge | Count shown on profile icon |
| Larger screens | Separate message icon | Additional message access point |

### Module Switching

- Not in bottom nav (bottom nav is intra-module)
- Separate mechanism needed (to be designed in M1)
- Could be: home screen, hamburger menu, swipe between modules, or module drawer

---

## 4. YoYo (Nearby) Feedback

### Layout

| Preference | Detail |
|------------|--------|
| **List view** | Vertical list with profile photos, names, distances |
| **NOT grid** | "Looks like back of a T-shirt in a pound shop" |
| Organic style | Clean cards with space, not cramped tiles |
| Distance prominent | Show how far away each person is |

### Functionality

- Coarse location notifications (Neil accepts battery trade-off)
- Push notifications even when app is closed (background location)
- Ambient, always-on feel — YoYo should feel like it's always working
- Notification when someone interesting is nearby

### Design Notes

- Individual profile cards in a scrollable list
- Photo, name, brief info, and distance
- Clean spacing between cards
- Tap to view full profile
- No grid/tile mosaic layouts

---

## 5. Interaction & Animation Requirements

### Photo Transitions

| Interaction | Animation |
|-------------|-----------|
| Swipe between photos | **Flip/rotation** transition (not just slide) |
| Dismiss/return | **Bounce-back** elastic animation |
| Card transitions | Smooth, physics-based movement |
| Button presses | Subtle feedback (scale, haptic) |

### General Animation Principles

- "The small things make it magical" — micro-interactions are a priority
- Transparent/semi-transparent buttons layered over images
- Consistent interaction patterns across all modules
- Animations should feel natural and physics-based, not mechanical
- Nothing should feel jarring or abrupt

### Specific Requests

- Photo swipe with 3D flip or rotation effect
- Elastic bounce when reaching end of content or dismissing
- Buttons that feel responsive (press states, micro-animations)
- Loading states that feel alive (not just a spinner)
- Transitions between screens should feel connected, not like page loads

---

## 6. Design Principles (Neil's Own Words)

These quotes capture the emotional target for the entire app:

> **"Modern, intelligent, not invasive"**
> — The app should feel smart without being pushy or cluttered

> **"Child-proof simplicity"**
> — Anyone should be able to use it without thinking

> **"Makes you want to press a button"**
> — UI elements should be inviting, not intimidating

> **"Pleasant on the eye, not scary"**
> — Calm, approachable, never overwhelming

> **"Comfortable — I'm not going to struggle with this"**
> — Zero learning curve feeling

> **"Fun to use and play"**
> — Interactions should feel enjoyable, not transactional

---

## 7. Summary: Design Do's and Don'ts

### Do

- Full-screen imagery with layered transparent UI
- Small, subtle badges and indicators
- Icon-only navigation where possible
- List layouts for people/content discovery
- Micro-interactions and physics-based animations
- Clean spacing and breathing room
- Modern, warm aesthetic (Street + Organic blend)
- Consistent patterns across all modules

### Don't

- Cover faces with UI elements
- Use large text labels in navigation
- Use grid/tile mosaic layouts for people
- Use oversized badges or boxes
- Make anything feel aggressive, loud, or childish
- Use retro or dated visual styles
- Rely on text when icons can communicate
- Use flat/mechanical transitions (always add physics)

---

## 8. Impact on Figma Design Phase

These preferences should directly inform Milestone 1 (Design & Architecture):

1. **Component library:** Build small, subtle badge variants from the start
2. **Navigation system:** Prototype the center FAB with module-specific actions
3. **Photo viewer:** Prototype the swipe-to-flip interaction early — this is a signature element
4. **YoYo list:** Design the organic list layout as a reusable pattern
5. **Color palette:** Warm, modern tones — avoid cold/sterile or overly bright colors
6. **Typography:** Clean, readable, not oversized — hierarchy through weight, not size
7. **Spacing:** Generous — cards and elements need room to breathe
8. **Animation spec:** Document micro-interactions as part of the design system, not an afterthought
