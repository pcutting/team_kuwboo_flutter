import { Injectable, Logger } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

export const INTEREST_SIGNAL_QUEUE = 'interest-signal';

export interface InterestSignalBumpJob {
  userId: string;
  interestIds: string[];
  source: string; // e.g. 'video.watched', 'content.liked', 'post.read', 'search.executed'
  weight?: number;
}

/**
 * Enqueues behavioural interest-signal bumps to BullMQ. The consumer
 * worker lives in D2d; this service just ensures producers (content,
 * interactions) have a stable API to call today.
 */
@Injectable()
export class InterestSignalsService {
  private readonly logger = new Logger(InterestSignalsService.name);

  constructor(
    @InjectQueue(INTEREST_SIGNAL_QUEUE) private readonly queue: Queue<InterestSignalBumpJob>,
  ) {}

  async enqueueBump(job: InterestSignalBumpJob): Promise<void> {
    if (!job.interestIds || job.interestIds.length === 0) return;
    await this.queue.add('bump', job, {
      removeOnComplete: 1000,
      removeOnFail: 500,
      attempts: 3,
      backoff: { type: 'exponential', delay: 2000 },
    });
    this.logger.debug(
      `Enqueued interest-signal bump user=${job.userId} source=${job.source} ids=${job.interestIds.length}`,
    );
  }
}
