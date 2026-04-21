import { LoginMetricsService } from './login-metrics.service';

describe('LoginMetricsService', () => {
  let svc: LoginMetricsService;

  beforeEach(() => {
    svc = new LoginMetricsService();
  });

  it('starts with all counters at zero', () => {
    expect(svc.snapshot()).toEqual({
      login_failures_total: 0,
      login_throttled_total: 0,
      login_soft_lock_total: 0,
    });
  });

  it('incrementFailure bumps login_failures_total only', () => {
    svc.incrementFailure();
    svc.incrementFailure();
    expect(svc.snapshot()).toMatchObject({
      login_failures_total: 2,
      login_throttled_total: 0,
      login_soft_lock_total: 0,
    });
  });

  it('incrementThrottled bumps login_throttled_total only', () => {
    svc.incrementThrottled();
    expect(svc.snapshot()).toMatchObject({
      login_failures_total: 0,
      login_throttled_total: 1,
      login_soft_lock_total: 0,
    });
  });

  it('incrementSoftLock bumps login_soft_lock_total only', () => {
    svc.incrementSoftLock();
    expect(svc.snapshot()).toMatchObject({
      login_failures_total: 0,
      login_throttled_total: 0,
      login_soft_lock_total: 1,
    });
  });

  it('snapshot returns a copy — mutating it does not mutate internal state', () => {
    svc.incrementFailure();
    const snap = svc.snapshot() as any;
    snap.login_failures_total = 999;
    expect(svc.snapshot().login_failures_total).toBe(1);
  });

  it('reset zeroes everything', () => {
    svc.incrementFailure();
    svc.incrementThrottled();
    svc.incrementSoftLock();
    svc.reset();
    expect(svc.snapshot()).toEqual({
      login_failures_total: 0,
      login_throttled_total: 0,
      login_soft_lock_total: 0,
    });
  });
});
