import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { Auction } from './auction.entity';
import { User } from '../../users/entities/user.entity';

@Entity({ tableName: 'bids' })
export class Bid {
  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => Auction)
  auction!: Auction;

  /**
   * Nullable so auction history survives a hard-purge of the bidder
   * (Migration20260420_account_deletion_financial_fk_nullability widens
   * the FK to ON DELETE SET NULL). In practice every new bid is written
   * with a live bidder.
   */
  @ManyToOne(() => User, { nullable: true })
  bidder?: User;

  @Property({ type: 'int' })
  amountCents!: number;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
