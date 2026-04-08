import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  OneToMany,
  Collection,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { ThreadModuleKey } from '../../../common/enums';
import { ThreadParticipant } from './thread-participant.entity';
import { Message } from './message.entity';

@Entity({ tableName: 'threads' })
export class Thread {
  [OptionalProps]?: 'createdAt' | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @Enum({ items: () => ThreadModuleKey, nullable: true })
  moduleKey?: ThreadModuleKey;

  @Property({ type: 'uuid', nullable: true })
  contextId?: string;

  @OneToMany(() => ThreadParticipant, (tp) => tp.thread)
  participants = new Collection<ThreadParticipant>(this);

  @OneToMany(() => Message, (m) => m.thread)
  messages = new Collection<Message>(this);

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
