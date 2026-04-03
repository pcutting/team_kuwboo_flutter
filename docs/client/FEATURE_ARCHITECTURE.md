# Kuwboo: Feature Architecture

**Created:** February 17, 2026
**Version:** 1.0
**Purpose:** Client-facing overview of current features and the re-engineered architecture for the rebuild
**Audience:** Neil Douglas (Guess This Ltd)

**Related Documents:**

- [FEATURE_ANALYSIS_MVP.md](FEATURE_ANALYSIS_MVP.md) -- Priority features mapped to current state
- [INITIAL_DESIGN_SCOPE.md](INITIAL_DESIGN_SCOPE.md) -- Screen inventory for the designer
- [DEVELOPMENT_SCOPE.md](DEVELOPMENT_SCOPE.md) -- Full development plan and cost breakdown
- [NEIL_CALL_NOTES_2026-02-16.md](NEIL_CALL_NOTES_2026-02-16.md) -- Rebuild decision and preferences

---

## Introduction

Kuwboo is being rebuilt from scratch. The current app works, but under the surface it's cluttered -- features were bolted on as separate mini-apps rather than woven into a cohesive experience. The result is an app that feels congested, with users forced to navigate between isolated modules that don't talk to each other.

The rebuild is an opportunity to restructure everything. Instead of ten separate systems each with their own screens, databases, and navigation, we're organising Kuwboo around four core experiences that users actually care about, with everything else folded in as natural extensions of those experiences.

**The philosophy:** Features should mix organically into the feeds users are already browsing -- not exist as separate apps-within-the-app that require users to go hunting for them.

---

## Part 1: What Exists Today

This is a platform-agnostic inventory of what Kuwboo currently offers. The existing app has inconsistencies between iOS and Android -- none of that matters for the rebuild. What matters is understanding what features exist and how they're currently structured.

### Core Modules (Fully Built)

These are the main features that users interact with daily. All are fully built with working backends, though individual sub-features vary in completeness across iOS and Android.

#### Video Making

A TikTok-style short video platform with creation tools and a discovery feed.

| Feature             | Description                                            |
| ------------------- | ------------------------------------------------------ |
| Video recording     | Up to 60 seconds, front/rear camera                    |
| Video editing       | Trim, filters, effects, text overlay                   |
| Audio library       | Music tracks, sound effects, favourites                |
| Discovery feed      | For You, Following, and Trending sections              |
| Social interactions | Like, comment, share, save to collections              |
| Hashtags and search | Tag videos, search by hashtag/user/audio               |
| Draft videos        | Save work-in-progress videos                           |
| User profiles       | Creator pages with video grids                         |
| Follow system       | Follow creators, see their new content                 |
| Content categories  | 27 categories (Entertainment, Sports, Education, etc.) |
| Push notifications  | New followers, comments, likes                         |
| Content moderation  | Report and review workflow                             |

#### Buy & Sell (Marketplace)

A marketplace for buying and selling items, with both fixed-price and auction formats.

| Feature                    | Description                                                       |
| -------------------------- | ----------------------------------------------------------------- |
| Product listings           | Photos, description, price, condition                             |
| Fixed-price sales          | Set a price, buyers purchase directly                             |
| Auctions and bidding       | Set a starting price, buyers bid, highest wins                    |
| Category browsing          | 54 categories in a hierarchy (Electronics > Laptops, etc.)        |
| Product search and filters | Search by keyword, filter by price, condition, location, category |
| Location-based search      | Find items near you                                               |
| Favourites and watchlist   | Save items to come back to                                        |
| In-app messaging           | Message sellers directly about a product                          |
| Bid history                | Track your bids and bid status                                    |
| My listings                | Manage your active, sold, and expired items                       |
| Item conditions            | New, used, like-new, etc.                                         |

#### Social (with "Stumble" Discovery)

A social networking feed for sharing posts, finding friends, and organising events. The current app calls its random-discovery mode "Stumble" -- a way to find new people you wouldn't normally come across. In the rebuild, Stumble lives within the Social tab as a discovery mode rather than a separate concept.

| Feature            | Description                                    |
| ------------------ | ---------------------------------------------- |
| Posts              | Create text and photo posts                    |
| Social feed        | Browse friends' and public posts               |
| Likes and comments | React to and discuss posts                     |
| Photo albums       | Organise photos into albums                    |
| User tagging       | Tag people in posts                            |
| Friend system      | Send and accept friend requests                |
| Events             | Create and browse local events                 |
| Saved posts        | Bookmark posts to revisit                      |
| Privacy controls   | Control who can see your posts and message you |
| User search        | Find people by name or username                |

