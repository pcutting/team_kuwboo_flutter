import { ExecutionContext, Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

/**
 * Skips rate limiting when the request targets a reserved test identifier.
 * Reserved phones use the NANPA 555-01xx fictional-use block and reserved
 * emails use the `+test` plus-tag convention. Configurable via env so App
 * Store reviewers or QA can be added without a code change.
 *
 * Everything else goes through the default ThrottlerGuard logic.
 */
@Injectable()
export class KuwbooThrottlerGuard extends ThrottlerGuard {
  private reservedPhones(): Set<string> {
    const raw = process.env.RESERVED_TEST_PHONES ?? '+12025550100';
    return new Set(
      raw
        .split(',')
        .map((s) => s.trim())
        .filter((s) => s.length > 0),
    );
  }

  private reservedEmails(): Set<string> {
    const raw =
      process.env.RESERVED_TEST_EMAILS ??
      'cuttingphilip+test@gmail.com,cuttingphilip@gmail.com,neildouglas33@hotmail.co.uk';
    return new Set(
      raw
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .filter((s) => s.length > 0),
    );
  }

  protected async shouldSkip(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest();
    const body = (req?.body ?? {}) as Record<string, unknown>;

    const phone = typeof body.phone === 'string' ? body.phone : undefined;
    if (phone && this.reservedPhones().has(phone)) return true;

    const email = typeof body.email === 'string' ? body.email.toLowerCase() : undefined;
    if (email && this.reservedEmails().has(email)) return true;

    return super.shouldSkip(context);
  }
}
