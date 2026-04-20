import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { randomUUID } from 'crypto';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { createTestUser, authHeader } from './helpers/test-users';
import { User } from '../src/modules/users/entities/user.entity';
import { UserConsent } from '../src/modules/consent/entities/user-consent.entity';
import {
  ConsentSource,
  ConsentType,
  UserStatus,
} from '../src/common/enums';

/**
 * Throttle for `DELETE /users/me` is 3 requests per 5 minutes per IP
 * (see AccountController). All tests in this file run from the same
 * loopback address, so the test ordering has to respect that budget
 * to avoid spurious 429s. Ordering:
 *
 *   1. stale_token / wrong-password — failure paths that 401 BEFORE
 *      consuming a successful-delete slot (the throttler records a
 *      hit regardless of outcome, but these don't rely on 204).
 *   2. The single happy-path 204 test.
 *   3. Hard-purge (separate endpoint, separate budget).
 *   4. The explicit throttle-exhaustion test, which deliberately
 *      burns the remaining budget and is tagged last.
 */
describe('Account deletion e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('DELETE /users/me 401s with stale_token when JWT iat is older than 15 min', async () => {
    const user = await createTestUser(ctx.em);
    // Sign with a 24h absolute expiry so the stale iat doesn't also
    // trip the generic expired-token path in passport-jwt. We want
    // the failure to come from FreshTokenGuard, not JwtAuthGuard.
    // Pre-encoding the payload via Buffer makes jsonwebtoken treat
    // it as opaque and preserve every claim byte-for-byte (including
    // the custom `iat`).
    const staleIat = Math.floor(Date.now() / 1000) - 16 * 60;
    const exp = Math.floor(Date.now() / 1000) + 24 * 60 * 60;
    const staleToken = jwt.sign(
      Buffer.from(
        JSON.stringify({
          sub: user.id,
          role: user.role,
          jti: randomUUID(),
          iat: staleIat,
          exp,
        }),
      ),
      process.env.JWT_ACCESS_SECRET as string,
      { algorithm: 'HS256' },
    );

    const http = request(ctx.app.getHttpServer());
    const res = await http
      .delete('/users/me')
      .set('Authorization', `Bearer ${staleToken}`)
      .send({})
      .expect(401);
    expect(JSON.stringify(res.body)).toContain('stale_token');
  });

  it('DELETE /users/me 401s on wrong password', async () => {
    const password = 'CorrectHorse1!';
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await createTestUser(ctx.em);
    const em1 = ctx.em.fork();
    const managed = await em1.findOneOrFail(User, { id: user.id });
    managed.passwordHash = passwordHash;
    await em1.flush();

    const http = request(ctx.app.getHttpServer());
    await http
      .delete('/users/me')
      .set(authHeader(ctx.jwtService, user))
      .send({ password: 'WRONG' })
      .expect(401);
  });

  it('DELETE /users/me 204s on valid password and flips users.deleted_at', async () => {
    const password = 'CorrectHorse1!';
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await createTestUser(ctx.em);
    const em1 = ctx.em.fork();
    const managed = await em1.findOneOrFail(User, { id: user.id });
    managed.passwordHash = passwordHash;
    await em1.flush();

    const http = request(ctx.app.getHttpServer());
    await http
      .delete('/users/me')
      .set(authHeader(ctx.jwtService, user))
      .send({ password })
      .expect(204);

    const em2 = ctx.em.fork();
    const reloaded = await em2.findOne(
      User,
      { id: user.id },
      { filters: { notDeleted: false } },
    );
    expect(reloaded?.deletedAt).toBeInstanceOf(Date);
  });

  it('POST /users/me/purge deletes the user row and preserves UserConsent with null user_id', async () => {
    const user = await createTestUser(ctx.em);

    // Seed a consent row so we can verify GDPR preservation post-purge.
    const em1 = ctx.em.fork();
    const userRef = em1.getReference(User, user.id);
    em1.create(UserConsent, {
      user: userRef,
      consentType: ConsentType.TERMS,
      version: 'v1.0.0',
      source: ConsentSource.REGISTRATION,
      ipAddress: '127.0.0.1',
    } as never);
    await em1.flush();

    const http = request(ctx.app.getHttpServer());
    await http
      .post('/users/me/purge')
      .set(authHeader(ctx.jwtService, user))
      .send({})
      .expect(204);

    const em2 = ctx.em.fork();
    const gone = await em2.findOne(
      User,
      { id: user.id },
      { filters: { notDeleted: false } },
    );
    expect(gone).toBeNull();

    // Consent row must survive, now with a nulled user FK.
    const survivingConsents = await em2.find(UserConsent, {
      consentType: ConsentType.TERMS,
      version: 'v1.0.0',
    });
    expect(survivingConsents.length).toBeGreaterThan(0);
    expect(survivingConsents.some((c) => c.user === null)).toBe(true);
  });

  it('DELETE /users/me returns 429 once the 3/5min budget is exhausted', async () => {
    // This test intentionally runs last — the preceding DELETE tests
    // may have already consumed 2-3 throttle slots, so seeing a 429
    // anywhere in the four attempts below is sufficient proof the
    // throttle guard is wired.
    const user = await createTestUser(ctx.em);
    const http = request(ctx.app.getHttpServer());
    const headers = authHeader(ctx.jwtService, user);

    const statuses: number[] = [];
    for (let i = 0; i < 4; i++) {
      const res = await http.delete('/users/me').set(headers).send({});
      statuses.push(res.status);
    }
    expect(statuses).toContain(429);
  });

  it('UserStatus enum retains DELETED', () => {
    expect(UserStatus.DELETED).toBeDefined();
  });
});
