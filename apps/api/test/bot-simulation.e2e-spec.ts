/**
 * Bot simulation integration smoke test.
 *
 * Boots the full AppModule against the testcontainers Postgres + Redis,
 * seeds a small bot population + two pre-existing content items, flips
 * `BOT_DEMO_MODE` on for tight cadence, and starts the scheduler. After
 * ~30 s we assert that the BullMQ pipeline produced real rows in
 * `bot_activity_logs` and that at least some feed-vertical actions
 * (createPost / createVideo / likeContent / commentOnContent /
 * viewContent / followUser) succeeded.
 *
 * The goal is to lock the wiring end-to-end (scheduler → queue →
 * processor → engine → DB) so accidental regressions of PR #63 (DI
 * failure) or future scheduler refactors fail loudly.
 */
import { bootstrapTestApp, TestAppContext } from './helpers/test-app';
import { EntityManager } from '@mikro-orm/postgresql';
import { MikroORM, RequestContext } from '@mikro-orm/core';
import { BotsService } from '../src/modules/bots/bots.service';
import { BotSchedulerService } from '../src/modules/bots/bot-scheduler.service';
import { BotProfile } from '../src/modules/bots/entities/bot-profile.entity';
import { BotActivityLog } from '../src/modules/bots/entities/bot-activity-log.entity';
import { Content } from '../src/modules/content/entities/content.entity';
import { Video } from '../src/modules/content/entities/video.entity';
import { Post } from '../src/modules/content/entities/post.entity';
import { User } from '../src/modules/users/entities/user.entity';
import {
  ContentStatus,
  ContentType,
  ContentTier,
  Visibility,
  PostSubType,
  Role,
  UserStatus,
} from '../src/common/enums';

const FEED_VERTICAL_ACTIONS = new Set([
  'createPost',
  'createVideo',
  'likeContent',
  'commentOnContent',
  'viewContent',
  'followUser',
]);

const wait = (ms: number) => new Promise((r) => setTimeout(r, ms));

describe('Bot simulation e2e', () => {
  let ctx: TestAppContext;
  let orm: MikroORM;
  let botsService: BotsService;
  let scheduler: BotSchedulerService;

  beforeAll(async () => {
    // Demo cadence: each bot fires every 1-3 s so a 25 s observation
    // window emits ~5-25 jobs across the population. Set BEFORE the
    // app boots so BotSchedulerService picks the values up via
    // ConfigService at construction time.
    process.env.BOT_DEMO_MODE = '1';
    process.env.BOT_DEMO_MIN_INTERVAL_MS = '1000';
    process.env.BOT_DEMO_MAX_INTERVAL_MS = '3000';
    // Auto-start path is exercised via the manual scheduler.startAllBots
    // call below — leaving BOT_SIMULATION_ENABLED unset keeps the test
    // deterministic regardless of the order Nest resolves OnModuleInit.
    process.env.BOT_SIMULATION_ENABLED = '';

    ctx = await bootstrapTestApp();
    orm = ctx.app.get(MikroORM);
    botsService = ctx.app.get(BotsService);
    scheduler = ctx.app.get(BotSchedulerService);
  }, 120_000);

  afterAll(async () => {
    if (scheduler) {
      try {
        await scheduler.stopAllBots();
      } catch {
        // Best-effort
      }
    }
    if (ctx) await ctx.close();
  });

  it('produces feed-vertical activity within 25 s of starting the scheduler', async () => {
    const botIds: string[] = await RequestContext.create(orm.em, async () => {
      const tem = orm.em as EntityManager;

      // 1. Seed two pre-existing content items so likeContent /
      //    commentOnContent / viewContent have something to interact with
      //    on the very first tick.
      const seedUser = tem.create(User, {
        name: 'Bot Test Seed User',
        phone: '+447900000999',
        role: Role.USER,
        status: UserStatus.ACTIVE,
      } as any);
      await tem.flush();

      tem.create(Video, {
        type: ContentType.VIDEO,
        creator: seedUser,
        videoUrl: 'https://example.com/seed.mp4',
        thumbnailUrl: 'https://example.com/seed.jpg',
        durationSeconds: 30,
        caption: 'seed video',
        status: ContentStatus.ACTIVE,
        visibility: Visibility.PUBLIC,
        tier: ContentTier.FREE,
      } as any);

      tem.create(Post, {
        type: ContentType.POST,
        creator: seedUser,
        text: 'seed post',
        subType: PostSubType.STANDARD,
        status: ContentStatus.ACTIVE,
        visibility: Visibility.PUBLIC,
        tier: ContentTier.FREE,
      } as any);
      await tem.flush();

      // 2. Create a small bot population spanning two distinct personas so
      //    different action mixes feed into the queue.
      const personas = ['social_butterfly', 'content_creator'];
      const ids: string[] = [];
      for (let i = 0; i < 4; i++) {
        const result = await botsService.createBot({
          name: `Test Bot ${i + 1}`,
          displayPersona: personas[i % personas.length],
          homeLatitude: 51.5074,
          homeLongitude: -0.1278,
        });
        ids.push(result.profile.id);
      }
      return ids;
    });

    // 3. Start everything and observe. Scheduler reads via the global
    //    EM with allowGlobalContext flowing through MikroORM
    //    discoveryRoot — but the service itself only does em.find /
    //    flush which work with the shared ORM. To be safe, wrap.
    const started = await RequestContext.create(orm.em, async () => {
      return scheduler.startAllBots();
    });
    expect(started).toBeGreaterThanOrEqual(botIds.length);

    // 4. Poll bot_activity_logs every 2 s, bail early once we see at
    //    least one feed-vertical success. 25 s wall-clock cap keeps
    //    the e2e run short while leaving plenty of headroom for queue
    //    delays on a slow CI runner.
    const deadline = Date.now() + 25_000;
    let logs: BotActivityLog[] = [];
    while (Date.now() < deadline) {
      logs = await RequestContext.create(orm.em, async () => {
        const fork = (orm.em as EntityManager).fork();
        return fork.find(
          BotActivityLog,
          { botProfile: { $in: botIds } },
          { orderBy: { executedAt: 'ASC' } },
        );
      });
      const feedSuccesses = logs.filter(
        (l) => l.success && FEED_VERTICAL_ACTIONS.has(l.actionType),
      );
      if (feedSuccesses.length >= 1) break;
      await wait(2_000);
    }

    // 5. Assertions.
    expect(logs.length).toBeGreaterThan(0);

    // Every job should have produced an audit row whether it succeeded
    // or not. If we see only failure rows the wiring is alive but
    // something downstream is broken — surface that as a failure.
    const successful = logs.filter((l) => l.success);
    expect(successful.length).toBeGreaterThan(0);

    const feedActions = successful.filter((l) =>
      FEED_VERTICAL_ACTIONS.has(l.actionType),
    );
    expect(feedActions.length).toBeGreaterThan(0);

    // Total content rows should have grown if any createPost / createVideo
    // fired. This is a soft check — if all successes were likeContent the
    // total stays at 2.
    const totalContent = await RequestContext.create(orm.em, async () => {
      return (orm.em as EntityManager).fork().count(Content);
    });
    expect(totalContent).toBeGreaterThanOrEqual(2);

    // Bot counters should have advanced.
    const profiles = await RequestContext.create(orm.em, async () => {
      return (orm.em as EntityManager)
        .fork()
        .find(BotProfile, { id: { $in: botIds } });
    });
    const totalActions = profiles.reduce((sum, p) => sum + p.totalActions, 0);
    expect(totalActions).toBeGreaterThan(0);
  }, 90_000);
});
