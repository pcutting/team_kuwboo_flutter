# Kuwboo App Rebuild -- Project Proposal

**Prepared for:** Neil Douglas / Guess This Ltd
**Prepared by:** Phil Cutting / LionPro Dev
**Date:** February 2026

---

## What You Need to Know

### Where Things Stand

- The code for your app exists, but when we actually tested it, most features do not work properly.
  - Video editing fails.
  - The login system does not function.
  - Many screens show placeholder data instead of real content.
  - Updating screens, doesn't happen in close to real time.  never mind in real time.  Ie. make a post on social and see how long it takes for it to show in the feed.
- The user interface is nearly unusable in places -- the bottom navigation is practically invisible (red on black). Basic usability was not finished.
- There is no working Android version. The Android app is roughly 65% complete with several features missing.
- There are real security problems that need fixing before anything else happens.
- Your previous developer still has access to everything -- database passwords, server credentials, the lot.

### What's at Risk

- Security holes in the system could expose user data. One vulnerability lets anyone bypass login entirely.
- The technology underneath both apps is so outdated that features which may have worked before no longer function. iOS is 5+ years behind current standards. Android libraries are 3+ years out of date. The outdated code is not just a future problem -- it is causing failures right now.
- Apple is tightening its requirements. From April 2026, app updates must use the latest development tools -- which the current app cannot support without significant changes.

### Our Recommendation

Rebuild from scratch with one modern codebase that runs on both iPhone and Android, giving you all 6 features, proper security, and a single app to maintain going forward.

---

> **Total investment: $60,000.**
> Design, development, launch, and 30 days post-launch support -- everything included.

---

## What We Found

We spent several weeks going through your iOS app (124,000 lines of code), your Android app (28,000 lines), your backend server (530 files), your AWS infrastructure, and your database. Here is what matters.

### Security

- There is a backdoor login that anyone who knows about it can use to get into the system -- no real verification needed.
- A vulnerability in your video processing system could allow an attacker to tamper with your database.
- Your previous developer still has every password and access key. Nothing has been changed since they left.

### Your App

- On paper, 3 of your 6 features (Video, Buy & Sell, Social) have code written for them. But when we tested them hands-on, key parts fail. Video editing crashes. The OTP login does not work -- the verification code system has no functioning code behind it. Many screens display mock data rather than real content.
- The app feels like multiple disconnected systems stacked together rather than one coherent product. Features exist in isolation with nothing properly connecting them.
- The user interface is unfinished. The bottom navigation bar is nearly invisible -- red icons on a black background. Basic usability was never completed.
- Dating has backend code but the mobile screens were never wired up. It does not work end-to-end.
- Yoyo (the nearby discovery feature) was paid for but never started.
- Sponsored Links were paid for but never built.

### Your Servers

- Everything runs on AWS in London, which is the right setup for UK users.
- Your database is misconfigured and wasting money. It should cost around $15 per month for the current load, not the $70 it is running at now.
- There are no automated backups configured. If something goes wrong, there is no safety net.
- There is no monitoring. If the server goes down at 3am, nobody gets alerted.

### Your Data

- All your data is intact and safe -- user accounts, videos, product listings, messages, and social posts.
- There is roughly 30 GB of content (videos, photos, and database records) stored across your servers. All of it is accessible and will be migrated to the new system.

---

## Your Options

### What's Actually Going On Under the Hood

These are facts, not opinions. They come directly from code review, infrastructure audit, and hands-on testing we completed during discovery.

- **The code looks more complete than it is.** When we read through the codebase, it appeared that Video, Buy & Sell, and Social were largely built. But when we actually ran the app and tested features, the reality is different. Video editing fails. The OTP verification has no working code behind it. Many screens show placeholder data. It is likely that outdated libraries are the cause -- the app may have worked at some point, but it does not now.
- **Nothing is properly connected.** The app feels like multiple separate systems stacked on top of each other rather than one product. Features exist in isolation. The user interface was never finished -- the bottom navigation is nearly invisible (red icons on a black background), making the app almost unusable.
- **Features that were paid for, were never delivered.** Dating has backend code but the mobile screens were never wired up. Yoyo was paid for but never started. Sponsored Links were paid for but never built. The admin panel source code was never handed over -- only a compiled version exists that cannot be modified.
- **Android and iOS are not on the same page.** iOS has more code written (~80% of features attempted). Android is about 65%. They were built by different developers using different approaches, and they do not match. Every change has to be made twice -- once for each platform.
- **Both apps have zero automated tests.** Industry standard is 60-80% test coverage. Kuwboo has 0% on both platforms. This means every change risks breaking something else with no safety net.
- **The code is built on outdated technology.** iOS uses Swift 5.0 (5+ years behind current). Android uses libraries that are 3+ years out of date. Neither platform can be updated to current standards without rewriting large portions anyway.

### Two Paths Forward

