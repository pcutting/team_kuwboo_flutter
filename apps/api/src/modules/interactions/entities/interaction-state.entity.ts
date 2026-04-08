import { Entity, PrimaryKey, Property, ManyToOne, Enum, Unique, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { Content } from '../../content/entities/content.entity';
import { InteractionStateType } from '../../../common/enums';

@Entity({ tableName: 'interaction_states' })
@Unique({ properties: ['user', 'content', 'type'] })
export class InteractionState {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  user!: User;

  @ManyToOne(() => Content)
  content!: Content;

  @Enum({ items: () => InteractionStateType })
  type!: InteractionStateType;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
