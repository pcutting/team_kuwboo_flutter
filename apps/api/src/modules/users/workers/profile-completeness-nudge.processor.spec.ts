import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { Job } from 'bullmq';
import {
  ProfileCompletenessNudgeProcessor,
  buildNudgeBody,
  NUDGE_TITLE,
  NUDGE_DEEP_LINK,
  NUDGE_MAX_FIELDS_IN_BODY,
  MISSING_FIELD_LABELS,
} from './profile-completeness-nudge.processor';
import { ProfileCompletenessNudgeJob } from './profile-completeness-nudge.queue';
import { NotificationsService } from '../../notifications/notifications.service';
import { NotificationType } from '../../../common/enums';

describe('buildNudgeBody', () => {
  it('returns a generic fallback when there are no missing fields', () => {
    expect(buildNudgeBody([])).toMatch(/Finish setting up your profile/i);
  });

  it('names a single missing field', () => {
    expect(buildNudgeBody(['dob'])).toBe(
      `Add ${MISSING_FIELD_LABELS.dob} to unlock more of Kuwboo.`,
    );
  });

  it('joins two missing fields with "and"', () => {
    expect(buildNudgeBody(['dob', 'avatar_url'])).toBe(
      `Add ${MISSING_FIELD_LABELS.dob} and ${MISSING_FIELD_LABELS.avatar_url} to unlock more of Kuwboo.`,
    );
  });

  it(`caps at ${NUDGE_MAX_FIELDS_IN_BODY} fields`, () => {
    const body = buildNudgeBody([
      'dob',
      'avatar_url',
      'username',
      'tutorial_completed',
    ]);
    expect(body).toContain(MISSING_FIELD_LABELS.dob);
    expect(body).toContain(MISSING_FIELD_LABELS.avatar_url);
    expect(body).not.toContain(MISSING_FIELD_LABELS.username);
    expect(body).not.toContain(MISSING_FIELD_LABELS.tutorial_completed);
  });

  it('falls back to the raw key when label is unknown', () => {
    expect(buildNudgeBody(['mystery_field'])).toContain('mystery_field');
  });
});

describe('ProfileCompletenessNudgeProcessor', () => {
  let processor: ProfileCompletenessNudgeProcessor;
  let findOne: jest.Mock;
  let flush: jest.Mock;
  let send: jest.Mock;
  let fakeUser: { id: string; lastProfileReminderAt?: Date };

  beforeEach(async () => {
    fakeUser = { id: 'u1' };
    findOne = jest.fn().mockResolvedValue(fakeUser);
    flush = jest.fn().mockResolvedValue(undefined);
    send = jest.fn().mockResolvedValue({ id: 'n1' });

    const em = {
      findOne,
      flush,
    } as unknown as EntityManager;
    const notifications = { send } as unknown as NotificationsService;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProfileCompletenessNudgeProcessor,
        { provide: EntityManager, useValue: em },
        { provide: NotificationsService, useValue: notifications },
      ],
    }).compile();

    processor = module.get(ProfileCompletenessNudgeProcessor);
  });

  const makeJob = (
    data: ProfileCompletenessNudgeJob,
    name = 'nudge',
  ): Job<ProfileCompletenessNudgeJob> =>
    ({ name, data }) as Job<ProfileCompletenessNudgeJob>;

  it('produces the expected FCM payload from a job', async () => {
    await processor.process(
      makeJob({
        userId: 'u1',
        completenessPct: 40,
        missingFields: ['dob', 'avatar_url'],
      }),
    );

    expect(send).toHaveBeenCalledTimes(1);
    const [user, type, title, body, data] = send.mock.calls[0];
    expect(user).toBe(fakeUser);
    expect(type).toBe(NotificationType.SYSTEM);
    expect(title).toBe(NUDGE_TITLE);
    expect(body).toBe(
      `Add ${MISSING_FIELD_LABELS.dob} and ${MISSING_FIELD_LABELS.avatar_url} to unlock more of Kuwboo.`,
    );
    expect(data).toEqual({
      deep_link: NUDGE_DEEP_LINK,
      kind: 'profile_completeness_nudge',
      completeness_pct: 40,
    });
  });

  it('stamps last_profile_reminder_at on success', async () => {
    await processor.process(
      makeJob({
        userId: 'u1',
        completenessPct: 40,
        missingFields: ['dob'],
      }),
    );

    expect(fakeUser.lastProfileReminderAt).toBeInstanceOf(Date);
    expect(flush).toHaveBeenCalled();
  });

  it('no-ops when the user has been deleted between enqueue and consume', async () => {
    findOne.mockResolvedValueOnce(null);
    await processor.process(
      makeJob({
        userId: 'ghost',
        completenessPct: 20,
        missingFields: ['dob'],
      }),
    );
    expect(send).not.toHaveBeenCalled();
    expect(flush).not.toHaveBeenCalled();
  });

  it('ignores unknown job names', async () => {
    await processor.process(
      makeJob(
        { userId: 'u1', completenessPct: 40, missingFields: [] },
        'ping',
      ),
    );
    expect(findOne).not.toHaveBeenCalled();
    expect(send).not.toHaveBeenCalled();
  });
});
