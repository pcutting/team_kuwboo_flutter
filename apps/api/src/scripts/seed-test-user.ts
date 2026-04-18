/**
 * Test-user seed script. Creates `cuttingphilip+test@gmail.com` as a
 * fully-connected demo user so when they log in via the rate-limit-bypass
 * email, every feed (videos, posts, marketplace, chat, yoyo, comments)
 * has content visible to them.
 *
 * Run on EC2:
 *   cd /home/ubuntu/team_kuwboo/apps/api
 *   npm run build && npm run seed:test-user
 *
 * Idempotent: skips if a user with this email already exists. To re-seed,
 * delete the user manually first (cascades clean up everything below).
 *
 * What it seeds (assumes seed-demo-data.ts has run first):
 *   - 1 User (Phil Test) + EMAIL credential
 *   - Connections: follows all 8 non-bot seed users; 3 follow back; 1 friend
 *   - Comments: 6 by Phil + 6 replies by seed users
 *   - Interactions: ~10 likes, 3 saves, 15 video views
 *   - Threads: 1 DM, 1 BUY_SELL, 1 YOYO — each with 5-8 messages
 *   - Waves: 1 sent, 1 received
 *   - Consent: TERMS + PRIVACY granted
 */
import { NestFactory } from '@nestjs/core';
import { EntityManager } from '@mikro-orm/postgresql';
import { AppModule } from '../app.module';
import { User } from '../modules/users/entities/user.entity';
import { Credential } from '../modules/credentials/entities/credential.entity';
import { Connection } from '../modules/connections/entities/connection.entity';
import { Comment } from '../modules/comments/entities/comment.entity';
import { InteractionState } from '../modules/interactions/entities/interaction-state.entity';
import { InteractionEvent } from '../modules/interactions/entities/interaction-event.entity';
import { Thread } from '../modules/messaging/entities/thread.entity';
import { ThreadParticipant } from '../modules/messaging/entities/thread-participant.entity';
import { Message } from '../modules/messaging/entities/message.entity';
import { Wave } from '../modules/yoyo/entities/wave.entity';
import { UserConsent } from '../modules/consent/entities/user-consent.entity';
import { Video } from '../modules/content/entities/video.entity';
import { Post } from '../modules/content/entities/post.entity';
import {
  Role,
  UserStatus,
  CredentialType,
  ConnectionContext,
  ConnectionStatus,
  InteractionStateType,
  InteractionEventType,
  ThreadModuleKey,
  WaveStatus,
  ConsentType,
  ConsentSource,
} from '../common/enums';

export const TEST_USER_EMAIL = 'cuttingphilip+test@gmail.com';
export const TEST_USER_USERNAME = 'phil_test';

interface SeedResult {
  userId: string;
  created: boolean;
  summary: {
    connections: number;
    comments: number;
    replies: number;
    likes: number;
    saves: number;
    views: number;
    threads: number;
    messages: number;
    waves: number;
    consents: number;
  };
}

/**
 * Idempotent: returns early with `{ created: false }` if the test user
 * already exists. Safe to call from `seed-demo-data.ts` after the main
 * seed has flushed.
 */
