import {
  Entity,
  PrimaryKey,
  Property,
  ManyToOne,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';

@Entity({ tableName: 'admin_audit_logs' })
@Index({ properties: ['adminUser', 'createdAt'] })
export class AdminAuditLog {
  [OptionalProps]?: 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @ManyToOne(() => User)
  adminUser!: User;

  @Property({ type: 'varchar', length: 50 })
  actionType!: string;

  @Property({ type: 'varchar', length: 50 })
  targetType!: string;

  @Property({ type: 'uuid', nullable: true })
  targetId?: string;

  @Property({ type: 'jsonb', nullable: true })
  details?: Record<string, any>;

  @Property({ type: 'varchar', length: 45, nullable: true })
  ipAddress?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
