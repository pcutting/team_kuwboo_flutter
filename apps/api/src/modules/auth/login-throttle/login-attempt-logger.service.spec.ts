import { createHash } from 'crypto';
import { LoginAttemptLogger } from './login-attempt-logger.service';
import { LoginAttemptOutcome } from './login-attempt.entity';

describe('LoginAttemptLogger.hashEmail', () => {
  it('produces a 64-char sha256 hex digest', () => {
    const h = LoginAttemptLogger.hashEmail('user@example.com');
    expect(h).toMatch(/^[0-9a-f]{64}$/);
  });

  it('is deterministic for identical inputs', () => {
    expect(LoginAttemptLogger.hashEmail('user@example.com')).toBe(
      LoginAttemptLogger.hashEmail('user@example.com'),
    );
  });

  it('differs for different inputs (anti-collision, not rigorous — sanity only)', () => {
    expect(LoginAttemptLogger.hashEmail('alice@example.com')).not.toBe(
      LoginAttemptLogger.hashEmail('bob@example.com'),
    );
  });

  it('matches a manual sha256 of the input', () => {
    const manual = createHash('sha256').update('manual@example.com').digest('hex');
    expect(LoginAttemptLogger.hashEmail('manual@example.com')).toBe(manual);
  });
});

describe('LoginAttemptLogger.log', () => {
  function makeLogger(persistAndFlush: jest.Mock) {
    const fork = {
      create: jest.fn().mockReturnValue({ sentinel: 'row' }),
      persistAndFlush,
    };
    const em = { fork: jest.fn().mockReturnValue(fork) };
    return new LoginAttemptLogger(em as any);
  }

  it('persists one row per log call on a forked EntityManager', async () => {
    const persist = jest.fn().mockResolvedValue(undefined);
    const logger = makeLogger(persist);

    await logger.log({
      email: 'user@example.com',
      ipAddress: '1.2.3.4',
      userAgent: 'ua/1.0',
      outcome: LoginAttemptOutcome.SUCCESS,
    });

    expect(persist).toHaveBeenCalledTimes(1);
    expect(persist).toHaveBeenCalledWith({ sentinel: 'row' });
  });

  it('swallows persistence errors without rethrowing', async () => {
    const persist = jest.fn().mockRejectedValue(new Error('pg down'));
    const logger = makeLogger(persist);
    await expect(
      logger.log({
        email: 'user@example.com',
        outcome: LoginAttemptOutcome.WRONG_PASSWORD,
      }),
    ).resolves.toBeUndefined();
  });
});
