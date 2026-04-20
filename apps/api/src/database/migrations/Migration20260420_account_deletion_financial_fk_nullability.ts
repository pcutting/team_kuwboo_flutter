import { Migration } from '@mikro-orm/migrations';

/**
 * Phase 1 of account-deletion — financial / marketplace FKs.
 *
 * Split into a second migration to keep the "social" FK changes
 * (user_consents, comments, messages) reviewable in isolation from the
 * marketplace ones (bids, seller_ratings). They were both introduced
 * together in the same PR, but separating them here means each group
 * can be rolled back independently if a specific subsystem surfaces
 * a regression.
 *
 *   - `bids.bidder_id` — on soft-delete we keep bid rows behind the
 *     seller-visible feed's own soft-delete filter; on hard-purge we
 *     null the FK so auction history is preserved without a dangling
 *     pointer. (Dropping bids outright would silently change auction
 *     totals that third parties may already have observed.)
 *   - `seller_ratings.seller_id` + `seller_ratings.buyer_id` — rating
 *     rows stay put as marketplace reputation is a public record; on
 *     purge we null both FKs (the rating number and review text stay
 *     visible, but the user identity is gone).
 *
 * Same rollback caveat as Migration20260420_account_deletion_fk_nullability
 * — `down()` will fail if null rows have been written since apply.
 */
export class Migration20260420AccountDeletionFinancialFkNullability extends Migration {
  override async up(): Promise<void> {
    // bids.bidder_id -> nullable + SET NULL
    this.addSql(
      `alter table "bids" drop constraint if exists "bids_bidder_id_foreign";`,
    );
    this.addSql(
      `alter table "bids" alter column "bidder_id" drop not null;`,
    );
    this.addSql(
      `alter table "bids" add constraint "bids_bidder_id_foreign" ` +
        `foreign key ("bidder_id") references "users" ("id") on update cascade on delete set null;`,
    );

    // seller_ratings.seller_id -> nullable + SET NULL
    this.addSql(
      `alter table "seller_ratings" drop constraint if exists "seller_ratings_seller_id_foreign";`,
    );
    this.addSql(
      `alter table "seller_ratings" alter column "seller_id" drop not null;`,
    );
    this.addSql(
      `alter table "seller_ratings" add constraint "seller_ratings_seller_id_foreign" ` +
        `foreign key ("seller_id") references "users" ("id") on update cascade on delete set null;`,
    );

    // seller_ratings.buyer_id -> nullable + SET NULL
    this.addSql(
      `alter table "seller_ratings" drop constraint if exists "seller_ratings_buyer_id_foreign";`,
    );
    this.addSql(
      `alter table "seller_ratings" alter column "buyer_id" drop not null;`,
    );
    this.addSql(
      `alter table "seller_ratings" add constraint "seller_ratings_buyer_id_foreign" ` +
        `foreign key ("buyer_id") references "users" ("id") on update cascade on delete set null;`,
    );
  }

  override async down(): Promise<void> {
    // Restore the original RESTRICT + NOT NULL shape. Will fail loudly
    // if any null rows exist (intentional — see migration header).
    this.addSql(
      `alter table "seller_ratings" drop constraint if exists "seller_ratings_buyer_id_foreign";`,
    );
    this.addSql(
      `alter table "seller_ratings" alter column "buyer_id" set not null;`,
    );
    this.addSql(
      `alter table "seller_ratings" add constraint "seller_ratings_buyer_id_foreign" ` +
        `foreign key ("buyer_id") references "users" ("id") on update cascade;`,
    );

    this.addSql(
      `alter table "seller_ratings" drop constraint if exists "seller_ratings_seller_id_foreign";`,
    );
    this.addSql(
      `alter table "seller_ratings" alter column "seller_id" set not null;`,
    );
    this.addSql(
      `alter table "seller_ratings" add constraint "seller_ratings_seller_id_foreign" ` +
        `foreign key ("seller_id") references "users" ("id") on update cascade;`,
    );

    this.addSql(
      `alter table "bids" drop constraint if exists "bids_bidder_id_foreign";`,
    );
    this.addSql(
      `alter table "bids" alter column "bidder_id" set not null;`,
    );
    this.addSql(
      `alter table "bids" add constraint "bids_bidder_id_foreign" ` +
        `foreign key ("bidder_id") references "users" ("id") on update cascade;`,
    );
  }
}
