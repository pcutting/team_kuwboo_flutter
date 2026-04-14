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

@Entity({ tableName: 'user_interests' })
@Unique({ properties: ['user', 'interest'] })
@Index({ name: 'user_interests_user_id_index', properties: ['user'] })
@Index({ name: 'user_interests_interest_id_index', properties: ['interest'] })
export class UserInterest {
  [OptionalProps]?: 'selectedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User, { deleteRule: 'cascade' })
  user!: User;

  @ManyToOne(() => Interest, { deleteRule: 'cascade' })
  interest!: Interest;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  selectedAt: Date = new Date();
}
