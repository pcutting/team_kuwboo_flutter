/**
 * Demo data seed script for development environments.
 *
 * Run on EC2:
 *   cd /home/ubuntu/team_kuwboo/apps/api
 *   git pull && npm install && npm run build
 *   NODE_ENV=development npm run seed:demo
 *
 * Idempotent: skips if any users already exist. To re-seed, truncate first.
 *
 * What it seeds:
 *   - 10 Users (mix of human + bot)
 *   - 15 Videos (royalty-free sample videos)
 *   - 10 Posts (text + Pexels images)
 *   - 8 Products (marketplace listings, GBP)
 *   - 5 Waves (yoyo encounters with PostGIS points near London)
 *
 * Skipped (would require deeper graph wiring):
 *   - Threads, Comments, Notifications, Auctions, Bids, Sponsored, Verifications
 */
import { NestFactory } from '@nestjs/core';
import { EntityManager } from '@mikro-orm/postgresql';
import { AppModule } from '../app.module';
import { User } from '../modules/users/entities/user.entity';
import { Video } from '../modules/content/entities/video.entity';
import { Post } from '../modules/content/entities/post.entity';
import { Product } from '../modules/content/entities/product.entity';
import { Wave } from '../modules/yoyo/entities/wave.entity';
import {
  Role,
  UserStatus,
  ContentStatus,
  Visibility,
  ContentTier,
  PostSubType,
  ProductCondition,
  WaveStatus,
} from '../common/enums';

