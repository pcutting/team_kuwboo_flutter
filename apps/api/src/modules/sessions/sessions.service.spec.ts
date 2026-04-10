import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { SessionsService } from './sessions.service';
import { RealtimeRevocationService } from '../realtime/realtime-revocation.service';
import { Session } from './entities/session.entity';

/**
 * Unit tests for SessionsService.revokeAllForUser.
 *
 * Focus: the contract between the DB update and the realtime kill.
 * Specifically verifies:
 *   - rows are updated with isRevoked=true and the provided reason
 *   - realtime kill is invoked exactly once per call
 *   - realtime kill failures do not cause the DB return value to
 *     change (the promise is awaited from a catch handler, not in
 *     the main flow)
 *   - second call on the same user still fires the realtime kill
 *     (the DB returns 0 on the second call but that's idempotency,
 *     not "skip realtime")
 */
describe('SessionsService.revokeAllForUser', () => {
  let service: SessionsService;
  let em: jest.Mocked<Pick<EntityManager, 'nativeUpdate'>>;
  let realtime: jest.Mocked<Pick<RealtimeRevocationService, 'killUser'>>;

  beforeEach(async () => {
    em = {
      nativeUpdate: jest.fn(),
    } as jest.Mocked<Pick<EntityManager, 'nativeUpdate'>>;

    realtime = {
      killUser: jest.fn().mockResolvedValue(undefined),
    } as jest.Mocked<Pick<RealtimeRevocationService, 'killUser'>>;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SessionsService,
        { provide: EntityManager, useValue: em },
        { provide: RealtimeRevocationService, useValue: realtime },
      ],
    }).compile();

    service = module.get(SessionsService);
  });

  it('updates isRevoked and revokeReason on all active sessions', async () => {
    em.nativeUpdate.mockResolvedValue(3);

    const count = await service.revokeAllForUser(
      'user-123',
      'apple_consent_revoked',
    );

    expect(count).toBe(3);
    expect(em.nativeUpdate).toHaveBeenCalledTimes(1);
    expect(em.nativeUpdate).toHaveBeenCalledWith(
      Session,
      { user: { id: 'user-123' }, isRevoked: false },
      { isRevoked: true, revokeReason: 'apple_consent_revoked' },
    );
  });

  it('omits revokeReason from the update when reason is undefined (backward-compatible)', async () => {
    em.nativeUpdate.mockResolvedValue(2);

    await service.revokeAllForUser('user-123');

    expect(em.nativeUpdate).toHaveBeenCalledWith(
      Session,
      { user: { id: 'user-123' }, isRevoked: false },
      { isRevoked: true },
    );
  });

  it('fires a realtime kill exactly once per call', async () => {
    em.nativeUpdate.mockResolvedValue(1);

    await service.revokeAllForUser('user-123', 'manual');

    // realtime.killUser is called synchronously (fire-and-forget)
    // so it's visible immediately without awaiting
    expect(realtime.killUser).toHaveBeenCalledTimes(1);
    expect(realtime.killUser).toHaveBeenCalledWith('user-123', 'manual');
  });

  it('returns the DB row count even when the realtime kill rejects', async () => {
    em.nativeUpdate.mockResolvedValue(5);
    realtime.killUser.mockRejectedValueOnce(new Error('socket kaboom'));

    const count = await service.revokeAllForUser('user-123', 'admin_ban');

    // The DB is the source of truth — socket failures do not change
    // the return value. The error is caught by the .catch() handler
    // inside revokeAllForUser.
    expect(count).toBe(5);
    // Wait one microtask tick to let the rejected promise settle and
    // the .catch handler run, so any uncaught-promise lint would have
    // already fired by now.
    await new Promise((resolve) => setImmediate(resolve));
    expect(realtime.killUser).toHaveBeenCalledTimes(1);
  });

  it('is idempotent at the DB level but still fires realtime kill on repeat calls', async () => {
    em.nativeUpdate.mockResolvedValueOnce(4).mockResolvedValueOnce(0);

    const first = await service.revokeAllForUser('user-123', 'manual');
    const second = await service.revokeAllForUser('user-123', 'manual');

    expect(first).toBe(4);
    expect(second).toBe(0);
    // Realtime kill fires on BOTH calls — this is intentional. A
    // second call might correspond to a retry where the user
    // reconnected after the first kill; we always re-emit the
    // client:state event as a safety net.
    expect(realtime.killUser).toHaveBeenCalledTimes(2);
  });
});
