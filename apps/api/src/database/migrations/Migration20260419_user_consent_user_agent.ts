import { Migration } from '@mikro-orm/migrations';

/**
 * Adds `user_agent` to `user_consents` so the T&P consent audit trail
 * captured at registration (PR B) includes the exact UA string the
 * acceptance came from. Nullable because rows written before this
 * migration have no UA to backfill from.
 *
 * All DDL uses `if not exists` so a repeat apply is a no-op (greenfield
 * RDS has a known broken `mikro_orm_migrations` tracker — see
 * reference_ec2_ops.md in memory).
 */
export class Migration20260419UserConsentUserAgent extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `alter table "user_consents" add column if not exists "user_agent" varchar(512) null;`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(
      `alter table "user_consents" drop column if exists "user_agent";`,
    );
  }
}
