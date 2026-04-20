import { Migration } from '@mikro-orm/migrations';

/**
 * Adds `transcoded_url` to `media` so the video processing pipeline
 * can persist the S3/CloudFront URL of the 720p H.264 MP4 derivative
 * produced by the async worker. Nullable because image rows never get
 * a transcode and existing video rows predate the pipeline.
 *
 * All DDL uses `if not exists` so a repeat apply is a no-op (greenfield
 * RDS has a known broken `mikro_orm_migrations` tracker — see
 * reference_ec2_ops.md in memory).
 */
export class Migration20260420MediaTranscodedUrl extends Migration {
  override async up(): Promise<void> {
    this.addSql(
      `alter table "media" add column if not exists "transcoded_url" varchar(1024) null;`,
    );
  }

  override async down(): Promise<void> {
    this.addSql(
      `alter table "media" drop column if exists "transcoded_url";`,
    );
  }
}
