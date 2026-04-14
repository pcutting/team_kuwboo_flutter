import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { EntityManager } from '@mikro-orm/postgresql';

/**
 * Per-tick decay factor. Weights are multiplied by this value on every run.
 * See docs/team/internal/IDENTITY_CONTRACT.md §9 — behavioural signals
 * half-life roughly every ~6-7 weeks at the default weekly cadence.
 */
export const DECAY_FACTOR = 0.9;

/**
 * Rows whose post-decay weight falls below this threshold are pruned to
 * keep the table compact.
 */
export const PRUNE_THRESHOLD = 0.01;

@Injectable()
export class InterestSignalDecayCron {
  private readonly logger = new Logger(InterestSignalDecayCron.name);

  constructor(private readonly em: EntityManager) {}

  /** Sunday 03:00 UTC. */
  @Cron('0 3 * * 0', { name: 'interest-signal-decay', timeZone: 'UTC' })
  async run(): Promise<void> {
    await this.decayOnce();
  }

  /**
   * Public for tests. Runs a single decay pass in one transaction: multiplies
   * every weight by DECAY_FACTOR, then prunes rows below PRUNE_THRESHOLD.
   * Returns the number of rows decayed and pruned.
   */
  async decayOnce(): Promise<{ decayed: number; pruned: number }> {
    return this.em.transactional(async (fork) => {
      const conn = fork.getConnection();

      const decayRes = (await conn.execute(
        `update "interest_signals" set "weight" = "weight" * $1;`,
        [DECAY_FACTOR],
      )) as { affectedRows?: number } | unknown;

      const pruneRes = (await conn.execute(
        `delete from "interest_signals" where "weight" < $1;`,
        [PRUNE_THRESHOLD],
      )) as { affectedRows?: number } | unknown;

      const decayed = extractAffected(decayRes);
      const pruned = extractAffected(pruneRes);

      this.logger.log(
        `Interest-signal decay: decayed=${decayed} pruned=${pruned} factor=${DECAY_FACTOR}`,
      );
      return { decayed, pruned };
    });
  }
}

function extractAffected(res: unknown): number {
  if (res && typeof res === 'object' && 'affectedRows' in res) {
    const v = (res as { affectedRows?: number }).affectedRows;
    return typeof v === 'number' ? v : 0;
  }
  return 0;
}
