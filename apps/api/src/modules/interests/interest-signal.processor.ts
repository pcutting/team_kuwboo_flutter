import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import {
  INTEREST_SIGNAL_QUEUE,
  InterestSignalBumpJob,
} from './interest-signals.service';

/**
 * Stub worker for the interest-signal queue.
 *
 * The real decay/upsert logic lands in D2d. This stub just acks messages
 * so dev environments don't backlog the queue while producers are already
 * wired up in D1b.
 */
@Processor(INTEREST_SIGNAL_QUEUE)
export class InterestSignalProcessor extends WorkerHost {
  private readonly logger = new Logger(InterestSignalProcessor.name);

  async process(job: Job<InterestSignalBumpJob>): Promise<void> {
    const { userId, interestIds, source } = job.data;
    this.logger.debug(
      `[stub] ack interest-signal bump user=${userId} source=${source} ids=${interestIds.length}`,
    );
  }
}
