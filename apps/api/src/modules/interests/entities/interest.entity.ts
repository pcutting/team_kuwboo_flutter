import {
  Entity,
  PrimaryKey,
  Property,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';

@Entity({ tableName: 'interests' })
@Index({ name: 'interests_is_active_display_order_index', properties: ['isActive', 'displayOrder'] })
export class Interest {
  [OptionalProps]?:
    | 'displayOrder'
    | 'isActive'
    | 'createdAt'
    | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @Property({ type: 'text' })
  slug!: string;

  @Property({ type: 'text' })
  label!: string;

  @Property({ type: 'text', nullable: true })
  category?: string;

  @Property({ type: 'int', default: 0 })
  displayOrder: number = 0;

  @Property({ type: 'boolean', default: true })
  isActive: boolean = true;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
