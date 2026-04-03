# Feature Comparison: iOS vs Android

**Comparison Date:** January 25, 2026
**Source:** Codebase analysis from Codiant archive (Dec 2, 2025)

---

## Summary

| Metric                       | iOS       | Android           | Notes             |
| ---------------------------- | --------- | ----------------- | ----------------- |
| **Lines of Code**      | 124,183   | 28,413            | iOS 4.4x larger   |
| **Source Files**       | 718 Swift | 1,130 Kotlin/Java |                   |
| **API Endpoint Files** | 21        | 2                 | iOS more modular  |
| **Main Modules**       | 3         | 3                 | Same core modules |

---

## Core Modules

Both platforms implement the same three main modules:

| Module                   | iOS            | Android         | Status           |
| ------------------------ | -------------- | --------------- | ---------------- |
| **Video Making**   | Yes (58 files) | Yes (614 files) | Both implemented |
| **Buy & Sell**     | Yes (67 files) | Yes (127 files) | Both implemented |
| **Social/Stumble** | Yes (51 files) | Yes (113 files) | Both implemented |

---

## Feature-by-Feature Comparison

### Video Making (TikTok-like)

| Feature                | iOS | Android |
| ---------------------- | --- | ------- |
| Video recording        | Yes | Yes     |
| Video editing/trimming | Yes | Yes     |
| Audio tracks/music     | Yes | Yes     |
| Filters/effects        | Yes | Yes     |
| Draft videos           | Yes | Yes     |
| Feed/discovery         | Yes | Yes     |
| Like/comment/share     | Yes | Yes     |
| Hashtags               | Yes | Yes     |
| User profiles          | Yes | Yes     |
| Following/followers    | Yes | Yes     |
| Notifications          | Yes | Yes     |
| Search                 | Yes | Yes     |

**Status:** Feature parity appears complete

---

### Buy & Sell (Marketplace)

| Feature             | iOS | Android |
| ------------------- | --- | ------- |
| Product listings    | Yes | Yes     |
| Categories          | Yes | Yes     |
| Fixed price         | Yes | Yes     |
| Auctions/bidding    | Yes | Yes     |
| Product search      | Yes | Yes     |
| Favorites/watchlist | Yes | Yes     |
| Messaging (product) | Yes | Yes     |
| My listings         | Yes | Yes     |
| Bid history         | Yes | Yes     |
| Product detail      | Yes | Yes     |
| Filters             | Yes | Yes     |
| Location            | Yes | Yes     |

**Status:** Feature parity appears complete

---

### Social/Stumble (Social Discovery)

| Feature         | iOS | Android |
| --------------- | --- | ------- |
| Create posts    | Yes | Yes     |
| Post feed       | Yes | Yes     |
| Like/dislike    | Yes | Yes     |
| Comments        | Yes | Yes     |
| Friend requests | Yes | Yes     |
| Events          | Yes | Yes     |
| User profiles   | Yes | Yes     |
| Tagged posts    | Yes | Yes     |
| Gallery         | Yes | Yes     |

**Status:** Feature parity appears complete

---

## Additional Features Comparison   { For the new version, mark these as future, and see who they fit in without looking like polution.  Most of these look like feature tags rather than full features.}

| Feature                  | iOS                     | Android                 | Notes              |
| ------------------------ | ----------------------- | ----------------------- | ------------------ |
| **Blog Module**    | Yes (6 files, 179 refs) | Partial (107 refs)      | iOS more developed |
| **VIP Pages**      | Yes (API + UI)          | Yes (3 files, 153 refs) | Both have it       |
| **Notice Board**   | Yes (API + UI)          | Yes (3 files)           | Both have it       |
| **Dating Profile** | Yes (API + settings)    | Partial (101 refs)      | iOS more developed |
| **Lost/Stolen**    | Yes (API + UI)          | Partial (365 refs)      | Both reference it  |
| **Missing Person** | Yes (API + UI)          | Partial (36 refs)       | iOS more developed |
| **Find Discount**  | Yes (API + UI)          | Partial (76 refs)       | iOS more developed |

---

## API Endpoints Comparison

### iOS API Modules (21 files)

| Endpoint File             | Description                   |
| ------------------------- | ----------------------------- |
| Account.swift             | Authentication, signup, login |
| Blog.swift                | Blog posts CRUD               |
| Chat.swift                | Messaging                     |
| CreatePost.swift          | Content creation              |
| DatingUser.swift          | Dating features               |
| DatingUserProfile.swift   | Dating profiles               |
| Feed.swift                | Video feed                    |
| FindDiscount.swift        | Discount discovery            |
| LostAndStolen.swift       | Lost/stolen items             |
| Media.swift               | Media upload                  |
| MissingPerson.swift       | Missing persons posts         |
| NoticeBoard.swift         | Notice board posts            |
| NoticeBoardInterest.swift | Notice board categories       |
| Product.swift             | Buy/sell products             |
| Profile.swift             | User profiles                 |
| Search.swift              | Search functionality          |
| Setting.swift             | App settings                  |
| SocialStumble.swift       | Social features               |
| Sound.swift               | Audio tracks                  |
| User.swift                | User management               |
| VIPPage.swift             | VIP pages                     |

