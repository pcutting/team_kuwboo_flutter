import { LoginNotifierService } from './login-notifier.service';

describe('LoginNotifierService.notifyAccountLocked', () => {
  function makeDeps() {
    const sendLoginThreatNotice = jest.fn().mockResolvedValue(undefined);
    const markLockNotified = jest.fn();
    return {
      emailService: { sendLoginThreatNotice },
      throttle: { markLockNotified },
      sendLoginThreatNotice,
      markLockNotified,
    };
  }

  it('sends the email AND logs the ops event on the first call within the dedupe window', async () => {
    const deps = makeDeps();
    deps.markLockNotified.mockResolvedValue(true);
    const svc = new LoginNotifierService(
      deps.emailService as any,
      deps.throttle as any,
    );

    await svc.notifyAccountLocked({
      email: 'target@example.com',
      ipAddress: '1.2.3.4',
      userAgent: 'ua/1.0',
      attemptsLast24h: 9,
    });

    expect(deps.markLockNotified).toHaveBeenCalledWith('target@example.com');
    expect(deps.sendLoginThreatNotice).toHaveBeenCalledWith({
      to: 'target@example.com',
      ipAddress: '1.2.3.4',
      userAgent: 'ua/1.0',
      attemptsLast24h: 9,
    });
  });

  it('de-dupes within the TTL window — skips email + ops log on the second call', async () => {
    const deps = makeDeps();
    deps.markLockNotified.mockResolvedValue(false);
    const svc = new LoginNotifierService(
      deps.emailService as any,
      deps.throttle as any,
    );

    await svc.notifyAccountLocked({
      email: 'target@example.com',
      attemptsLast24h: 4,
    });

    expect(deps.markLockNotified).toHaveBeenCalledTimes(1);
    expect(deps.sendLoginThreatNotice).not.toHaveBeenCalled();
  });

  it('never throws when the email send rejects — error is swallowed + logged', async () => {
    const deps = makeDeps();
    deps.markLockNotified.mockResolvedValue(true);
    deps.sendLoginThreatNotice.mockRejectedValue(new Error('ses down'));
    const svc = new LoginNotifierService(
      deps.emailService as any,
      deps.throttle as any,
    );

    await expect(
      svc.notifyAccountLocked({
        email: 'target@example.com',
        attemptsLast24h: 3,
      }),
    ).resolves.toBeUndefined();
  });

  it('falls back to string "unknown" for missing ip / user-agent', async () => {
    const deps = makeDeps();
    deps.markLockNotified.mockResolvedValue(true);
    const svc = new LoginNotifierService(
      deps.emailService as any,
      deps.throttle as any,
    );

    await svc.notifyAccountLocked({
      email: 'target@example.com',
      attemptsLast24h: 1,
    });

    expect(deps.sendLoginThreatNotice).toHaveBeenCalledWith(
      expect.objectContaining({
        ipAddress: 'unknown',
        userAgent: 'unknown',
      }),
    );
  });
});
