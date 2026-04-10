import { Test, TestingModule } from '@nestjs/testing';
import { RealtimeRevocationService } from './realtime-revocation.service';
import { NotificationGateway } from '../notifications/notification.gateway';
import { ChatGateway } from '../messaging/chat.gateway';
import { FeedGateway } from '../feed/feed.gateway';
import { PresenceGateway } from '../presence/presence.gateway';

/**
 * Unit tests for RealtimeRevocationService.
 *
 * Focus: parallel fan-out contract across the four gateways.
 * Verifies:
 *   - all four gateways' killUser methods are called with the same
 *     userId and a payload containing state='killed' and the reason
 *   - the fan-out runs via Promise.all (parallel, not sequential)
 *   - a slow gateway does not block the others from being called
 *   - a rejecting gateway causes the Promise.all to reject (caller's
 *     responsibility to catch — SessionsService does this)
 */
describe('RealtimeRevocationService', () => {
  let service: RealtimeRevocationService;
  let notifications: jest.Mocked<Pick<NotificationGateway, 'killUser'>>;
  let chat: jest.Mocked<Pick<ChatGateway, 'killUser'>>;
  let feed: jest.Mocked<Pick<FeedGateway, 'killUser'>>;
  let presence: jest.Mocked<Pick<PresenceGateway, 'killUser'>>;

  beforeEach(async () => {
    notifications = { killUser: jest.fn().mockResolvedValue(undefined) };
    chat = { killUser: jest.fn().mockResolvedValue(undefined) };
    feed = { killUser: jest.fn().mockResolvedValue(undefined) };
    presence = { killUser: jest.fn().mockResolvedValue(undefined) };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RealtimeRevocationService,
        { provide: NotificationGateway, useValue: notifications },
        { provide: ChatGateway, useValue: chat },
        { provide: FeedGateway, useValue: feed },
        { provide: PresenceGateway, useValue: presence },
      ],
    }).compile();

    service = module.get(RealtimeRevocationService);
  });

  it('calls killUser on all four gateways with the same payload', async () => {
    await service.killUser('user-123', 'apple_consent_revoked');

    const expectedPayload = {
      state: 'killed',
      reason: 'apple_consent_revoked',
    };

    expect(notifications.killUser).toHaveBeenCalledWith(
      'user-123',
      expectedPayload,
    );
    expect(chat.killUser).toHaveBeenCalledWith('user-123', expectedPayload);
    expect(feed.killUser).toHaveBeenCalledWith('user-123', expectedPayload);
    expect(presence.killUser).toHaveBeenCalledWith('user-123', expectedPayload);
  });

  it('includes undefined reason in the payload when none is provided', async () => {
    await service.killUser('user-123');

    const expectedPayload = { state: 'killed', reason: undefined };
    expect(notifications.killUser).toHaveBeenCalledWith(
      'user-123',
      expectedPayload,
    );
  });

  it('fans out in parallel (Promise.all), not sequentially', async () => {
    // Make each gateway block until we manually resolve it. If the
    // service called them sequentially, gateway N+1 would not be
    // invoked until gateway N resolves. With Promise.all, all four
    // should be invoked effectively simultaneously.
    const resolvers: Array<() => void> = [];
    const makeBlocking = () =>
      jest.fn().mockImplementation(
        () =>
          new Promise<void>((resolve) => {
            resolvers.push(resolve);
          }),
      );

    notifications.killUser = makeBlocking();
    chat.killUser = makeBlocking();
    feed.killUser = makeBlocking();
    presence.killUser = makeBlocking();

    const killPromise = service.killUser('user-123', 'manual');

    // Let the event loop run one tick — all four gateway calls should
    // have fired by now even though none have resolved yet.
    await new Promise((resolve) => setImmediate(resolve));

    expect(notifications.killUser).toHaveBeenCalledTimes(1);
    expect(chat.killUser).toHaveBeenCalledTimes(1);
    expect(feed.killUser).toHaveBeenCalledTimes(1);
    expect(presence.killUser).toHaveBeenCalledTimes(1);
    expect(resolvers).toHaveLength(4);

    // Now resolve all four and let killUser return
    resolvers.forEach((resolve) => resolve());
    await killPromise;
  });

  it('rejects when any gateway rejects (caller catches at the boundary)', async () => {
    chat.killUser.mockRejectedValueOnce(new Error('chat gateway down'));

    await expect(
      service.killUser('user-123', 'manual'),
    ).rejects.toThrow('chat gateway down');

    // The other gateways should still have been called because
    // Promise.all fires them all eagerly even though it rejects as
    // soon as one fails.
    expect(notifications.killUser).toHaveBeenCalledTimes(1);
    expect(feed.killUser).toHaveBeenCalledTimes(1);
    expect(presence.killUser).toHaveBeenCalledTimes(1);
  });
});
