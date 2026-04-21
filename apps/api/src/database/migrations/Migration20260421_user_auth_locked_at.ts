import { Migration } from '@mikro-orm/migrations';

/**
 * Adds `auth_locked_at` to `users` so the login-throttle subsystem
 * can soft-lock an account when the cross-IP credential-stuffing
 * detector crosses its threshold (issue #174 phase 2).
 *
 * The column is nullable and has no default — the vast majority of
 * accounts sit at `NULL` (never locked). Recovery requires the
 * user to complete the password-reset flow; `emailResetPassword`
 * clears the column as part of the reset transaction.
 *
 * Uses `if not exists` so a repeat apply is a no-op — same pattern
 * as Migration20260420_media_transcoded_url.
 */
export class Migration20260421UserAuthLockedAt extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `alter table "users" add column if not exists "auth_locked_at" timestamptz null;`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(
      `alter table "users" drop column if exists "auth_locked_at";`,
    );
  }
}
