import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { getQueueToken } from '@nestjs/bullmq';
import {
  ProfileCompletenessNudgeCron,
  COMPLETENESS_THRESHOLD,
  REMINDER_COOLDOWN_DAYS,
  isNudgesEnabled,
} from './profile-completeness-nudge.cron';
import { PROFILE_COMPLETENESS_NUDGE_QUEUE } from './profile-completeness-nudge.queue';
import { User } from '../entities/user.entity';
import { Credential } from '../../credentials/entities/credential.entity';
import {
  CredentialType,
  OnboardingProgress,
} from '../../../common/enums';

describe('isNudgesEnabled', () => {
  const original = process.env.NUDGES_ENABLED;
  afterEach(() => {
    if (original === undefined) delete process.env.NUDGES_ENABLED;
    else process.env.NUDGES_ENABLED = original;
  });

  it('defaults to false when unset', () => {
    delete process.env.NUDGES_ENABLED;
    expect(isNudgesEnabled()).toBe(false);
  });

  it('is false for "0"', () => {
    process.env.NUDGES_ENABLED = '0';
    expect(isNudgesEnabled()).toBe(false);
  });

  it('is true for "1", "true", "yes" (any case)', () => {
    for (const v of ['1', 'true', 'TRUE', 'Yes']) {
      process.env.NUDGES_ENABLED = v;
      expect(isNudgesEnabled()).toBe(true);
    }
  });
});

describe('ProfileCompletenessNudgeCron', () => {
  let cron: ProfileCompletenessNudgeCron;
  let find: jest.Mock;
  let add: jest.Mock;
  const originalFlag = process.env.NUDGES_ENABLED;

  /**
   * Seed a 3-user fixture that exercises the full eligibility filter:
   *
   *   - eligible:       onboarding complete, pct=40, never reminded
   *   - recent-reminder: onboarding complete, pct=40, reminded yesterday
   *   - complete-profile: onboarding complete, pct=90
   *
   * A hand-rolled EM.find() honours the same predicate shape the cron
   * uses so the cooldown / threshold logic is exercised end-to-end
   * without a real DB.
   */
  beforeEach(async () => {
    process.env.NUDGES_ENABLED = '1';
    const now = Date.now();
    const fixture: User[] = [
      fakeUser({
        id: 'eligible',
        profileCompletenessPct: 40,
        onboardingProgress: OnboardingProgress.COMPLETE,
        lastProfileReminderAt: undefined,
      }),
      fakeUser({
        id: 'recent',
        profileCompletenessPct: 40,
        onboardingProgress: OnboardingProgress.COMPLETE,
        lastProfileReminderAt: new Date(now - 24 * 60 * 60 * 1000),
      }),
      fakeUser({
        id: 'complete',
        profileCompletenessPct: 90,
        onboardingProgress: OnboardingProgress.COMPLETE,
        lastProfileReminderAt: undefined,
      }),
    ];

    find = jest.fn(async (entity: unknown, where: any) => {
      if (entity === User) {
        const cutoff = where.$or?.[1]?.lastProfileReminderAt?.$lt as Date;
        return fixture.filter((u) => {
          if (u.profileCompletenessPct >= COMPLETENESS_THRESHOLD) return false;
          if (u.onboardingProgress !== OnboardingProgress.COMPLETE) return false;
          if (!u.lastProfileReminderAt) return true;
          return u.lastProfileReminderAt < cutoff;
        });
      }
      if (entity === Credential) {
        // Return one phone credential so the missing-fields list is
        // deterministic.
        return [{ type: CredentialType.PHONE }];
      }
      return [];
    });
    add = jest.fn().mockResolvedValue(undefined);

    const em = { find } as unknown as EntityManager;
    const queue = { add } as unknown as { add: jest.Mock };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProfileCompletenessNudgeCron,
        { provide: EntityManager, useValue: em },
        { provide: getQueueToken(PROFILE_COMPLETENESS_NUDGE_QUEUE), useValue: queue },
      ],
    }).compile();

    cron = module.get(ProfileCompletenessNudgeCron);
  });

  afterEach(() => {
    if (originalFlag === undefined) delete process.env.NUDGES_ENABLED;
    else process.env.NUDGES_ENABLED = originalFlag;
  });

  it('enqueues exactly one nudge — the eligible user', async () => {
    const enqueued = await cron.runOnce();

    expect(enqueued).toBe(1);
    expect(add).toHaveBeenCalledTimes(1);
    const [jobName, payload] = add.mock.calls[0];
    expect(jobName).toBe('nudge');
    expect(payload.userId).toBe('eligible');
    expect(payload.completenessPct).toBe(40);
    expect(Array.isArray(payload.missingFields)).toBe(true);
    // The fake Credentials return includes PHONE, so phone is not listed.
    expect(payload.missingFields).not.toContain('primary_phone_verified');
  });

  it(`uses a ${REMINDER_COOLDOWN_DAYS}-day cooldown`, async () => {
    await cron.runOnce();
    const userWhere = find.mock.calls.find((c) => c[0] === User)?.[1];
    const cutoff = userWhere.$or[1].lastProfileReminderAt.$lt as Date;
    const expected =
      Date.now() - REMINDER_COOLDOWN_DAYS * 24 * 60 * 60 * 1000;
    expect(Math.abs(cutoff.getTime() - expected)).toBeLessThan(1000);
  });

  it('short-circuits when NUDGES_ENABLED=0', async () => {
    process.env.NUDGES_ENABLED = '0';
    const enqueued = await cron.runOnce();
    expect(enqueued).toBe(0);
    expect(find).not.toHaveBeenCalled();
    expect(add).not.toHaveBeenCalled();
  });
});

function fakeUser(overrides: Partial<User>): User {
  const u = {
    id: 'u',
    name: '',
    profileCompletenessPct: 0,
    onboardingProgress: OnboardingProgress.WELCOME,
    dateOfBirth: undefined,
    username: undefined,
    avatarUrl: undefined,
    tutorialCompletedAt: undefined,
    lastProfileReminderAt: undefined,
    ...overrides,
  };
  return u as unknown as User;
}
