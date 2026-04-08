import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { AdminAuditLog } from './entities/admin-audit-log.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AdminAuditService {
  constructor(private readonly em: EntityManager) {}

  async log(
    adminUserId: string,
    actionType: string,
    targetType: string,
    targetId?: string,
    details?: Record<string, any>,
    ipAddress?: string,
  ): Promise<AdminAuditLog> {
    const entry = this.em.create(AdminAuditLog, {
      adminUser: this.em.getReference(User, adminUserId),
      actionType,
      targetType,
      targetId,
      details,
      ipAddress,
    });
    await this.em.persistAndFlush(entry);
    return entry;
  }

  async findAll(
    page = 1,
    limit = 20,
    adminUserId?: string,
    actionType?: string,
    targetType?: string,
  ): Promise<{ items: AdminAuditLog[]; total: number }> {
    const where: any = {};
    if (adminUserId) where.adminUser = adminUserId;
    if (actionType) where.actionType = actionType;
    if (targetType) where.targetType = targetType;

    const [items, total] = await this.em.findAndCount(AdminAuditLog, where, {
      orderBy: { createdAt: 'DESC' },
      limit,
      offset: (page - 1) * limit,
      populate: ['adminUser'],
    });

    return { items, total };
  }
}
