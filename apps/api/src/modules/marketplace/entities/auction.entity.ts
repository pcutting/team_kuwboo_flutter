import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  OneToOne,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { Content } from '../../content/entities/content.entity';
import { AuctionStatus } from '../../../common/enums';

@Entity({ tableName: 'auctions' })
@Index({ properties: ['status', 'endsAt'] })
export class Auction {
  [OptionalProps]?:
    | 'status'
    | 'minIncrementCents'
    | 'antiSnipeMinutes'
    | 'createdAt'
    | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @OneToOne(() => Content)
  product!: Content;

  @Property({ type: 'int' })
  startPriceCents!: number;

  @Property({ type: 'int' })
  currentPriceCents!: number;

  @Property({ type: 'int', default: 100 })
  minIncrementCents: number = 100;

  @Property({ type: 'timestamptz' })
  startsAt!: Date;

  @Property({ type: 'timestamptz' })
  endsAt!: Date;

  @Enum({ items: () => AuctionStatus, default: AuctionStatus.SCHEDULED })
  status: AuctionStatus = AuctionStatus.SCHEDULED;

  @Property({ type: 'uuid', nullable: true })
  winnerId?: string;

  @Property({ type: 'int', default: 2 })
  antiSnipeMinutes: number = 2;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
