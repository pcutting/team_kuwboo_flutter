import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { NotFoundException } from '@nestjs/common';
import { ContentInterestTagsService } from './content-interest-tags.service';
import { ContentInterestTag } from './entities/content-interest-tag.entity';
import { Content } from './entities/content.entity';
import { Interest } from '../interests/entities/interest.entity';

describe('ContentInterestTagsService', () => {
  let service: ContentInterestTagsService;
  let em: {
    findOne: jest.Mock;
    find: jest.Mock;
    create: jest.Mock;
    remove: jest.Mock;
    flush: jest.Mock;
    nativeDelete: jest.Mock;
    getReference: jest.Mock;
    createQueryBuilder: jest.Mock;
  };

  const qb = {
    select: jest.fn().mockReturnThis(),
    where: jest.fn().mockReturnThis(),
    orderBy: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    offset: jest.fn().mockReturnThis(),
    execute: jest.fn(),
  };

  beforeEach(async () => {
    em = {
      findOne: jest.fn(),
      find: jest.fn(),
      create: jest.fn((_cls, data) => data),
      remove: jest.fn(),
      flush: jest.fn().mockResolvedValue(undefined),
      nativeDelete: jest.fn().mockResolvedValue(0),
      getReference: jest.fn((_cls: unknown, id: string) => ({ id })),
      createQueryBuilder: jest.fn().mockReturnValue(qb),
    };
    qb.select.mockClear().mockReturnThis();
    qb.where.mockClear().mockReturnThis();
    qb.orderBy.mockClear().mockReturnThis();
    qb.limit.mockClear().mockReturnThis();
    qb.offset.mockClear().mockReturnThis();
    qb.execute.mockClear();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ContentInterestTagsService,
        { provide: EntityManager, useValue: em },
      ],
    }).compile();

    service = module.get(ContentInterestTagsService);
  });

  describe('tagContent', () => {
    it('no-ops when interestIds is empty', async () => {
      await service.tagContent('c1', []);
      expect(em.findOne).not.toHaveBeenCalled();
      expect(em.flush).not.toHaveBeenCalled();
    });

    it('throws NotFound when content does not exist', async () => {
      em.findOne.mockResolvedValueOnce(null);
      await expect(service.tagContent('c1', ['i1'])).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });

    it('throws NotFound when any interest is missing', async () => {
      em.findOne.mockResolvedValueOnce({ id: 'c1' } as Content);
      em.find.mockResolvedValueOnce([{ id: 'i1' } as Interest]); // only 1 of 2 found
      await expect(
        service.tagContent('c1', ['i1', 'i2']),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('is idempotent — does not re-create existing rows', async () => {
      em.findOne.mockResolvedValueOnce({ id: 'c1' } as Content);
      em.find
        .mockResolvedValueOnce([
          { id: 'i1' } as Interest,
          { id: 'i2' } as Interest,
        ]) // interests
        .mockResolvedValueOnce([
          { interest: { id: 'i1' } } as ContentInterestTag,
        ]); // existing tags — i1 already present

      await service.tagContent('c1', ['i1', 'i2'], 'u1');

      // Only i2 should be created.
      expect(em.create).toHaveBeenCalledTimes(1);
      const [, data] = em.create.mock.calls[0];
      expect(data.interest.id).toBe('i2');
      expect(em.flush).toHaveBeenCalled();
    });

    it('dedupes duplicate IDs in the input array', async () => {
      em.findOne.mockResolvedValueOnce({ id: 'c1' } as Content);
      em.find
        .mockResolvedValueOnce([{ id: 'i1' } as Interest])
        .mockResolvedValueOnce([]);

      await service.tagContent('c1', ['i1', 'i1', 'i1']);

      expect(em.create).toHaveBeenCalledTimes(1);
    });
  });

  describe('replaceTags', () => {
    it('removes rows not in the new set and inserts new ones', async () => {
      em.findOne.mockResolvedValueOnce({ id: 'c1' } as Content);
      em.find
        .mockResolvedValueOnce([
          { id: 'i2' } as Interest,
          { id: 'i3' } as Interest,
        ]) // validate desired
        .mockResolvedValueOnce([
          { interest: { id: 'i1' } } as ContentInterestTag,
          { interest: { id: 'i2' } } as ContentInterestTag,
        ]); // existing

      const result = await service.replaceTags('c1', ['i2', 'i3'], 'u1');

      expect(result).toEqual(['i2', 'i3']);
      // i1 removed (not in desired), i3 created (new), i2 kept.
      expect(em.remove).toHaveBeenCalledTimes(1);
      expect(em.create).toHaveBeenCalledTimes(1);
      const [, data] = em.create.mock.calls[0];
      expect(data.interest.id).toBe('i3');
    });

    it('clears all tags when given an empty array', async () => {
      em.findOne.mockResolvedValueOnce({ id: 'c1' } as Content);
      em.find.mockResolvedValueOnce([
        { interest: { id: 'i1' } } as ContentInterestTag,
        { interest: { id: 'i2' } } as ContentInterestTag,
      ]);

      await service.replaceTags('c1', []);

      expect(em.remove).toHaveBeenCalledTimes(2);
      expect(em.create).not.toHaveBeenCalled();
    });
  });

  describe('untagContent', () => {
    it('no-ops on empty array', async () => {
      await service.untagContent('c1', []);
      expect(em.nativeDelete).not.toHaveBeenCalled();
    });

    it('deletes matching rows', async () => {
      await service.untagContent('c1', ['i1', 'i2']);
      expect(em.nativeDelete).toHaveBeenCalledWith(ContentInterestTag, {
        content: { id: 'c1' },
        interest: { id: { $in: ['i1', 'i2'] } },
      });
    });
  });

  describe('getInterestIdsForContent', () => {
    it('returns the flat list of interest IDs', async () => {
      qb.execute.mockResolvedValueOnce([
        { interest_id: 'i1' },
        { interest_id: 'i2' },
      ]);
      const ids = await service.getInterestIdsForContent('c1');
      expect(ids).toEqual(['i1', 'i2']);
    });

    it('returns empty array for untagged content', async () => {
      qb.execute.mockResolvedValueOnce([]);
      const ids = await service.getInterestIdsForContent('c1');
      expect(ids).toEqual([]);
    });
  });

  describe('getContentIdsByInterest', () => {
    it('returns a paginated list of content IDs', async () => {
      qb.execute.mockResolvedValueOnce([
        { content_id: 'c1' },
        { content_id: 'c2' },
      ]);
      const ids = await service.getContentIdsByInterest('i1', { limit: 2 });
      expect(ids).toEqual(['c1', 'c2']);
      expect(qb.limit).toHaveBeenCalledWith(2);
    });
  });
});
