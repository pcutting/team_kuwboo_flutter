import { Entity, PrimaryKey, Property, ManyToOne, Unique, Index, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';

@Entity({ tableName: 'blocks' })
@Unique({ properties: ['blocker', 'blocked'] })
@Index({ properties: ['blocker'] })
@Index({ properties: ['blocked'] })
export class Block {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  blocker!: User;

  @ManyToOne(() => User)
  blocked!: User;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
