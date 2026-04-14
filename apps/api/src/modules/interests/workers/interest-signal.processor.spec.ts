import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { Job } from 'bullmq';
import {
  InterestSignalProcessor,
  SOURCE_WEIGHTS,
  DEFAULT_WEIGHT,
} from './interest-signal.processor';
import { InterestSignalBumpJob } from '../interest-signals.service';

describe('InterestSignalProcessor', () => {
  let processor: InterestSignalProcessor;
  let execute: jest.Mock;

  beforeEach(async () => {
    execute = jest.fn().mockResolvedValue({ affectedRows: 1 });
    const em = {
      getConnection: () => ({ execute }),
    } as unknown as EntityManager;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InterestSignalProcessor,
        { provide: EntityManager, useValue: em },
      ],
    }).compile();

    processor = module.get(InterestSignalProcessor);
  });

  describe('resolveWeight', () => {
    it('returns explicit weight when provided', () => {
      expect(processor.resolveWeight('video.watched', 7.5)).toBe(7.5);
    });

    it('returns per-source default when weight is absent', () => {
      expect(processor.resolveWeight('video.watched')).toBe(
        SOURCE_WEIGHTS['video.watched'],
      );
      expect(processor.resolveWeight('content.liked')).toBe(
        SOURCE_WEIGHTS['content.liked'],
      );
      expect(processor.resolveWeight('post.read')).toBe(
        SOURCE_WEIGHTS['post.read'],
      );
      expect(processor.resolveWeight('search.executed')).toBe(
        SOURCE_WEIGHTS['search.executed'],
      );
    });

    it('falls back to DEFAULT_WEIGHT for unknown sources', () => {
      expect(processor.resolveWeight('something.new')).toBe(DEFAULT_WEIGHT);
    });
  });

  describe('process', () => {
    const makeJob = (data: InterestSignalBumpJob, name = 'bump'): Job<InterestSignalBumpJob> =>
      ({ name, data }) as Job<InterestSignalBumpJob>;

    it('no-ops on empty interestIds', async () => {
      await processor.process(
        makeJob({ userId: 'u1', interestIds: [], source: 'video.watched' }),
      );
      expect(execute).not.toHaveBeenCalled();
    });

    it('no-ops for unknown job names', async () => {
      await processor.process(
        makeJob(
          { userId: 'u1', interestIds: ['i1'], source: 'video.watched' },
          'ping',
        ),
      );
      expect(execute).not.toHaveBeenCalled();
    });

    it('invokes upsert SQL with the computed delta', async () => {
      await processor.process(
        makeJob({
          userId: 'u1',
          interestIds: ['i1', 'i2'],
          source: 'content.liked',
        }),
      );

      expect(execute).toHaveBeenCalledTimes(1);
      const [sql, params] = execute.mock.calls[0];
      expect(sql).toMatch(/insert into "interest_signals"/);
      expect(sql).toMatch(/on conflict \("user_id", "interest_id"\) do update/);
      expect(sql).toMatch(
        /weight = "interest_signals"\."weight" \+ excluded\.weight/,
      );
      // params: [userId, ...interestIds, delta]
      expect(params[0]).toBe('u1');
      expect(params[1]).toBe('i1');
      expect(params[2]).toBe('i2');
      expect(params[3]).toBe(SOURCE_WEIGHTS['content.liked']);
    });

    it('honours an explicit weight override', async () => {
      await processor.process(
        makeJob({
          userId: 'u1',
          interestIds: ['i1'],
          source: 'video.watched',
          weight: 42,
        }),
      );

      const [, params] = execute.mock.calls[0];
      expect(params[params.length - 1]).toBe(42);
    });
  });
});
