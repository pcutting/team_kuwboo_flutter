import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectQueue } from '@nestjs/bullmq';
import { EntityManager } from '@mikro-orm/postgresql';
import { Queue } from 'bullmq';
import { User } from '../entities/user.entity';
import { Credential } from '../../credentials/entities/credential.entity';
import { OnboardingProgress } from '../../../common/enums';
import { UsersService } from '../users.service';
import {
  PROFILE_COMPLETENESS_NUDGE_QUEUE,
  ProfileCompletenessNudgeJob,
} from './profile-completeness-nudge.queue';

/**
 * Users whose completeness is under this percentage are candidates for a
 * nudge (per IDENTITY_CONTRACT §8).
 */
export const COMPLETENESS_THRESHOLD = 70;

/** Minimum days between nudges to the same user. */
export const REMINDER_COOLDOWN_DAYS = 7;

/**
 * Nightly cron that enumerates users eligible for a profile-completeness
 * nudge and enqueues one BullMQ job per user. The actual FCM send is
 * performed by `ProfileCompletenessNudgeProcessor` so that retries,
 * backoff, and rate-limiting are handled by the BullMQ worker.
 */
@Injectable()
export class ProfileCompletenessNudgeCron {
  private readonly logger = new Logger(ProfileCompletenessNudgeCron.name);

  constructor(
    private readonly em: EntityManager,
    @InjectQueue(PROFILE_COMPLETENESS_NUDGE_QUEUE)
    private readonly queue: Queue<ProfileCompletenessNudgeJob>,
  ) {}

  /** Daily 11:00 UTC — most US timezones are awake, EU is mid-afternoon. */
  @Cron('0 11 * * *', {
    name: 'profile-completeness-nudge',
    timeZone: 'UTC',
  })
  async run(): Promise<void> {
    await this.runOnce();
  }

  /**
   * Exposed for tests. Respects `NUDGES_ENABLED` so dev/staging do not
   * spam real devices. Returns the number of jobs enqueued.
   */
  async runOnce(): Promise<number> {
    if (!isNudgesEnabled()) {
      this.logger.log('Profile-completeness nudge skipped: NUDGES_ENABLED=0');
      return 0;
    }

    const cutoff = new Date(
      Date.now() - REMINDER_COOLDOWN_DAYS * 24 * 60 * 60 * 1000,
    );

    const eligible = await this.em.find(User, {
      profileCompletenessPct: { $lt: COMPLETENESS_THRESHOLD },
      onboardingProgress: OnboardingProgress.COMPLETE,
      $or: [
        { lastProfileReminderAt: null },
        { lastProfileReminderAt: { $lt: cutoff } },
      ],
    });

    if (eligible.length === 0) {
      this.logger.log('Profile-completeness nudge: no eligible users');
      return 0;
    }

    let enqueued = 0;
    for (const user of eligible) {
      const credentials = await this.em.find(Credential, {
        user: user.id,
        revokedAt: null,
      });
      const missingFields = UsersService.computeMissingFields(user, credentials);

      await this.queue.add(
        'nudge',
        {
          userId: user.id,
          completenessPct: user.profileCompletenessPct,
          missingFields,
        },
        {
          removeOnComplete: 1000,
          removeOnFail: 500,
          attempts: 3,
          backoff: { type: 'exponential', delay: 2000 },
        },
      );
      enqueued++;
    }

    this.logger.log(
      `Profile-completeness nudge enqueued=${enqueued} threshold=${COMPLETENESS_THRESHOLD}`,
    );
    return enqueued;
  }
}

/** Exported so the processor can short-circuit on the same flag. */
export function isNudgesEnabled(): boolean {
  const flag = process.env.NUDGES_ENABLED;
  if (flag === undefined || flag === null) return false;
  const normalised = flag.trim().toLowerCase();
  return normalised === '1' || normalised === 'true' || normalised === 'yes';
}
