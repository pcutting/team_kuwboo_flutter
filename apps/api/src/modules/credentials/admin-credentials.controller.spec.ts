import 'reflect-metadata';
import { Test, TestingModule } from '@nestjs/testing';
import { ConflictException, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AdminCredentialsController } from './admin-credentials.controller';
import { CredentialsService } from './credentials.service';
import { TrustService } from '../trust/trust.service';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Role } from '../../common/enums';
import { ROLES_KEY } from '../../common/decorators/roles.decorator';

describe('AdminCredentialsController', () => {
  let controller: AdminCredentialsController;
  let credentialsService: {
    listForUser: jest.Mock;
    revoke: jest.Mock;
  };
  let trustService: { append: jest.Mock };

  beforeEach(async () => {
    credentialsService = {
      listForUser: jest.fn(),
      revoke: jest.fn(),
    };
    trustService = { append: jest.fn().mockResolvedValue(undefined) };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminCredentialsController],
      providers: [
        { provide: CredentialsService, useValue: credentialsService },
        { provide: TrustService, useValue: trustService },
      ],
    }).compile();

    controller = module.get(AdminCredentialsController);
  });

  describe('list', () => {
    it('returns credentials for the target user (admin can view another user)', async () => {
      const creds = [
        { id: 'c1', type: 'PHONE', identifier: '+15555551111' },
        { id: 'c2', type: 'EMAIL', identifier: 'u@example.com' },
      ];
      credentialsService.listForUser.mockResolvedValueOnce(creds);

      const res = await controller.list('target-user-id');

      expect(credentialsService.listForUser).toHaveBeenCalledWith('target-user-id');
      expect(res).toEqual({ credentials: creds });
    });
  });

  describe('revoke', () => {
    it('revokes a credential for the target user and appends a trust signal', async () => {
      credentialsService.revoke.mockResolvedValueOnce({ id: 'cred-1' });

      await controller.revoke('target-user', 'cred-1', 'admin-42');

      expect(credentialsService.revoke).toHaveBeenCalledWith('cred-1', 'target-user');
      expect(trustService.append).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: 'target-user',
          type: 'credential_revoked_by_admin',
          delta: 0,
          source: 'admin',
          metadata: expect.objectContaining({
            credentialId: 'cred-1',
            adminId: 'admin-42',
            reason: 'credential cred-1 revoked by admin admin-42',
          }),
        }),
      );
    });

    it('propagates ConflictException when revoking the last credential (invariant preserved)', async () => {
      credentialsService.revoke.mockRejectedValueOnce(
        new ConflictException({
          code: 'last_credential',
          message: 'Cannot revoke your last active credential.',
        }),
      );

      await expect(
        controller.revoke('target-user', 'cred-1', 'admin-42'),
      ).rejects.toBeInstanceOf(ConflictException);

      // Audit signal must NOT be written when the revoke itself failed.
      expect(trustService.append).not.toHaveBeenCalled();
    });

    it('service propagates ForbiddenException if the credential does not belong to the target user', async () => {
      credentialsService.revoke.mockRejectedValueOnce(
        new ForbiddenException('Not your credential'),
      );

      await expect(
        controller.revoke('target-user', 'cred-1', 'admin-42'),
      ).rejects.toBeInstanceOf(ForbiddenException);
    });
  });
});

describe('AdminCredentialsController (RolesGuard)', () => {
  const guard = new RolesGuard(new Reflector());

  const makeCtx = (role: Role | undefined): ExecutionContext => {
    const handler = () => undefined;
    Reflect.defineMetadata(
      ROLES_KEY,
      [Role.ADMIN, Role.SUPER_ADMIN],
      handler,
    );
    return {
      getHandler: () => handler,
      getClass: () => AdminCredentialsController,
      switchToHttp: () => ({
        getRequest: () => ({ user: role ? { role } : undefined }),
      }),
    } as unknown as ExecutionContext;
  };

  it('allows ADMIN', () => {
    expect(guard.canActivate(makeCtx(Role.ADMIN))).toBe(true);
  });

  it('allows SUPER_ADMIN', () => {
    expect(guard.canActivate(makeCtx(Role.SUPER_ADMIN))).toBe(true);
  });

  it('denies regular USER (non-admin gets 403)', () => {
    expect(guard.canActivate(makeCtx(Role.USER))).toBe(false);
  });

  it('denies MODERATOR (below ADMIN threshold)', () => {
    expect(guard.canActivate(makeCtx(Role.MODERATOR))).toBe(false);
  });
});
