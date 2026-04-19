import { NotImplementedException } from '@nestjs/common';
import { SocialController } from './social.controller';
import { SocialService } from './social.service';

/**
 * Smoke tests for the scaffolded Social module. Every handler must
 * delegate to a service method that throws NotImplementedException —
 * this locks in the contract that the route surface is wired but the
 * feature logic is deliberately absent.
 */
describe('SocialController (scaffold)', () => {
  let controller: SocialController;

  beforeEach(() => {
    controller = new SocialController(new SocialService());
  });

  it('is defined', () => {
    expect(controller).toBeDefined();
  });

  it('getFeed throws NotImplementedException', async () => {
    await expect(controller.getFeed('user-1', {})).rejects.toBeInstanceOf(
      NotImplementedException,
    );
  });

  it('getStumble throws NotImplementedException', async () => {
    await expect(controller.getStumble('user-1', {})).rejects.toBeInstanceOf(
      NotImplementedException,
    );
  });

  it('listEvents throws NotImplementedException', async () => {
    await expect(controller.listEvents({})).rejects.toBeInstanceOf(
      NotImplementedException,
    );
  });

  it('createEvent throws NotImplementedException', async () => {
    await expect(
      controller.createEvent('user-1', {
        title: 'Scaffold event',
        startsAt: '2030-01-01T00:00:00Z',
        endsAt: '2030-01-01T02:00:00Z',
      }),
    ).rejects.toBeInstanceOf(NotImplementedException);
  });
});
