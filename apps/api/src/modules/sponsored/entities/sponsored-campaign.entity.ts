import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  ManyToOne,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { Content } from '../../content/entities/content.entity';
import { CampaignStatus } from '../../../common/enums';

@Entity({ tableName: 'sponsored_campaigns' })
export class SponsoredCampaign {
  [OptionalProps]?: 'status' | 'spentCents' | 'createdAt' | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  advertiser!: User;

  @ManyToOne(() => Content)
  content!: Content;

  @Property({ type: 'int' })
  budgetCents!: number;

  @Property({ type: 'int', default: 0 })
  spentCents: number = 0;

  @Enum({ items: () => CampaignStatus, default: CampaignStatus.DRAFT })
  status: CampaignStatus = CampaignStatus.DRAFT;

  @Property({ type: 'jsonb', nullable: true })
  targeting?: Record<string, any>;

  @Property({ type: 'timestamptz' })
  startsAt!: Date;

  @Property({ type: 'timestamptz' })
  endsAt!: Date;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
