import { Migration } from '@mikro-orm/migrations';

/**
 * Milestone 3 scaffold — Event CTI columns on `content`.
 *
 * Adds the subtype columns for the Event STI child (title, description,
 * venue, starts_at, ends_at, capacity, attendee_count). `title` and
 * `description` are also used by future WantedAd / Product refinements
 * so they're already nullable on the base table via the baseline
 * schema; this migration is additive only.
 *
 * All DDL is wrapped with `if not exists` / `do $$` idempotent guards
 * because greenfield RDS has a broken `mikro_orm_migrations` tracker
 * (see memory: reference_ec2_ops.md). Running this migration twice is
 * a no-op.
 */
export class Migration20260419EventContentColumns extends Migration {
  override async up(): Promise<void> {
    // `title` and `description` already exist on the `content` table
    // from the baseline schema (shared with Product). The Event-only
    // fields live below.
    this.addSql(
      `alter table "content" add column if not exists "venue" varchar(255) null;`,
    );
    this.addSql(
      `alter table "content" add column if not exists "starts_at" timestamptz null;`,
    );
    this.addSql(
      `alter table "content" add column if not exists "ends_at" timestamptz null;`,
    );
    this.addSql(
      `alter table "content" add column if not exists "capacity" int null;`,
    );
    this.addSql(
      `alter table "content" add column if not exists "attendee_count" int not null default 0;`,
    );

    // Helpful index for the upcoming-events query (`starts_at >= now()`
    // scoped by content type). Partial so it doesn't bloat for rows
    // where the columns are null.
    this.addSql(
      `create index if not exists "content_event_starts_at_index" ` +
        `on "content" ("starts_at") where "type" = 'EVENT';`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(`drop index if exists "content_event_starts_at_index";`);
    this.addSql(`alter table "content" drop column if exists "attendee_count";`);
    this.addSql(`alter table "content" drop column if exists "capacity";`);
    this.addSql(`alter table "content" drop column if exists "ends_at";`);
    this.addSql(`alter table "content" drop column if exists "starts_at";`);
    this.addSql(`alter table "content" drop column if exists "venue";`);
  }
}
