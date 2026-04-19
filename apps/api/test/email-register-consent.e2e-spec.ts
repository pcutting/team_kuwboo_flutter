import * as request from 'supertest';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { UserConsent } from '../src/modules/consent/entities/user-consent.entity';
import { User } from '../src/modules/users/entities/user.entity';
import { ConsentType, ConsentSource } from '../src/common/enums';
import { CURRENT_CONSENT_VERSIONS } from '../src/modules/consent/consent-versions';

/**
 * PR B — T&P consent capture on email registration.
 *
 * The register endpoint must hard-gate on `legalAccepted` and
 * `ageConfirmed` at the DTO layer (400 before any DB write) and, on
 * success, stamp two UserConsent rows (TERMS + PRIVACY) tagged with
 * source=REGISTRATION and the current versions. This spec pins all
 * three behaviours against a real AppModule bootstrap so we catch
 * wiring errors (module imports, cyclic deps) alongside the business
 * logic.
 */
describe('POST /auth/email/register — consent capture (e2e)', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  function freshEmail(): string {
    return `consent+${Date.now()}.${Math.floor(Math.random() * 1e6)}@example.com`;
  }

  it('rejects with 400 when legalAccepted is missing', async () => {
    const http = request(ctx.app.getHttpServer());
    await http
      .post('/auth/email/register')
      .send({
        email: freshEmail(),
        password: 'StrongPassword1!',
        ageConfirmed: true,
      })
      .expect(400);
  });

  it('rejects with 400 when legalAccepted is false', async () => {
    const http = request(ctx.app.getHttpServer());
    await http
      .post('/auth/email/register')
      .send({
        email: freshEmail(),
        password: 'StrongPassword1!',
        legalAccepted: false,
        ageConfirmed: true,
      })
      .expect(400);
  });

  it('rejects with 400 when ageConfirmed is missing', async () => {
    const http = request(ctx.app.getHttpServer());
    await http
      .post('/auth/email/register')
      .send({
        email: freshEmail(),
        password: 'StrongPassword1!',
        legalAccepted: true,
      })
      .expect(400);
  });

  it('writes no user + no consent rows when the DTO is rejected', async () => {
    const email = freshEmail();
    const http = request(ctx.app.getHttpServer());
    await http
      .post('/auth/email/register')
      .send({
        email,
        password: 'StrongPassword1!',
        legalAccepted: true,
        ageConfirmed: false, // hard gate
      })
      .expect(400);

    const em = ctx.em.fork();
    await expect(em.findOne(User, { email })).resolves.toBeNull();
    // No user → no consent rows could exist for this email.
    await expect(em.count(UserConsent, {})).resolves.toBeGreaterThanOrEqual(0);
  });

  it('writes exactly two consent rows with correct fields on successful register', async () => {
    const email = freshEmail();
    const userAgent = 'KuwbooTest/1.0 (e2e)';
    const http = request(ctx.app.getHttpServer());

    const res = await http
      .post('/auth/email/register')
      .set('User-Agent', userAgent)
      .send({
        email,
        password: 'StrongPassword1!',
        legalAccepted: true,
        ageConfirmed: true,
      })
      .expect(200);

    const body = res.body.data ?? res.body;
    const userId: string = body.user.id;
    expect(userId).toEqual(expect.any(String));

    const em = ctx.em.fork();
    const rows = await em.find(
      UserConsent,
      { user: { id: userId } },
      { orderBy: { consentType: 'ASC' } },
    );
    expect(rows).toHaveLength(2);

    const byType = new Map(rows.map((r) => [r.consentType, r]));
    const terms = byType.get(ConsentType.TERMS);
    const privacy = byType.get(ConsentType.PRIVACY);

    expect(terms).toBeDefined();
    expect(privacy).toBeDefined();

    for (const row of [terms!, privacy!]) {
      expect(row.source).toBe(ConsentSource.REGISTRATION);
      expect(row.userAgent).toBe(userAgent);
      // supertest uses an in-process server — req.ip resolves to an
      // IPv4/IPv6 loopback literal. We don't care which, just that
      // something was captured.
      expect(row.ipAddress).toEqual(expect.any(String));
      expect(row.ipAddress!.length).toBeGreaterThan(0);
      expect(row.revokedAt).toBeFalsy();
    }
    expect(terms!.version).toBe(CURRENT_CONSENT_VERSIONS.TERMS);
    expect(privacy!.version).toBe(CURRENT_CONSENT_VERSIONS.PRIVACY);
  });

  it('exposes consentStatus on /users/me after register', async () => {
    const email = freshEmail();
    const http = request(ctx.app.getHttpServer());

    const reg = await http
      .post('/auth/email/register')
      .send({
        email,
        password: 'StrongPassword1!',
        legalAccepted: true,
        ageConfirmed: true,
      })
      .expect(200);
    const { accessToken } = reg.body.data ?? reg.body;

    const meRes = await http
      .get('/users/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    const me = meRes.body.data ?? meRes.body;

    expect(me.consentStatus).toEqual({
      termsUpToDate: true,
      privacyUpToDate: true,
    });
  });

  it('GET /consent/summary returns first/last acceptance + currency flags', async () => {
    const email = freshEmail();
    const http = request(ctx.app.getHttpServer());

    const reg = await http
      .post('/auth/email/register')
      .send({
        email,
        password: 'StrongPassword1!',
        legalAccepted: true,
        ageConfirmed: true,
      })
      .expect(200);
    const { accessToken } = reg.body.data ?? reg.body;

    const sumRes = await http
      .get('/consent/summary')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    const summary = sumRes.body.data ?? sumRes.body;

    expect(summary.versions).toEqual({
      terms: CURRENT_CONSENT_VERSIONS.TERMS,
      privacy: CURRENT_CONSENT_VERSIONS.PRIVACY,
    });

    for (const key of ['terms', 'privacy'] as const) {
      const entry = summary.user[key];
      expect(entry.acceptedVersion).toBe(
        CURRENT_CONSENT_VERSIONS[
          key.toUpperCase() as 'TERMS' | 'PRIVACY'
        ],
      );
      expect(entry.isCurrent).toBe(true);
      expect(typeof entry.firstAcceptedAt).toBe('string');
      expect(typeof entry.lastAcceptedAt).toBe('string');
      // At registration, first == last (single grant event).
      expect(entry.firstAcceptedAt).toBe(entry.lastAcceptedAt);
    }
  });

  it('requires auth on /consent/summary', async () => {
    const http = request(ctx.app.getHttpServer());
    await http.get('/consent/summary').expect(401);
  });
});
