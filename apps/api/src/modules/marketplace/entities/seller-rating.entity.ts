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

  /**
   * Nullable so marketplace reputation survives a hard-purge of either
   * party (Migration20260420_account_deletion_financial_fk_nullability
   * widens both FKs to ON DELETE SET NULL). In practice both fields
   * are set on every new row.
   */
  @ManyToOne(() => User, { nullable: true })
  seller?: User;

  @ManyToOne(() => User, { nullable: true })
  buyer?: User;

  @ManyToOne(() => Content)
  product!: Content;

  @Property({ type: 'smallint' })
  rating!: number;

  @Property({ type: 'text', nullable: true })
  review?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
