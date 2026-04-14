import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InterestsService } from './interests.service';
import { Interest } from './entities/interest.entity';
import { UserInterest } from './entities/user-interest.entity';

/**
 * Unit tests for InterestsService.
 *
 * The EntityManager is mocked — these tests verify the service's contract
 * (argument shaping, error conditions, replace-semantics) not the ORM's
 * behaviour. Full round-trip would require an integration test harness
 * that this project does not yet have.
 */
describe('InterestsService', () => {
  let service: InterestsService;
  let em: jest.Mocked<
    Pick<
      EntityManager,
      | 'find'
      | 'findOne'
      | 'nativeDelete'
      | 'create'
      | 'persist'
      | 'flush'
      | 'getReference'
    >
  >;

  beforeEach(async () => {
    em = {
      find: jest.fn(),
      findOne: jest.fn(),
      nativeDelete: jest.fn(),
      create: jest.fn((_entity, data) => data),
      persist: jest.fn(),
      flush: jest.fn().mockResolvedValue(undefined),
      getReference: jest.fn((_entity, id) => ({ id })),
    } as unknown as typeof em;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InterestsService,
        { provide: EntityManager, useValue: em },
      ],
    }).compile();

    service = module.get(InterestsService);
  });

  describe('listActive', () => {
    it('filters to active interests and orders by display_order, label', async () => {
      em.find.mockResolvedValue([] as never);
      await service.listActive();
      expect(em.find).toHaveBeenCalledWith(
        Interest,
        { isActive: true },
        { orderBy: { displayOrder: 'ASC', label: 'ASC' } },
      );
    });
  });

  describe('listMine', () => {
    it('scopes query to user and populates interest relation', async () => {
      em.find.mockResolvedValue([] as never);
      await service.listMine('user-1');
      expect(em.find).toHaveBeenCalledWith(
        UserInterest,
        { user: { id: 'user-1' } },
        { populate: ['interest'], orderBy: { selectedAt: 'ASC' } },
      );
    });
  });

  describe('selectMany', () => {
    it('empty set deletes all user links and returns []', async () => {
      em.nativeDelete.mockResolvedValue(2);
      const result = await service.selectMany('user-1', []);
      expect(em.nativeDelete).toHaveBeenCalledWith(UserInterest, {
        user: { id: 'user-1' },
      });
      expect(result).toEqual([]);
    });

    it('throws BadRequest when any id is unknown or inactive', async () => {
      em.find.mockResolvedValueOnce([{ id: 'i1' }] as never); // returns 1, asked for 2
      await expect(
        service.selectMany('user-1', ['i1', 'i2']),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('replaces existing set atomically (delete then insert)', async () => {
      const interests = [
        { id: 'i1', isActive: true },
        { id: 'i2', isActive: true },
      ];
      em.find
        .mockResolvedValueOnce(interests as never) // Interest query
        .mockResolvedValueOnce([] as never); // final listMine
      em.nativeDelete.mockResolvedValue(5);

      await service.selectMany('user-1', ['i1', 'i2']);

      expect(em.nativeDelete).toHaveBeenCalledWith(UserInterest, {
        user: { id: 'user-1' },
      });
      expect(em.persist).toHaveBeenCalledTimes(2);
      expect(em.flush).toHaveBeenCalledTimes(1);
    });

    it('deduplicates repeated ids before fetch', async () => {
      em.find
        .mockResolvedValueOnce([{ id: 'i1', isActive: true }] as never)
        .mockResolvedValueOnce([] as never);
      em.nativeDelete.mockResolvedValue(0);

      await service.selectMany('user-1', ['i1', 'i1', 'i1']);

      expect(em.find).toHaveBeenNthCalledWith(1, Interest, {
        id: { $in: ['i1'] },
        isActive: true,
      });
    });
  });

  describe('deselect', () => {
    it('deletes matching row', async () => {
      em.nativeDelete.mockResolvedValue(1);
      await service.deselect('user-1', 'int-1');
      expect(em.nativeDelete).toHaveBeenCalledWith(UserInterest, {
        user: { id: 'user-1' },
        interest: { id: 'int-1' },
      });
    });

    it('throws NotFound when nothing was removed', async () => {
      em.nativeDelete.mockResolvedValue(0);
      await expect(service.deselect('u', 'i')).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });

  describe('adminCreate', () => {
    it('rejects duplicate slug with Conflict', async () => {
      em.findOne.mockResolvedValue({ id: 'existing' } as never);
      await expect(
        service.adminCreate({ slug: 'music-live', label: 'Live' }),
      ).rejects.toBeInstanceOf(ConflictException);
    });

    it('creates interest with display_order default 0', async () => {
      em.findOne.mockResolvedValue(null);
      await service.adminCreate({ slug: 's', label: 'L' });
      expect(em.create).toHaveBeenCalledWith(
        Interest,
        expect.objectContaining({ slug: 's', label: 'L', displayOrder: 0 }),
      );
      expect(em.flush).toHaveBeenCalled();
    });
  });

  describe('adminUpdate', () => {
    it('throws NotFound for missing id', async () => {
      em.findOne.mockResolvedValue(null);
      await expect(service.adminUpdate('x', { label: 'y' })).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });

    it('applies only provided fields', async () => {
      const entity = {
        id: 'i1',
        label: 'Old',
        category: 'cat',
        displayOrder: 5,
        isActive: true,
        updatedAt: new Date(0),
      };
      em.findOne.mockResolvedValue(entity as never);
      await service.adminUpdate('i1', { label: 'New' });
      expect(entity.label).toBe('New');
      expect(entity.category).toBe('cat'); // untouched
      expect(entity.displayOrder).toBe(5);
      expect(em.flush).toHaveBeenCalled();
    });
  });

  describe('adminSoftDelete', () => {
    it('sets is_active=false, never hard-deletes', async () => {
      const entity = { id: 'i1', isActive: true, updatedAt: new Date(0) };
      em.findOne.mockResolvedValue(entity as never);
      await service.adminSoftDelete('i1');
      expect(entity.isActive).toBe(false);
      expect(em.nativeDelete).not.toHaveBeenCalled();
      expect(em.flush).toHaveBeenCalled();
    });
  });

  describe('adminReorder', () => {
    it('assigns displayOrder from array index', async () => {
      const entities = [
        { id: 'a', displayOrder: 99, updatedAt: new Date(0) },
        { id: 'b', displayOrder: 99, updatedAt: new Date(0) },
        { id: 'c', displayOrder: 99, updatedAt: new Date(0) },
      ];
      em.find
        .mockResolvedValueOnce(entities as never) // lookup
        .mockResolvedValueOnce(entities as never); // final adminList
      await service.adminReorder(['c', 'a', 'b']);
      expect(entities.find((e) => e.id === 'c')!.displayOrder).toBe(0);
      expect(entities.find((e) => e.id === 'a')!.displayOrder).toBe(1);
      expect(entities.find((e) => e.id === 'b')!.displayOrder).toBe(2);
    });

    it('rejects when any id is missing', async () => {
      em.find.mockResolvedValueOnce([{ id: 'a' }] as never);
      await expect(service.adminReorder(['a', 'b'])).rejects.toBeInstanceOf(
        BadRequestException,
      );
    });
  });
});
