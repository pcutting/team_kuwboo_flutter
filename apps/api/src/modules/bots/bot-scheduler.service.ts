import { Injectable, Logger } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { EntityManager } from '@mikro-orm/postgresql';
import { ConfigService } from '@nestjs/config';
import { BotProfile } from './entities/bot-profile.entity';
import { BotSimulationStatus } from '../../common/enums';

/**
 * Optional fast-cadence override read from the env on each tick. When
 * `BOT_DEMO_MODE` is truthy the scheduler overrides each bot's persona
 * interval window with a tight `BOT_DEMO_MIN_INTERVAL_MS` /
 * `BOT_DEMO_MAX_INTERVAL_MS` range and bypasses the active-hours gate
 * so the demo emits steady traffic regardless of wall-clock time.
 *
 * Defaults (10 s – 60 s) target the "every bot fires once per ~30 s"
 * cadence requested for live demos. Production deployments should leave
 * `BOT_DEMO_MODE` unset and let persona-defined intervals apply.
 */
function isTruthy(v: string | undefined): boolean {
  if (!v) return false;
  return ['1', 'true', 'yes', 'on'].includes(v.toLowerCase());
}

@Injectable()
export class BotSchedulerService {
  private readonly logger = new Logger(BotSchedulerService.name);

  constructor(
    @InjectQueue('bot-actions') private readonly botQueue: Queue,
    private readonly em: EntityManager,
    private readonly config: ConfigService,
  ) {}

  private get demoMode(): boolean {
    return isTruthy(this.config.get<string>('BOT_DEMO_MODE'));
  }

  private get demoMinIntervalMs(): number {
    return parseInt(this.config.get<string>('BOT_DEMO_MIN_INTERVAL_MS') || '10000', 10);
  }

  private get demoMaxIntervalMs(): number {
    return parseInt(this.config.get<string>('BOT_DEMO_MAX_INTERVAL_MS') || '60000', 10);
  }

  async startBot(profileId: string): Promise<void> {
    const profile = await this.em.findOneOrFail(BotProfile, { id: profileId });

    if (profile.simulationStatus === BotSimulationStatus.RUNNING) {
      this.logger.warn(`Bot ${profileId} is already running`);
      return;
    }

    profile.simulationStatus = BotSimulationStatus.RUNNING;
    profile.errorMessage = undefined;
    await this.em.flush();

    await this.scheduleNextAction(profileId, profile.behaviorConfig);
    this.logger.log(`Started bot ${profileId}`);
  }

  async pauseBot(profileId: string): Promise<void> {
    const profile = await this.em.findOneOrFail(BotProfile, { id: profileId });
    profile.simulationStatus = BotSimulationStatus.PAUSED;
    await this.em.flush();

    await this.removeJobs(profileId);
    this.logger.log(`Paused bot ${profileId}`);
  }

  async stopBot(profileId: string): Promise<void> {
    const profile = await this.em.findOne(BotProfile, { id: profileId });
    if (!profile) return;

    profile.simulationStatus = BotSimulationStatus.IDLE;
    await this.em.flush();

    await this.removeJobs(profileId);
    this.logger.log(`Stopped bot ${profileId}`);
  }

  async startAllBots(): Promise<number> {
    const bots = await this.em.find(BotProfile, {
      simulationStatus: { $in: [BotSimulationStatus.IDLE, BotSimulationStatus.PAUSED] },
    });

    for (const bot of bots) {
      bot.simulationStatus = BotSimulationStatus.RUNNING;
      bot.errorMessage = undefined;
      await this.scheduleNextAction(bot.id, bot.behaviorConfig);
    }

    await this.em.flush();
    this.logger.log(`Started ${bots.length} bots`);
    return bots.length;
  }

  async stopAllBots(): Promise<number> {
    const bots = await this.em.find(BotProfile, {
      simulationStatus: BotSimulationStatus.RUNNING,
    });

    for (const bot of bots) {
      bot.simulationStatus = BotSimulationStatus.IDLE;
      await this.removeJobs(bot.id);
    }

    await this.em.flush();
    this.logger.log(`Stopped ${bots.length} bots`);
    return bots.length;
  }

  async scheduleNextAction(
    profileId: string,
    behaviorConfig: { minActionIntervalMs: number; maxActionIntervalMs: number; activeHoursStart: number; activeHoursEnd: number },
  ): Promise<void> {
    let delay: number;

    if (this.demoMode) {
      // Demo mode: ignore active-hours and persona intervals; emit steady
      // traffic in a tight window. Min/max are read from env on every
      // schedule call so an operator can tune cadence without restarting.
      const min = Math.max(1000, this.demoMinIntervalMs);
      const max = Math.max(min + 1, this.demoMaxIntervalMs);
      delay = min + Math.random() * (max - min);
    } else {
      const now = new Date();
      const currentHour = now.getHours();
      const { activeHoursStart, activeHoursEnd } = behaviorConfig;

      // Check if we're within active hours
      const isActive = activeHoursEnd > activeHoursStart
        ? currentHour >= activeHoursStart && currentHour < activeHoursEnd
        : currentHour >= activeHoursStart || currentHour < activeHoursEnd;

      if (isActive) {
        // Random delay between min and max interval
        const range = behaviorConfig.maxActionIntervalMs - behaviorConfig.minActionIntervalMs;
        delay = behaviorConfig.minActionIntervalMs + Math.random() * range;
      } else {
        // Schedule for start of active hours
        const nextActive = new Date(now);
        nextActive.setHours(activeHoursStart, 0, 0, 0);
        if (nextActive <= now) nextActive.setDate(nextActive.getDate() + 1);
        delay = nextActive.getTime() - now.getTime();
      }
    }

    await this.botQueue.add(
      'bot-action',
      { botProfileId: profileId },
      {
        delay: Math.round(delay),
        jobId: `bot-${profileId}-${Date.now()}`,
        removeOnComplete: true,
        removeOnFail: 5,
      },
    );
  }

  private async removeJobs(profileId: string): Promise<void> {
    const delayed = await this.botQueue.getDelayed();
    for (const job of delayed) {
      if (job.data?.botProfileId === profileId) {
        await job.remove();
      }
    }
  }
}
