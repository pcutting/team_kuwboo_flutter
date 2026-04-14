import { Test, TestingModule } from '@nestjs/testing';
import { getQueueToken } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import {
  InterestSignalsService,
  INTEREST_SIGNAL_QUEUE,
} from './interest-signals.service';

describe('InterestSignalsService', () => {
  let service: InterestSignalsService;
  let queue: jest.Mocked<Pick<Queue, 'add'>>;

  beforeEach(async () => {
    queue = { add: jest.fn().mockResolvedValue(undefined) } as never;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InterestSignalsService,
        { provide: getQueueToken(INTEREST_SIGNAL_QUEUE), useValue: queue },
      ],
    }).compile();

    service = module.get(InterestSignalsService);
  });

  it('no-ops when interestIds is empty', async () => {
    await service.enqueueBump({
      userId: 'u1',
      interestIds: [],
      source: 'video.watched',
    });
    expect(queue.add).not.toHaveBeenCalled();
  });

  it('enqueues job with retry + removeOnComplete defaults', async () => {
    await service.enqueueBump({
      userId: 'u1',
      interestIds: ['i1', 'i2'],
      source: 'content.liked',
      weight: 0.5,
    });

    expect(queue.add).toHaveBeenCalledTimes(1);
    const [name, payload, opts] = queue.add.mock.calls[0];
    expect(name).toBe('bump');
    expect(payload).toMatchObject({
      userId: 'u1',
      interestIds: ['i1', 'i2'],
      source: 'content.liked',
    });
    expect(opts).toMatchObject({
      attempts: 3,
      backoff: { type: 'exponential', delay: 2000 },
    });
  });
});
