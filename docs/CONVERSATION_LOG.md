# Conversation Log

Structured log of client conversations between Neil Douglas and Phil Cutting regarding the Kuwboo project.

---

## #1 — Upwork Chat Thread (Pre-Discovery)

| Field | Detail |
|-------|--------|
| **Dates** | Jan 5 – Feb 6, 2026 |
| **Participants** | Neil Douglas (Client), Phil Cutting (Contractor) |
| **Type** | Upwork messaging (asynchronous text) |
| **Includes** | 3 Zoom calls embedded (Jan 5 ~33min, Jan 24 ~25min, Feb 5 ~31min) |

### Timeline Summary

**Jan 5** — First contact. Neil reached out after Upwork shared Phil's profile. Phil had responded to Upwork's referral with a detailed introduction covering transition experience and methodology.

**Jan 5 (evening)** — Neil shared the TestFlight link for Phil to review the app. OTP code for testing: `4444`. Neil provided his initial assessment:
- Video making and buy/sell are "in the right direction"
- All other modules are "poor design and not modern app look or feel"

**Jan 5 — Design Reference Statement (key quote):**
> "I'm looking for a full look and feel like whatts app snap chat and instagram and facebook ect. These are leading platforms out there and if kuwboo is not alike it would stand a chance"

**Jan 5** — First Zoom call (~33 min). Phil proposed $5,000 discovery phase. Neil shared company address for NDA (Guess This Ltd, 15 Lord Porter Avenue, Stainforth, Doncaster, UK).

**Jan 6–7** — Neil attempted to get AWS access. Friend helped reset AWS password.

**Jan 8–17** — Access delays. Upwork blocked credential sharing before contract. Neil's son was hospitalized. Neil works night shifts as HGV driver, limiting availability. Phil recommended starting the fixed-price discovery contract to unblock credential sharing.

**Jan 18–23** — Scheduling difficulties. Neil working nights, long shifts (up to 18 hours). Mark (Upwork manager) helping Neil set up the contract. Multiple missed call attempts.

**Jan 24** — Second Zoom call (~25 min). Discovery contract created and funded immediately after. $5,000 fixed-price milestone. Phil outlined full discovery scope of work including:
- Code & system review
- Live system review
- Product & UX direction (explicitly referencing Snapchat and Instagram as benchmarks)
- Planning, staging & milestones
- Minimum 2 live discovery calls

**Jan 24 (evening)** — Neil shared AWS credentials and access. Phil got into AWS account with Neil providing OTPs in real-time.

**Jan 25** — Vikrant (previous developer) sent Dropbox link with iOS codebase (608 MB) and Android codebase (21 MB). Phil uploaded copies to Upwork for Neil's records. Phil requested backend code and .env files. Vikrant sent Neil a link to "Shortze" (a different app by Codiant) saying "go for this and crack the market" instead of providing the requested code.

**Jan 26** — Neil provided his module priority list:
1. Video Making
2. Dating
3. Social
4. Buy and Sell
5. Yoyo
6. Sponsored ads with payment gateway

Said he's OK dropping other modules if needed.

**Jan 27–28** — Vikrant went silent. No backend code or admin panel source provided.

**Jan 28** — Phil reported completing iOS code review, SSL certificate renewal (was expired), fixed API endpoint, and iOS builds running on simulator.

**Jan 30** — Neil revised priority list:
1. Video Making
2. Buy and Sell
3. Dating
4. Yoyo
5. Sponsored Links
6. Social

**Feb 3–5** — Multiple scheduling attempts. Neil repeatedly apologetic about delays due to demanding night driving schedule ("18 hour shift"). Third Zoom call on Feb 5 (~31 min) with connection issues.

**Feb 6** — Apple ID / TestFlight access discussion. Neil's Apple ID email is his Hotmail, not the iCloud email (which he avoids using).

### Design & Appearance References

