import { ExecutionContext } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { KuwbooThrottlerGuard } from './kuwboo-throttler.guard';

function ctxWithBody(body: unknown): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => ({ body }),
    }),
  } as unknown as ExecutionContext;
}

describe('KuwbooThrottlerGuard', () => {
  let guard: KuwbooThrottlerGuard;
  const superShouldSkip = jest.fn().mockResolvedValue(false);

  beforeEach(() => {
    jest
      .spyOn(ThrottlerGuard.prototype, 'shouldSkip' as never)
      .mockImplementation(superShouldSkip as never);

    guard = new KuwbooThrottlerGuard(
      {} as never,
      {} as never,
      {} as never,
    );
    superShouldSkip.mockClear();
  });

  afterEach(() => {
    delete process.env.RESERVED_TEST_PHONES;
    delete process.env.RESERVED_TEST_EMAILS;
  });

  it('skips for the default reserved phone', async () => {
    const skip = await guard['shouldSkip'](
      ctxWithBody({ phone: '+12025550100' }),
    );
    expect(skip).toBe(true);
    expect(superShouldSkip).not.toHaveBeenCalled();
  });

  it('skips for the default reserved email (case-insensitive)', async () => {
    const skip = await guard['shouldSkip'](
      ctxWithBody({ email: 'CuttingPhilip+Test@gmail.com' }),
    );
    expect(skip).toBe(true);
  });

  it('delegates to super for unreserved phones', async () => {
    const skip = await guard['shouldSkip'](
      ctxWithBody({ phone: '+14045550199' }),
    );
    expect(skip).toBe(false);
    expect(superShouldSkip).toHaveBeenCalledTimes(1);
  });

  it('respects RESERVED_TEST_PHONES env override', async () => {
    process.env.RESERVED_TEST_PHONES = '+15555550000, +447700900001';
    const skip = await guard['shouldSkip'](
      ctxWithBody({ phone: '+447700900001' }),
    );
    expect(skip).toBe(true);
  });

  it('handles missing body without crashing', async () => {
    const skip = await guard['shouldSkip'](ctxWithBody(undefined));
    expect(skip).toBe(false);
    expect(superShouldSkip).toHaveBeenCalledTimes(1);
  });
});
