import { Migration } from '@mikro-orm/migrations';

/**
 * Phase 1 of account-deletion (App Store 5.1.1(v) + GDPR Art. 17).
 *
 * Three user-FK columns need to survive a purged user for audit or
 * thread-coherence reasons:
 *
 *   - `user_consents.user_id` — retained post-purge so the GDPR
 *     consent audit trail (who accepted which version when from
 *     which IP/UA) is preserved. Becomes NULL when the grantor is
 *     purged.
 *   - `comments.author_id` — retained on soft-delete to keep comment
 *     threads coherent ("[deleted user]" style). Hard-purge deletes
 *     the rows outright, but the FK is widened anyway so both paths
 *     share the same schema shape.
 *   - `messages.sender_id` — retained on soft-delete for the same
 *     reason as comments (conversation history stays readable for
 *     the remaining participant).
 *
 * The FK is dropped, the column is relaxed to nullable, then the FK
 * is re-added with ON DELETE SET NULL. On rollback we restore NOT
 * NULL — which will fail if any row has been null-anchored since
 * this migration ran. That's intentional: rolling this migration back
 * after purges have happened would lose data lineage, and we want the
 * failure to be loud.
 *
 * All DDL uses `if exists` / `if not exists` guards so a repeat apply
 * is a no-op (greenfield RDS has a broken mikro_orm_migrations
 * tracker — same justification as Migration20260419).
 */
export class Migration20260420AccountDeletionFkNullability extends Migration {
  override async up(): Promise<void> {
    // user_consents.user_id -> nullable + SET NULL
    this.addSql(
      `alter table "user_consents" drop constraint if exists "user_consents_user_id_foreign";`,
    );
    this.addSql(
      `alter table "user_consents" alter column "user_id" drop not null;`,
    );
    this.addSql(
      `alter table "user_consents" add constraint "user_consents_user_id_foreign" ` +
        `foreign key ("user_id") references "users" ("id") on update cascade on delete set null;`,
    );

    // comments.author_id -> nullable + SET NULL
    this.addSql(
      `alter table "comments" drop constraint if exists "comments_author_id_foreign";`,
    );
    this.addSql(
      `alter table "comments" alter column "author_id" drop not null;`,
    );
    this.addSql(
      `alter table "comments" add constraint "comments_author_id_foreign" ` +
        `foreign key ("author_id") references "users" ("id") on update cascade on delete set null;`,
    );

    // messages.sender_id -> nullable + SET NULL
    this.addSql(
      `alter table "messages" drop constraint if exists "messages_sender_id_foreign";`,
    );
    this.addSql(
      `alter table "messages" alter column "sender_id" drop not null;`,
    );
    this.addSql(
      `alter table "messages" add constraint "messages_sender_id_foreign" ` +
        `foreign key ("sender_id") references "users" ("id") on update cascade on delete set null;`,
    );
  }

  override async down(): Promise<void> {
    // Restore NOT NULL. This will fail if any row has a null FK since
    // the migration ran — that is intentional. Restore the original
    // RESTRICT delete behaviour too.
    this.addSql(
      `alter table "messages" drop constraint if exists "messages_sender_id_foreign";`,
    );
    this.addSql(
      `alter table "messages" alter column "sender_id" set not null;`,
    );
    this.addSql(
      `alter table "messages" add constraint "messages_sender_id_foreign" ` +
        `foreign key ("sender_id") references "users" ("id") on update cascade;`,
    );

    this.addSql(
      `alter table "comments" drop constraint if exists "comments_author_id_foreign";`,
    );
    this.addSql(
      `alter table "comments" alter column "author_id" set not null;`,
    );
    this.addSql(
      `alter table "comments" add constraint "comments_author_id_foreign" ` +
        `foreign key ("author_id") references "users" ("id") on update cascade;`,
    );

    this.addSql(
      `alter table "user_consents" drop constraint if exists "user_consents_user_id_foreign";`,
    );
    this.addSql(
      `alter table "user_consents" alter column "user_id" set not null;`,
    );
    this.addSql(
      `alter table "user_consents" add constraint "user_consents_user_id_foreign" ` +
        `foreign key ("user_id") references "users" ("id") on update cascade;`,
    );
  }
}
