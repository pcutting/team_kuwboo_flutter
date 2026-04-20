# apps/api/scripts

Ops-only shell scripts. **Not** part of the API runtime, **not** reachable
over HTTP. Each script documents its own usage in its header; read the file
before running it.

| Script                 | Purpose                                              |
|------------------------|------------------------------------------------------|
| `delete_user.sh`       | Hard-delete a test user and every row that references them. Runs on the API EC2 (needs VPC-internal psql + Secrets Manager read). Dry-run by default. |
| `delete_user.ssm.sh`   | Mac-side wrapper that ships `delete_user.sh` to the API EC2 via `aws ssm send-command` and streams output back. |

## delete_user.sh

Hard-delete a user during prototype testing. Discovers every FK that points at
`users.id` (or `users.username`) dynamically from `information_schema` so new
schema additions are swept automatically. Dry-run by default; pass `--confirm`
to mutate. Refuses by default when the target has a non-NULL `email` or an
ADMIN-ish role.

Behaviour:

1. Resolve the user id from `--by {phone|email|id} --value <v>`. For phone
   lookups, both `users.phone` and `credentials.identifier` are checked.
2. Print per-table row counts that reference the user (dry-run).
3. With `--confirm`: open one transaction, sweep transitive rows (content,
   threads, bot profiles), then loop the per-FK DELETEs up to 3 passes until
   quiescent, then delete the user. Rolls back if any FK violation remains.

Safety flags:

- `--allow-email-users` — permit deletion when `users.email IS NOT NULL`.
- `--allow-admin` — permit deletion when `users.role` is `ADMIN` / `SUPER_ADMIN` / `MODERATOR`.

### Worked example — delete test phone +16142856112

Preview on your Mac (via SSM wrapper, dry-run):

```bash
cd apps/api/scripts
bash delete_user.ssm.sh --by phone --value "+16142856112"
```

If the plan looks right, mutate:

```bash
bash delete_user.ssm.sh --by phone --value "+16142856112" --confirm
```

### Tables this script will touch (non-CASCADE / non-SET-NULL FKs on `users.id`)

Live probe at 2026-04-19 against the `kuwboo` DB:

```
bids.bidder_id                    connections.from_user_id     connections.to_user_id
blocks.blocker_id                 blocks.blocked_id            bot_profiles.user_id
comments.author_id                content.creator_id           devices.user_id
interaction_events.user_id        interaction_states.user_id   interest_signals.user_id *
media.uploader_id                 messages.sender_id           notifications.user_id
notification_preferences.user_id  reports.reporter_id          seller_ratings.buyer_id
seller_ratings.seller_id          sessions.user_id             sponsored_campaigns.advertiser_id
thread_participants.user_id       trust_signals.user_id *      user_consents.user_id
user_interests.user_id *          user_preferences.user_id     waves.from_user_id
waves.to_user_id                  yoyo_overrides.target_user_id yoyo_overrides.user_id
yoyo_settings.user_id             credentials.user_id *
```

`*` = already CASCADE and auto-deletes when the user row goes away.
`admin_audit_logs.admin_user_id`, `apple_notification_events.user_id`, and
`reports.reported_user_id`/`reported_comment_id`/`reported_content_id` are
SET NULL and are not mutated by this script.

Transitive (via `content.creator_id`): `auctions`, `content_tags`,
`interaction_events`, `interaction_states`, `seller_ratings.product_id`,
`sponsored_campaigns.content_id`, `comments.content_id`.
Via `bot_profiles`: `bot_activity_logs`.
Via `threads`: `messages`, `thread_participants` (shared threads are NOT
deleted — only this user's messages and participation are removed).

## delete_user.ssm.sh

Wrapper for running `delete_user.sh` from your Mac when you don't have VPC
access. Base64-encodes the script + args and invokes them on
`i-0766e373b3147a2aa` via SSM under the `ubuntu` user. All flags are
forwarded.

Environment overrides: `INSTANCE_ID`, `AWS_PROFILE` (default
`neil-douglas-kuwboo`), `AWS_REGION` (default `eu-west-2`).
