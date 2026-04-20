import { ConflictException, HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import { Queue } from 'bullmq';
import { AdminService } from './admin.service';
import { AdminAuditService } from './admin-audit.service';
import { SessionsService } from '../sessions/sessions.service';
import { ContentService } from '../content/content.service';
import { User } from '../users/entities/user.entity';
import { Content } from '../content/entities/content.entity';
import { ContentStatus } from '../../common/enums';
import { ACCOUNT_ANONYMIZE_DELAY_MS } from '../users/workers/account-anonymize.queue';

/**
 * Unit tests for `AdminService.restoreUser` — the grace-period rescue
 * path for `DELETE /users/me`. We stub every collaborator directly
 * because the branching is the point: job-pending/job-missing/job-throws,
 * out-of-grace, not-deleted, missing user, and the content-restore
 * +/- 5 minute window around the user's `deletedAt`.
 */
describe('AdminService.restoreUser', () => {
  function buildService(overrides: {
    user?: Partial<User> | null;
    content?: Content[];
    getJob?: jest.Mock;
    removeJob?: jest.Mock;
  } = {}) {
    const user =
      overrides.user === null
        ? null
        : ({
            id: 'user-1',
            deletedAt: new Date(Date.now() - 60 * 1000),
            ...overrides.user,
          } as User);

    const content = overrides.content ?? [];

    const em = {
      findOne: jest.fn().mockResolvedValue(user),
      find: jest.fn().mockResolvedValue(content),
      flush: jest.fn().mockResolvedValue(undefined),
    };

    const auditService = {
      log: jest.fn().mockResolvedValue(undefined),
    } as unknown as AdminAuditService;

    const getJob = overrides.getJob ?? jest.fn().mockResolvedValue(null);
    const removeJob = overrides.removeJob ?? jest.fn().mockResolvedValue(undefined);
    const anonymizeQueue = {
      getJob,
    } as unknown as Queue;

    const botQueue = {} as unknown as Queue;
    const sessionsService = {} as unknown as SessionsService;
    const contentService = {} as unknown as ContentService;

    const svc = new AdminService(
      botQueue,
      anonymizeQueue,
      em as never,
      auditService,
      sessionsService,
      contentService,
    );

    return { svc, em, auditService, getJob, removeJob, user, content };
  }

  it('throws NotFoundException when the user row is missing', async () => {
    const { svc } = buildService({ user: null });
    await expect(svc.restoreUser('admin-1', 'missing')).rejects.toThrow(
      NotFoundException,
    );
  });

  it('throws ConflictException when the user is not pending deletion', async () => {
    const { svc } = buildService({ user: { deletedAt: undefined } });
    await expect(svc.restoreUser('admin-1', 'user-1')).rejects.toThrow(
      ConflictException,
    );
  });

  it('returns 410 GONE when deletedAt is older than the grace window', async () => {
    const past = new Date(Date.now() - ACCOUNT_ANONYMIZE_DELAY_MS - 60 * 1000);
    const { svc } = buildService({ user: { deletedAt: past } });
    await expect(svc.restoreUser('admin-1', 'user-1')).rejects.toMatchObject({
      constructor: HttpException,
      status: HttpStatus.GONE,
    });
  });

  it('happy path — cancels the pending anonymize job, clears deletedAt, audits', async () => {
    const remove = jest.fn().mockResolvedValue(undefined);
    const getJob = jest.fn().mockResolvedValue({ remove });
    const { svc, em, auditService, user } = buildService({ getJob, removeJob: remove });

    const restored = await svc.restoreUser('admin-1', 'user-1');

    expect(getJob).toHaveBeenCalledWith('anon-user-1');
    expect(remove).toHaveBeenCalledTimes(1);
    expect(restored.deletedAt).toBeUndefined();
    expect(user?.deletedAt).toBeUndefined();
    expect(em.flush).toHaveBeenCalledTimes(1);
    expect(auditService.log).toHaveBeenCalledWith(
      'admin-1',
      'RESTORE_USER',
      'USER',
      'user-1',
      expect.objectContaining({ contentRestoredCount: 0 }),
    );
  });

  it('proceeds when the anonymize job has already fired (getJob returns null)', async () => {
    const getJob = jest.fn().mockResolvedValue(null);
    const { svc, em } = buildService({ getJob });

    await expect(svc.restoreUser('admin-1', 'user-1')).resolves.toBeDefined();
    expect(getJob).toHaveBeenCalledWith('anon-user-1');
    expect(em.flush).toHaveBeenCalledTimes(1);
  });

  it('proceeds when job.remove throws — still clears deletedAt and audits', async () => {
    const remove = jest.fn().mockRejectedValue(new Error('redis down'));
    const getJob = jest.fn().mockResolvedValue({ remove });
    const { svc, em, auditService } = buildService({ getJob });

    const restored = await svc.restoreUser('admin-1', 'user-1');

    expect(restored.deletedAt).toBeUndefined();
    expect(em.flush).toHaveBeenCalledTimes(1);
    expect(auditService.log).toHaveBeenCalledTimes(1);
  });

  it('restores content soft-deleted within +/- 5 minutes of the user deletedAt', async () => {
    const deletedAt = new Date(Date.now() - 60 * 1000);
    const withinWindow = {
      id: 'c-1',
      deletedAt: new Date(deletedAt.getTime() + 2 * 60 * 1000),
      status: ContentStatus.REMOVED,
    } as Content;
    const outsideWindow = {
      id: 'c-2',
      deletedAt: new Date(deletedAt.getTime() - 10 * 60 * 1000),
      status: ContentStatus.REMOVED,
    } as Content;

    // The service's `em.find` receives a where-clause that filters by
    // the 5-minute window; we simulate the DB by returning only the
    // row that should match.
    const { svc, em, auditService } = buildService({
      user: { deletedAt },
      content: [withinWindow],
    });

    const restored = await svc.restoreUser('admin-1', 'user-1');

    expect(restored).toBeDefined();
    expect(withinWindow.deletedAt).toBeUndefined();
    expect(withinWindow.status).toBe(ContentStatus.ACTIVE);
    // The fixture outside the window is untouched (we didn't return it).
    expect(outsideWindow.deletedAt).toBeInstanceOf(Date);
    expect(outsideWindow.status).toBe(ContentStatus.REMOVED);

    // And the em.find call used a creator filter + window bounds.
    expect(em.find).toHaveBeenCalledWith(
      Content,
      expect.objectContaining({
        creator: 'user-1',
        deletedAt: expect.objectContaining({ $gte: expect.any(Date), $lte: expect.any(Date) }),
      }),
      expect.objectContaining({ filters: { notDeleted: false } }),
    );
    expect(auditService.log).toHaveBeenCalledWith(
      'admin-1',
      'RESTORE_USER',
      'USER',
      'user-1',
      expect.objectContaining({ contentRestoredCount: 1 }),
    );
  });

  it('writes a RESTORE_USER audit log entry', async () => {
    const { svc, auditService } = buildService();
    await svc.restoreUser('admin-1', 'user-1');
    expect(auditService.log).toHaveBeenCalledWith(
      'admin-1',
      'RESTORE_USER',
      'USER',
      'user-1',
      expect.objectContaining({ restoredAt: expect.any(String) }),
    );
  });
});
