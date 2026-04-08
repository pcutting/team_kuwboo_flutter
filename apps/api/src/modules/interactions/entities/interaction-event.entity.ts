import { Entity, PrimaryKey, Property, ManyToOne, Enum, Index, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { Content } from '../../content/entities/content.entity';
import { InteractionEventType } from '../../../common/enums';

@Entity({ tableName: 'interaction_events' })
@Index({ properties: ['content', 'createdAt'] })
export class InteractionEvent {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  user!: User;

  @ManyToOne(() => Content)
  content!: Content;

  @Enum({ items: () => InteractionEventType })
  type!: InteractionEventType;

  @Property({ type: 'jsonb', nullable: true })
  metadata?: Record<string, unknown>;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
