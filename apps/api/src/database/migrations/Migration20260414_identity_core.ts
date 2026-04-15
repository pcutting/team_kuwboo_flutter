import { Migration } from '@mikro-orm/migrations';

/**
 * Identity core: credentials + trust_signals tables, plus user columns for
 * onboarding/profile-completeness/tutorial state.
 *
 * Implements IDENTITY_CONTRACT §3.2–3.5.
 *
 * NOTE: this migration intentionally leaves the legacy columns on `users`
 * (`phone`, `email`, `google_id`, `apple_id`, `password_hash`) in place.
 * They are being superseded by rows in `credentials`, but removing them in
 * the same migration as the credentials table creation would break the
 * refactored auth service during rollout. A follow-up migration will drop
 * them once the auth flow has been migrated and back-filled.
 */
export class Migration20260414IdentityCore extends Migration {
  override async up(): Promise<void> {
    // --- credentials ----------------------------------------------------
    this.addSql(
      `create table "credentials" (
        "id" uuid not null,
        "user_id" uuid not null,
        "type" text check ("type" in ('phone', 'email', 'google', 'apple')) not null,
        "identifier" varchar(320) not null,
        "provider_data" jsonb null,
        "verified_at" timestamptz not null,
        "is_primary" boolean not null default false,
        "revoked_at" timestamptz null,
        "created_at" timestamptz not null default now(),
        "last_used_at" timestamptz null,
        constraint "credentials_pkey" primary key ("id")
      );`,
    );
    this.addSql(
      `alter table "credentials" add constraint "credentials_type_identifier_unique" unique ("type", "identifier");`,
    );
    this.addSql(
      `create index "credentials_user_id_index" on "credentials" ("user_id");`,
    );
    this.addSql(
      `create index "credentials_type_identifier_index" on "credentials" ("type", "identifier");`,
    );
    this.addSql(
      `create unique index "credentials_user_primary_active_unique"
        on "credentials" ("user_id", "type")
        where "is_primary" = true and "revoked_at" is null;`,
    );
    this.addSql(
      `alter table "credentials"
        add constraint "credentials_user_id_foreign"
        foreign key ("user_id") references "users" ("id") on delete cascade;`,
    );

    // --- trust_signals --------------------------------------------------
    this.addSql(
      `create table "trust_signals" (
        "id" uuid not null,
        "user_id" uuid not null,
        "signal_type" varchar(64) not null,
        "delta" int not null,
        "source" varchar(32) null,
        "metadata" jsonb null,
        "expires_at" timestamptz null,
        "created_at" timestamptz not null default now(),
        constraint "trust_signals_pkey" primary key ("id")
      );`,
    );
    this.addSql(
      `create index "trust_signals_user_id_index" on "trust_signals" ("user_id");`,
    );
    // Plain index on user_id — a partial predicate referencing `now()`
    // is rejected by Postgres ("functions in index predicate must be
    // marked IMMUTABLE") so we keep the index total. Query planner can
    // still use it for the common lookup path; the `expires_at` filter
    // is applied afterwards.
    this.addSql(
      `create index "trust_signals_user_active_index"
        on "trust_signals" ("user_id", "expires_at");`,
    );
    this.addSql(
      `alter table "trust_signals"
        add constraint "trust_signals_user_id_foreign"
        foreign key ("user_id") references "users" ("id") on delete cascade;`,
    );

    // --- users extensions ----------------------------------------------
    this.addSql(
      `alter table "users"
        add column "username" varchar(50) null,
        add column "bio" text null,
        add column "birthday_skipped" boolean not null default false,
        add column "onboarding_progress" text
          check ("onboarding_progress" in
            ('welcome', 'method', 'phone', 'otp', 'birthday',
             'profile', 'interests', 'tutorial', 'complete'))
          not null default 'welcome',
        add column "profile_completeness_pct" int not null default 0,
        add column "tutorial_version" int not null default 0,
        add column "tutorial_completed_at" timestamptz null,
        add column "last_reminder_at" timestamptz null,
        add column "last_login_at" timestamptz null,
        add column "age_verification_status" text
          check ("age_verification_status" in
            ('unverified', 'self_declared', 'provider_verified', 'failed'))
          not null default 'self_declared';`,
    );
    this.addSql(
      `alter table "users" add constraint "users_username_unique" unique ("username");`,
    );
    this.addSql(
      `create index "users_onboarding_progress_incomplete_index"
        on "users" ("onboarding_progress")
        where "onboarding_progress" != 'complete';`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(`drop index if exists "users_onboarding_progress_incomplete_index";`);
    this.addSql(`alter table "users" drop constraint if exists "users_username_unique";`);
    this.addSql(
      `alter table "users"
        drop column if exists "username",
        drop column if exists "bio",
        drop column if exists "birthday_skipped",
        drop column if exists "onboarding_progress",
        drop column if exists "profile_completeness_pct",
        drop column if exists "tutorial_version",
        drop column if exists "tutorial_completed_at",
        drop column if exists "last_reminder_at",
        drop column if exists "last_login_at",
        drop column if exists "age_verification_status";`,
    );
    this.addSql(`drop table if exists "trust_signals" cascade;`);
    this.addSql(`drop table if exists "credentials" cascade;`);
  }
}