---

### Extended Modules (Partially Implemented)

These features exist in the current app but were treated as separate systems -- each with their own screens, database tables, and navigation. Most are essentially content types that duplicate the same patterns (create, list, comment, like, tag) that the core modules already handle.

#### Dating (Backend Only)

Profile-based matching with swipe-to-like mechanics. The backend supports dating profiles, matching, unmatching, and profile photo galleries -- but the mobile app screens were never finished. Unlike the extended modules below, Dating isn't being absorbed into another experience -- it's being promoted to a core tab and built properly from scratch. The backend groundwork gives us a head start.

**Current state:** Backend complete (profiles, matching, chat integration). Mobile screens incomplete on both platforms.

#### Blog

Long-form text and image posts. Has its own categories (30), comments, likes, tags, and bookmarks. Functionally, it's a longer version of a Social post -- but it was built as a completely separate system with 7 dedicated database tables.

**Current state:** Fully built on iOS, partial on Android. Working backend.

#### VIP Pages

Brand or creator pages with their own posts, comments, and member lists. Similar to a Facebook Page. Has 9 dedicated database tables including its own post system, comments, likes, and images -- all separate from the main Social feed.

**Current state:** Built on both platforms. Working backend.

#### Notice Board

Community announcements and notices. Has its own categories, comments, likes, tags, and images. Essentially a Social post with a "notice" label, but built as a standalone module with 8 dedicated database tables.

**Current state:** Built on both platforms. Working backend.

#### Find Discount

Deals and discount listings from shops and sellers. Has its own favourites, followers (for stores), and image galleries. 4 dedicated database tables.

**Current state:** More developed on iOS, partial on Android. Working backend.

#### Lost & Found

Listings for lost, found, or stolen items with location tagging. Has its own image handling. 3 dedicated database tables. Supports three types: lost, found, and stolen.

**Current state:** More developed on iOS, partial on Android. Working backend.

#### Missing Person

Community safety posts for missing persons, with photo uploads. 2 dedicated database tables. The most sensitive of the extended modules -- involves legal and safety considerations.

**Current state:** More developed on iOS, partial on Android. Working backend.

---

### Cross-Cutting Systems

These systems serve all modules and remain relevant for the rebuild.

| System                       | Description                                                                                                                           |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Authentication**     | Phone OTP, email login, Google Sign-In, Apple Sign-In, JWT tokens                                                                     |
| **Chat and Messaging** | Real-time 1:1 and group chat (Socket.io), shared across all modules -- a marketplace enquiry and a social DM use the same chat system |
| **User Profiles**      | Unified user identity with profile photos, bio, settings, and per-module follow relationships                                         |
| **Push Notifications** | Firebase-based notifications for all modules                                                                                          |
| **Content Moderation** | Report and review workflow with separate report queues per module                                                                     |
| **Location Services**  | GPS coordinates, Haversine distance calculations, city/state/country database (60,000+ cities)                                        |

---

### The Problem with the Current Structure

The current app has **130 database tables** across these modules. Here's why that number is so high:

Each extended module was built as a copy-paste of the core module pattern. Blog has its own comments table, its own likes table, its own tags table, its own images table. Notice Board has the same. VIP Pages has the same. There are **11 separate report tables** -- one for each module type.

This means:

- Every new feature requires building the same infrastructure from scratch
- Bug fixes in commenting need to be applied in 6+ places
- Users see fragmented experiences -- their "likes" are scattered across separate systems
- Navigation is cluttered with module-specific screens that feel disconnected

The rebuild eliminates this duplication entirely.

---

## Part 2: The Rebuild -- Re-Engineered Feature Architecture

### Four Core Experiences

The new Kuwboo is organised around four tabs -- four distinct experiences that feel different but share a common foundation.

| Tab              | Experience         | What Users Do Here                                                                                                                                                                     |
| ---------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Video**  | Watch and create   | Browse a TikTok-style vertical video feed, record and edit videos, discover creators and trending content                                                                              |
| **Dating** | Connect and match  | Browse profiles, swipe to match, chat with matches. The current app has backend support for dating but no finished mobile screens -- this will be built fresh in the rebuild (Phase 3) |
| **Social** | Share and discover | Post updates, browse friends' content, join events, discover new people through the "Stumble" random-discovery mode                                                                    |
| **Shop**   | Buy and sell       | List items for sale, browse and bid on products, message sellers, manage your listings                                                                                                 |

