import { Migration } from '@mikro-orm/migrations';

/**
 * Interests: declared (user_interests) + behavioural (interest_signals) tables
 * plus the admin-managed `interests` taxonomy.
 *
 * See docs/team/internal/IDENTITY_CONTRACT.md §3.6 and §9-11.
 *
 * Note: the contract describes composite PKs on (user_id, interest_id) for
 * user_interests and interest_signals. This implementation uses a surrogate
 * UUID PK plus a UNIQUE(user_id, interest_id) constraint to match the existing
 * project convention (see interaction_states). Uniqueness semantics are
 * preserved; upserts target the unique constraint.
 */
export class Migration20260414Interests extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `create table "interests" (
        "id" uuid not null,
        "slug" text not null,
        "label" text not null,
        "category" text null,
        "display_order" int not null default 0,
        "is_active" boolean not null default true,
        "created_at" timestamptz not null default now(),
        "updated_at" timestamptz not null default now(),
        constraint "interests_pkey" primary key ("id")
      );`,
    );
    this.addSql(`alter table "interests" add constraint "interests_slug_unique" unique ("slug");`);
    this.addSql(
      `create index "interests_is_active_display_order_index" on "interests" ("is_active", "display_order");`,
    );

    this.addSql(
      `create table "user_interests" (
        "id" uuid not null,
        "user_id" uuid not null,
        "interest_id" uuid not null,
        "selected_at" timestamptz not null default now(),
        constraint "user_interests_pkey" primary key ("id")
      );`,
    );
    this.addSql(
      `alter table "user_interests" add constraint "user_interests_user_id_interest_id_unique" unique ("user_id", "interest_id");`,
    );
    this.addSql(
      `create index "user_interests_user_id_index" on "user_interests" ("user_id");`,
    );
    this.addSql(
      `create index "user_interests_interest_id_index" on "user_interests" ("interest_id");`,
    );
    this.addSql(
      `alter table "user_interests" add constraint "user_interests_user_id_foreign" foreign key ("user_id") references "users" ("id") on delete cascade;`,
    );
    this.addSql(
      `alter table "user_interests" add constraint "user_interests_interest_id_foreign" foreign key ("interest_id") references "interests" ("id") on delete cascade;`,
    );

    this.addSql(
      `create table "interest_signals" (
        "id" uuid not null,
        "user_id" uuid not null,
        "interest_id" uuid not null,
        "weight" double precision not null default 0,
        "event_count" int not null default 0,
        "last_seen_at" timestamptz not null default now(),
        constraint "interest_signals_pkey" primary key ("id")
      );`,
    );
    this.addSql(
      `alter table "interest_signals" add constraint "interest_signals_user_id_interest_id_unique" unique ("user_id", "interest_id");`,
    );
    this.addSql(
      `create index "interest_signals_user_id_index" on "interest_signals" ("user_id");`,
    );
    this.addSql(
      `alter table "interest_signals" add constraint "interest_signals_user_id_foreign" foreign key ("user_id") references "users" ("id") on delete cascade;`,
    );
    this.addSql(
      `alter table "interest_signals" add constraint "interest_signals_interest_id_foreign" foreign key ("interest_id") references "interests" ("id") on delete cascade;`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "interest_signals" cascade;`);
    this.addSql(`drop table if exists "user_interests" cascade;`);
    this.addSql(`drop table if exists "interests" cascade;`);
  }
}
