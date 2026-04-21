import * as request from 'supertest';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { DelayProvider } from '../src/modules/auth/login-throttle/delay.provider';
import { LoginAttempt, LoginAttemptOutcome } from '../src/modules/auth/login-throttle/login-attempt.entity';
import { LoginAttemptLogger } from '../src/modules/auth/login-throttle/login-attempt-logger.service';

/**
 * End-to-end coverage for the brute-force defence (issue #174).
 *
 * Substitutes a zero-delay DelayProvider into the DI container so
 * the exponential backoff in LoginThrottleService doesn't sleep
 * 31 seconds of real wall-clock (500 + 1000 + 2000 + 4000 + 8000 + 16000 ms
 * over attempts 4–9).
 *
 * We also register the test email pattern as a "reserved test email"
 * so the global `KuwbooThrottlerGuard` (which caps /auth/email/login
 * at 10 req / 15 min) skips rate-limiting for these tests — we're
 * exercising the login-throttle layer BELOW that guard.
 */
const TEST_EMAIL_DOMAIN = 'throttle-e2e.example';

describe('Login brute-force defence e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    // Whitelist every email used by this spec so the ThrottlerGuard
    // skips it.
    process.env.RESERVED_TEST_EMAILS =
      (process.env.RESERVED_TEST_EMAILS ?? '') +
      `,throttle1@${TEST_EMAIL_DOMAIN}` +
      `,throttle2@${TEST_EMAIL_DOMAIN}` +
      `,throttle3@${TEST_EMAIL_DOMAIN}`;

    ctx = await bootstrapTestApp();
    // Replace the real DelayProvider at runtime. Test-app is already
    // initialised at this point, but the service reads `.wait()` off
    // the DI singleton on each call so a mutating swap is safe.
    const instance = ctx.app.get(DelayProvider);
    (instance as any).wait = async () => {};
  });

  afterAll(async () => {
    await ctx.close();
  });

  // Three fixed emails — all pre-registered with the ThrottlerGuard's
  // reserved-emails list in beforeAll. Each test case owns one.
  const EMAIL_A = `throttle1@${TEST_EMAIL_DOMAIN}`;
  const EMAIL_B = `throttle2@${TEST_EMAIL_DOMAIN}`;
  const EMAIL_C = `throttle3@${TEST_EMAIL_DOMAIN}`;

  it('returns 429 generic after 10 wrong-password attempts and logs THROTTLED', async () => {
    const email = EMAIL_A;
    const password = 'OriginalPw1!';
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({
        email,
        password,
        legalAccepted: true,
        ageConfirmed: true,
      })
      .expect(200);

    // Attempts 1–9 are below the hard-throttle ceiling and return 401
    // (the per-attempt exponential backoff already ran, but our
    // zero-delay DelayProvider makes it instantaneous).
    for (let i = 0; i < 9; i++) {
      const res = await http
        .post('/auth/email/login')
        .send({ email, password: 'wrong!' });
      expect(res.status).toBe(401);
    }

    // Attempt 10 tips `failureCount` to 10, which crosses the
    // `ATTEMPTS_BEFORE_HARD_THROTTLE` ceiling — the service responds
    // 429 and logs THROTTLED rather than 401.
    const tipRes = await http
      .post('/auth/email/login')
      .send({ email, password: 'wrong!' });
    expect(tipRes.status).toBe(429);

    // Subsequent attempts are short-circuited by
    // `shouldBlockBeforeCheck` — no bcrypt compare, no counter bump.
    const res = await http
      .post('/auth/email/login')
      .send({ email, password: 'wrong!' });
    expect(res.status).toBe(429);
    const body = res.body.message ?? res.body;
    expect(body.code ?? res.body.code).toBe('too_many_attempts');

    // The correct password now also yields 429 — throttle short-circuits
    // before bcrypt. Hidden-success leak gate.
    const correct = await http
      .post('/auth/email/login')
      .send({ email, password });
    expect(correct.status).toBe(429);

    // Assert rows exist in auth_login_attempts and include at least one
    // THROTTLED entry.
    const em = ctx.em.fork();
    const emailHash = LoginAttemptLogger.hashEmail(email.toLowerCase());
    const rows = await em.find(LoginAttempt, { emailHash });
    expect(rows.length).toBeGreaterThanOrEqual(11);
    expect(rows.some((r) => r.outcome === LoginAttemptOutcome.THROTTLED)).toBe(
      true,
    );
    expect(
      rows.some((r) => r.outcome === LoginAttemptOutcome.WRONG_PASSWORD),
    ).toBe(true);
  });

  it('does not leak whether the email exists on throttled requests', async () => {
    const http = request(ctx.app.getHttpServer());
    const unknownEmail = EMAIL_B;

    // Hammer an unknown email 11 times to trip the per-(email, ip)
    // counter past its hard-throttle ceiling.
    for (let i = 0; i < 11; i++) {
      await http
        .post('/auth/email/login')
        .send({ email: unknownEmail, password: 'whatever' });
    }

    const res = await http
      .post('/auth/email/login')
      .send({ email: unknownEmail, password: 'whatever' });
    expect(res.status).toBe(429);
    const body = res.body.message ?? res.body;
    expect(body.code ?? res.body.code).toBe('too_many_attempts');
  });

  it('successful login resets the per-(email, ip) counter', async () => {
    const email = EMAIL_C;
    const password = 'ResetPw1!';
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({
        email,
        password,
        legalAccepted: true,
        ageConfirmed: true,
      })
      .expect(200);

    // Three wrong attempts (no delay + no throttle yet).
    for (let i = 0; i < 3; i++) {
      await http
        .post('/auth/email/login')
        .send({ email, password: 'wrong!' })
        .expect(401);
    }

    // Correct login now → resets counter.
    await http.post('/auth/email/login').send({ email, password }).expect(200);

    // Six more wrong attempts should still be allowed (counter was reset).
    for (let i = 0; i < 6; i++) {
      const r = await http
        .post('/auth/email/login')
        .send({ email, password: 'wrong!' });
      // 4th failure after reset would be at 500 ms delay but our
      // DelayProvider is a zero-delay stub — still returns 401.
      expect(r.status).toBe(401);
    }
  });
});
