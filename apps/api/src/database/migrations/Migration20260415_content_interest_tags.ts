import { Migration } from '@mikro-orm/migrations';

/**
 * content_interest_tags: join table mapping Content -> Interest for
 * behavioural-signal routing (D3b, unblocks D2d's interest signal emission).
 *
 * Composite PK on (content_id, interest_id). Both FKs cascade-delete.
 * assigned_by_user_id is null for system/auto-classified tags.
 *
 * Renamed from `Migration20260414_content_interest_tags.ts` to this
 * 20260415 timestamp so filename sort runs *after* the companion
 * `Migration20260414_interests.ts` (which creates the `interests` table
 * this migration FK-references). Pre-rename, a fresh DB rebuild failed
 * with `relation "interests" does not exist` because `c` sorts before
 * `i`. DDL below is idempotent — on environments that already applied
 * the pre-rename migration, re-running this file is a safe no-op.
 */
export class Migration20260415ContentInterestTags extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `create table if not exists "content_interest_tags" (
        "content_id" uuid not null,
        "interest_id" uuid not null,
        "assigned_at" timestamptz not null default now(),
        "assigned_by_user_id" uuid null,
        "confidence" double precision not null default 1.0,
        constraint "content_interest_tags_pkey" primary key ("content_id", "interest_id")
      );`,
    );
    this.addSql(
      `create index if not exists "content_interest_tags_content_id_index" on "content_interest_tags" ("content_id");`,
    );
    this.addSql(
      `create index if not exists "content_interest_tags_interest_id_index" on "content_interest_tags" ("interest_id");`,
    );
    this.addSql(
      `do $$ begin
        alter table "content_interest_tags" add constraint "content_interest_tags_content_id_foreign" foreign key ("content_id") references "content" ("id") on update cascade on delete cascade;
      exception when duplicate_object then null; end $$;`,
    );
    this.addSql(
      `do $$ begin
        alter table "content_interest_tags" add constraint "content_interest_tags_interest_id_foreign" foreign key ("interest_id") references "interests" ("id") on update cascade on delete cascade;
      exception when duplicate_object then null; end $$;`,
    );
    this.addSql(
      `do $$ begin
        alter table "content_interest_tags" add constraint "content_interest_tags_assigned_by_user_id_foreign" foreign key ("assigned_by_user_id") references "users" ("id") on update cascade on delete set null;
      exception when duplicate_object then null; end $$;`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "content_interest_tags" cascade;`);
  }
}