These four tabs replace the current module-selector pattern. Users no longer need to "switch modules" -- everything is one tap away.

### Cross-Cutting Capabilities

These aren't tabs. They're woven throughout all four experiences.

| Capability                 | What It Does                                                                                                                                                                                                                                                                                                                                                                                                   | Where It Appears                                                                                                                          |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **YoYo (Proximity)** | Discovers nearby users based on your location. Think of it as "who's around me right now?" -- similar to Happn or Bumble's "People Nearby." Users opt in, set their interests (social, dating, shopping, networking), and see other active YoYo users within range. The current app already has location infrastructure (GPS, distance calculations, a database of 60,000+ cities) which YoYo builds on top of | Available from the header bar across all tabs. See who's nearby whether you're browsing videos, shopping, or socialising                  |
| **Sponsored Links**  | Promoted content from advertisers and sellers                                                                                                                                                                                                                                                                                                                                                                  | Appears naturally within feeds -- a promoted video in the Video feed, a boosted product in the Shop feed                                  |
| **Messaging**        | Real-time chat with anyone                                                                                                                                                                                                                                                                                                                                                                                     | Unified inbox accessible from the header bar. One conversation list, whether you're chatting about a product, a match, or a friend's post |

### Unified Moderation and Reporting

The current app has 11 separate report systems -- one for each module type. In the rebuild, there's one reporting flow that works the same way everywhere. Whether a user reports a video, a marketplace listing, a social post, or a missing person alert, the process is identical: tap "Report," pick a reason, and it enters a single review queue. This makes moderation far simpler to manage and means nothing falls through the cracks.

### Video as the Content Engine

Video isn't just the Video tab. It's a content capability that extends across the entire app:

- **In Dating:** Record a video introduction for your profile
- **In Social:** Share video posts alongside photos and text
- **In Shop:** Film a product demo or unboxing to attach to your listing

The Video tab is where the TikTok-style discovery feed lives -- it's the primary surface for finding new video content. But the tools for creating and sharing video are available everywhere.

---

### How the Extended Modules Are Absorbed

This is the key architectural change. Instead of building Blog, VIP Pages, Notice Board, Find Discount, Lost & Found, and Missing Person as separate systems, each one becomes a natural part of an existing core experience.

| What It Was              | What It Becomes                                     | Where It Lives | How It Works                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------------------ | --------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Blog**           | Long-form post type                                 | Social         | A post in the Social feed with a longer text body and image gallery. No separate Blog section -- it's just a richer kind of post. Users can filter the Social feed to see long-form content specifically.                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **VIP Pages**      | Enhanced creator profiles + content visibility tier | All modules    | Instead of a separate "VIP Pages" section, the concept splits in two.**(1) VIP profiles** replace VIP Pages -- a VIP creator's profile becomes their "page," with enhanced customisation, a verified badge, and the ability to post across all modules with priority placement. Followers of a VIP user see their content first. **(2) VIP as a visibility tier** -- any user's content can be VIP-tier, meaning it gets boosted in feeds. The separate "VIP Pages" post system (with its own comments, likes, and member lists) is replaced by the VIP user simply posting in the regular Social, Video, or Shop feeds with their VIP badge visible. |
| **Notice Board**   | Announcement post type                              | Social         | A post type in the Social feed with a "Notice" label, pinning capability, and priority display. Community notices appear in the Social feed with visual distinction -- not in a separate corner of the app.                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **Find Discount**  | Deal tag on listings                                | Shop           | Sellers mark a product as discounted, and it surfaces in a "Deals" filter in the Shop. No separate "Find Discount" section -- deals are where you'd naturally look for them, in the marketplace.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| **Lost & Found**   | Community listing type                              | Shop           | A listing category in the marketplace (Lost / Found / Stolen) with location tagging and community alert features. Appears alongside regular listings with clear visual labels.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| **Missing Person** | Community safety post                               | Social         | A special post type with alert-style display, potentially requiring admin approval before publishing. Appears in the Social feed with prominent styling to draw attention.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |

**What this achieves:** Users don't need to learn six new sections of the app. Blog posts appear where they'd naturally share content (Social). Deals appear where they'd naturally shop (Shop). VIP is a badge of distinction, not a separate destination. Everything feels integrated rather than bolted on.

---

