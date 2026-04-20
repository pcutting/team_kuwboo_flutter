import { Job } from 'bullmq';
import { AccountAnonymizeProcessor } from './account-anonymize.processor';
import { AccountAnonymizeJob } from './account-anonymize.queue';
import { User } from '../entities/user.entity';
import { UserStatus } from '../../../common/enums';

/**
 * Unit tests for the 30-day anonymize processor. We stub the
 * EntityManager directly — the point of the processor is the
 * "should we proceed?" branching, not the SQL.
 */
describe('AccountAnonymizeProcessor', () => {
  function makeEm(user: User | null) {
    const em: Record<string, jest.Mock> = {
      fork: jest.fn(),
      findOne: jest.fn().mockResolvedValue(user),
      create: jest.fn(),
      flush: jest.fn().mockResolvedValue(undefined),
    };
    // em.fork() returns the same object so the processor's
    // `this.em.fork()` stays usable in the same shape.
    em.fork.mockReturnValue(em);
    return em;
  }

  function makeJob(
    userId = 'user-1',
    deletedAtIso = new Date(
      Date.now() - 31 * 24 * 60 * 60 * 1000,
    ).toISOString(),
  ): Job<AccountAnonymizeJob> {
    return {
      name: 'anonymize',
      data: { userId, deletedAtIso },
    } as Job<AccountAnonymizeJob>;
  }

  function makeUser(partial: Partial<User>): User {
    return {
      id: 'user-1',
      email: 'real@example.com',
      phone: '+14155551212',
      name: 'Alice',
      status: UserStatus.ACTIVE,
      ...partial,
    } as User;
  }

  it('skips when the user is gone (hard-purged)', async () => {
    const em = makeEm(null);
    const proc = new AccountAnonymizeProcessor(em as never);
    await expect(proc.process(makeJob())).resolves.toBeUndefined();
  });

  it('skips when the user has been restored (deletedAt null)', async () => {
    const user = makeUser({ deletedAt: undefined });
    const em = makeEm(user);
    const proc = new AccountAnonymizeProcessor(em as never);
    await expect(proc.process(makeJob())).resolves.toBeUndefined();
    expect(user.email).toBe('real@example.com');
  });

  it('skips when a newer soft-delete rescheduled the clock', async () => {
    const older = new Date(Date.now() - 40 * 24 * 60 * 60 * 1000);
    const newer = new Date(Date.now() - 1 * 24 * 60 * 60 * 1000);
    const user = makeUser({ deletedAt: newer });
    const em = makeEm(user);
    const proc = new AccountAnonymizeProcessor(em as never);
    await expect(
      proc.process(makeJob('user-1', older.toISOString())),
    ).resolves.toBeUndefined();
    // Not wiped.
    expect(user.email).toBe('real@example.com');
  });

  it('skips when deletedAt is less than 30 days old', async () => {
    const recent = new Date(Date.now() - 1 * 60 * 1000);
    const user = makeUser({ deletedAt: recent });
    const em = makeEm(user);
    const proc = new AccountAnonymizeProcessor(em as never);
    await expect(
      proc.process(makeJob('user-1', recent.toISOString())),
    ).resolves.toBeUndefined();
    expect(user.email).toBe('real@example.com');
  });

  it('nulls PII and flips status when the 30-day threshold has passed', async () => {
    const old = new Date(Date.now() - 31 * 24 * 60 * 60 * 1000);
    const user = makeUser({
      deletedAt: old,
      avatarUrl: 'https://cdn/a.png',
      bio: 'hello',
      googleId: 'g-123',
      appleId: 'a-456',
      username: 'alice',
      passwordHash: 'x',
    });
    const em = makeEm(user);
    const proc = new AccountAnonymizeProcessor(em as never);
    await proc.process(makeJob('user-1', old.toISOString()));

    expect(user.email).toBeUndefined();
    expect(user.phone).toBeUndefined();
    expect(user.name).toBe('Deleted user');
    expect(user.avatarUrl).toBeUndefined();
    expect(user.bio).toBeUndefined();
    expect(user.googleId).toBeUndefined();
    expect(user.appleId).toBeUndefined();
    expect(user.username).toBeUndefined();
    expect(user.passwordHash).toBeUndefined();
    expect(user.status).toBe(UserStatus.DELETED);
    expect(em.create).toHaveBeenCalled();
    expect(em.flush).toHaveBeenCalled();
  });

  it('ignores unknown job names', async () => {
    const em = makeEm(null);
    const proc = new AccountAnonymizeProcessor(em as never);
    await expect(
      proc.process({ name: 'unknown', data: {} } as Job<AccountAnonymizeJob>),
    ).resolves.toBeUndefined();
    expect(em.findOne).not.toHaveBeenCalled();
  });
});