### Android API Modules (2 files)

| Endpoint File                 | Endpoint Count |
| ----------------------------- | -------------- |
| WebServiceInterface.kt        | 50+ endpoints  |
| BuySellWebServiceInterface.kt | 25+ endpoints  |

**Note:** Android consolidates all endpoints into fewer files while iOS splits them by feature.

---

## Code References Analysis

| Feature        | iOS References | Android References | Likely Status                 |
| -------------- | -------------- | ------------------ | ----------------------------- |
| Dating         | 55             | 101                | Android may have more UI work |
| Blog           | 179            | 107                | iOS more complete             |
| Lost/Found     | 743            | 365                | iOS significantly more        |
| Missing Person | 24             | 36                 | Similar                       |
| Discount       | 70             | 76                 | Similar                       |
| VIP            | 184            | 153                | Similar                       |

---

## UI Components Comparison

### iOS Storyboards/Features

```
Storyboards/
├── Account.storyboard
├── Blog/                 # Blog module
├── BuySell/             # Marketplace
├── Chat.storyboard
├── CreatePost.storyboard
├── Dating/              # Dating feature
├── FindDiscount/        # Discount feature
├── Home.storyboard
├── LostAndFound/        # Lost items
├── Main.storyboard
├── MissingPerson/       # Missing persons
├── NoticeBoard/         # Announcements
├── Profile.storyboard
├── Search.storyboard
├── Setting.storyboard
├── SocialStumble/       # Social discovery
└── Vip/                 # VIP pages
```

### Android Packages/Features

```
com.kuwboo/
├── buyandsell/          # Marketplace (127 files)
├── common/              # Shared code
├── data/                # Data layer
├── fcm/                 # Push notifications
├── noticeboard/         # Announcements (3 files)
├── socialstumble/       # Social discovery (113 files)
├── utils/               # Utilities
├── videomaking/         # Video features (614 files)
└── vippages/            # VIP pages (3 files)
```

---

## Key Differences

### iOS Has More Developed

1. **Blog Module** - Full API implementation, more references
2. **Lost/Stolen** - Significantly more code (743 vs 365 refs)
3. **Dating Features** - Dedicated API files
4. **Missing Person** - More structured implementation
5. **Find Discount** - Dedicated module

### Android Has

1. **More Video Making code** - 614 Kotlin files vs iOS's 58 Swift files
2. **Similar core functionality** - All three main modules work
3. **Same Firebase integration** - Push, analytics, crashlytics

---

## Conclusions

### Feature Parity Assessment

| Module         | Parity Level | Confidence |
| -------------- | ------------ | ---------- |
| Video Making   | High         | High       |
| Buy & Sell     | High         | High       |
| Social/Stumble | High         | High       |
| Blog           | iOS ahead    | Medium     |
| VIP Pages      | Similar      | Medium     |
| Notice Board   | Similar      | Medium     |
| Dating         | iOS ahead    | Medium     |
| Lost/Stolen    | iOS ahead    | Medium     |
| Missing Person | iOS ahead    | Low        |
| Find Discount  | iOS ahead    | Low        |

### Why iOS Has 4.4x More Code

1. **Additional features more developed** (Blog, Dating, Lost/Found)
2. **More verbose architecture** (21 API files vs 2)
3. **Git history included** (commit-by-commit additions)
4. **iOS-specific patterns** (Storyboards, more delegation)

### Recommendations

1. **Test both apps** - Actually run them to verify feature parity
2. **Focus on core modules first** - Video, Buy/Sell, Social work on both
3. **Investigate additional features** - Some may be backend-only with no UI
4. **Check backend API** - Verify all endpoints exist on server

---

## Testing Checklist

### High Priority (Core Features)

- [ ] Video Making: Record, edit, publish video
- [ ] Video Making: Browse feed, like, comment, share
- [ ] Buy & Sell: List product, browse, bid
- [ ] Buy & Sell: Message seller, watch items
- [ ] Social/Stumble: Create post, browse, interact
- [ ] Auth: Login, signup, social auth
- [ ] Profile: Edit profile, settings

### Medium Priority (Additional Features)

- [ ] VIP Pages: Create, join, browse
- [ ] Notice Board: Post, browse
- [ ] Blog: Create post, browse (iOS first)
- [ ] Dating: Profile setup, matching (if enabled)

### Low Priority (May Be Incomplete)

- [ ] Lost/Stolen: Post, browse
- [ ] Missing Person: Post, browse
- [ ] Find Discount: Browse, save

---

*Analysis by LionPro Dev - January 25, 2026*
