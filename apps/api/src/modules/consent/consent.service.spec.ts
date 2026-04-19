import { ConsentService } from './consent.service';
import { CURRENT_CONSENT_VERSIONS } from './consent-versions';
import { ConsentType } from '../../common/enums';

/**
 * Pure-unit tests for the summary aggregation math in
 * `ConsentService.getSummary`. The service reaches into raw SQL via
 * `em.getConnection().execute(...)` for the first/last/max aggregation,
 * so we stub just enough of that surface — no real Postgres needed.
 *
 * Each row the stub returns mirrors the shape the real driver hands
 * back: `{ first, last, version }` with Date objects for the
 * timestamps. `isCurrent` is derived client-side, so these tests pin
 * the "which stored version counts as current" rule.
 */
describe('ConsentService.getSummary', () => {
  function makeService(
    rowsByType: Partial<Record<ConsentType, { first: Date | null; last: Date | null; version: string | null }>>,
  ): ConsentService {
    const fakeConn = {
      execute: jest.fn(async (_sql: string, params: unknown[]) => {
        const consentType = params[1] as ConsentType;
        const row = rowsByType[consentType] ?? {
          first: null,
          last: null,
          version: null,
        };
        return [row];
      }),
    };
    const fakeEm = {
      getConnection: () => fakeConn,
    };
    return new ConsentService(fakeEm as never);
  }

  it('returns nulls and isCurrent=false when the user has never accepted', async () => {
    const svc = makeService({});
    const out = await svc.getSummary('user-1');

    expect(out.versions).toEqual({
      terms: CURRENT_CONSENT_VERSIONS.TERMS,
      privacy: CURRENT_CONSENT_VERSIONS.PRIVACY,
    });
    expect(out.user.terms).toEqual({
      firstAcceptedAt: null,
      lastAcceptedAt: null,
      acceptedVersion: null,
      isCurrent: false,
    });
    expect(out.user.privacy).toEqual({
      firstAcceptedAt: null,
      lastAcceptedAt: null,
      acceptedVersion: null,
      isCurrent: false,
    });
  });

  it('reports first < last from two grants at different times for TERMS', async () => {
    const firstTime = new Date('2026-01-01T10:00:00.000Z');
    const lastTime = new Date('2026-04-19T12:30:00.000Z');
    const svc = makeService({
      [ConsentType.TERMS]: {
        first: firstTime,
        last: lastTime,
        version: CURRENT_CONSENT_VERSIONS.TERMS,
      },
    });

    const out = await svc.getSummary('user-1');
    expect(out.user.terms.firstAcceptedAt).toBe(firstTime.toISOString());
    expect(out.user.terms.lastAcceptedAt).toBe(lastTime.toISOString());
    expect(
      new Date(out.user.terms.firstAcceptedAt!).getTime(),
    ).toBeLessThan(new Date(out.user.terms.lastAcceptedAt!).getTime());
  });

  it('surfaces MAX(version) as acceptedVersion and flags it current when it matches', async () => {
    const svc = makeService({
      [ConsentType.TERMS]: {
        first: new Date('2026-01-01T10:00:00.000Z'),
        last: new Date('2026-04-19T12:30:00.000Z'),
        version: CURRENT_CONSENT_VERSIONS.TERMS, // e.g. '1.0'
      },
    });

    const out = await svc.getSummary('user-1');
    expect(out.user.terms.acceptedVersion).toBe(CURRENT_CONSENT_VERSIONS.TERMS);
    expect(out.user.terms.isCurrent).toBe(true);
  });

  it('flags isCurrent=false when the stored max version trails the current one', async () => {
    const svc = makeService({
      [ConsentType.PRIVACY]: {
        first: new Date('2025-01-01T00:00:00.000Z'),
        last: new Date('2025-06-01T00:00:00.000Z'),
        version: '0.9', // strictly less than '1.0' under string ordering
      },
    });

    const out = await svc.getSummary('user-1');
    expect(out.user.privacy.acceptedVersion).toBe('0.9');
    expect(out.user.privacy.isCurrent).toBe(false);
  });

  it('treats TERMS and PRIVACY independently', async () => {
    const svc = makeService({
      [ConsentType.TERMS]: {
        first: new Date('2026-01-01T00:00:00.000Z'),
        last: new Date('2026-01-01T00:00:00.000Z'),
        version: CURRENT_CONSENT_VERSIONS.TERMS,
      },
      // PRIVACY omitted — user never accepted privacy policy
    });

    const out = await svc.getSummary('user-1');
    expect(out.user.terms.isCurrent).toBe(true);
    expect(out.user.privacy.acceptedVersion).toBeNull();
    expect(out.user.privacy.isCurrent).toBe(false);
  });
});

describe('ConsentService.getCurrencyFlags', () => {
  it('mirrors the isCurrent flags from the full summary', async () => {
    const fakeConn = {
      execute: jest.fn(async (_sql: string, params: unknown[]) => {
        const consentType = params[1] as ConsentType;
        if (consentType === ConsentType.TERMS) {
          return [{
            first: new Date(),
            last: new Date(),
            version: CURRENT_CONSENT_VERSIONS.TERMS,
          }];
        }
        // PRIVACY out of date
        return [{ first: new Date(), last: new Date(), version: '0.9' }];
      }),
    };
    const svc = new ConsentService({ getConnection: () => fakeConn } as never);

    await expect(svc.getCurrencyFlags('user-1')).resolves.toEqual({
      termsUpToDate: true,
      privacyUpToDate: false,
    });
  });
});
