import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Unique,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { Content } from '../../content/entities/content.entity';

@Entity({ tableName: 'seller_ratings' })
@Unique({ properties: ['buyer', 'product'] })
export class SellerRating {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  seller!: User;

  @ManyToOne(() => User)
  buyer!: User;

  @ManyToOne(() => Content)
  product!: Content;

  @Property({ type: 'smallint' })
  rating!: number;

  @Property({ type: 'text', nullable: true })
  review?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
