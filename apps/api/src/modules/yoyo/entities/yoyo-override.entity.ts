import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Enum,
  Unique,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { YoyoOverrideAction } from '../../../common/enums';

@Entity({ tableName: 'yoyo_overrides' })
@Unique({ properties: ['user', 'targetUser'] })
export class YoyoOverride {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  user!: User;

  @ManyToOne(() => User)
  targetUser!: User;

  @Enum({ items: () => YoyoOverrideAction })
  action!: YoyoOverrideAction;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
