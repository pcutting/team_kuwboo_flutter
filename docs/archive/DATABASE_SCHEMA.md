> **DEPRECATED** — Superseded by team/internal/TECHNICAL_DESIGN.md (32-entity MikroORM schema). Retained for historical context.

# Database Schema - Kuwboo

**Database:** `kuwboo_db_stag`
**Engine:** Aurora MySQL 8.0
**Tables:** 130
**Dump Location:** `docs/database/kuwboo_db_dump_20260126.sql` (34MB)

---

## Module Key Architecture (Critical Concept)

Kuwboo uses a **shared infrastructure pattern** where core tables serve multiple distinct feature modules. The `moduleKey` discriminator field determines which app feature a record belongs to.

**Why this matters:**
- **Chat/threads are shared** - A single `threads` table serves video DMs, marketplace inquiries, dating matches, and social messages
- **Followers can be per-module** - Users can follow someone's videos without following their marketplace activity
- **Queries must filter** - Most queries need `WHERE moduleKey = 'video_making'` or similar
- **Categories are separate** - Each module has its own category table (not a shared taxonomy)

### Core Modules (from `Thread.moduleKey` enum)

| Module | Description |
|--------|-------------|
| `video_making` | TikTok-like video feed |
| `buy_sell` | Marketplace for buying/selling |
| `dating` | Dating/matching profiles |
| `social_stumble` | Social discovery feed |

Extended modules (from `MediaTemp`):
- `blog` - Blog posts
- `notice-board` - Announcements
- `vip-page` - VIP/brand pages
- `find-discount` - Discount listings
- `lost-and-found` - Lost/stolen items
- `missing-person` - Missing person reports

---

## Category Tables Summary

### categories (Generic - appears unused)
Empty table, generic category structure.

### video_categories (27 categories)
Used for video feed content categorization.

| ID | Name |
|----|------|
| 1 | Adrenalin |
| 2 | Airplanes/trains |
| 3 | Boats |
| 4 | Building |
| 5 | Cars |
| 6 | Dinosaurs |
| 7 | Drug/alcohol advice |
| 8 | Education |
| 9 | Electrical |
| 10 | Entertainment |
| 11 | Funny |
| 12 | Garden |
| 13 | Health |
| 14 | History |
| 15 | Legal |
| 16 | Life/Advice |
| 17 | Medical |
| 18 | Movies |
| 19 | News |
| 20 | Random |
| 21 | Religion |
| 22 | Sex/education |
| 23 | Space/universe |
| 24 | Sports |
| 25 | Super natural |
| 26 | Thinking of you |
| 27 | Welfare |

### buy_sell_categories (54 categories)
Hierarchical marketplace categories (supports parent_id).

**Active Top-Level Categories:**
| ID | Name |
|----|------|
| 2 | Antiques |
| 4 | Books & magazines & comic |
| 5 | Business & industrial & office |
| 6 | Camera & photographer |
| 7 | Cars & vehicle & motorcycle |
| 8 | Cloths & shoes & accessories |
| 9 | Coins |
| 10 | Collectibles |
| 11 | Computers & tablets & networking |
| 12 | Crafts |
| 13 | Dolls & teddy's |
| 14 | Events & tickets |
| 15 | Film & tv & pantomime |
| 16 | Garden & garden furniture |
| 18 | Holiday & travel |
| 19 | Home & furniture & D.I.Y |
| 20 | Jewellery & watches |
| 21 | Mobile phones & communication |
| 22 | Music |
| 23 | Musical instruments |
| 24 | Pets & pet accessories |
| 25 | Porcelain & pottery & glass |
| 26 | Property for sale |
| 27 | Sound & vision |
| 28 | Sporting goods |
| 29 | Sports memorabilia |
| 30 | Stamps |
| 31 | Toys & games |
| 32 | Vehicle & parts & accessories |
| 33 | Video games & consoles |
| 34 | Wholesale & bundle bye |
| 35 | Anything else |
| 38 | Unique |
| 41 | Art |
| 43 | Updated time Carss |
| 44 | Laptops |
| 45 | Vintage Cars |
| 46 | Artificial intelligence AI |
| 47 | Tech12 Innovation12 |
| 49 | Antiquess |
| 50 | Miscellaneous Topics |
| 51 | BMW M8 |
| 52 | Drones |
| 53 | Newly |
| 54 | laundry for Clothing |

