import { Injectable, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { User } from '../users/entities/user.entity';
import { BotProfile, BotBehaviorConfig } from './entities/bot-profile.entity';
import { BotActivityLog } from './entities/bot-activity-log.entity';
import { YoyoSettings } from '../yoyo/entities/yoyo-settings.entity';
import { BotSimulationStatus, UserStatus, OnlineStatus, Role } from '../../common/enums';
import { CreateBotDto } from './dto/create-bot.dto';
import { UpdateBotDto } from './dto/update-bot.dto';
import { BulkCreateBotsDto } from './dto/bulk-create-bots.dto';
import { getPreset, PERSONA_NAMES } from './presets/persona-presets';

@Injectable()
export class BotsService {
  constructor(private readonly em: EntityManager) {}

  async createBot(dto: CreateBotDto): Promise<{ user: User; profile: BotProfile }> {
    const behaviorConfig = this.buildBehaviorConfig(dto.displayPersona, dto.behaviorConfigOverrides);

    const user = this.em.create(User, {
      name: dto.name,
      avatarUrl: dto.avatarUrl,
      dateOfBirth: dto.dateOfBirth ? new Date(dto.dateOfBirth) : undefined,
      role: Role.USER,
      status: UserStatus.ACTIVE,
      onlineStatus: OnlineStatus.OFFLINE,
      isBot: true,
      lastLocation: { latitude: dto.homeLatitude, longitude: dto.homeLongitude },
    } as any);

    await this.em.flush();

    const profile = this.em.create(BotProfile, {
      user,
      displayPersona: dto.displayPersona,
      backstory: dto.backstory,
      behaviorConfig,
      homeLocation: { latitude: dto.homeLatitude, longitude: dto.homeLongitude },
      roamRadiusKm: dto.roamRadiusKm ?? 5,
    } as any);

    // Create yoyo settings so the bot is visible in proximity
    this.em.create(YoyoSettings, { user } as any);

    await this.em.flush();
    return { user, profile };
  }

  async bulkCreateBots(dto: BulkCreateBotsDto): Promise<BotProfile[]> {
    const profiles: BotProfile[] = [];
    const prefix = dto.namePrefix || 'Bot';

    for (let i = 0; i < dto.count; i++) {
      const persona = dto.displayPersona || PERSONA_NAMES[i % PERSONA_NAMES.length];
      const name = `${prefix}_${String(i + 1).padStart(3, '0')}`;

      // Scatter bots slightly around the home location
      const jitterLat = (Math.random() - 0.5) * 0.02;
      const jitterLng = (Math.random() - 0.5) * 0.02;
      const lat = dto.homeLatitude + jitterLat;
      const lng = dto.homeLongitude + jitterLng;

      const result = await this.createBot({
        name,
        displayPersona: persona,
        homeLatitude: lat,
        homeLongitude: lng,
        roamRadiusKm: dto.roamRadiusKm,
      });
      profiles.push(result.profile);
    }

    return profiles;
  }

  async findAll(
    page = 1,
    limit = 20,
    simulationStatus?: BotSimulationStatus,
    displayPersona?: string,
  ): Promise<{ items: BotProfile[]; total: number }> {
    const where: any = {};
    if (simulationStatus) where.simulationStatus = simulationStatus;
    if (displayPersona) where.displayPersona = displayPersona;

    const [items, total] = await this.em.findAndCount(BotProfile, where, {
      populate: ['user'],
      orderBy: { createdAt: 'DESC' },
      limit,
      offset: (page - 1) * limit,
    });

    return { items, total };
  }

  async findById(id: string): Promise<BotProfile> {
    const profile = await this.em.findOne(BotProfile, { id }, { populate: ['user'] });
    if (!profile) throw new NotFoundException('Bot profile not found');
    return profile;
  }

  async updateBot(id: string, dto: UpdateBotDto): Promise<BotProfile> {
    const profile = await this.findById(id);

    if (dto.displayPersona !== undefined) {
      profile.displayPersona = dto.displayPersona;
      // Re-apply preset if persona changed and no explicit config override
      if (!dto.behaviorConfig) {
        profile.behaviorConfig = getPreset(dto.displayPersona);
      }
    }
    if (dto.backstory !== undefined) profile.backstory = dto.backstory;
    if (dto.behaviorConfig !== undefined) {
      profile.behaviorConfig = dto.behaviorConfig as unknown as BotBehaviorConfig;
    }
    if (dto.homeLatitude !== undefined && dto.homeLongitude !== undefined) {
      profile.homeLocation = { latitude: dto.homeLatitude, longitude: dto.homeLongitude };
    }
    if (dto.roamRadiusKm !== undefined) profile.roamRadiusKm = dto.roamRadiusKm;

    await this.em.flush();
    return profile;
  }

  async deleteBot(id: string): Promise<void> {
    const profile = await this.findById(id);
    profile.simulationStatus = BotSimulationStatus.IDLE;
    profile.user.deletedAt = new Date();
    profile.user.status = UserStatus.DELETED;
    await this.em.flush();
  }

  async getActivityLog(
    botProfileId: string,
    cursor?: string,
    limit = 50,
  ): Promise<{ items: BotActivityLog[]; nextCursor?: string }> {
    const where: any = { botProfile: botProfileId };
    if (cursor) where.executedAt = { $lt: new Date(cursor) };

    const items = await this.em.find(BotActivityLog, where, {
      orderBy: { executedAt: 'DESC' },
      limit: limit + 1,
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      items.pop();
      nextCursor = items[items.length - 1].executedAt.toISOString();
    }

    return { items, nextCursor };
  }

  async getBotStats(): Promise<Record<string, number>> {
    const [totalBots, runningBots, pausedBots, idleBots, errorBots] = await Promise.all([
      this.em.count(BotProfile, {}),
      this.em.count(BotProfile, { simulationStatus: BotSimulationStatus.RUNNING }),
      this.em.count(BotProfile, { simulationStatus: BotSimulationStatus.PAUSED }),
      this.em.count(BotProfile, { simulationStatus: BotSimulationStatus.IDLE }),
      this.em.count(BotProfile, { simulationStatus: BotSimulationStatus.ERROR }),
    ]);

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const actionsToday = await this.em.count(BotActivityLog, {
      executedAt: { $gte: today },
    });

    return { totalBots, runningBots, pausedBots, idleBots, errorBots, actionsToday };
  }

  async resetBot(id: string): Promise<BotProfile> {
    const profile = await this.findById(id);
    profile.simulationStatus = BotSimulationStatus.IDLE;
    profile.errorMessage = undefined;
    await this.em.flush();
    return profile;
  }

  async getActivityStats(botProfileId: string): Promise<Record<string, unknown>> {
    const profile = await this.findById(botProfileId);

    const totalActions = await this.em.count(BotActivityLog, {
      botProfile: botProfileId,
    });

    const successfulActions = await this.em.count(BotActivityLog, {
      botProfile: botProfileId,
      success: true,
    });

    const successRate = totalActions > 0
      ? Math.round((successfulActions / totalActions) * 10000) / 100
      : 0;

    const now = new Date();
    const last24h = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    const actionsLast24h = await this.em.count(BotActivityLog, {
      botProfile: botProfileId,
      executedAt: { $gte: last24h },
    });

    const knex = this.em.getKnex();
    const actionsByTypeRows = await knex('bot_activity_logs')
      .select('action_type')
      .count('* as count')
      .where('bot_profile_id', botProfileId)
      .groupBy('action_type');

    const actionsByType: Record<string, number> = {};
    for (const row of actionsByTypeRows) {
      actionsByType[row.action_type] = Number(row.count);
    }

    return {
      totalActions,
      successRate,
      actionsLast24h,
      actionsByType,
    };
  }

  private buildBehaviorConfig(
    persona: string,
    overrides?: Record<string, unknown>,
  ): BotBehaviorConfig {
    const config = getPreset(persona);
    if (overrides) {
      // Deep merge action weights if provided
      if (overrides.actionWeights && typeof overrides.actionWeights === 'object') {
        Object.assign(config.actionWeights, overrides.actionWeights);
        delete overrides.actionWeights;
      }
      Object.assign(config, overrides);
    }
    return config;
  }
}
