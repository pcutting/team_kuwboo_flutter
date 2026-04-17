import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { Verification } from '../src/modules/verification/entities/verification.entity';
import { VerificationType, DobChoice } from '../src/common/enums';

/**
 * Email / password auth happy-path coverage. Each test uses a fresh
 * random email so the whole file can run in parallel with other e2e
 * specs sharing the same Postgres container.
 */
describe('Auth (email + password) e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  function freshEmail(): string {
    return `test+${Date.now()}.${Math.floor(Math.random() * 1e6)}@example.com`;
  }

  it('registers a new user, returns tokens, and authenticates /users/me', async () => {
    const email = freshEmail();
    const http = request(ctx.app.getHttpServer());

    const registerRes = await http
      .post('/auth/email/register')
      .send({
        email,
        password: 'StrongPassword1!',
        name: 'Ada Lovelace',
        dobChoice: DobChoice.ADULT_SELF_DECLARED,
      })
      .expect(200);

    const body = registerRes.body.data ?? registerRes.body;
    expect(body.accessToken).toEqual(expect.any(String));
    expect(body.refreshToken).toEqual(expect.any(String));
    expect(body.user.email).toBe(email);
    expect(body.isNewUser).toBe(true);

    const meRes = await http
      .get('/users/me')
      .set('Authorization', `Bearer ${body.accessToken}`)
      .expect(200);
    const me = meRes.body.data ?? meRes.body;
    expect(me.email).toBe(email);
  });

  it('rejects a duplicate registration with 409 email_taken', async () => {
    const email = freshEmail();
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({ email, password: 'StrongPassword1!' })
      .expect(200);

    const res = await http
      .post('/auth/email/register')
      .send({ email, password: 'AnotherPass2!' })
      .expect(409);
    expect(res.body.code ?? res.body.message?.code).toBeDefined();
  });

  it('logs in with correct credentials and rejects wrong password', async () => {
    const email = freshEmail();
    const password = 'StrongPassword1!';
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({ email, password })
      .expect(200);

    const loginRes = await http
      .post('/auth/email/login')
      .send({ email, password })
      .expect(200);
    const loginBody = loginRes.body.data ?? loginRes.body;
    expect(loginBody.accessToken).toEqual(expect.any(String));
    expect(loginBody.user.email).toBe(email);

    await http
      .post('/auth/email/login')
      .send({ email, password: 'wrong-password' })
      .expect(401);
  });

  it('completes the forgot -> reset -> login cycle', async () => {
    const email = freshEmail();
    const originalPassword = 'OriginalPw1!';
    const newPassword = 'NewRotatedPw9!';
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({ email, password: originalPassword })
      .expect(200);

    const forgotRes = await http
      .post('/auth/email/password/forgot')
      .send({ email })
      .expect(200);
    // Dev mode returns a devCode, but we override the hash below so the
    // test is deterministic regardless of container NODE_ENV.
    expect(forgotRes.body).toBeDefined();

    const knownCode = '135791';
    const knownHash = await bcrypt.hash(knownCode, 10);
    const em = ctx.em.fork();
    const verification = await em.findOne(
      Verification,
      {
        identifier: email,
        type: VerificationType.PASSWORD_RESET,
        verifiedAt: null,
      },
      { orderBy: { createdAt: 'DESC' } },
    );
    expect(verification).toBeTruthy();
    verification!.codeHash = knownHash;
    await em.flush();

    const resetRes = await http
      .post('/auth/email/password/reset')
      .send({ email, code: knownCode, newPassword })
      .expect(200);
    const resetBody = resetRes.body.data ?? resetRes.body;
    expect(resetBody.accessToken).toEqual(expect.any(String));

    // Old password should now fail; new password works.
    await http
      .post('/auth/email/login')
      .send({ email, password: originalPassword })
      .expect(401);
    await http
      .post('/auth/email/login')
      .send({ email, password: newPassword })
      .expect(200);
  });

  it('rejects password reset with an invalid code as 400 invalid_code', async () => {
    const email = freshEmail();
    const http = request(ctx.app.getHttpServer());

    await http
      .post('/auth/email/register')
      .send({ email, password: 'Pw123456!' })
      .expect(200);
    await http.post('/auth/email/password/forgot').send({ email }).expect(200);

    const res = await http
      .post('/auth/email/password/reset')
      .send({ email, code: '999999', newPassword: 'WhateverNew1!' })
      .expect(400);
    const payload = res.body.message ?? res.body;
    expect(payload.code ?? res.body.code).toBe('invalid_code');
  });

  it('sends + confirms an email verification code', async () => {
    const email = freshEmail();
    const http = request(ctx.app.getHttpServer());

    const reg = await http
      .post('/auth/email/register')
      .send({ email, password: 'Pw123456!' })
      .expect(200);
    const { accessToken } = reg.body.data ?? reg.body;

    await http
      .post('/auth/email/verify/send')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);

    const knownCode = '246802';
    const knownHash = await bcrypt.hash(knownCode, 10);
    const em = ctx.em.fork();
    const verification = await em.findOne(
      Verification,
      {
        identifier: email,
        type: VerificationType.EMAIL_VERIFY,
        verifiedAt: null,
      },
      { orderBy: { createdAt: 'DESC' } },
    );
    expect(verification).toBeTruthy();
    verification!.codeHash = knownHash;
    await em.flush();

    const confirmRes = await http
      .post('/auth/email/verify/confirm')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ code: knownCode })
      .expect(200);
    const body = confirmRes.body.data ?? confirmRes.body;
    expect(body.emailVerified).toBe(true);
  });
});