### blog_categories (30 categories)
Same structure as video_categories, used for blog posts.

### notice_board_categories
Similar to video_categories, used for notice board posts.

---

## All Tables by Feature

### Users & Authentication (20 tables)

| Table | Columns | Purpose |
|-------|---------|---------|
| `users` | email, password, name, username, bio, phone, userType (admin/user/approver/subadmin), status, gender, etc. | Main user table |
| `user_addresses` | userId, address fields | User addresses |
| `user_blocks` | userId, blockedUserId | Blocked users |
| `user_devices` | userId, deviceToken, platform (web/ios/android) | Push notification tokens |
| `user_feedback` | userId, feedback | User feedback |
| `user_followers` | userId, followerId | Follower relationships |
| `user_follower_by_modules` | userId, followerId, module | Per-module followers |
| `user_friends` | userId, friendId | Friend relationships |
| `user_friend_requests` | userId, friendId, status (pending/accepted/rejected) | Friend requests |
| `user_hobbies` | userId, hobby | User hobbies |
| `user_image_galleries` | userId, image | Profile gallery |
| `user_interests` | userId, interest | User interests |
| `user_languages` | userId, languageId | Language preferences |
| `user_match_profiles` | userId, matchedUserId | Dating matches |
| `user_roles` | name, permissions | Role definitions |
| `user_sessions` | userId, token | Active sessions |
| `user_settings` | userId, various settings | User preferences |
| `user_tokens` | userId, token, platform, status | Auth tokens |
| `login_logs` | userId, ip, timestamp | Login history |
| `dating_unmatch_profiles` | userId, unmatchedUserId | Unmatched profiles |

### Video Making / Feed (15 tables)

| Table | Purpose |
|-------|---------|
| `feeds` | Video posts with status (active/inprocess/inactive/deleted), privacy (public/follower/private) |
| `feed_approval_histories` | Approval workflow for videos |
| `feed_category` | Feed-to-category mappings |
| `feed_collections` | User collections of saved videos |
| `feed_comments` | Comments on videos |
| `feed_job_queues` | Video processing queue (inprocess/completed) |
| `feed_languages` | Language tags for videos |
| `feed_likes` | Video likes |
| `feed_shares` | Share tracking (whatsapp) |
| `feed_tags` | Hashtags on videos |
| `feed_views` | View counts |
| `feed_view_histories` | Detailed view history |
| `collections` | Named video collections |
| `collection_feeds` | Videos in collections |
| `collection_tracks` | Audio tracks in collections |

### Audio/Music (7 tables)

| Table | Purpose |
|-------|---------|
| `albums` | Music albums |
| `artists` | Artist profiles |
| `audio_artists` | Artist-to-track links |
| `audio_tracks` | Audio files for videos |
| `audio_track_claims` | Copyright claims (pending/claimed/rejected) |
| `audio_track_favorites` | Favorited tracks |
| `favorite_tags` | Favorite hashtags |

### Buy & Sell (10 tables)

| Table | Purpose |
|-------|---------|
| `buy_sell_products` | Product listings |
| `buy_sell_product_images` | Product images |
| `buy_sell_product_tags` | Product tags |
| `buy_sell_categories` | Hierarchical categories |
| `buy_sell_conditions` | Item condition options |
| `buy_sell_consents` | Purchase agreements |
| `buy_sell_favorite_products` | Wishlist |
| `bids` | Auction bids |
| `product_messages` | Product inquiries |

### Social Stumble (11 tables)

| Table | Purpose |
|-------|---------|
| `social_stumbles` | Social posts |
| `social_stumble_albums` | Photo albums |
| `social_stumble_album_galleries` | Album photos |
| `social_stumble_comments` | Comments |
| `social_stumble_events` | Events |
| `social_stumble_galleries` | Post images |
| `social_stumble_like_dislikes` | Likes/dislikes |
| `social_stumble_saved_posts` | Saved posts |
| `social_stumble_tags` | Tags |
| `social_stumble_user_tags` | User mentions |

### Blog (7 tables)

| Table | Purpose |
|-------|---------|
| `blogs` | Blog posts with privacy (public/follower/private) |
| `blog_bookmarks` | Saved blogs |
| `blog_categories` | Blog categories |
| `blog_comments` | Comments |
| `blog_like_dislikes` | Likes/dislikes |
| `blog_tags` | Tags |
| `user_blog_categories` | User category preferences |

### Notice Board (8 tables)

