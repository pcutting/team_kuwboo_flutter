import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Unique,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { Interest } from './interest.entity';

@Entity({ tableName: 'interest_signals' })
@Unique({ properties: ['user', 'interest'] })
@Index({ name: 'interest_signals_user_id_index', properties: ['user'] })
export class InterestSignal {
  [OptionalProps]?: 'weight' | 'eventCount' | 'lastSeenAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User, { deleteRule: 'cascade' })
  user!: User;

  @ManyToOne(() => Interest, { deleteRule: 'cascade' })
  interest!: Interest;

  @Property({ type: 'float', default: 0 })
  weight: number = 0;

  @Property({ type: 'int', default: 0 })
  eventCount: number = 0;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  lastSeenAt: Date = new Date();
}
