import { Migration } from '@mikro-orm/migrations';

/**
 * Append-only audit table for login attempts (issue #174 brute-force
 * defence).
 *
 * Every `POST /auth/email/login` request writes exactly one row here
 * (success OR failure) so we have a first-class audit trail for
 * forensics and can drive adaptive throttling from the backing
 * Postgres row, not just the volatile Redis counters.
 *
 * Indexing: `(email_hash, attempted_at DESC)` and
 * `(ip_address, attempted_at DESC)` so per-email and per-IP lookups
 * stay O(log n) as the table grows. The table is append-only and
 * can be partitioned / archived on a timer later — no rows are ever
 * updated in place.
 *
 * All DDL uses `if not exists` so a repeat apply is a no-op
 * (greenfield RDS has a known broken `mikro_orm_migrations` tracker —
 * see `reference_ec2_ops.md` in memory).
 */
export class Migration20260421AuthLoginAttempts extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `create table if not exists "auth_login_attempts" (
        "id" uuid not null,
        "email_hash" varchar(64) not null,
        "ip_address" varchar(45) null,
        "user_agent" text null,
        "attempted_at" timestamptz not null default now(),
        "outcome" varchar(32) not null,
        constraint "auth_login_attempts_pkey" primary key ("id")
      );`,
    );
    this.addSql(
      `create index if not exists "auth_login_attempts_email_hash_attempted_at_index" ` +
        `on "auth_login_attempts" ("email_hash", "attempted_at" desc);`,
    );
    this.addSql(
      `create index if not exists "auth_login_attempts_ip_address_attempted_at_index" ` +
        `on "auth_login_attempts" ("ip_address", "attempted_at" desc);`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "auth_login_attempts";`);
  }
}
