import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { CredentialsService } from './credentials.service';
import { Credential } from './entities/credential.entity';
import { CredentialType } from '../../common/enums';

describe('CredentialsService', () => {
  let service: CredentialsService;
  let em: {
    findOne: jest.Mock;
    find: jest.Mock;
    count: jest.Mock;
    create: jest.Mock;
    flush: jest.Mock;
  };

  beforeEach(async () => {
    em = {
      findOne: jest.fn(),
      find: jest.fn(),
      count: jest.fn(),
      create: jest.fn((_entity, data) => ({ ...data, id: 'new-id' })),
      flush: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CredentialsService,
        { provide: EntityManager, useValue: em },
      ],
    }).compile();

    service = module.get(CredentialsService);
  });

  describe('attach', () => {
    it('creates a credential when none exists', async () => {
      em.findOne
        .mockResolvedValueOnce(null) // existing (type, identifier)
        .mockResolvedValueOnce({ id: 'user-1' }) // user
        .mockResolvedValueOnce(null); // existing of type

      const credential = await service.attach({
        userId: 'user-1',
        type: CredentialType.EMAIL,
        identifier: 'x@y.com',
      });

      expect(em.create).toHaveBeenCalled();
      expect(em.flush).toHaveBeenCalled();
      expect(credential.isPrimary).toBe(true);
    });

    it('throws 409 credential_in_use when identifier belongs to another user', async () => {
      em.findOne.mockResolvedValueOnce({
        id: 'cred-1',
        user: { id: 'other-user' },
      });

      await expect(
        service.attach({
          userId: 'me',
          type: CredentialType.EMAIL,
          identifier: 'x@y.com',
        }),
      ).rejects.toBeInstanceOf(ConflictException);
    });

    it('returns existing credential when the same user re-attaches the same identity', async () => {
      const existing = { id: 'cred-1', user: { id: 'me' } };
      em.findOne.mockResolvedValueOnce(existing);

      const result = await service.attach({
        userId: 'me',
        type: CredentialType.EMAIL,
        identifier: 'x@y.com',
      });

      expect(result).toBe(existing);
      expect(em.create).not.toHaveBeenCalled();
    });
  });

  describe('revoke', () => {
    it('throws 409 last_credential when revoking would leave no active credentials', async () => {
      em.findOne.mockResolvedValueOnce({
        id: 'cred-1',
        user: { id: 'me' },
        revokedAt: null,
        isPrimary: true,
        type: CredentialType.PHONE,
      });
      em.count.mockResolvedValueOnce(1);

      await expect(service.revoke('cred-1', 'me')).rejects.toBeInstanceOf(
        ConflictException,
      );
    });

    it('soft-deletes when other active credentials remain', async () => {
      const cred = {
        id: 'cred-1',
        user: { id: 'me' },
        revokedAt: null as Date | null,
        isPrimary: false,
        type: CredentialType.PHONE,
      };
      em.findOne.mockResolvedValueOnce(cred);
      em.count.mockResolvedValueOnce(2);

      const revoked = await service.revoke('cred-1', 'me');

      expect(revoked.revokedAt).toBeInstanceOf(Date);
      expect(em.flush).toHaveBeenCalled();
    });

    it('promotes successor of same type when revoking a primary', async () => {
      const cred = {
        id: 'cred-1',
        user: { id: 'me' },
        revokedAt: null as Date | null,
        isPrimary: true,
        type: CredentialType.PHONE,
      };
      const successor = { id: 'cred-2', isPrimary: false };
      em.findOne
        .mockResolvedValueOnce(cred) // the credential
        .mockResolvedValueOnce(successor); // successor lookup
      em.count.mockResolvedValueOnce(2);

      await service.revoke('cred-1', 'me');

      expect(cred.isPrimary).toBe(false);
      expect(successor.isPrimary).toBe(true);
    });

    it('throws NotFoundException for unknown credential', async () => {
      em.findOne.mockResolvedValueOnce(null);
      await expect(service.revoke('nope', 'me')).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });
});
