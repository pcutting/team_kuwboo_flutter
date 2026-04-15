import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { Verification } from '../src/modules/verification/entities/verification.entity';
import { VerificationType } from '../src/common/enums';

describe('Auth (phone OTP) e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('sends OTP, verifies with a known code, and authenticates /users/me', async () => {
    // Valid E.164 US mobile: +1 (area) XXX-XXXX. Use 415 area for a
    // real NPA so libphonenumber / class-validator accepts it.
    const phone = `+1415${Math.floor(2000000 + Math.random() * 7999999)}`;
    const http = request(ctx.app.getHttpServer());

    // 1. Trigger OTP issuance. Local dev fallback writes a bcrypt-hashed
    // code to the `verifications` table — we overwrite it with a hash
    // we control so we can complete the verify step deterministically.
    await http.post('/auth/phone/send-otp').send({ phone }).expect(200);

    const knownCode = '424242';
    const knownHash = await bcrypt.hash(knownCode, 10);

    const em = ctx.em.fork();
    const verification = await em.findOne(
      Verification,
      {
        identifier: phone,
        type: VerificationType.PHONE_OTP,
        verifiedAt: null,
      },
      { orderBy: { createdAt: 'DESC' } },
    );
    expect(verification).toBeTruthy();
    verification!.codeHash = knownHash;
    await em.flush();

    // 2. Verify with the known code — expect tokens + user in response
    // (the TransformInterceptor wraps responses in `{ data, meta }`).
    const verifyRes = await http
      .post('/auth/phone/verify-otp')
      .send({ phone, code: knownCode })
      .expect(200);

    const body = verifyRes.body.data ?? verifyRes.body;
    expect(body.accessToken).toEqual(expect.any(String));
    expect(body.refreshToken).toEqual(expect.any(String));
    expect(body.user).toBeTruthy();
    expect(body.user.phone).toBe(phone);

    // 3. Fetch /users/me using that access token — should return the
    // same user.
    const meRes = await http
      .get('/users/me')
      .set('Authorization', `Bearer ${body.accessToken}`)
      .expect(200);
    const me = meRes.body.data ?? meRes.body;
    expect(me.id).toBe(body.user.id);
    expect(me.phone).toBe(phone);
  });
});
