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

  @ManyToOne(() => User)
  bidder!: User;

  @Property({ type: 'int' })
  amountCents!: number;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