| App | Who Said It | Context | Source |
|-----|-------------|---------|--------|
| **WhatsApp** | Neil | "Full look and feel like..." | Upwork chat, Jan 5 |
| **Snapchat** | Neil | "Full look and feel like..." | Upwork chat, Jan 5 |
| **Instagram** | Neil | "Full look and feel like..." | Upwork chat, Jan 5 |
| **Facebook** | Neil | "Full look and feel like..." | Upwork chat, Jan 5 |
| **Snapchat** | Phil | UX evaluation benchmark in discovery scope | Contract scope, Jan 24 |
| **Instagram** | Phil | UX evaluation benchmark in discovery scope | Contract scope, Jan 24 |

**Neil's design statements (direct quotes):**
> "I feel he did the video making in the right direction And the buy and sell in the right direction But all other modus are poor design and not modern app look or feel"

> "I'm looking for a full look and feel like whatts app snap chat and instagram and facebook ect These are leading platforms out there and if kuwboo is not alike it would stand a chance"

### Code Handover Status (as of Feb 6)

| Asset | Status | Source |
|-------|--------|--------|
| iOS codebase | Received (608 MB zip) | Vikrant via Dropbox |
| Android codebase | Received (21 MB zip) | Vikrant via Dropbox |
| Backend code | Extracted from server by Phil | EC2 instance |
| Database dump | Extracted by Phil | EC2 instance |
| Admin panel source | Not received (only compiled build) | Never provided |
| .env / credentials | Extracted from server | EC2 instance |
| SSH key | Not provided | Vikrant unresponsive |

### Key Decisions

1. Fixed-price $5,000 discovery milestone (not hourly — Phil advised against hourly billing)
2. Discovery has 14-day payment release + 90-day extended window for thoroughness
3. 6 core modules prioritized; Neil OK dropping others
4. All future work to be milestone-based with defined deliverables
5. Phil to maintain infrastructure oversight (billing access enabled on AWS)

### Action Items

| # | Owner | Action | Status |
|---|-------|--------|--------|
| 1 | Neil | Fund discovery milestone ($5,000) | Completed (Jan 24) |
| 2 | Neil | Share AWS credentials | Completed (Jan 24) |
| 3 | Neil | Request backend source from Vikrant | Done — Vikrant unresponsive |
| 4 | Neil | Request admin panel source from Vikrant | Done — Vikrant unresponsive |
| 5 | Phil | Renew SSL certificate | Completed |
| 6 | Phil | Fix iOS build (API endpoint, SDK update) | Completed |
| 7 | Phil | Full iOS codebase audit | Completed |
| 8 | Phil | Android codebase audit | In progress |
| 9 | Phil | Extract backend code from server | Completed |
| 10 | Neil | Update Apple age rating (App Store Connect, due Jan 31) | Pending |
| 11 | Neil | Confirm Apple ID email for TestFlight | Completed (neildouglas33@hotmail.co.uk) |

### Notable Context

- Neil works demanding night shifts as an HGV driver, severely limiting daytime availability
- His son was hospitalized twice during this period (Jan 14 and Jan 24)
- Neil is extremely apologetic about delays — Phil consistently patient and understanding
- Vikrant (previous dev) became unresponsive when asked for source code; sent a link to a different app ("Shortze") instead of providing requested assets
- Neil described Vikrant as a "100% distance liar" who "had me over a barrel" because he held the code
- Phil emphasized getting Neil proper control of his codebase and infrastructure to prevent future dependency on any single developer
- The project has been in development for "just under 5 years" according to Neil
- Neil explicitly said he's "really crap at this" regarding technical tasks — relies heavily on guidance
- Upwork blocks sharing contact information before a contract starts, which delayed initial access

---

## #2 — Introductory Call (First Zoom)

| Field | Detail |
|-------|--------|
| **Date** | January 5, 2026 |
| **Participants** | Neil Douglas (Client), Phil Cutting (Contractor) |
| **Type** | Video call (Upwork Zoom) |
| **Duration** | ~33 minutes |