| Table | Purpose |
|-------|---------|
| `notice_boards` | Notices/announcements |
| `notice_board_categories` | Categories |
| `notice_board_comments` | Comments |
| `notice_board_images` | Images |
| `notice_board_like_dislikes` | Likes/dislikes |
| `notice_board_tags` | Tags |
| `user_notice_board_categories` | User category preferences |

### VIP Pages (9 tables)

| Table | Purpose |
|-------|---------|
| `vip_pages` | VIP/brand pages |
| `vip_page_images` | Page images |
| `vip_page_posts` | Page posts |
| `vip_page_post_comments` | Post comments |
| `vip_page_post_images` | Post images |
| `vip_page_post_like_dislikes` | Post likes/dislikes |
| `vip_page_post_links` | External links |
| `vip_page_user_joins` | Page members |

### Find Discount (4 tables)

| Table | Purpose |
|-------|---------|
| `find_discounts` | Discount listings |
| `find_discount_favorites` | Saved discounts |
| `find_discount_followers` | Store followers |
| `find_discount_images` | Discount images |

### Lost & Found (3 tables)

| Table | Purpose |
|-------|---------|
| `lost_and_founds` | Items with type (lost/found/stolen) |
| `lost_and_found_images` | Item images |

### Missing Person (2 tables)

| Table | Purpose |
|-------|---------|
| `missing_person_infos` | Missing person reports |
| `missing_person_images` | Person images |

### Chat/Messaging (7 tables)

| Table | Purpose |
|-------|---------|
| `threads` | Chat threads (single/group) with moduleKey |
| `thread_users` | Thread participants |
| `chats` | Messages with status (sent/delivered/seen), type (text/offer/feed/request) |
| `chat_media` | Message attachments |
| `messages` | System messages |
| `delete_chat_histories` | Deleted chat tracking |
| `notifications` | Push notifications |

### Reports (11 tables)

| Table | Purpose |
|-------|---------|
| `report_blogs` | Blog reports |
| `report_feeds` | Feed reports with status (pending/action_taken) |
| `report_find_discounts` | Discount reports |
| `report_lost_and_founds` | Lost item reports |
| `report_missing_persons` | Missing person reports |
| `report_missing_person_infos` | Report details |
| `report_notice_boards` | Notice reports |
| `report_social_stumbles` | Social reports |
| `report_users` | User reports |
| `report_vip_pages` | VIP page reports |
| `report_vip_page_posts` | VIP post reports |

### System/Config (14 tables)

| Table | Purpose |
|-------|---------|
| `categories` | Generic categories (unused) |
| `video_categories` | Video feed categories |
| `countries` | Country list |
| `states` | State/province list |
| `cities` | City list |
| `currencies` | Currency list |
| `languages` | Language list |
| `cms` | CMS content pages |
| `faqs` | FAQ entries |
| `settings` | App settings |
| `interval_settings` | Timing configurations |
| `role_permissions` | Role-based permissions |
| `tags` | Global hashtags |
| `media_temps` | Temporary media storage |
| `search_preferences` | Search preferences |
| `social_profile_links` | Social media links |
| `topic_notifications` | Topic subscriptions |
| `change_mobile_histories` | Phone number change history |
| `SequelizeMeta` | Migration tracking |

---

## Key Enums

### User Types
```sql
ENUM('admin', 'user', 'approver', 'subadmin')
```

### Status (common)
```sql
ENUM('active', 'inactive', 'deleted')
ENUM('active', 'pending', 'inactive', 'deleted')  -- for users
```

### Privacy
```sql
ENUM('public', 'follower', 'private')
```

### Platform
```sql
ENUM('web', 'ios', 'android')
```

### Chat
```sql
-- Thread type
ENUM('single', 'group')

-- Module key
ENUM('video_making', 'buy_sell', 'dating', 'social_stumble')

-- Message status
ENUM('sent', 'delivered', 'seen')

-- Message type
ENUM('text', 'offer', 'feed', 'request')
```

### Lost & Found
```sql
ENUM('lost', 'found', 'stolen')
```

---

## Database Connection

**Host:** `kuwboo-db-staging.cluster-cepsv4bfmn1r.eu-west-2.rds.amazonaws.com`
**Port:** 3306
**Database:** `kuwboo_db_stag`
**User:** `admin`
**Password:** In `backend/kuwboo-api/.env`

---

*Schema documented January 26, 2026*
