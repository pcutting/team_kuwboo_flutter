import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { YoyoSettings } from './entities/yoyo-settings.entity';
import { YoyoOverride } from './entities/yoyo-override.entity';
import { Wave } from './entities/wave.entity';
import { User } from '../users/entities/user.entity';
import { Thread } from '../messaging/entities/thread.entity';
import { ThreadParticipant } from '../messaging/entities/thread-participant.entity';
import { YoyoOverrideAction, WaveStatus, ThreadModuleKey } from '../../common/enums';
import { UpdateYoyoSettingsDto } from './dto/update-yoyo-settings.dto';

@Injectable()
export class YoyoService {
  constructor(private readonly em: EntityManager) {}

  async updateLocation(userId: string, latitude: number, longitude: number): Promise<void> {
    await this.em.nativeUpdate(
      User,
      { id: userId },
      { lastLocation: { latitude, longitude } } as any,
    );
  }

  async getNearbyUsers(
    userId: string,
    lat: number,
    lng: number,
    radiusKm?: number,
  ): Promise<any[]> {
    // Get the caller's settings (or defaults)
    const settings = await this.getSettings(userId);
    const radius = radiusKm ?? settings.radiusKm;
    const radiusMeters = radius * 1000;

    // Get blocked user IDs (in either direction)
    const blocks = await this.em.find(YoyoOverride, {
      $or: [
        { user: userId, action: YoyoOverrideAction.BLOCK },
        { targetUser: userId, action: YoyoOverrideAction.BLOCK },
      ],
    });
    const blockedIds = blocks.map((b) =>
      b.user.id === userId ? b.targetUser.id : b.user.id,
    );
    blockedIds.push(userId); // Exclude self

    const knex = this.em.getKnex();

    let query = knex('users as u')
      .select(
        'u.id',
        'u.name',
        'u.avatar_url',
        'u.date_of_birth',
        knex.raw(
          'ST_Distance(u.last_location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) as distance',
          [lng, lat],
        ),
      )
      .join('yoyo_settings as ys', 'ys.user_id', 'u.id')
      .whereRaw(
        'ST_DWithin(u.last_location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)',
        [lng, lat, radiusMeters],
      )
      .andWhere('ys.is_visible', true)
      .andWhere('u.deleted_at', null)
      .whereNotIn('u.id', blockedIds)
      .orderByRaw('distance ASC')
      .limit(50);

    // Apply age filters if set
    if (settings.ageMin != null || settings.ageMax != null) {
      const now = new Date();
      if (settings.ageMax != null) {
        const minDob = new Date(now.getFullYear() - settings.ageMax - 1, now.getMonth(), now.getDate());
        query = query.andWhere('u.date_of_birth', '>=', minDob);
      }
      if (settings.ageMin != null) {
        const maxDob = new Date(now.getFullYear() - settings.ageMin, now.getMonth(), now.getDate());
        query = query.andWhere('u.date_of_birth', '<=', maxDob);
      }
    }

    const rows = await query;

    return rows.map((row: any) => ({
      id: row.id,
      name: row.name,
      avatarUrl: row.avatar_url,
      distanceMeters: Math.round(row.distance),
    }));
  }

  async getSettings(userId: string): Promise<YoyoSettings> {
    let settings = await this.em.findOne(YoyoSettings, { user: userId });
    if (!settings) {
      const user = await this.em.findOneOrFail(User, { id: userId });
      settings = this.em.create(YoyoSettings, { user } as any);
      await this.em.flush();
    }
    return settings;
  }

  async updateSettings(userId: string, dto: UpdateYoyoSettingsDto): Promise<YoyoSettings> {
    const settings = await this.getSettings(userId);

    if (dto.isVisible !== undefined) settings.isVisible = dto.isVisible;
    if (dto.radiusKm !== undefined) settings.radiusKm = dto.radiusKm;
    if (dto.ageMin !== undefined) settings.ageMin = dto.ageMin;
    if (dto.ageMax !== undefined) settings.ageMax = dto.ageMax;
    if (dto.genderFilter !== undefined) settings.genderFilter = dto.genderFilter;

    await this.em.flush();
    return settings;
  }

  async createOverride(
    userId: string,
    targetUserId: string,
    action: YoyoOverrideAction,
  ): Promise<YoyoOverride> {
    if (userId === targetUserId) {
      throw new ConflictException('Cannot override yourself');
    }

    const targetUser = await this.em.findOne(User, { id: targetUserId });
    if (!targetUser) throw new NotFoundException('Target user not found');

    // Upsert: remove existing override if present
    const existing = await this.em.findOne(YoyoOverride, {
      user: userId,
      targetUser: targetUserId,
    });

    if (existing) {
      existing.action = action;
      await this.em.flush();
      return existing;
    }

    const user = await this.em.findOneOrFail(User, { id: userId });
    const override = this.em.create(YoyoOverride, {
      user,
      targetUser,
      action,
    } as any);
    await this.em.flush();
    return override;
  }

  async sendWave(
    fromUserId: string,
    toUserId: string,
    message?: string,
  ): Promise<Wave> {
    if (fromUserId === toUserId) {
      throw new ConflictException('Cannot wave at yourself');
    }

    const toUser = await this.em.findOne(User, { id: toUserId });
    if (!toUser) throw new NotFoundException('Recipient not found');

    // Check for existing pending wave
    const existing = await this.em.findOne(Wave, {
      fromUser: fromUserId,
      toUser: toUserId,
      status: WaveStatus.PENDING,
    });
    if (existing) {
      throw new ConflictException('You already have a pending wave to this user');
    }

    // Check if blocked
    const blocked = await this.em.findOne(YoyoOverride, {
      user: toUserId,
      targetUser: fromUserId,
      action: YoyoOverrideAction.BLOCK,
    });
    if (blocked) {
      throw new ForbiddenException('Cannot send wave to this user');
    }

    const fromUser = await this.em.findOneOrFail(User, { id: fromUserId });
    const wave = this.em.create(Wave, {
      fromUser,
      toUser,
      message,
    } as any);
    await this.em.flush();
    return wave;
  }

  async respondToWave(
    waveId: string,
    userId: string,
    accept: boolean,
  ): Promise<Wave> {
    const wave = await this.em.findOne(Wave, { id: waveId }, { populate: ['fromUser', 'toUser'] });
    if (!wave) throw new NotFoundException('Wave not found');

    if (wave.toUser.id !== userId) {
      throw new ForbiddenException('Not the recipient of this wave');
    }

    if (wave.status !== WaveStatus.PENDING) {
      throw new ConflictException('Wave has already been responded to');
    }

    wave.status = accept ? WaveStatus.ACCEPTED : WaveStatus.DECLINED;
    wave.respondedAt = new Date();

    if (accept) {
      // Create a messaging thread between the two users
      const thread = this.em.create(Thread, {
        moduleKey: ThreadModuleKey.SOCIAL_STUMBLE,
      } as any);
      await this.em.flush();

      this.em.create(ThreadParticipant, { thread, user: wave.fromUser } as any);
      this.em.create(ThreadParticipant, { thread, user: wave.toUser } as any);
    }

    await this.em.flush();
    return wave;
  }

  async getIncomingWaves(userId: string): Promise<Wave[]> {
    return this.em.find(
      Wave,
      { toUser: userId, status: WaveStatus.PENDING },
      { populate: ['fromUser'], orderBy: { createdAt: 'DESC' } },
    );
  }
}
