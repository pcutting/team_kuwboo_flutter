/**
 * Seeds a population of `BotProfile` rows + their backing `User` records.
 *
 * Designed to be called from `seed-demo-data.ts` at the tail (after the
 * sample human + content seed has flushed) so the bot scheduler has both
 * a graph of users to follow and a corpus of content to interact with on
 * the very first tick.
 *
 * Idempotent: if any bot rows exist whose name matches the seed-prefix
 * pattern (`Kuwboo Bot ___`) the function logs and returns without
 * inserting more. Pass `force=true` to wipe the seeded bots first.
 *
 * Standalone usage:
 *   cd apps/api
 *   npm run build
 *   npm run seed:bots
 *
 * Auto-run from seed:demo (default).
 */
import { NestFactory } from '@nestjs/core';
import { RequestContext } from '@mikro-orm/core';
import { EntityManager } from '@mikro-orm/postgresql';
import { AppModule } from '../app.module';
import { BotsService } from '../modules/bots/bots.service';
import { BotProfile } from '../modules/bots/entities/bot-profile.entity';
import { User } from '../modules/users/entities/user.entity';
import { PERSONA_NAMES } from '../modules/bots/presets/persona-presets';

const SEED_BOT_PREFIX = 'Kuwboo Bot';

// 12 distinct bot identities with varied names and personas. Spread
// across the 5 preset personas so action mix is realistic. Coordinates
// scatter around central London so the geo features (yoyo / nearby /
// movement) have something to work with.
const SEED_BOTS: Array<{
  name: string;
  persona: string;
  backstory?: string;
  lat: number;
  lng: number;
}> = [
  { name: `${SEED_BOT_PREFIX} Aria`,    persona: 'social_butterfly', lat: 51.5074, lng: -0.1278 },
  { name: `${SEED_BOT_PREFIX} Beck`,    persona: 'content_creator',  lat: 51.5234, lng: -0.0858 },
  { name: `${SEED_BOT_PREFIX} Cleo`,    persona: 'lurker',           lat: 51.5419, lng: -0.1408 },
  { name: `${SEED_BOT_PREFIX} Dax`,     persona: 'explorer',         lat: 51.4626, lng: -0.1146 },
  { name: `${SEED_BOT_PREFIX} Eve`,     persona: 'shopper',          lat: 51.4777, lng: -0.0015 },
  { name: `${SEED_BOT_PREFIX} Finn`,    persona: 'social_butterfly', lat: 51.5394, lng: -0.1432 },
  { name: `${SEED_BOT_PREFIX} Gigi`,    persona: 'content_creator',  lat: 51.5155, lng: -0.0922 },
  { name: `${SEED_BOT_PREFIX} Hugo`,    persona: 'explorer',         lat: 51.5320, lng: -0.1769 },
  { name: `${SEED_BOT_PREFIX} Indi`,    persona: 'shopper',          lat: 51.5083, lng: -0.1949 },
  { name: `${SEED_BOT_PREFIX} Jules`,   persona: 'social_butterfly', lat: 51.5137, lng: -0.0985 },
  { name: `${SEED_BOT_PREFIX} Kira`,    persona: 'lurker',           lat: 51.4964, lng: -0.1456 },
  { name: `${SEED_BOT_PREFIX} Leo`,     persona: 'content_creator',  lat: 51.5478, lng: -0.0050 },
];

export interface SeedBotsResult {
  created: number;
  skipped: boolean;
}

export async function seedBots(
  em: EntityManager,
  botsService: BotsService,
  options: { force?: boolean } = {},
): Promise<SeedBotsResult> {
  // BotsService.createBot uses its injected (global) EM via this.em.create(),
  // which throws cannotUseGlobalContext outside a request scope. Wrap the
  // whole body so every service call resolves to the forked EM via
  // AsyncLocalStorage — same pattern as BotActionProcessor (PR #202).
  return RequestContext.create(em, async () => {
    const seedNames = SEED_BOTS.map((b) => b.name);

    if (options.force) {
      // Soft-delete the User rows we previously seeded; cascading rules
      // remove their BotProfile and content. Direct nativeDelete cascades
      // through onDelete: cascade FKs declared on BotProfile.user.
      const deleted = await em.nativeDelete(User, { name: { $in: seedNames } });
      console.log(`[seed-bots] --force: deleted ${deleted} previously-seeded bots (cascades to BotProfile + content).`);
    } else {
      const existing = await em.count(BotProfile, {
        user: { name: { $in: seedNames } },
      });
      if (existing > 0) {
        console.log(`[seed-bots] Skipping — ${existing} seed bots already exist. Re-run with force=true to regenerate.`);
        return { created: 0, skipped: true };
      }
    }

    let created = 0;
    for (const def of SEED_BOTS) {
      if (!PERSONA_NAMES.includes(def.persona)) {
        console.warn(`[seed-bots] Skipping ${def.name} — unknown persona ${def.persona}`);
        continue;
      }
      await botsService.createBot({
        name: def.name,
        displayPersona: def.persona,
        backstory: def.backstory,
        homeLatitude: def.lat,
        homeLongitude: def.lng,
        roamRadiusKm: 5,
      });
      created++;
    }

    console.log(`[seed-bots] Created ${created} bots across ${PERSONA_NAMES.length} personas.`);
    return { created, skipped: false };
  });
}

// Standalone bootstrap when invoked via `npm run seed:bots`.
async function bootstrap() {
  const force = process.argv.includes('--force');
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn', 'log'],
  });
  try {
    const em = app.get(EntityManager).fork();
    const botsService = app.get(BotsService);
    await seedBots(em, botsService, { force });
  } finally {
    await app.close();
  }
}

if (require.main === module) {
  bootstrap().catch((err) => {
    console.error('[seed-bots] FAILED:', err);
    process.exit(1);
  });
}
