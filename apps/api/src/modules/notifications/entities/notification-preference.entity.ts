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

@Entity({ tableName: 'notification_preferences' })
@Unique({ properties: ['user', 'moduleKey', 'eventType'] })
export class NotificationPreference {
  [OptionalProps]?: 'pushEnabled' | 'inAppEnabled' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  user!: User;

  @Property({ type: 'varchar', length: 50 })
  moduleKey!: string;

  @Property({ type: 'varchar', length: 50 })
  eventType!: string;

  @Property({ type: 'boolean', default: true })
  pushEnabled: boolean = true;

  @Property({ type: 'boolean', default: true })
  inAppEnabled: boolean = true;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
