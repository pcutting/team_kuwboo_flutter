import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Unique,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { Thread } from './thread.entity';
import { User } from '../../users/entities/user.entity';

@Entity({ tableName: 'thread_participants' })
@Unique({ properties: ['thread', 'user'] })
export class ThreadParticipant {
  [OptionalProps]?: 'joinedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => Thread)
  thread!: Thread;

  @ManyToOne(() => User)
  user!: User;

  @Property({ type: 'timestamptz', nullable: true })
  lastReadAt?: Date;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  joinedAt: Date = new Date();
}
