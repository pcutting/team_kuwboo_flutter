import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { createTestUser, authHeader } from './helpers/test-users';
import { User } from '../src/modules/users/entities/user.entity';
import { Role } from '../src/common/enums';

/**
 * E2E coverage for `POST /admin/users/:id/restore` — the grace-period
 * rescue path for `DELETE /users/me`. Happy path, not-pending-deletion
 * (409), and unknown uuid (404).
 */
describe('Admin restore user e2e', () => {
  let ctx: TestAppContext;

  beforeAll(async () => {
    ctx = await bootstrapTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('restores a user that was soft-deleted inside the grace window', async () => {
    const password = 'CorrectHorse1!';
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await createTestUser(ctx.em);
    const em1 = ctx.em.fork();
    const managed = await em1.findOneOrFail(User, { id: user.id });
    managed.passwordHash = passwordHash;
    await em1.flush();

    const admin = await createTestUser(ctx.em, { role: Role.ADMIN });

    const http = request(ctx.app.getHttpServer());

    // Step 1 — self-soft-delete.
    await http
      .delete('/users/me')
      .set(authHeader(ctx.jwtService, user))
      .send({ password })
      .expect(204);

    const em2 = ctx.em.fork();
    const deleted = await em2.findOne(
      User,
      { id: user.id },
      { filters: { notDeleted: false } },
    );
    expect(deleted?.deletedAt).toBeInstanceOf(Date);

    // Step 2 — admin restores.
    const res = await http
      .post(`/admin/users/${user.id}/restore`)
      .set(authHeader(ctx.jwtService, admin))
      .send({})
      .expect(201);

    const body = res.body.data ?? res.body;
    expect(body.id).toBe(user.id);
    expect(body.deletedAt ?? null).toBeNull();

    const em3 = ctx.em.fork();
    const reloaded = await em3.findOne(
      User,
      { id: user.id },
      { filters: { notDeleted: false } },
    );
    expect(reloaded?.deletedAt ?? null).toBeNull();
  });

  it('returns 409 when the target user is not pending deletion', async () => {
    const user = await createTestUser(ctx.em);
    const admin = await createTestUser(ctx.em, { role: Role.ADMIN });
    const http = request(ctx.app.getHttpServer());

    await http
      .post(`/admin/users/${user.id}/restore`)
      .set(authHeader(ctx.jwtService, admin))
      .send({})
      .expect(409);
  });

  it('returns 404 for an unknown user uuid', async () => {
    const admin = await createTestUser(ctx.em, { role: Role.ADMIN });
    const http = request(ctx.app.getHttpServer());

    const unknown = randomUUID();
    await http
      .post(`/admin/users/${unknown}/restore`)
      .set(authHeader(ctx.jwtService, admin))
      .send({})
      .expect(404);
  });
});