### Background & Context

- Neil's previous developer (Codiant/Vikrant) spent approximately 4 years and ~£50K on the project with poor results
- The previous developer was suspended from Upwork; Upwork credited Neil ~$4,000 as goodwill
- Upwork account managers (Mark, Ferdy) are actively supporting Neil in finding a reliable replacement
- Neil found Phil through Upwork and wanted to discuss taking over the project

### Key Topics Discussed

1. **Project History** — Neil outlined the troubled development history: drawn-out timelines, poor design quality, and modules paid for but never delivered
2. **Neil's Vision** — Wants modern design matching leading platforms; on the call he specifically cited Facebook-quality as the benchmark. In the Upwork chat just before the call he also named WhatsApp, Snapchat, and Instagram (see Chat Thread #1 above)
3. **Module Status Assessment:**
   - **Video Making & Buy/Sell** — Partially built but with poor design
   - **Dating** — Very weak implementation
   - **Introduction Module** (proximity-based social discovery, similar to Happn/Bumble BFF/WeChat "People Nearby") — Paid for but never started
   - **Sponsored Links/Advertising** — Paid for but never built
4. **Payment Gateways** — Neil wants Apple Pay, PayPal, and Google Pay integrated
5. **Timeline & Budget** — Neil is comfortable with a 12–18 month timeline and prefers milestone-based payments
6. **Module Strategy** — Neil is open to Phil's professional guidance on which modules to keep, cut, or adjust based on feasibility and market fit
7. **Discovery Phase** — Phil proposed a $5,000 discovery phase (discounted from typical $6–8K range), covered by Upwork's $4K credit plus $1K from Neil
8. **AWS Access** — Previous developer changed the AWS account email/password; Neil has an open support ticket with AWS to regain access
9. **NDA** — Mutual NDA to be signed; Neil's company is Guess This Limited (UK)
10. **Long-Term Partnership** — Neil expressed interest in a long-term working relationship and mentioned potential equity share

### Reference Apps Mentioned

| App | Context | Source |
|-----|---------|--------|
| Facebook | Overall quality benchmark for design and UX | Call (direct quote) |
| WhatsApp | "Full look and feel like..." | Upwork chat (pre-call) |
| Snapchat | "Full look and feel like..." | Upwork chat (pre-call) |
| Instagram | "Full look and feel like..." | Upwork chat (pre-call) |
| Happn | Model for the "Introduction" proximity-based discovery module | Call |
| Bumble BFF | Alternative reference for social proximity features | Call |
| WeChat "People Nearby" | Another reference for proximity-based social discovery | Call |

### Decisions Made

1. Phil will conduct a paid discovery phase before committing to rebuild estimates
2. Discovery priced at $5,000 (milestone-based via Upwork)
3. Mutual NDA required before sharing credentials/code access
4. Milestone-based payment structure for all future work

### Action Items

| # | Owner | Action | Status |
|---|-------|--------|--------|
| 1 | Neil | Speak with Upwork managers (Mark & Ferdy) about engagement structure | Completed |
| 2 | Neil | Resolve AWS account access (support ticket submitted) | Completed |
| 3 | Neil | Send company address details for NDA | Completed |
| 4 | Phil | Send mutual NDA to Neil | Completed |
| 5 | Phil | Begin discovery phase once access granted ($5,000 milestone) | Completed |

### Notable Context

- Neil has been through a difficult experience with the previous developer and values transparency and honest communication
- The Upwork goodwill credit indicates the platform acknowledged the previous engagement was problematic
- Neil is non-technical but has a clear vision for what the app should feel like — modern, polished, matching WhatsApp/Snapchat/Instagram/Facebook quality (all four named explicitly)
- The introduction/proximity module was a significant undelivered piece that Neil had already paid for

---

*This log is for internal project reference only. Do not share externally.*
