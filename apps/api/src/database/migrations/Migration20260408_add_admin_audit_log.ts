import { Migration } from '@mikro-orm/migrations';

export class Migration20260408AddAdminAuditLog extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      CREATE TABLE "admin_audit_logs" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "admin_user_id" uuid NOT NULL,
        "action_type" varchar(50) NOT NULL,
        "target_type" varchar(50) NOT NULL,
        "target_id" uuid NULL,
        "details" jsonb NULL,
        "ip_address" varchar(45) NULL,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "admin_audit_logs_pkey" PRIMARY KEY ("id"),
        CONSTRAINT "admin_audit_logs_admin_user_id_fkey" FOREIGN KEY ("admin_user_id")
          REFERENCES "users" ("id") ON UPDATE CASCADE ON DELETE CASCADE
      );
    `);
    this.addSql(
      `CREATE INDEX "idx_admin_audit_logs_admin_user_created" ON "admin_audit_logs" ("admin_user_id", "created_at" DESC);`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(`DROP TABLE IF EXISTS "admin_audit_logs";`);
  }
}
