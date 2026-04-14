import { Test, TestingModule } from '@nestjs/testing';
import { EntityManager } from '@mikro-orm/postgresql';
import { InteractionsService } from './interactions.service';
import { InterestSignalsService } from '../interests/interest-signals.service';
import { InteractionStateType, ContentType } from '../../common/enums';
import { Content } from '../content/entities/content.entity';
import { InteractionState } from './entities/interaction-state.entity';

describe('InteractionsService — interest signal emission', () => {
  let service: InteractionsService;
  let em: {
    findOne: jest.Mock;
    findOneOrFail: jest.Mock;
    nativeUpdate: jest.Mock;
    create: jest.Mock;
    remove: jest.Mock;
    persist: jest.Mock;
    flush: jest.Mock;
    getReference: jest.Mock;
  };
  let interestSignals: { enqueueBump: jest.Mock };
  let emitSpy: jest.SpyInstance;

  beforeEach(async () => {
    em = {
      findOne: jest.fn(),
      findOneOrFail: jest.fn(),
      nativeUpdate: jest.fn().mockResolvedValue(1),
      create: jest.fn(),
      remove: jest.fn(),
      persist: jest.fn(),
      flush: jest.fn().mockResolvedValue(undefined),
      getReference: jest.fn((_cls: unknown, id: string) => ({ id })),
    };

    interestSignals = { enqueueBump: jest.fn().mockResolvedValue(undefined) };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InteractionsService,
        { provide: EntityManager, useValue: em },
        { provide: InterestSignalsService, useValue: interestSignals },
      ],
    }).compile();

    service = module.get(InteractionsService);
    emitSpy = jest.spyOn(
      service as unknown as { emitInterestSignal: (...a: unknown[]) => Promise<void> },
      'emitInterestSignal',
    );
  });

  it('emits content.liked when a user newly likes content', async () => {
    // No existing LIKE state -> transition to liked.
    em.findOne.mockResolvedValueOnce(null); // toggleState lookup
    em.findOneOrFail.mockResolvedValueOnce({ id: 'c1' } as Content); // toggleState content

    const result = await service.toggleLike('u1', 'c1');

    expect(result).toEqual({ liked: true });
    expect(emitSpy).toHaveBeenCalledWith('u1', 'c1', 'content.liked');
  });

  it('does not emit content.liked when a user unlikes content', async () => {
    // Existing LIKE state -> removed.
    em.findOne.mockResolvedValueOnce({
      id: 's1',
      type: InteractionStateType.LIKE,
    } as InteractionState);

    const result = await service.toggleLike('u1', 'c1');

    expect(result).toEqual({ liked: false });
    expect(emitSpy).not.toHaveBeenCalled();
  });

  it('emits video.watched when the viewed content is a VIDEO', async () => {
    em.findOneOrFail.mockResolvedValueOnce({ id: 'c1' } as Content); // logEvent
    em.findOne.mockResolvedValueOnce({
      id: 'c1',
      type: ContentType.VIDEO,
    } as Content); // type check

    await service.logView('u1', 'c1');

    expect(emitSpy).toHaveBeenCalledWith('u1', 'c1', 'video.watched');
  });

  it('does not emit video.watched for non-video content', async () => {
    em.findOneOrFail.mockResolvedValueOnce({ id: 'c1' } as Content);
    em.findOne.mockResolvedValueOnce({
      id: 'c1',
      type: ContentType.POST,
    } as Content);

    await service.logView('u1', 'c1');

    expect(emitSpy).not.toHaveBeenCalled();
  });
});
