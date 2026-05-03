import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { MikroORM, RequestContext } from '@mikro-orm/core';
import { EntityManager } from '@mikro-orm/postgresql';
import { BotProfile } from './entities/bot-profile.entity';
import { BotEngineService } from './bot-engine.service';
import { BotSchedulerService } from './bot-scheduler.service';
import { BotSimulationStatus } from '../../common/enums';

interface BotActionJobData {
  botProfileId: string;
}

@Processor('bot-actions')
export class BotActionProcessor extends WorkerHost {
  private readonly logger = new Logger(BotActionProcessor.name);
  private readonly failureCounts = new Map<string, number>();

  constructor(
    private readonly orm: MikroORM,
    private readonly engine: BotEngineService,
    private readonly scheduler: BotSchedulerService,
  ) {
    super();
  }

  async process(job: Job<BotActionJobData>): Promise<void> {
    const { botProfileId } = job.data;

    // BullMQ workers run outside the Nest request lifecycle, so the
    // global EM has no AsyncLocalStorage context. Wrapping the entire
    // job in RequestContext.create gives downstream services
    // (BotEngineService, ContentService, InteractionsService, …) a
    // forked EM to use without any of them having to know they are
    // running inside a queue worker. Without this every `em.find` /
    // `em.flush` throws ValidationError.cannotUseGlobalContext.
    return RequestContext.create(this.orm.em, async () => {
      const em = this.orm.em as EntityManager;
      try {
        const profile = await em.findOne(
          BotProfile,
          { id: botProfileId },
          { populate: ['user'] },
        );
        if (!profile) {
          this.logger.warn(`Bot profile ${botProfileId} not found, skipping`);
          return;
        }

        // Only execute if still running
        if (profile.simulationStatus !== BotSimulationStatus.RUNNING) {
          this.logger.debug(
            `Bot ${botProfileId} is ${profile.simulationStatus}, skipping`,
          );
          return;
        }

        // Execute an action
        const result = await this.engine.executeRandomAction(profile);

        if (result.success) {
          this.failureCounts.delete(botProfileId);
        } else {
          const failures = (this.failureCounts.get(botProfileId) || 0) + 1;
          this.failureCounts.set(botProfileId, failures);

          // After 10 consecutive failures, put bot in error state
          if (failures >= 10) {
            profile.simulationStatus = BotSimulationStatus.ERROR;
            profile.errorMessage = `Too many consecutive failures: ${result.errorMessage}`;
            await em.flush();
            this.failureCounts.delete(botProfileId);
            this.logger.error(
              `Bot ${botProfileId} moved to ERROR state after 10 failures`,
            );
            return;
          }
        }

        // Schedule the next action
        await this.scheduler.scheduleNextAction(
          botProfileId,
          profile.behaviorConfig,
        );
      } catch (error: any) {
        this.logger.error(
          `Bot ${botProfileId} processor error: ${error.message}`,
        );

        // Try to mark as error. Use a separate fork so the failed
        // unit-of-work above doesn't bleed into this update.
        try {
          const recoveryEm = (this.orm.em as EntityManager).fork();
          const profile = await recoveryEm.findOne(BotProfile, {
            id: botProfileId,
          });
          if (profile) {
            profile.simulationStatus = BotSimulationStatus.ERROR;
            profile.errorMessage = error.message?.slice(0, 255);
            await recoveryEm.flush();
          }
        } catch {
          // Best-effort error recording
        }
      }
    });
  }
}