export async function seedTestUser(em: EntityManager): Promise<SeedResult> {
  const tem = em.fork();
  const summary = {
    connections: 0,
    comments: 0,
    replies: 0,
    likes: 0,
    saves: 0,
    views: 0,
    threads: 0,
    messages: 0,
    waves: 0,
    consents: 0,
  };

  const existing = await tem.findOne(User, { email: TEST_USER_EMAIL });
  if (existing) {
    console.log(
      `[seed:test-user] Skipping — user ${TEST_USER_EMAIL} already exists (id=${existing.id}).`,
    );
    return { userId: existing.id, created: false, summary };
  }

  // Pull the seeded humans + a sample of content. We don't gate on the seed
  // demo having run, but a useful test user requires content to interact
  // with — log a hint if nothing is there.
  const seededHumans = await tem.find(
    User,
    { isBot: false, email: { $ne: TEST_USER_EMAIL } },
    { limit: 8, orderBy: { createdAt: 'ASC' } },
  );
  if (seededHumans.length === 0) {
    console.warn(
      '[seed:test-user] WARNING: no seeded human users found. Run `npm run seed:demo` first.',
    );
  }
  const videos = await tem.find(Video, {}, { limit: 15, orderBy: { createdAt: 'ASC' } });
  const posts = await tem.find(Post, {}, { limit: 10, orderBy: { createdAt: 'ASC' } });

  await tem.transactional(async (trx) => {
    // 1. User + credential
    const user = trx.create(User, {
      email: TEST_USER_EMAIL,
      name: 'Phil (Test)',
      username: TEST_USER_USERNAME,
      role: Role.USER,
      status: UserStatus.ACTIVE,
      avatarUrl: `https://i.pravatar.cc/300?u=${encodeURIComponent(TEST_USER_EMAIL)}`,
      emailVerified: true,
      emailVerifiedAt: new Date(),
    });
    await trx.persistAndFlush(user);

    trx.create(Credential, {
      user,
      type: CredentialType.EMAIL,
      identifier: TEST_USER_EMAIL.toLowerCase(),
      verifiedAt: new Date(),
      isPrimary: true,
    });

    // 2. Consent rows so authenticated endpoints don't trip the consent gate
    const now = new Date();
    for (const consentType of [ConsentType.TERMS, ConsentType.PRIVACY]) {
      trx.create(UserConsent, {
        user,
        consentType,
        version: '1.0',
        source: ConsentSource.REGISTRATION,
        grantedAt: now,
      });
      summary.consents++;
    }

    // 3. Connections
    // Phil follows every seeded human.
    for (const target of seededHumans) {
      trx.create(Connection, {
        fromUser: user,
        toUser: target,
        context: ConnectionContext.FOLLOW,
        status: ConnectionStatus.ACTIVE,
        confirmedAt: now,
      });
      summary.connections++;
    }
    // The first 3 humans follow Phil back (bidirectional follows).
    for (const follower of seededHumans.slice(0, 3)) {
      trx.create(Connection, {
        fromUser: follower,
        toUser: user,
        context: ConnectionContext.FOLLOW,
        status: ConnectionStatus.ACTIVE,
        confirmedAt: now,
      });
      summary.connections++;
    }
    // 1 friend relationship (mutual FRIEND edges, both ACTIVE/confirmed).
    if (seededHumans.length >= 1) {
      const friend = seededHumans[0];
      trx.create(Connection, {
        fromUser: user,
        toUser: friend,
        context: ConnectionContext.FRIEND,
        status: ConnectionStatus.ACTIVE,
        confirmedAt: now,
      });
      trx.create(Connection, {
        fromUser: friend,
        toUser: user,
        context: ConnectionContext.FRIEND,
        status: ConnectionStatus.ACTIVE,
        confirmedAt: now,
      });
      summary.connections += 2;
    }

    // 4. Comments by Phil on a mix of videos + posts, plus replies
    const commentTargets = [
      ...videos.slice(0, 4),
      ...posts.slice(0, 2),
    ];
    const commentTexts = [
      'Loved this — saved for later.',
      'Where was this filmed?',
      'Underrated. More like this please.',
      'This made my morning.',
      'Genuinely useful, thanks for sharing.',
      'Sending this to my brother.',
    ];
    const replyTexts = [
      'Glad you liked it!',
      'Shoreditch — DM me for the spot.',
      'Working on a follow-up now.',
      'Cheers.',
      'Means a lot.',
      'Hope he enjoys.',
    ];

    for (let i = 0; i < commentTargets.length; i++) {
      const content = commentTargets[i];
      const parent = trx.create(Comment, {
        content,
        author: user,
        text: commentTexts[i] ?? commentTexts[0],
      });
      summary.comments++;
      // Reply from a seeded user (cycle through them; the creator replies
      // to their own content's comment when possible).
      const replier =
        seededHumans.find((h) => h.id === content.creator.id) ??
        seededHumans[i % Math.max(seededHumans.length, 1)];
      if (replier) {
        trx.create(Comment, {
          content,
          author: replier,
          text: replyTexts[i] ?? replyTexts[0],
          parentComment: parent,
        });
        summary.replies++;
      }
    }

    // 5. Interactions: likes on 10 items (mix of videos + posts), saves on 3,
    // VIEW events on every video.
    const likeTargets = [...videos.slice(0, 7), ...posts.slice(0, 3)];
    for (const content of likeTargets) {
      trx.create(InteractionState, {
        user,
        content,
        type: InteractionStateType.LIKE,
      });
      summary.likes++;
    }
    for (const content of videos.slice(0, 3)) {
      trx.create(InteractionState, {
        user,
        content,
        type: InteractionStateType.SAVE,
      });
      summary.saves++;
    }
    for (const video of videos) {
      trx.create(InteractionEvent, {
        user,
        content: video,
        type: InteractionEventType.VIEW,
      });
      summary.views++;
    }

    // 6. Threads — at least one per representative moduleKey
    const threadSpecs: Array<{
      moduleKey: ThreadModuleKey | undefined;
      otherIdx: number;
      script: Array<{ from: 'phil' | 'other'; text: string }>;
    }> = [
      {
        // 1-on-1 DM, no module context (general chat).
        moduleKey: undefined,
        otherIdx: 0,
        script: [
          { from: 'phil', text: 'Hey — long time! How have you been?' },
          { from: 'other', text: 'Phil! Yeah good, busy with work. You?' },
          { from: 'phil', text: 'Same. Free for a coffee this weekend?' },
          { from: 'other', text: 'Saturday morning works.' },
          { from: 'phil', text: 'Brick Lane at 10?' },
          { from: 'other', text: 'See you there.' },
        ],
      },
      {
        moduleKey: ThreadModuleKey.BUY_SELL,
        otherIdx: 1,
        script: [
          { from: 'phil', text: 'Is the Brompton still available?' },
          { from: 'other', text: 'Yes — when did you want to view?' },
          { from: 'phil', text: 'Tomorrow evening if that works.' },
          { from: 'other', text: 'Sure, 7pm at Old Street?' },
          { from: 'phil', text: 'Perfect, see you then.' },
        ],
      },
      {
        moduleKey: ThreadModuleKey.YOYO,
        otherIdx: 2,
        script: [
          { from: 'other', text: 'Hey — saw your wave!' },
          { from: 'phil', text: 'Hi! Where are you headed?' },
          { from: 'other', text: 'Just walking near Camden.' },
          { from: 'phil', text: 'Ah nice, I was just there.' },
          { from: 'other', text: 'Small world.' },
          { from: 'phil', text: 'Catch you next time.' },
        ],
      },
    ];

    for (const spec of threadSpecs) {
      if (seededHumans.length <= spec.otherIdx) continue;
      const other = seededHumans[spec.otherIdx];
      const thread = trx.create(Thread, { moduleKey: spec.moduleKey });
      await trx.persistAndFlush(thread);

      trx.create(ThreadParticipant, { thread, user });
      trx.create(ThreadParticipant, { thread, user: other });

      for (const line of spec.script) {
        trx.create(Message, {
          thread,
          sender: line.from === 'phil' ? user : other,
          text: line.text,
        });
        summary.messages++;
      }
      summary.threads++;
    }

    // 7. Waves — one outbound, one inbound (both with seed humans)
    if (seededHumans.length >= 4) {
      trx.create(Wave, {
        fromUser: user,
        toUser: seededHumans[3],
        message: `Hey ${seededHumans[3].name.split(' ')[0]}, saw you nearby!`,
        status: WaveStatus.PENDING,
      });
      summary.waves++;
    }
    if (seededHumans.length >= 5) {
      trx.create(Wave, {
        fromUser: seededHumans[4],
        toUser: user,
        message: 'Hey Phil, fancy a wave?',
        status: WaveStatus.ACCEPTED,
        respondedAt: now,
      });
      summary.waves++;
    }
  });

  // Re-fetch the user id outside the transactional fork.
  const created = await tem.findOneOrFail(User, { email: TEST_USER_EMAIL });
  console.log(`[seed:test-user] Created ${TEST_USER_EMAIL} (id=${created.id}).`);
  console.table(summary);
  return { userId: created.id, created: true, summary };
}

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn', 'log'],
  });
  try {
    const em = app.get(EntityManager);
    await seedTestUser(em);
  } finally {
    await app.close();
  }
}

// Only run bootstrap when invoked directly (not when imported by
// seed-demo-data.ts).
if (require.main === module) {
  bootstrap().catch((err) => {
    console.error('[seed:test-user] FAILED:', err);
    process.exit(1);
  });
}
