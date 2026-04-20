import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { randomUUID } from 'crypto';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { Verification } from '../src/modules/verification/entities/verification.entity';
import { User } from '../src/modules/users/entities/user.entity';
import { Credential } from '../src/modules/credentials/entities/credential.entity';
import {
  CredentialType,
  OnboardingProgress,
  Role,
  UserStatus,
  VerificationType,
} from '../src/common/enums';
import { FRESH_TOKEN_MAX_AGE_SECONDS } from '../src/common/guards/fresh-token.guard';

/**
 * End-to-end coverage for `POST /auth/confirm-identity` — the SSO-only
 * re-prove flow. The test seeds a user + EMAIL credential directly via
 * the EM (no SSO round-trip needed — the endpoint only cares that an
 * EMAIL credential exists), issues an OTP via the live send path, then
 * deterministically overwrites the stored hash so the verify step is
 * reproducible without depending on the dev-echo env flag.
 */
describe('POST /auth/confirm-identity e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  function freshEmail(): string {
    return `confirm+${Date.now()}.${Math.floor(
      Math.random() * 1e6,
    )}@example.com`;
  }

  async function seedSsoUser(email: string): Promise<User> {
    const em = ctx.em.fork();
    const user = em.create(User, {
      name: `sso-${randomUUID().slice(0, 8)}`,
      email,
      role: Role.USER,
      status: UserStatus.ACTIVE,
      onboardingProgress: OnboardingProgress.COMPLETE,
    } as never);
    em.create(Credential, {
      user,
      type: CredentialType.EMAIL,
      identifier: email,
      verifiedAt: new Date(),
      isPrimary: true,
    } as never);
    await em.flush();
    return user;
  }

  async function seedOtpAndRewriteHash(
    email: string,
    knownCode: string,
  ): Promise<void> {
    const http = request(ctx.app.getHttpServer());
    await http.post('/auth/email/send-otp').send({ email }).expect(200);

    const knownHash = await bcrypt.hash(knownCode, 10);
    const em = ctx.em.fork();
    const row = await em.findOne(
      Verification,
      {
        identifier: email,
        type: VerificationType.EMAIL_VERIFY,
        verifiedAt: null,
      },
      { orderBy: { createdAt: 'DESC' } },
    );
    expect(row).toBeTruthy();
    row!.codeHash = knownHash;
    await em.flush();
  }

  it('returns an elevated token + expiresAt when the seeded OTP matches', async () => {
    const email = freshEmail();
    const user = await seedSsoUser(email);

    const code = '424242';
    await seedOtpAndRewriteHash(email, code);

    const http = request(ctx.app.getHttpServer());
    const res = await http
      .post('/auth/confirm-identity')
      .send({ email, otpCode: code })
      .expect(200);

    const body = res.body.data ?? res.body;
    expect(body.elevatedToken).toEqual(expect.any(String));
    expect(body.expiresAt).toEqual(expect.any(String));
    expect(Number.isNaN(Date.parse(body.expiresAt))).toBe(false);

    // Decoding (no verify — matches what FreshTokenGuard does): check
    // the claim shape matches a normal access token, iat is now, and
    // exp is 15 minutes out.
    const decoded = jwt.decode(body.elevatedToken) as {
      sub: string;
      role: string;
      iat: number;
      exp: number;
      jti: string;
    } | null;
    expect(decoded).toBeTruthy();
    expect(decoded!.sub).toBe(user.id);
    expect(decoded!.role).toBe(Role.USER);
    expect(decoded!.exp - decoded!.iat).toBe(FRESH_TOKEN_MAX_AGE_SECONDS);

    const nowSeconds = Math.floor(Date.now() / 1000);
    // Allow 5s slack for slow CI clocks.
    expect(Math.abs(decoded!.iat - nowSeconds)).toBeLessThanOrEqual(5);
  });

  it('401s on a tampered OTP', async () => {
    const email = freshEmail();
    await seedSsoUser(email);
    await seedOtpAndRewriteHash(email, '135791');

    const http = request(ctx.app.getHttpServer());
    const res = await http
      .post('/auth/confirm-identity')
      .send({ email, otpCode: '999999' })
      .expect(401);
    const payload = res.body.message ?? res.body;
    expect(payload.code ?? res.body.code).toBe('invalid_otp');
  });

  it('401s on an unknown email (no EMAIL credential exists)', async () => {
    const http = request(ctx.app.getHttpServer());
    const res = await http
      .post('/auth/confirm-identity')
      .send({ email: freshEmail(), otpCode: '424242' })
      .expect(401);
    const payload = res.body.message ?? res.body;
    expect(payload.code ?? res.body.code).toBe('invalid_otp');
  });
});
