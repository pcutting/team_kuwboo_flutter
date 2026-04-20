import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Job } from 'bullmq';
import { User } from '../entities/user.entity';
import { TrustSignal } from '../../trust/entities/trust-signal.entity';
import { UserStatus } from '../../../common/enums';
import {
  ACCOUNT_ANONYMIZE_QUEUE,
  AccountAnonymizeJob,
} from './account-anonymize.queue';

/**
 * Runs 30 days after a `DELETE /users/me` soft-delete to complete the
 * GDPR Art. 17 erasure:
 *
 *   1. Null out every PII column on the user row
 *      (email / phone / name / avatarUrl / bio / googleId / appleId /
 *       username).
 *   2. Flip status to DELETED so the row is excluded from any future
 *      directory / search surface that doesn't already honour
 *      `deletedAt`.
 *   3. Append a TrustSignal row recording the fact of anonymization
 *      for ops-side auditability (the AdminAuditLog row written at the
 *      soft-delete endpoint already captures the initiation; this
 *      captures the completion).
 *
 * Refuses to run if:
 *   - the user row is gone (hard-purged in the meantime),
 *   - `deletedAt` is now null (user restored),
 *   - `deletedAt` has moved forward (second soft-delete rescheduled
 *     the clock — the new job will anonymize on its own timeline),
 *   - the observed `deletedAt` is less than 30 days old (defensive
 *     against someone manually replaying a job early).
 *
 * All branches log at info so the ops timeline is readable without
 * needing to join across PG and BullMQ.
 */
@Processor(ACCOUNT_ANONYMIZE_QUEUE)
export class AccountAnonymizeProcessor extends WorkerHost {
  private readonly logger = new Logger(AccountAnonymizeProcessor.name);

  /**
   * Minimum time between the observed `deletedAt` and now before we
   * actually wipe PII. 29.9 days in ms — the scheduled delay is 30
   * days so this is just a fuzz factor for clock skew / BullMQ
   * rescheduling edge cases.
   */
  private static readonly MIN_AGE_MS = 29 * 24 * 60 * 60 * 1000;

  constructor(private readonly em: EntityManager) {
    super();
  }

  async process(job: Job<AccountAnonymizeJob>): Promise<void> {
    if (job.name !== 'anonymize') {
      this.logger.warn(`Unknown job name: ${job.name}`);
      return;
    }

    const { userId, deletedAtIso } = job.data;
    const em = this.em.fork();

    const user = await em.findOne(
      User,
      { id: userId },
      { filters: { notDeleted: false } },
    );
    if (!user) {
      this.logger.log(
        `Anonymize skipped: user ${userId} not found (already hard-purged?)`,
      );
      return;
    }

    if (!user.deletedAt) {
      this.logger.log(`Anonymize skipped: user ${userId} was restored.`);
      return;
    }

    const scheduledDeletedAt = new Date(deletedAtIso);
    if (user.deletedAt.getTime() > scheduledDeletedAt.getTime()) {
      this.logger.log(
        `Anonymize skipped: user ${userId} has a newer deletedAt ` +
          `(${user.deletedAt.toISOString()} > ${deletedAtIso}) — the newer ` +
          `job will handle anonymization.`,
      );
      return;
    }

    const ageMs = Date.now() - user.deletedAt.getTime();
    if (ageMs < AccountAnonymizeProcessor.MIN_AGE_MS) {
      this.logger.warn(
        `Anonymize refused: user ${userId} deletedAt is only ` +
          `${Math.floor(ageMs / 1000 / 60)}min old — below the 30-day floor.`,
      );
      return;
    }

    // Wipe PII. Keep the row so downstream FK SET-NULL cascades that
    // may have already fired stay consistent, and so the ID is still
    // valid for any audit-log row that references it by uuid.
    user.email = undefined;
    user.phone = undefined;
    user.name = 'Deleted user';
    user.avatarUrl = undefined;
    user.bio = undefined;
    user.googleId = undefined;
    user.appleId = undefined;
    user.username = undefined;
    user.status = UserStatus.DELETED;
    user.passwordHash = undefined;

    em.create(TrustSignal, {
      user,
      signalType: 'account_anonymized',
      delta: 0,
      source: 'account_anonymize_processor',
      metadata: {
        deletedAt: user.deletedAt.toISOString(),
        anonymizedAt: new Date().toISOString(),
      },
    } as never);

    await em.flush();

    this.logger.log(
      `Account anonymization complete for user ${userId} ` +
        `(soft-deleted ${user.deletedAt.toISOString()}).`,
    );
  }
}
