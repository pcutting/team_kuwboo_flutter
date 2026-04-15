import * as request from 'supertest';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { createTestUser, authHeader } from './helpers/test-users';
import { Role } from '../src/common/enums';

describe('Interests e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('admin creates an interest, user selects it, and /users/me/interests returns it', async () => {
    const admin = await createTestUser(ctx.em, { role: Role.ADMIN });
    const user = await createTestUser(ctx.em);

    const adminAuth = authHeader(ctx.jwtService, admin);
    const userAuth = authHeader(ctx.jwtService, user);
    const http = request(ctx.app.getHttpServer());

    // Create a brand-new interest (using a unique slug so we don't
    // collide with the 30 rows seeded by Migration20260414_seed_interests).
    const slug = `e2e-${Date.now()}`;
    const createRes = await http
      .post('/admin/interests')
      .set(adminAuth)
      .send({ slug, label: 'E2E Test Interest', category: 'testing' })
      .expect(201);

    const created = createRes.body.data ?? createRes.body;
    const interestId: string = created.id;
    expect(interestId).toEqual(expect.any(String));

    // User selects exactly this interest.
    await http
      .post('/users/me/interests')
      .set(userAuth)
      .send({ interest_ids: [interestId] })
      .expect(201);

    // List — expect exactly the selected interest back.
    const listRes = await http
      .get('/users/me/interests')
      .set(userAuth)
      .expect(200);
    const body = listRes.body.data ?? listRes.body;
    expect(body.interests).toHaveLength(1);
    expect(body.interests[0].interest.id).toBe(interestId);
    expect(body.interests[0].interest.slug).toBe(slug);
  });
});
