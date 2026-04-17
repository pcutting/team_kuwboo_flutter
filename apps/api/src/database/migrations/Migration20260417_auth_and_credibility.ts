import { Migration } from '@mikro-orm/migrations';

/**
 * Auth + credibility extensions:
 *
 *   - `users.email_verified` / `users.email_verified_at` track whether the
 *     user has proven control of the email on file (distinct from whether
 *     a credential row exists).
 *   - `users.credibility_score` is the cached numeric aggregate consumed
 *     by feed ranking and trust tiers. The source of truth remains the
 *     `trust_signals` append-only ledger; this column is a denormalised
 *     sum maintained by the trust module.
 *   - `users.dob_choice` captures the onboarding answer the user gave
 *     at the DOB step. Stored as a free-form `varchar(32)` so we can
 *     extend the allowed values (e.g. `guardian_verified`) without a
 *     further migration. Application-level enum is `DobChoice`.
 *   - `users.age_verification_status` check constraint is widened to
 *     accept the two new values (`self_declared_adult`,
 *     `prefer_not_to_say`) introduced alongside `dob_choice`.
 *   - `content.thumbnail_url` is promoted to a first-class field on the
 *     Content base (the column already exists from the baseline schema
 *     — it was treated as a Video-only attribute). We leave the column
 *     in place and only surface it in the ORM model here; there is no
 *     DDL to add for thumbnail_url.
 */
export class Migration20260417AuthAndCredibility extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `alter table "users"
        add column "email_verified" boolean not null default false,
        add column "email_verified_at" timestamptz null,
        add column "credibility_score" int not null default 0,
        add column "dob_choice" varchar(32) null;`,
    );

    // Widen the age_verification_status check constraint. Postgres does
    // not support `ALTER ... SET CHECK`, so drop + re-add.
    this.addSql(
      `alter table "users" drop constraint if exists "users_age_verification_status_check";`,
    );
    this.addSql(
      `alter table "users"
        add constraint "users_age_verification_status_check"
        check ("age_verification_status" in
          ('unverified',
           'self_declared',
           'self_declared_adult',
           'prefer_not_to_say',
           'provider_verified',
           'failed'));`,
    );

    // `content.thumbnail_url` already exists (baseline schema created
    // it for the Video STI subtype). No DDL needed.
  }

  override async down(): Promise<void> {
    // Nothing to drop for `content.thumbnail_url` — it predates this
    // migration.

    this.addSql(
      `alter table "users" drop constraint if exists "users_age_verification_status_check";`,
    );
    this.addSql(
      `alter table "users"
        add constraint "users_age_verification_status_check"
        check ("age_verification_status" in
          ('unverified', 'self_declared', 'provider_verified', 'failed'));`,
    );

    this.addSql(
      `alter table "users"
        drop column if exists "email_verified",
        drop column if exists "email_verified_at",
        drop column if exists "credibility_score",
        drop column if exists "dob_choice";`,
    );
  }
}
