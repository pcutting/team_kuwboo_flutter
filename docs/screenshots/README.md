# Kuwboo App Screenshots

This directory contains screenshots documenting the current state of the Kuwboo mobile app.

## Current Status

**Screenshots: PENDING**

Automated screenshot capture requires resolving GoogleSignIn SDK compatibility first.

### Blocker

The iOS app uses GoogleSignIn **5.0.2** which doesn't include Apple Silicon simulator support. Building for the iOS Simulator fails with:

```
ld: building for 'iOS-simulator', but linking in object file
(.../GoogleSignIn.framework/GoogleSignIn) built for 'iOS'
```

**Resolution:** Update GoogleSignIn to 7.x (Phase 1, Milestone 1.1 in DEVELOPMENT_ROADMAP.md)

---

## Manual Screenshot Capture (Workaround)

Until the GoogleSignIn SDK is updated, screenshots can be captured manually:

### Option 1: Physical Device

1. Connect an iPhone to your Mac
2. Open `Kuwboo.xcworkspace` in Xcode
3. Select your device as the build target
4. Build and run (Cmd+R)
5. Use QuickTime Player > File > New Movie Recording
6. Select your iPhone as the camera source
7. Capture screenshots from QuickTime

### Option 2: Intel Mac Simulator (if available)

On an Intel-based Mac (not Apple Silicon):
1. Open `Kuwboo.xcworkspace` in Xcode
2. Select any iPhone Simulator
3. Build and run (Cmd+R)
4. Use Simulator > File > Save Screen (Cmd+S)

### Option 3: TestFlight

If a TestFlight build exists:
1. Install from TestFlight on a physical device
2. Navigate through the app
3. Take screenshots with device buttons (Side + Volume Up)

---

## Directory Structure

```
screenshots/
├── onboarding/       # Login, OTP, module selection
├── video-making/     # Video feed, recording, editing
├── buy-sell/         # Marketplace, listings, product details
├── social-stumble/   # Social feed, posts, friends
└── common/           # Settings, profile, notifications, chat
```

---

## Automated Capture (After GoogleSignIn Update)

Once GoogleSignIn 7.x is integrated, run:

```bash
cd mobile/ios/kuwboo
fastlane screenshots
```

Configuration files are ready:
- `fastlane/Snapfile` - Device and language configuration
- `fastlane/Fastfile` - Fastlane lanes
- `KuwbooUITests/ScreenshotTests.swift` - UI navigation tests
- `KuwbooUITests/SnapshotHelper.swift` - Screenshot capture helper

Screenshots will be saved directly to this `docs/screenshots/` directory.

---

## Required Screenshots

### Onboarding (Priority: High)
- [ ] Splash screen
- [ ] Phone number entry
- [ ] OTP verification
- [ ] Module selection (if shown)

### Video Making Module (Priority: High)
- [ ] Video feed (home)
- [ ] Video recording screen
- [ ] Video editing screen
- [ ] Video detail/player
- [ ] Comments view

### Buy & Sell Module (Priority: Medium)
- [ ] Product listings (home)
- [ ] Product detail page
- [ ] Create listing flow
- [ ] Bidding/auction view
- [ ] Search/filters

### Social/Stumble Module (Priority: Medium)
- [ ] Social feed
- [ ] Create post
- [ ] User profile
- [ ] Friends/connections

### Common Screens (Priority: High)
- [ ] Settings
- [ ] User profile (own)
- [ ] Chat/messaging
- [ ] Notifications
- [ ] Search

---

## Test Account

For screenshot capture, use:
- **Phone:** 7566662735
- **OTP:** 4444 (works in development/staging mode)

---

## Notes

- Prefer iPhone 15 Pro resolution for consistency
- Capture in light mode by default
- Avoid capturing sensitive test data or debug banners
- Name files descriptively: `01_splash.png`, `02_phone_entry.png`, etc.

---

## Related Documents

- `iOS_CODEBASE_AUDIT.md` - Details on GoogleSignIn issue
- `DEVELOPMENT_ROADMAP.md` - Phase 1 includes SDK update
- `RISK_REGISTER.md` - TEC-001 covers GoogleSignIn risk

---

**Last Updated:** January 27, 2026
**Status:** Pending GoogleSignIn 7.x update for automated capture