const SAMPLE_VIDEOS = [
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', thumb: 'https://images.pexels.com/photos/3389528/pexels-photo-3389528.jpeg', dur: 596, caption: 'Big Buck Bunny — animated short' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', thumb: 'https://images.pexels.com/photos/4577793/pexels-photo-4577793.jpeg', dur: 653, caption: 'Elephants Dream' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', thumb: 'https://images.pexels.com/photos/355288/pexels-photo-355288.jpeg', dur: 15, caption: 'For Bigger Blazes' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4', thumb: 'https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg', dur: 15, caption: 'For Bigger Escapes' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4', thumb: 'https://images.pexels.com/photos/1170412/pexels-photo-1170412.jpeg', dur: 60, caption: 'For Bigger Fun' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4', thumb: 'https://images.pexels.com/photos/3422964/pexels-photo-3422964.jpeg', dur: 15, caption: 'For Bigger Joyrides' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4', thumb: 'https://images.pexels.com/photos/3052361/pexels-photo-3052361.jpeg', dur: 15, caption: 'For Bigger Meltdowns' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', thumb: 'https://images.pexels.com/photos/1308881/pexels-photo-1308881.jpeg', dur: 888, caption: 'Sintel — open movie' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4', thumb: 'https://images.pexels.com/photos/1592384/pexels-photo-1592384.jpeg', dur: 60, caption: 'Subaru Outback test drive' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', thumb: 'https://images.pexels.com/photos/2387418/pexels-photo-2387418.jpeg', dur: 734, caption: 'Tears of Steel' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4', thumb: 'https://images.pexels.com/photos/1149831/pexels-photo-1149831.jpeg', dur: 60, caption: 'Volkswagen GTI Review' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4', thumb: 'https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg', dur: 47, caption: 'We Are Going On Bullrun' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4', thumb: 'https://images.pexels.com/photos/3729464/pexels-photo-3729464.jpeg', dur: 25, caption: 'What car for a grand?' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', thumb: 'https://images.pexels.com/photos/2832382/pexels-photo-2832382.jpeg', dur: 596, caption: 'Bunny encore' },
  { url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', thumb: 'https://images.pexels.com/photos/1308881/pexels-photo-1308881.jpeg', dur: 888, caption: 'Sintel encore' },
];

const SAMPLE_USERS = [
  { name: 'Alice Walker', phone: '+447911000001', isBot: false },
  { name: 'Ben Carter', phone: '+447911000002', isBot: false },
  { name: 'Chloe Evans', phone: '+447911000003', isBot: false },
  { name: 'Daniel Foster', phone: '+447911000004', isBot: false },
  { name: 'Emma Gold', phone: '+447911000005', isBot: false },
  { name: 'Felix Hart', phone: '+447911000006', isBot: false },
  { name: 'Grace Iverson', phone: '+447911000007', isBot: false },
  { name: 'Henry Johansson', phone: '+447911000008', isBot: false },
  { name: 'Bot Marley', phone: '+447911900001', isBot: true },
  { name: 'Bot Dylan', phone: '+447911900002', isBot: true },
];

const SAMPLE_POSTS = [
  'Just discovered the best coffee shop in Shoreditch ☕',
  'Anyone else watching the sunset over the Thames tonight?',
  'Marathon training: 10k done, 32k to go.',
  'Looking for a chess buddy in Camden — DM me.',
  'New album drop tomorrow. Stay tuned.',
  'Rainy Sunday in London = pub roast and a film.',
  'Vegan tacos at Borough Market — life-changing.',
  'Anyone got recommendations for Lisbon weekend trip?',
  'Made it to the top of Primrose Hill at sunrise. Worth it.',
  'Open mic night Friday @ Brixton — bring your own lyrics.',
];

const SAMPLE_PRODUCTS = [
  { title: 'Vintage Leica M3 camera', desc: 'Excellent condition, includes 50mm lens. Tested.', price: 75000, condition: ProductCondition.GOOD },
  { title: 'IKEA Poäng armchair', desc: 'Birch veneer, beige cushion. Almost new.', price: 6500, condition: ProductCondition.LIKE_NEW },
  { title: 'Brompton M6L folding bike', desc: '2024 model, racing green. Light scratches.', price: 95000, condition: ProductCondition.GOOD },
  { title: 'Pile of vinyl records (50)', desc: 'Mostly 70s rock. All sleeves intact.', price: 8000, condition: ProductCondition.GOOD },
  { title: 'AeroPress coffee maker', desc: 'New in box. Original packaging.', price: 3500, condition: ProductCondition.NEW },
  { title: 'Dyson V11 vacuum', desc: 'Cordless, all attachments included. 1 year old.', price: 24000, condition: ProductCondition.LIKE_NEW },
  { title: 'Stack of cookbooks', desc: 'Ottolenghi, Nigella, Hugh F-W. 12 books.', price: 4500, condition: ProductCondition.GOOD },
  { title: 'Gibson Les Paul Studio (2018)', desc: 'Wine red, with hard case. Pro setup.', price: 120000, condition: ProductCondition.GOOD },
];

// London-area coordinates
const LONDON_POINTS = [
  { latitude: 51.5074, longitude: -0.1278 }, // central
  { latitude: 51.5234, longitude: -0.0858 }, // shoreditch
  { latitude: 51.5419, longitude: -0.1408 }, // primrose hill
  { latitude: 51.4626, longitude: -0.1146 }, // brixton
  { latitude: 51.4777, longitude: -0.0015 }, // greenwich
  { latitude: 51.5394, longitude: -0.1432 }, // camden
];

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule, { logger: ['error', 'warn', 'log'] });
  const em = app.get(EntityManager).fork();

  const existingCount = await em.count(User);
  if (existingCount > 0) {
    console.log(`[seed] Skipping — ${existingCount} users already exist. Truncate to re-seed.`);
    await app.close();
    return;
  }

  const summary = { users: 0, videos: 0, posts: 0, products: 0, waves: 0 };

  await em.transactional(async (tem) => {
    // Users
    const users: User[] = SAMPLE_USERS.map((u) => {
      const user = tem.create(User, {
        name: u.name,
        phone: u.phone,
        isBot: u.isBot,
        role: Role.USER,
        status: UserStatus.ACTIVE,
        avatarUrl: `https://i.pravatar.cc/300?u=${encodeURIComponent(u.phone)}`,
      });
      return user;
    });
    summary.users = users.length;

    // Videos — round-robin creators
    const videos: Video[] = SAMPLE_VIDEOS.map((v, i) => {
      const creator = users[i % users.length];
      return tem.create(Video, {
        creator,
        videoUrl: v.url,
        thumbnailUrl: v.thumb,
        durationSeconds: v.dur,
        caption: v.caption,
        status: ContentStatus.ACTIVE,
        visibility: Visibility.PUBLIC,
        tier: ContentTier.FREE,
      }, { partial: true });
    });
    summary.videos = videos.length;

    // Posts
    const posts: Post[] = SAMPLE_POSTS.map((text, i) => {
      const creator = users[i % users.length];
      return tem.create(Post, {
        creator,
        text,
        subType: PostSubType.STANDARD,
        status: ContentStatus.ACTIVE,
        visibility: Visibility.PUBLIC,
        tier: ContentTier.FREE,
      }, { partial: true });
    });
    summary.posts = posts.length;

    // Products
    const products: Product[] = SAMPLE_PRODUCTS.map((p, i) => {
      const creator = users[i % users.length];
      return tem.create(Product, {
        creator,
        title: p.title,
        description: p.desc,
        priceCents: p.price,
        currency: 'GBP',
        condition: p.condition,
        status: ContentStatus.ACTIVE,
        visibility: Visibility.PUBLIC,
        tier: ContentTier.FREE,
      }, { partial: true });
    });
    summary.products = products.length;

    await tem.flush();

    // Waves — between distinct user pairs, with PostGIS implied via creator's last_location
    // Wave entity has fromUser + toUser, no location field — keep simple
    const waves: Wave[] = [];
    for (let i = 0; i < 5; i++) {
      const fromUser = users[i];
      const toUser = users[(i + 3) % users.length];
      const wave = tem.create(Wave, {
        fromUser,
        toUser,
        message: `Hey ${toUser.name.split(' ')[0]}, saw you nearby!`,
        status: i % 2 === 0 ? WaveStatus.PENDING : WaveStatus.ACCEPTED,
      });
      waves.push(wave);
    }
    summary.waves = waves.length;

    // Set last_location on a few users so /yoyo/nearby has data
    users.slice(0, LONDON_POINTS.length).forEach((u, i) => {
      u.lastLocation = LONDON_POINTS[i];
    });

    await tem.flush();
  });

  console.log('\n[seed] Done:');
  console.table(summary);
  await app.close();
}

bootstrap().catch((err) => {
  console.error('[seed] FAILED:', err);
  process.exit(1);
});