|                                    | Update What Exists                                                                         | Modern Cross-Platform Rebuild                          |
| ---------------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| **What it means**            | Fix both apps separately, try to align them                                                | One new app that runs on both iPhone and Android       |
| **Your 6 features**          | None fully working, 3 partially built, 3 missing entirely                                  | All 6 included                                         |
| **Dating & Yoyo**            | Need to be built from scratch either way                                                   | Built once, works on both platforms                    |
| **Admin panel**              | Source code lost, needs rebuilding either way                                              | Included                                               |
| **Ongoing cost to maintain** | Two separate codebases, two developers needed                                              | One codebase, one developer                            |
| **2-year total cost**        | Higher (~$128,000 including maintenance)                                                   | Lower (~$86,000 including maintenance)                 |
| **Design**                   | Modernising would preserve the old look -- wasted effort when a redesign is planned anyway | Fresh design, modern look matching the apps you admire |
| **Risk**                     | Building on weak foundations with no tests                                                 | Clean start with modern architecture                   |

Updating the current apps means trying to fix broken foundations -- code that does not work, libraries that are years out of date, and a user interface that was never finished. It costs more, takes longer to maintain, still leaves you with two separate codebases, and **does not get you Dating, Yoyo, or a working admin panel**. The rebuild gives you everything in one go, built properly from the start.

---

## Recommended Path

3 phases, 6 milestone payments. You pay when you receive the deliverable, not before.

| Phase | Milestone | What You Receive | Cost |
|---|---|---|---|
| **1. Design & Groundwork** | M1 | Professional screen designs in Figma. Security issues fixed. Server costs cut. | $10,000 |
| **2. Core App** | M2a | Working test app with video feed, recording, and editing. New backend running. | $10,000 |
| | M2b | Buy & Sell fully working. All existing user data migrated to the new system. | $10,000 |
| | M2c | Social feed, real-time chat, push notifications. Core app complete. | $10,000 |
| **3. New Features** | M3a | Dating with swipe matching. Yoyo proximity discovery. | $10,000 |
| | M3b | Sponsored Links with impression tracking. Admin panel for you. | $10,000 |
| **Total** | | | **$60,000** |

**Note on what is already started:** The project is not starting from zero. Login, navigation, project structure, and the backend framework are already in place from the discovery phase. This gives us a head start on Phase 2.

**Deployment and testing:** We use TestFlight (Apple's beta testing system) throughout development so you can see and test progress on your phone as features are completed. Once the app is ready, App Store and Google Play submission typically takes 2-4 weeks for approval. 30 days of post-launch bug support is included.

---

## What Happens Next

### To Go Ahead

Say yes, and we start within a week. To get moving, we need:

- Any brand preferences you have (logo, colours, fonts you like). If you do not have these yet, we can work with the designer to figure them out.
- A 30-minute weekly check-in at a time that works around your schedule. We will make these work for you -- evenings, weekends, whenever suits.

### What You Don't Need to Worry About

- **You do not need to understand the technical details.** That is what you are paying for.
- **Your existing users and data are safe.** We migrate everything across. Nothing gets lost.
- **Your current app keeps working during the rebuild.** Users will not notice anything until the new version is ready.
- **You are not locked in.** Milestone payments mean you keep everything delivered so far. If you ever need to stop or change direction, you own all the work completed up to that point.

### Common Questions

**Will the App Store reject it?**
We use TestFlight throughout development, which means Apple is reviewing the app long before we formally submit. By the time we go for full approval, any issues will already be sorted. App Store and Google Play approval typically takes 2-4 weeks.

**What happens after launch?**
30 days of bug fixes are included in the $60,000. After that, if you want ongoing feature development or maintenance, we can discuss a separate arrangement -- but there is no obligation.

**When will I be able to see progress?**
From Phase 2 onwards, you will have a working app on your phone via TestFlight. You will be able to tap through real features, not just look at pictures.

---

## Quick Reference

|                               |                                                           |
| ----------------------------- | --------------------------------------------------------- |
| **Total investment**    | $60,000                                                   |
| **Payment structure**   | 6 milestones of $10,000 each                              |
| **Timeline**            | ~7-9 months                                               |
| **What you get**        | New app for iPhone + Android, all 6 features, admin panel |
| **Post-launch support** | 30 days bug fixes included                                |
| **First deliverable**   | Screen designs in ~6 weeks                                |
| **Your time needed**    | 30 min/week + occasional design feedback                  |

### Glossary

**TestFlight** -- Apple's system for sharing test versions of an app before it goes live on the App Store. You download it on your iPhone and get early access to see the app as it is being built.

**Figma** -- A design tool where the designer creates all the screen layouts. You can view designs in your browser and leave comments directly on them.

**Flutter** -- The technology used to build one app that works on both iPhone and Android. Instead of building and maintaining two separate apps, we build one.
