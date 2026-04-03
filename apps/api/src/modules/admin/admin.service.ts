import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { User } from '../users/entities/user.entity';
import { Media } from '../media/entities/media.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { Role, UserStatus } from '../../common/enums';

@Injectable()
export class AdminService {
  constructor(private readonly em: EntityManager) {}

  async listUsers(
    page = 1,
    limit = 20,
    status?: UserStatus,
    role?: Role,
  ): Promise<{ items: User[]; total: number }> {
    const where: any = {};
    if (status) where.status = status;
    if (role) where.role = role;

    const [items, total] = await this.em.findAndCount(User, where, {
      orderBy: { createdAt: 'DESC' },
      limit,
      offset: (page - 1) * limit,
    });

    return { items, total };
  }

  async updateUserStatus(
    userId: string,
    status: UserStatus,
    adminRole: Role,
  ): Promise<User> {
    const user = await this.em.findOne(User, { id: userId });
    if (!user) throw new NotFoundException('User not found');

    // Prevent non-super-admins from modifying admins
    if (user.role === Role.ADMIN || user.role === Role.SUPER_ADMIN) {
      if (adminRole !== Role.SUPER_ADMIN) {
        throw new ForbiddenException('Only super admins can modify admin accounts');
      }
    }

    user.status = status;
    await this.em.flush();
    return user;
  }

  async updateUserRole(
    userId: string,
    newRole: Role,
    adminRole: Role,
  ): Promise<User> {
    const user = await this.em.findOne(User, { id: userId });
    if (!user) throw new NotFoundException('User not found');

    // Only SUPER_ADMIN can promote to ADMIN or SUPER_ADMIN
    if (
      (newRole === Role.ADMIN || newRole === Role.SUPER_ADMIN) &&
      adminRole !== Role.SUPER_ADMIN
    ) {
      throw new ForbiddenException('Only super admins can promote to admin roles');
    }

    user.role = newRole;
    await this.em.flush();
    return user;
  }

  async deleteMedia(mediaId: string): Promise<void> {
    const media = await this.em.findOne(Media, { id: mediaId });
    if (!media) throw new NotFoundException('Media not found');
    await this.em.removeAndFlush(media);
  }

  async getStats(): Promise<Record<string, number>> {
    const [totalUsers, activeUsers, totalMedia, totalNotifications] = await Promise.all([
      this.em.count(User, {}),
      this.em.count(User, { status: UserStatus.ACTIVE }),
      this.em.count(Media, {}),
      this.em.count(Notification, {}),
    ]);

    return { totalUsers, activeUsers, totalMedia, totalNotifications };
  }
}