### Content Visibility Tiers

The old VIP module becomes a system-wide concept. Every piece of content in Kuwboo has a visibility tier that determines how it surfaces in feeds:

| Tier              | Who Gets It                     | What It Does                                                                                                                                                        |
| ----------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Free**    | Everyone by default             | Standard visibility. Content appears chronologically or by algorithm in the relevant feed.                                                                          |
| **Member**  | Registered, active users        | Slight boost in feed placement. Content visible to followers first, then broader audience.                                                                          |
| **VIP**     | Premium or verified users       | Priority placement in feeds. VIP badge on profile and content. Content surfaces more frequently to non-followers. Enhanced profile with more customisation options. |
| **Boosted** | Paid promotion (anyone can buy) | Content appears in Sponsored Links placements across feeds. Analytics on views and engagement. Time-limited promotion period.                                       |

These tiers are **properties on content**, not separate systems. The rules for who sees what and how content surfaces in feeds are handled by one feed algorithm -- not by routing users to different sections of the app.

---

### Feed Mixing

This is what makes the rebuild feel different from the current app.

In the current app, each module is a silo. If you want to see blog posts, you go to the Blog section. If you want to see deals, you go to Find Discount. If you want to see notices, you go to the Notice Board. Each section has its own feed, its own navigation, its own look.

In the rebuild, content mixes organically within each core feed. Here's what a Social feed might look like:

1. A friend's photo post
2. A VIP creator's video (badge visible, from their Social presence)
3. A community notice about a local event (labelled "Notice", pinned to top)
4. A friend's long-form post with photos (what used to be a "Blog" post)
5. A sponsored local business listing
6. A community alert about a found item nearby (what used to be "Lost & Found")

Each piece of content is visually distinct -- badges, labels, and subtle styling cues tell users what they're looking at -- but they don't need to leave the feed to find it. The feed does the work of surfacing relevant content, not the navigation.

The same principle applies to the Shop feed:

1. A product listing near you
2. A discounted item (what used to be "Find Discount", now labelled "Deal")
3. A sponsored product listing
4. An auction ending soon
5. A lost item report from your area (labelled "Lost", with a community badge)

---

### What This Means in Practice

#### For Users

- **Simpler navigation:** Four tabs instead of ten separate sections
- **Less hunting:** Content finds you through the feed, rather than you going to find it
- **One inbox:** All conversations in one place, regardless of context
- **Consistent experience:** Liking, commenting, sharing, and reporting work the same way everywhere

#### For the Platform

- **Faster to build:** One commenting system, one likes system, one reporting system -- not six copies
- **Easier to maintain:** Fix a bug once, it's fixed everywhere
- **Better analytics:** One feed algorithm to tune, not six separate ranking systems
- **Cleaner database:** ~15 unified models instead of 130+ fragmented tables

#### For Growth

- **New content types are easy to add:** Want to add "Reviews" later? It's a new post type with a star rating property, not a new module with 8 database tables
- **Cross-pollination:** A user who came for videos might discover a marketplace listing in their feed, driving engagement across the platform
- **VIP and Boosted tiers create revenue:** Users and businesses pay for visibility, using the same system everywhere

---

## Summary

| Aspect                        | Current App                                                                                 | Rebuilt App                                                            |
| ----------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| **Navigation**          | Module selector + 5 tabs per module                                                         | 4 unified tabs + header icons                                          |
| **Extended features**   | 6 separate mini-apps (Blog, VIP, Notice Board, Find Discount, Lost & Found, Missing Person) | Absorbed as content types and properties within the 4 core experiences |
| **Database**            | 130+ tables with heavy duplication                                                          | ~15 unified models                                                     |
| **VIP**                 | Separate section with its own posts, comments, and navigation                               | A visibility tier and badge system applied across all content          |
| **Content discovery**   | Go to the right section, browse its dedicated feed                                          | Content mixes organically in the feeds you're already browsing         |
| **Chat**                | Shared infrastructure (good), but module-switching to reach it                              | One unified inbox accessible from every screen                         |
| **Adding new features** | Build a new module with its own tables, screens, reports, and navigation                    | Add a content type or property to the existing system                  |

The rebuild doesn't drop any features -- everything the current app offers is preserved. What changes is how it's organised. Features that were isolated become integrated. Systems that were duplicated become shared. The app goes from feeling like a collection of separate tools to feeling like one cohesive platform.

---

*Document by LionPro Dev -- February 17, 2026*
