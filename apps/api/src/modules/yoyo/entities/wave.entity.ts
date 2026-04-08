import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Enum,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { WaveStatus } from '../../../common/enums';

@Entity({ tableName: 'waves' })
@Index({ properties: ['toUser', 'status'] })
export class Wave {
  [OptionalProps]?: 'status' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  fromUser!: User;

  @ManyToOne(() => User)
  toUser!: User;

  @Property({ type: 'varchar', length: 255, nullable: true })
  message?: string;

  @Enum({ items: () => WaveStatus, default: WaveStatus.PENDING })
  status: WaveStatus = WaveStatus.PENDING;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', nullable: true })
  respondedAt?: Date;
}
