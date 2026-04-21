import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import { MikroORM, RequestContext } from '@mikro-orm/core';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { DelayProvider } from '../src/modules/auth/login-throttle/delay.provider';
import { AuthService } from '../src/modules/auth/auth.service';
import { User } from '../src/modules/users/entities/user.entity';
import { Verification } from '../src/modules/verification/entities/verification.entity';
import { VerificationType } from '../src/common/enums';

/**
 * End-to-end coverage for phase 2 of issue #174 — the cross-IP
 * credential-stuffing detector and the account-level soft-lock.
 *
 * Key scenario: an attacker running a dictionary against a single
 * email across a rotating IP pool trips the account lock after the
 * third distinct IP, not after the 10-attempt ceiling (which would
 * let any single IP burn through 10 passwords before being noticed).
 *
 * Recovery path: completing a password reset clears `authLockedAt`.
 * Auto-unlock on timer is deliberately NOT implemented.
 */
const TEST_DOMAIN = 'account-lock-e2e.example';

describe('Account-level soft-lock e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    // Reserve the emails so the global ThrottlerGuard doesn't
    // shadow the app-level lock logic we're actually testing.
    process.env.RESERVED_TEST_EMAILS =
      (process.env.RESERVED_TEST_EMAILS ?? '') +
      `,stuff1@${TEST_DOMAIN}` +
      `,stuff2@${TEST_DOMAIN}`;

    ctx = await bootstrapTestApp();
    const delay = ctx.app.get(DelayProvider);
    (delay as any).wait = async () => {};
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('locks the account on the 3rd distinct IP and returns 429 on further logins', async () => {
    const email = `stuff1@${TEST_DOMAIN}`;
    const password = 'StrongPw1!';
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({ email, password, legalAccepted: true, ageConfirmed: true })
      .expect(200);

    // Drive the AuthService directly to simulate three distinct
    // source IPs. Going through the HTTP layer would require the
    // test bootstrap to honour `X-Forwarded-For` — it doesn't, and
    // wiring trust-proxy just for this test overlaps with a
    // behaviour-change that belongs in a separate PR.
    const authService = ctx.app.get(AuthService);

    const orm = ctx.app.get(MikroORM);

    // Call AuthService.emailLogin inside a fresh MikroORM request
    // context per IP so the injected EntityManager has a valid
    // identity map. Without this wrapper MikroORM throws "Using
    // global EntityManager..." because the HTTP middleware that
    // normally opens a request context is bypassed.
    for (const ip of ['10.1.1.1', '10.2.2.2', '10.3.3.3']) {
      await RequestContext.create(orm.em, async () => {
        try {
          await authService.emailLogin(email, 'wrong', { ipAddress: ip });
        } catch {
          /* expected rejection */
        }
      });
    }

    // By now the detector has crossed its threshold — assert the
    // lock column has been populated on the User row. Use a fresh
    // EM fork so we observe persisted state rather than a stale
    // managed instance.
    const em = ctx.em.fork({ clear: true });
    const userRow = await em.findOne(User, { email });
    expect(userRow).toBeTruthy();
    expect(userRow!.authLockedAt).toBeTruthy();

    // Subsequent login — even with the CORRECT password — must
    // return 429 without any user-existence leak. Going through the
    // HTTP layer here verifies the controller wiring.
    const res = await http
      .post('/auth/email/login')
      .send({ email, password });
    expect(res.status).toBe(429);
    const body = res.body.message ?? res.body;
    expect(body.code ?? res.body.code).toBe('too_many_attempts');
  });

  it('completing a password reset clears authLockedAt and lets login succeed again', async () => {
    const email = `stuff2@${TEST_DOMAIN}`;
    const password = 'StrongPw1!';
    const newPassword = 'RecoveredPw2!';
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({ email, password, legalAccepted: true, ageConfirmed: true })
      .expect(200);

    // Manually trip the lock — fastest way to get into the locked
    // state without fighting trust-proxy. Hit the findByEmail /
    // assign path directly via the entity manager.
    const em = ctx.em.fork();
    const userRow = await em.findOne(User, { email });
    expect(userRow).toBeTruthy();
    userRow!.authLockedAt = new Date();
    await em.flush();

    // Confirm the lock blocks login.
    const blocked = await http
      .post('/auth/email/login')
      .send({ email, password });
    expect(blocked.status).toBe(429);

    // Kick off a password reset. The forgot flow burns a code —
    // same pattern as email-password.e2e-spec.ts.
    await http
      .post('/auth/email/password/forgot')
      .send({ email })
      .expect(200);

    const knownCode = '246813';
    const knownHash = await bcrypt.hash(knownCode, 10);
    const em2 = ctx.em.fork();
    const verification = await em2.findOne(
      Verification,
      { identifier: email, type: VerificationType.PASSWORD_RESET, verifiedAt: null },
      { orderBy: { createdAt: 'DESC' } },
    );
    expect(verification).toBeTruthy();
    verification!.codeHash = knownHash;
    await em2.flush();

    await http
      .post('/auth/email/password/reset')
      .send({ email, code: knownCode, newPassword })
      .expect(200);

    // Reset cleared the lock. The new password works.
    const em3 = ctx.em.fork();
    const freshUser = await em3.findOne(User, { email });
    expect(freshUser!.authLockedAt).toBeFalsy();

    await http
      .post('/auth/email/login')
      .send({ email, password: newPassword })
      .expect(200);
  });
});
