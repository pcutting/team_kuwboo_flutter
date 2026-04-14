import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Job } from 'bullmq';
import {
  INTEREST_SIGNAL_QUEUE,
  InterestSignalBumpJob,
} from '../interest-signals.service';

/**
 * Default per-source weight deltas applied when a job arrives without an
 * explicit `weight`. Tunable — revisit once we have real retention data.
 * See docs/team/internal/IDENTITY_CONTRACT.md §9.
 */
export const SOURCE_WEIGHTS: Record<string, number> = {
  'video.watched': 1.0,
  'content.liked': 2.0,
  'post.read': 0.5,
  'search.executed': 3.0,
};

export const DEFAULT_WEIGHT = 1.0;

/**
 * Consumes behavioural interest signals and upserts them into
 * `interest_signals`. Idempotency is deferred to the decay cron — if a
 * duplicate event arrives the weight compounds and weekly decay normalises.
 */
@Processor(INTEREST_SIGNAL_QUEUE)
export class InterestSignalProcessor extends WorkerHost {
  private readonly logger = new Logger(InterestSignalProcessor.name);

  constructor(private readonly em: EntityManager) {
    super();
  }

  async process(job: Job<InterestSignalBumpJob>): Promise<void> {
    if (job.name !== 'bump') {
      this.logger.warn(`Unknown job name: ${job.name}`);
      return;
    }

    const { userId, interestIds, source, weight } = job.data;
    if (!interestIds || interestIds.length === 0) return;

    const delta = this.resolveWeight(source, weight);
    await this.upsert(userId, interestIds, delta);

    this.logger.debug(
      `Processed interest-signal bump user=${userId} source=${source} ids=${interestIds.length} delta=${delta}`,
    );
  }

  /** Exposed for unit testing; resolves per-source default when delta absent. */
  resolveWeight(source: string, weight?: number): number {
    if (typeof weight === 'number') return weight;
    return SOURCE_WEIGHTS[source] ?? DEFAULT_WEIGHT;
  }

  /**
   * Upserts one row per (user_id, interest_id). New rows take `weight=delta`;
   * existing rows get `weight = weight + delta`, `event_count += 1`, and
   * `last_seen_at = now()`.
   */
  async upsert(
    userId: string,
    interestIds: string[],
    delta: number,
  ): Promise<void> {
    if (interestIds.length === 0) return;

    // Build parameterised VALUES list: ($1, $2, $delta_idx), ($1, $3, ...)
    const placeholders: string[] = [];
    const params: unknown[] = [userId];
    interestIds.forEach((id, i) => {
      placeholders.push(`($1, $${i + 2}, $${interestIds.length + 2})`);
      params.push(id);
    });
    params.push(delta);

    const sql =
      `insert into "interest_signals" ("user_id", "interest_id", "weight", "event_count", "last_seen_at") ` +
      `select v.user_id, v.interest_id, v.weight, 1, now() from (values ` +
      placeholders
        .map(
          (_, i) =>
            `($1::uuid, $${i + 2}::uuid, $${interestIds.length + 2}::float8)`,
        )
        .join(', ') +
      `) as v(user_id, interest_id, weight) ` +
      `on conflict ("user_id", "interest_id") do update set ` +
      `weight = "interest_signals"."weight" + excluded.weight, ` +
      `event_count = "interest_signals"."event_count" + 1, ` +
      `last_seen_at = now();`;

    await this.em.getConnection().execute(sql, params);
  }
}
