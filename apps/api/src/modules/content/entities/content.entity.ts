import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  ManyToOne,
  OneToMany,
  Collection,
  Filter,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { PointType, Point } from '../../../database/types/point.type';
import {
  ContentType,
  ContentStatus,
  ContentTier,
  Visibility,
} from '../../../common/enums';

@Entity({
  tableName: 'content',
  discriminatorColumn: 'type',
  discriminatorMap: {
    VIDEO: 'Video',
    PRODUCT: 'Product',
    POST: 'Post',
    EVENT: 'Event',
    WANTED_AD: 'WantedAd',
  },
})
@Filter({ name: 'notDeleted', cond: { deletedAt: null }, default: true })
@Filter({ name: 'active', cond: { status: ContentStatus.ACTIVE } })
@Index({ properties: ['status', 'type', 'createdAt'] })
export class Content {
  [OptionalProps]?:
    | 'visibility'
    | 'tier'
    | 'status'
    | 'likeCount'
    | 'saveCount'
    | 'shareCount'
    | 'viewCount'
    | 'commentCount'
    | 'createdAt'
    | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @Enum({ items: () => ContentType })
  type!: ContentType;

  @ManyToOne(() => User)
  creator!: User;

  @Enum({ items: () => Visibility, default: Visibility.PUBLIC })
  visibility: Visibility = Visibility.PUBLIC;

  @Enum({ items: () => ContentTier, default: ContentTier.FREE })
  tier: ContentTier = ContentTier.FREE;

  @Property({ type: PointType, nullable: true })
  location?: Point;

  @Property({ type: 'varchar', length: 255, nullable: true })
  locationName?: string;

  @Property({ type: 'int', default: 0 })
  likeCount: number = 0;

  @Property({ type: 'int', default: 0 })
  saveCount: number = 0;

  @Property({ type: 'int', default: 0 })
  shareCount: number = 0;

  @Property({ type: 'int', default: 0 })
  viewCount: number = 0;

  @Property({ type: 'int', default: 0 })
  commentCount: number = 0;

  @Enum({ items: () => ContentStatus, default: ContentStatus.PENDING })
  status: ContentStatus = ContentStatus.PENDING;

  @Property({ type: 'timestamptz', nullable: true })
  boostExpiresAt?: Date;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ type: 'timestamptz', nullable: true })
  deletedAt?: Date;
}
