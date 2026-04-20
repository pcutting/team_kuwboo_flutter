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

  /**
   * Nullable so conversation history survives a soft-delete or
   * hard-purge of the sender (Migration20260420_account_deletion_fk_nullability
   * widens the FK to ON DELETE SET NULL). In practice every new row
   * is written with a live sender.
   */
  @ManyToOne(() => User, { nullable: true })
  sender?: User;

  @Property({ type: 'text' })
  text!: string;

  @Property({ type: 'uuid', nullable: true })
  mediaId?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
