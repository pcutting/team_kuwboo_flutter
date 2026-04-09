import { Migration } from '@mikro-orm/migrations';

/**
 * Apple Sign In Server-to-Server support.
 *
 * Adds the schema required for Apple's S2S notification webhook to land
 * events idempotently, track per-user Apple state transitions, and route
 * system-initiated audit entries through the existing admin audit log.
 *
 * Changes:
 *   1. users: three Apple state columns (private relay flag, consent
 *      revoked timestamp, account deleted timestamp)
 *   2. sessions: provider / provider_identifier / revoke_reason columns
 *      so session revocation can target a specific auth provider's
 *      sessions and record WHY each session was revoked
 *   3. admin_audit_logs: actor_type discriminant + nullable admin_user_id
 *      so system-initiated events (Apple webhook handlers) can write
 *      audit entries without requiring a synthetic admin user. CHECK
 *      constraint enforces that admin actions always carry an
 *      admin_user_id
 *   4. apple_notification_events: new table storing every received
 *      webhook keyed by jti (Apple's unique JWT ID) for idempotency
 */
export class Migration20260409AppleS2s extends Migration {
  override async up(): Promise<void> {
    // 1. User columns — Apple state tracking
    this.addSql(`
      ALTER TABLE "users"
        ADD COLUMN "apple_email_is_private_relay" boolean NOT NULL DEFAULT false,
        ADD COLUMN "apple_consent_revoked_at" timestamptz NULL,
        ADD COLUMN "apple_account_deleted_at" timestamptz NULL;
    `);

    // 2. Session columns — provider context for targeted revocation
    this.addSql(`
      ALTER TABLE "sessions"
        ADD COLUMN "provider" varchar(20) NULL,
        ADD COLUMN "provider_identifier" varchar(255) NULL,
        ADD COLUMN "revoke_reason" varchar(100) NULL;
    `);
    this.addSql(`
      CREATE INDEX "idx_sessions_provider_identifier"
        ON "sessions" ("provider", "provider_identifier");
    `);

    // 3. admin_audit_logs — relax admin_user_id for system actors
    //
    // The original FK was ON DELETE CASCADE which meant deleting an admin
    // user would wipe their audit history — bad for compliance. Change to
    // ON DELETE SET NULL and rely on the actor_type discriminant to know
    // whether the row originally had an admin.
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        DROP CONSTRAINT IF EXISTS "admin_audit_logs_admin_user_id_fkey";
    `);
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        ALTER COLUMN "admin_user_id" DROP NOT NULL;
    `);
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        ADD COLUMN "actor_type" varchar(20) NOT NULL DEFAULT 'admin';
    `);
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        ADD CONSTRAINT "admin_audit_logs_admin_user_id_fkey"
        FOREIGN KEY ("admin_user_id") REFERENCES "users" ("id")
        ON UPDATE CASCADE ON DELETE SET NULL;
    `);
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        ADD CONSTRAINT "admin_audit_logs_actor_check"
        CHECK (
          (actor_type = 'admin' AND admin_user_id IS NOT NULL)
          OR actor_type = 'system'
        );
    `);

    // 4. apple_notification_events — idempotent event store
    //
    // jti is Apple's unique JWT ID on each webhook payload — we use it as
    // the idempotency key. A UNIQUE constraint on jti turns "INSERT ON
    // CONFLICT DO NOTHING" into a cheap dedupe at the database level so
    // retries from Apple are safe.
    //
    // user_id is nullable because a notification may arrive for an
    // apple_sub we no longer recognize (e.g. user already hard-deleted).
    // We still persist the event for audit.
    this.addSql(`
      CREATE TABLE "apple_notification_events" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "jti" varchar(64) NOT NULL,
        "event_type" varchar(30) NOT NULL,
        "apple_sub" varchar(255) NOT NULL,
        "apple_event_time" timestamptz NOT NULL,
        "user_id" uuid NULL,
        "signature_valid" boolean NOT NULL DEFAULT true,
        "raw_payload_sha256" varchar(64) NOT NULL,
        "claims" jsonb NOT NULL,
        "event_payload" jsonb NOT NULL,
        "source_ip" varchar(45) NULL,
        "user_agent" varchar(255) NULL,
        "processed_at" timestamptz NULL,
        "processing_error" text NULL,
        "processing_attempts" int NOT NULL DEFAULT 0,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "apple_notification_events_pkey" PRIMARY KEY ("id"),
        CONSTRAINT "apple_notification_events_jti_unique" UNIQUE ("jti"),
        CONSTRAINT "apple_notification_events_user_id_fkey"
          FOREIGN KEY ("user_id") REFERENCES "users" ("id")
          ON UPDATE CASCADE ON DELETE SET NULL
      );
    `);
    this.addSql(`
      CREATE INDEX "idx_apple_events_type_processed"
        ON "apple_notification_events" ("event_type", "processed_at");
    `);
    this.addSql(`
      CREATE INDEX "idx_apple_events_apple_sub"
        ON "apple_notification_events" ("apple_sub");
    `);
    this.addSql(`
      CREATE INDEX "idx_apple_events_user"
        ON "apple_notification_events" ("user_id");
    `);
    this.addSql(`
      CREATE INDEX "idx_apple_events_event_time"
        ON "apple_notification_events" ("apple_event_time" DESC);
    `);
  }

  override async down(): Promise<void> {
    // 4. drop the apple_notification_events table
    this.addSql(`DROP TABLE IF EXISTS "apple_notification_events";`);

    // 3. roll back admin_audit_logs changes
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        DROP CONSTRAINT IF EXISTS "admin_audit_logs_actor_check";
    `);
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        DROP CONSTRAINT IF EXISTS "admin_audit_logs_admin_user_id_fkey";
    `);
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        DROP COLUMN IF EXISTS "actor_type";
    `);
    // NOTE: We do not restore NOT NULL on admin_user_id in down()
    // because there may be NULL rows written by the system actor that
    // would block the constraint. The down() path is only for reverting
    // in a test environment where we are about to re-run the migration.
    this.addSql(`
      ALTER TABLE "admin_audit_logs"
        ADD CONSTRAINT "admin_audit_logs_admin_user_id_fkey"
        FOREIGN KEY ("admin_user_id") REFERENCES "users" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
    `);

    // 2. roll back sessions changes
    this.addSql(`DROP INDEX IF EXISTS "idx_sessions_provider_identifier";`);
    this.addSql(`
      ALTER TABLE "sessions"
        DROP COLUMN IF EXISTS "revoke_reason",
        DROP COLUMN IF EXISTS "provider_identifier",
        DROP COLUMN IF EXISTS "provider";
    `);

    // 1. roll back users changes
    this.addSql(`
      ALTER TABLE "users"
        DROP COLUMN IF EXISTS "apple_account_deleted_at",
        DROP COLUMN IF EXISTS "apple_consent_revoked_at",
        DROP COLUMN IF EXISTS "apple_email_is_private_relay";
    `);
  }
}
