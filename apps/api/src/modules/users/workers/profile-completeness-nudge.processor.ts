import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Job } from 'bullmq';
import { User } from '../entities/user.entity';
import { NotificationsService } from '../../notifications/notifications.service';
import { NotificationType } from '../../../common/enums';
import {
  PROFILE_COMPLETENESS_NUDGE_QUEUE,
  ProfileCompletenessNudgeJob,
} from './profile-completeness-nudge.queue';

/**
 * Human-readable copy for each missing profile field. Kept small and
 * concrete so the push body reads naturally when composed.
 */
export const MISSING_FIELD_LABELS: Record<string, string> = {
  dob: 'your birthday',
  display_name: 'your name',
  username: 'a username',
  avatar_url: 'a profile photo',
  interests: 'your interests',
  primary_phone_verified: 'a verified phone',
  primary_email_verified: 'a verified email',
  tutorial_completed: 'the quick tutorial',
};

export const NUDGE_TITLE = 'Finish your Kuwboo profile';
export const NUDGE_DEEP_LINK = 'kuwboo://profile/edit';
export const NUDGE_MAX_FIELDS_IN_BODY = 2;

/**
 * Composes the FCM body for a nudge, capped at
 * `NUDGE_MAX_FIELDS_IN_BODY` items so the notification stays short.
 */
export function buildNudgeBody(missingFields: string[]): string {
  const labels = missingFields
    .slice(0, NUDGE_MAX_FIELDS_IN_BODY)
    .map((f) => MISSING_FIELD_LABELS[f] ?? f);

  if (labels.length === 0) {
    return 'Finish setting up your profile to unlock more of Kuwboo.';
  }
  if (labels.length === 1) {
    return `Add ${labels[0]} to unlock more of Kuwboo.`;
  }
  return `Add ${labels[0]} and ${labels[1]} to unlock more of Kuwboo.`;
}

/**
 * Consumes `profile-completeness-nudge` jobs and sends one FCM push per
 * user via `NotificationsService`. Updates
 * `users.last_profile_reminder_at` on success so the cron's 7-day
 * cooldown query excludes the user on subsequent runs.
 */
@Processor(PROFILE_COMPLETENESS_NUDGE_QUEUE)
export class ProfileCompletenessNudgeProcessor extends WorkerHost {
  private readonly logger = new Logger(ProfileCompletenessNudgeProcessor.name);

  constructor(
    private readonly em: EntityManager,
    private readonly notifications: NotificationsService,
  ) {
    super();
  }

  async process(job: Job<ProfileCompletenessNudgeJob>): Promise<void> {
    if (job.name !== 'nudge') {
      this.logger.warn(`Unknown job name: ${job.name}`);
      return;
    }

    const { userId, missingFields, completenessPct } = job.data;

    const user = await this.em.findOne(User, { id: userId });
    if (!user) {
      this.logger.warn(`Nudge skipped: user ${userId} not found`);
      return;
    }

    const title = NUDGE_TITLE;
    const body = buildNudgeBody(missingFields);

    await this.notifications.send(user, NotificationType.SYSTEM, title, body, {
      deep_link: NUDGE_DEEP_LINK,
      kind: 'profile_completeness_nudge',
      completeness_pct: completenessPct,
    });

    user.lastProfileReminderAt = new Date();
    await this.em.flush();

    this.logger.debug(
      `Profile-completeness nudge sent user=${userId} pct=${completenessPct} missing=${missingFields.length}`,
    );
  }
}
