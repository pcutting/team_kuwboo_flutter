import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { createTestUser, authHeader } from './helpers/test-users';
import { Credential } from '../src/modules/credentials/entities/credential.entity';
import { Verification } from '../src/modules/verification/entities/verification.entity';
import { CredentialType, VerificationType } from '../src/common/enums';
import { User } from '../src/modules/users/entities/user.entity';

describe('Credentials e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('attaches email credential and blocks revoking the last credential', async () => {
    const phone = `+1415${Math.floor(2000000 + Math.random() * 7999999)}`;
    const user = await createTestUser(ctx.em, { phone });
    const auth = authHeader(ctx.jwtService, user);
    const http = request(ctx.app.getHttpServer());

    // Seed the user's primary phone credential (so the account has a
    // real active credential before we start attaching/revoking).
    const seedEm = ctx.em.fork();
    const phoneCred = seedEm.create(Credential, {
      user: seedEm.getReference(User, user.id),
      type: CredentialType.PHONE,
      identifier: phone,
      verifiedAt: new Date(),
      isPrimary: true,
    } as never);
    await seedEm.flush();

    // Attach a verified email credential. Controller requires a fresh
    // email OTP — issue one via send-otp then hijack its hash so we
    // know the code.
    const email = `e2e+${Date.now()}@example.com`;
    await http.post('/auth/email/send-otp').send({ email }).expect(200);

    const knownCode = '737373';
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

    const attachRes = await http
      .post('/credentials')
      .set(auth)
      .send({ type: CredentialType.EMAIL, identifier: email, otp: knownCode })
      .expect(201);
    const attachBody = attachRes.body.data ?? attachRes.body;
    expect(attachBody.credential).toBeTruthy();
    expect(attachBody.credential.type).toBe(CredentialType.EMAIL);

    // Revoke the email credential — leaves the primary phone as the
    // last active credential.
    await http
      .delete(`/credentials/${attachBody.credential.id}`)
      .set(auth)
      .expect(204);

    // Attempting to revoke the sole remaining credential must return
    // 409 with `last_credential`.
    const lastRevoke = await http
      .delete(`/credentials/${phoneCred.id}`)
      .set(auth)
      .expect(409);
    const errBody = lastRevoke.body;
    // ErrorResponse shape from HttpExceptionFilter may nest the code
    // under body.error or body.message — accept either.
    const flat = JSON.stringify(errBody);
    expect(flat).toMatch(/last_credential/);
  });
});
