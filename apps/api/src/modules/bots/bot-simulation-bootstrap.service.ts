import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EntityManager } from '@mikro-orm/postgresql';
import { BotSchedulerService } from './bot-scheduler.service';
import { BotProfile } from './entities/bot-profile.entity';
import { BotSimulationStatus } from '../../common/enums';

/**
 * Auto-starts bot simulation on app boot when `BOT_SIMULATION_ENABLED`
 * is truthy. Production deployments should leave the flag unset so the
 * scheduler stays idle until an admin explicitly invokes
 * `POST /admin/bots/start-all`.
 *
 * The bootstrap respects an optional `BOT_SIMULATION_MAX_BOTS` cap so
 * staging environments can run the system end-to-end with a bounded
 * number of bots. Bots beyond the cap are left in their current state
 * (typically IDLE).
 */
function isTruthy(v: string | undefined): boolean {
  if (!v) return false;
  return ['1', 'true', 'yes', 'on'].includes(v.toLowerCase());
}

@Injectable()
export class BotSimulationBootstrap implements OnModuleInit {
  private readonly logger = new Logger(BotSimulationBootstrap.name);

  constructor(
    private readonly config: ConfigService,
    private readonly em: EntityManager,
    private readonly scheduler: BotSchedulerService,
  ) {}

  async onModuleInit(): Promise<void> {
    const enabled = isTruthy(this.config.get<string>('BOT_SIMULATION_ENABLED'));
    if (!enabled) {
      this.logger.log('Bot simulation auto-start disabled (BOT_SIMULATION_ENABLED unset).');
      return;
    }

    const maxBotsRaw = this.config.get<string>('BOT_SIMULATION_MAX_BOTS');
    const maxBots = maxBotsRaw ? parseInt(maxBotsRaw, 10) : undefined;

    // Use a forked EM since OnModuleInit runs outside the request scope
    // and the global EM has no active context yet.
    const em = this.em.fork();

    const candidates = await em.find(
      BotProfile,
      { simulationStatus: { $in: [BotSimulationStatus.IDLE, BotSimulationStatus.PAUSED] } },
      { limit: maxBots, orderBy: { createdAt: 'ASC' } },
    );

    if (candidates.length === 0) {
      this.logger.log('Bot simulation enabled but no bots in IDLE/PAUSED — nothing to start.');
      return;
    }

    let started = 0;
    for (const bot of candidates) {
      try {
        await this.scheduler.startBot(bot.id);
        started++;
      } catch (err: any) {
        this.logger.warn(`Failed to auto-start bot ${bot.id}: ${err.message}`);
      }
    }

    this.logger.log(
      `Bot simulation auto-start: ${started}/${candidates.length} bots started ` +
        `(BOT_DEMO_MODE=${this.config.get<string>('BOT_DEMO_MODE') ?? 'unset'}).`,
    );
  }
}
