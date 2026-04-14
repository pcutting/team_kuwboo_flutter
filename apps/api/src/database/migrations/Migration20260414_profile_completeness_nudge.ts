import { Migration } from '@mikro-orm/migrations';

/**
 * Profile-completeness nudge pipeline (D3a).
 *
 * Adds `users.last_profile_reminder_at` + a partial index that makes the
 * daily eligibility scan (`profile_completeness_pct < 70` AND
 * `onboarding_progress = 'complete'`) cheap even at millions of rows.
 *
 * See IDENTITY_CONTRACT §8 for the reminder policy.
 */
export class Migration20260414ProfileCompletenessNudge extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `alter table "users"
        add column "last_profile_reminder_at" timestamptz null;`,
    );
    this.addSql(
      `create index "ix_users_profile_reminder_eligible"
        on "users" ("profile_completeness_pct", "last_profile_reminder_at")
        where "onboarding_progress" = 'complete'
          and "profile_completeness_pct" < 70;`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(`drop index if exists "ix_users_profile_reminder_eligible";`);
    this.addSql(
      `alter table "users" drop column if exists "last_profile_reminder_at";`,
    );
  }
}
