import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { MikroORM } from '@mikro-orm/core';
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

    // Fork EntityManager for clean unit-of-work per job
    const em = this.orm.em.fork();

    try {
      const profile = await em.findOne(BotProfile, { id: botProfileId }, { populate: ['user'] });
      if (!profile) {
        this.logger.warn(`Bot profile ${botProfileId} not found, skipping`);
        return;
      }

      // Only execute if still running
      if (profile.simulationStatus !== BotSimulationStatus.RUNNING) {
        this.logger.debug(`Bot ${botProfileId} is ${profile.simulationStatus}, skipping`);
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
          this.logger.error(`Bot ${botProfileId} moved to ERROR state after 10 failures`);
          return;
        }
      }

      // Schedule the next action
      await this.scheduler.scheduleNextAction(botProfileId, profile.behaviorConfig);
    } catch (error: any) {
      this.logger.error(`Bot ${botProfileId} processor error: ${error.message}`);

      // Try to mark as error
      try {
        const profile = await em.findOne(BotProfile, { id: botProfileId });
        if (profile) {
          profile.simulationStatus = BotSimulationStatus.ERROR;
          profile.errorMessage = error.message?.slice(0, 255);
          await em.flush();
        }
      } catch {
        // Best-effort error recording
      }
    }
  }
}
