import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { Thread } from './thread.entity';
import { User } from '../../users/entities/user.entity';

@Entity({ tableName: 'messages' })
@Index({ properties: ['thread', 'createdAt'] })
export class Message {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => Thread)
  thread!: Thread;

  @ManyToOne(() => User)
  sender!: User;

  @Property({ type: 'text' })
  text!: string;

  @Property({ type: 'uuid', nullable: true })
  mediaId?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
