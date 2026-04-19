import { NotImplementedException } from '@nestjs/common';
import { VideoController } from './video.controller';
import { VideoService } from './video.service';

/**
 * Smoke tests for the scaffolded Video module. Every handler must
 * delegate to a service method that throws NotImplementedException —
 * this locks in the contract that the route surface is wired but the
 * feature logic is deliberately absent.
 */
describe('VideoController (scaffold)', () => {
  let controller: VideoController;

  beforeEach(() => {
    controller = new VideoController(new VideoService());
  });

  it('is defined', () => {
    expect(controller).toBeDefined();
  });

  it('getFeed throws NotImplementedException', async () => {
    await expect(controller.getFeed('user-1', {})).rejects.toBeInstanceOf(
      NotImplementedException,
    );
  });

  it('getTrending throws NotImplementedException', async () => {
    await expect(controller.getTrending({})).rejects.toBeInstanceOf(
      NotImplementedException,
    );
  });

  it('listCategories throws NotImplementedException', async () => {
    await expect(controller.listCategories()).rejects.toBeInstanceOf(
      NotImplementedException,
    );
  });

  it('listAudioTracks throws NotImplementedException', async () => {
    await expect(controller.listAudioTracks({})).rejects.toBeInstanceOf(
      NotImplementedException,
    );
  });
});
