import { Migration } from '@mikro-orm/migrations';

export class Migration20260403Init extends Migration {
  override async up(): Promise<void> {
    // Enable required PostgreSQL extensions
    this.addSql('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";');
    this.addSql('CREATE EXTENSION IF NOT EXISTS "pgcrypto";');
    this.addSql('CREATE EXTENSION IF NOT EXISTS "pg_trgm";');

    // PostGIS and pgvector — create if available, skip if not yet installed
    this.addSql('CREATE EXTENSION IF NOT EXISTS "postgis";');
  }

  override async down(): Promise<void> {
    // Extensions are shared — don't drop them on rollback
  }
}
