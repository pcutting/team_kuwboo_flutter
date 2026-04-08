import { Entity, PrimaryKey, Property, ManyToOne, Enum, Unique, Index, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { ConnectionContext, ConnectionStatus, ModuleScope } from '../../../common/enums';

@Entity({ tableName: 'connections' })
@Unique({ properties: ['fromUser', 'toUser', 'context', 'moduleScope'] })
@Index({ properties: ['fromUser', 'context'] })
@Index({ properties: ['toUser', 'context'] })
export class Connection {
  [OptionalProps]?: 'status' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  fromUser!: User;

  @ManyToOne(() => User)
  toUser!: User;

  @Enum({ items: () => ConnectionContext })
  context!: ConnectionContext;

  @Enum({ items: () => ConnectionStatus, default: ConnectionStatus.ACTIVE })
  status: ConnectionStatus = ConnectionStatus.ACTIVE;

  @Enum({ items: () => ModuleScope, nullable: true })
  moduleScope?: ModuleScope;

  @Property({ type: 'timestamptz', nullable: true })
  confirmedAt?: Date;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
