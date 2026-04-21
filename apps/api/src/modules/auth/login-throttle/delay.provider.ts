import { Injectable } from '@nestjs/common';
import { setTimeout as sleep } from 'timers/promises';

/**
 * Indirection over `setTimeout` used by `LoginThrottleService` to add
 * the exponential backoff delay before a wrong-password attempt returns.
 *
 * The production implementation below is a thin wrapper over
 * `timers/promises.setTimeout`. In unit tests we substitute a zero-delay
 * stub via NestJS DI — cleaner and more reliable than
 * `jest.useFakeTimers()`, which is fiddly around
 * `async/await + setTimeout`.
 *
 * Keeping this a class (not a symbol token for a function) makes the DI
 * wiring identical to every other collaborator in the auth module.
 */
export abstract class DelayProvider {
  abstract wait(ms: number): Promise<void>;
}

@Injectable()
export class RealDelayProvider extends DelayProvider {
  async wait(ms: number): Promise<void> {
    if (ms <= 0) return;
    await sleep(ms);
  }
}
