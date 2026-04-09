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

/**
 * Who (or what) performed the action being audited.
 *
 * - 'admin' — a human admin via the admin dashboard. adminUser is required.
 * - 'system' — an automated process (e.g. Apple S2S webhook handlers,
 *   cron jobs, BullMQ workers). adminUser is NULL.
 *
 * Enforced at the DB level by admin_audit_logs_actor_check.
 */
export type AuditActorType = 'admin' | 'system';

@Entity({ tableName: 'admin_audit_logs' })
@Index({ properties: ['adminUser', 'createdAt'] })
export class AdminAuditLog {
  [OptionalProps]?: 'actorType' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  /**
   * The admin who performed the action. NULL for system-initiated
   * audits (actorType = 'system'). Uses ON DELETE SET NULL so deleting
   * an admin user preserves their audit history.
   */
  @ManyToOne(() => User, { nullable: true })
  adminUser?: User;

  @Property({ type: 'varchar', length: 20, default: 'admin' })
  actorType: AuditActorType = 'admin';

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
