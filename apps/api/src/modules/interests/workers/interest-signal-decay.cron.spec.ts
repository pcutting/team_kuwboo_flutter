import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import {
  InterestSignalDecayCron,
  DECAY_FACTOR,
  PRUNE_THRESHOLD,
} from './interest-signal-decay.cron';

describe('InterestSignalDecayCron', () => {
  let cron: InterestSignalDecayCron;
  let execute: jest.Mock;

  beforeEach(async () => {
    execute = jest
      .fn()
      .mockResolvedValueOnce({ affectedRows: 10 })
      .mockResolvedValueOnce({ affectedRows: 2 });

    const forked = {
      getConnection: () => ({ execute }),
    };
    const em = {
      transactional: (fn: (f: typeof forked) => Promise<unknown>) => fn(forked),
    } as unknown as EntityManager;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InterestSignalDecayCron,
        { provide: EntityManager, useValue: em },
      ],
    }).compile();

    cron = module.get(InterestSignalDecayCron);
  });

  it('multiplies all weights by DECAY_FACTOR and prunes rows below PRUNE_THRESHOLD', async () => {
    const result = await cron.decayOnce();

    expect(execute).toHaveBeenCalledTimes(2);

    // MikroORM's Knex connection uses `?` positional bindings, not `$n` —
    // see the comment in interest-signal-decay.cron.ts::decayOnce.
    const [decaySql, decayParams] = execute.mock.calls[0];
    expect(decaySql).toMatch(/update "interest_signals"/);
    expect(decaySql).toMatch(/set "weight" = "weight" \* \?/);
    expect(decayParams).toEqual([DECAY_FACTOR]);

    const [pruneSql, pruneParams] = execute.mock.calls[1];
    expect(pruneSql).toMatch(/delete from "interest_signals"/);
    expect(pruneSql).toMatch(/"weight" < \?/);
    expect(pruneParams).toEqual([PRUNE_THRESHOLD]);

    expect(result).toEqual({ decayed: 10, pruned: 2 });
  });

  it('applies the expected half-life math: w * 0.9 is the per-run formula', () => {
    // Sanity: after one pass a weight of 1.0 becomes 0.9.
    const w = 1.0;
    expect(w * DECAY_FACTOR).toBeCloseTo(0.9);
    // After ~7 weekly runs, a weight of 1.0 decays below 0.5 (half-life).
    let w2 = 1.0;
    for (let i = 0; i < 7; i++) w2 *= DECAY_FACTOR;
    expect(w2).toBeLessThan(0.5);
    expect(w2).toBeGreaterThan(0.4);
  });
});
