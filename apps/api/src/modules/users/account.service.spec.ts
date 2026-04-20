import { UnauthorizedException, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { AccountService } from './account.service';
import { User } from './entities/user.entity';

/**
 * Unit tests for AccountService. We don't stand up a real EntityManager
 * here — the service delegates almost all SQL to `em.nativeDelete` /
 * `em.transactional`, and the interesting branching logic is in
 * `verifyDeletionCredential` and the ordering of audit-log writes.
 *
 * The goal is to prove:
 *   1. Password check is enforced for users with a passwordHash.
 *   2. SSO-only users (no passwordHash) fall through without a
 *      password.
 *   3. softDelete schedules the anonymize job with a 30-day delay and
 *      a deterministic jobId.
 *   4. hardPurge writes the audit log BEFORE the transaction that
 *      deletes the user row (so it survives even if the user row is
 *      gone).
 *   5. Both flows revoke sessions with the right reason code.
 */
describe('AccountService', () => {
  function makeMockEm(options: { user?: Partial<User>; missing?: boolean } = {}) {
    const defaultUser: Partial<User> = {
      id: 'user-1',
      passwordHash: undefined,
      username: 'alice',
      ...options.user,
    };
    const emInner = {
      findOneOrFail: jest.fn().mockResolvedValue(defaultUser),
      find: jest.fn().mockResolvedValue([]),
      // Return 1 so the hardPurge "user row gone" check passes.
      nativeDelete: jest.fn().mockResolvedValue(1),
      nativeUpdate: jest.fn().mockResolvedValue(0),
      flush: jest.fn().mockResolvedValue(undefined),
    };
    const em = {
      findOne: jest
        .fn()
        .mockResolvedValue(options.missing ? null : defaultUser),
      transactional: jest.fn(async (cb: (em: typeof emInner) => Promise<void>) => {
        await cb(emInner);
      }),
      nativeDelete: jest.fn().mockResolvedValue(1),
      nativeUpdate: jest.fn().mockResolvedValue(0),
      find: jest.fn().mockResolvedValue([]),
      flush: jest.fn().mockResolvedValue(undefined),
    };
    return { em, emInner, user: defaultUser };
  }

  function makeMocks() {
    const sessionsService: {
      revokeAllForUser: jest.Mock;
    } = {
      revokeAllForUser: jest.fn().mockResolvedValue(0),
    };
    const adminAuditService: {
      log: jest.Mock;
    } = {
      log: jest.fn().mockResolvedValue({ id: 'audit-1' }),
    };
    const anonymizeQueue: {
      add: jest.Mock;
    } = {
      add: jest.fn().mockResolvedValue({ id: 'job-1' }),
    };
    return { sessionsService, adminAuditService, anonymizeQueue };
  }

  describe('verifyDeletionCredential (via softDelete)', () => {
    it('rejects when user has a password and none is supplied', async () => {
      const passwordHash = await bcrypt.hash('correct-horse', 10);
      const { em } = makeMockEm({ user: { id: 'u', passwordHash } });
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await expect(svc.softDelete('u', undefined, {})).rejects.toThrow(
        UnauthorizedException,
      );
      expect(anonymizeQueue.add).not.toHaveBeenCalled();
      expect(sessionsService.revokeAllForUser).not.toHaveBeenCalled();
    });

    it('rejects when supplied password does not match', async () => {
      const passwordHash = await bcrypt.hash('correct-horse', 10);
      const { em } = makeMockEm({ user: { id: 'u', passwordHash } });
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await expect(
        svc.softDelete('u', undefined, { password: 'wrong' }),
      ).rejects.toThrow(UnauthorizedException);
      expect(adminAuditService.log).not.toHaveBeenCalled();
    });

    it('accepts correct password', async () => {
      const passwordHash = await bcrypt.hash('correct-horse', 10);
      const { em } = makeMockEm({ user: { id: 'u', passwordHash } });
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await expect(
        svc.softDelete('u', '1.2.3.4', { password: 'correct-horse' }),
      ).resolves.toBeUndefined();
      expect(adminAuditService.log).toHaveBeenCalledTimes(1);
    });

    it('lets SSO-only users through with no password', async () => {
      const { em } = makeMockEm({ user: { id: 'u', passwordHash: undefined } });
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await expect(svc.softDelete('u', undefined, {})).resolves.toBeUndefined();
      expect(adminAuditService.log).toHaveBeenCalledWith(
        'u',
        'USER_DELETE_SELF',
        'user',
        'u',
        expect.objectContaining({ credentialCheck: 'sso_only' }),
        undefined,
      );
    });
  });

  describe('softDelete', () => {
    it('throws NotFoundException when user is missing', async () => {
      const { em } = makeMockEm({ missing: true });
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await expect(svc.softDelete('missing', undefined, {})).rejects.toThrow(
        NotFoundException,
      );
    });

    it('revokes sessions with the self-delete reason', async () => {
      const { em } = makeMockEm();
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await svc.softDelete('user-1', undefined, {});
      expect(sessionsService.revokeAllForUser).toHaveBeenCalledWith(
        'user-1',
        'account_delete_self',
      );
    });

    it('schedules a 30-day anonymize job with a deterministic jobId', async () => {
      // The service looks up the user by id via em.findOne — the mock
      // returns our defaultUser regardless of the requested id. The
      // jobId is derived from `user.id` (the id on the managed
      // entity), which is `user-1` in the default mock.
      const { em } = makeMockEm();
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await svc.softDelete('user-1', undefined, {});
      expect(anonymizeQueue.add).toHaveBeenCalledWith(
        'anonymize',
        expect.objectContaining({ userId: 'user-1' }),
        expect.objectContaining({
          delay: 30 * 24 * 60 * 60 * 1000,
          jobId: 'anon-user-1',
        }),
      );
    });
  });

  describe('hardPurge', () => {
    it('writes the audit log BEFORE deleting the user row', async () => {
      const { em } = makeMockEm();
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );

      const callOrder: string[] = [];
      (adminAuditService.log as jest.Mock).mockImplementation(
        async () => {
          callOrder.push('audit');
          return { id: 'a' };
        },
      );
      (em.transactional as jest.Mock).mockImplementation(
        async (cb: (em: unknown) => Promise<void>) => {
          callOrder.push('transaction');
          await cb({
            find: jest.fn().mockResolvedValue([]),
            nativeDelete: jest.fn().mockResolvedValue(1),
            nativeUpdate: jest.fn().mockResolvedValue(0),
            flush: jest.fn(),
          });
        },
      );

      await svc.hardPurge('user-1', '1.2.3.4', {});
      expect(callOrder[0]).toBe('audit');
      expect(callOrder[1]).toBe('transaction');
    });

    it('revokes sessions with the self-purge reason', async () => {
      const { em } = makeMockEm();
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await svc.hardPurge('user-1', undefined, {});
      expect(sessionsService.revokeAllForUser).toHaveBeenCalledWith(
        'user-1',
        'account_purge_self',
      );
    });

    it('does not schedule a 30-day anonymize job', async () => {
      const { em } = makeMockEm();
      const { sessionsService, adminAuditService, anonymizeQueue } = makeMocks();
      const svc = new AccountService(
        em as never,
        sessionsService as never,
        adminAuditService as never,
        anonymizeQueue as never,
      );
      await svc.hardPurge('user-1', undefined, {});
      expect(anonymizeQueue.add).not.toHaveBeenCalled();
    });
  });
});
