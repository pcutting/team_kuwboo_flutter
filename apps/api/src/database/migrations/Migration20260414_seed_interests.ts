import { Migration } from '@mikro-orm/migrations';

/**
 * Seed ~30 starter interests spanning 10 categories.
 *
 * UUIDs are hardcoded so the seed is idempotent across environments
 * (dev, staging, production) — downstream code can reliably reference
 * seeded interests by slug OR id if ever needed.
 *
 * Use `ON CONFLICT (slug) DO NOTHING` so re-running on an env that
 * already has some of these rows (e.g. if a partial migration was
 * applied) will not fail.
 */
export class Migration20260414SeedInterests extends Migration {
  override async up(): Promise<void> {
    const rows: Array<{
      id: string;
      slug: string;
      label: string;
      category: string;
      order: number;
    }> = [
      // Music (0-2)
      { id: '10000000-0000-4000-8000-000000000001', slug: 'music-live', label: 'Live Music', category: 'music', order: 0 },
      { id: '10000000-0000-4000-8000-000000000002', slug: 'music-production', label: 'Music Production', category: 'music', order: 1 },
      { id: '10000000-0000-4000-8000-000000000003', slug: 'music-djing', label: 'DJing', category: 'music', order: 2 },

      // Sports (10-12)
      { id: '10000000-0000-4000-8000-000000000011', slug: 'sports-football', label: 'Football', category: 'sports', order: 10 },
      { id: '10000000-0000-4000-8000-000000000012', slug: 'sports-basketball', label: 'Basketball', category: 'sports', order: 11 },
      { id: '10000000-0000-4000-8000-000000000013', slug: 'sports-running', label: 'Running', category: 'sports', order: 12 },

      // Food (20-22)
      { id: '10000000-0000-4000-8000-000000000021', slug: 'food-cooking', label: 'Cooking', category: 'food', order: 20 },
      { id: '10000000-0000-4000-8000-000000000022', slug: 'food-baking', label: 'Baking', category: 'food', order: 21 },
      { id: '10000000-0000-4000-8000-000000000023', slug: 'food-restaurants', label: 'Restaurants', category: 'food', order: 22 },

      // Travel (30-32)
      { id: '10000000-0000-4000-8000-000000000031', slug: 'travel-backpacking', label: 'Backpacking', category: 'travel', order: 30 },
      { id: '10000000-0000-4000-8000-000000000032', slug: 'travel-city-breaks', label: 'City Breaks', category: 'travel', order: 31 },
      { id: '10000000-0000-4000-8000-000000000033', slug: 'travel-roadtrips', label: 'Road Trips', category: 'travel', order: 32 },

      // Tech (40-42)
      { id: '10000000-0000-4000-8000-000000000041', slug: 'tech-coding', label: 'Coding', category: 'tech', order: 40 },
      { id: '10000000-0000-4000-8000-000000000042', slug: 'tech-ai', label: 'AI & ML', category: 'tech', order: 41 },
      { id: '10000000-0000-4000-8000-000000000043', slug: 'tech-gadgets', label: 'Gadgets', category: 'tech', order: 42 },

      // Arts (50-52)
      { id: '10000000-0000-4000-8000-000000000051', slug: 'arts-photography', label: 'Photography', category: 'arts', order: 50 },
      { id: '10000000-0000-4000-8000-000000000052', slug: 'arts-painting', label: 'Painting', category: 'arts', order: 51 },
      { id: '10000000-0000-4000-8000-000000000053', slug: 'arts-film', label: 'Film & Cinema', category: 'arts', order: 52 },

      // Wellness (60-62)
      { id: '10000000-0000-4000-8000-000000000061', slug: 'wellness-yoga', label: 'Yoga', category: 'wellness', order: 60 },
      { id: '10000000-0000-4000-8000-000000000062', slug: 'wellness-meditation', label: 'Meditation', category: 'wellness', order: 61 },
      { id: '10000000-0000-4000-8000-000000000063', slug: 'wellness-fitness', label: 'Fitness', category: 'wellness', order: 62 },

      // Gaming (70-72)
      { id: '10000000-0000-4000-8000-000000000071', slug: 'gaming-console', label: 'Console Gaming', category: 'gaming', order: 70 },
      { id: '10000000-0000-4000-8000-000000000072', slug: 'gaming-pc', label: 'PC Gaming', category: 'gaming', order: 71 },
      { id: '10000000-0000-4000-8000-000000000073', slug: 'gaming-esports', label: 'Esports', category: 'gaming', order: 72 },

      // Pets (80-82)
      { id: '10000000-0000-4000-8000-000000000081', slug: 'pets-dogs', label: 'Dogs', category: 'pets', order: 80 },
      { id: '10000000-0000-4000-8000-000000000082', slug: 'pets-cats', label: 'Cats', category: 'pets', order: 81 },
      { id: '10000000-0000-4000-8000-000000000083', slug: 'pets-exotic', label: 'Exotic Pets', category: 'pets', order: 82 },

      // Outdoors (90-92)
      { id: '10000000-0000-4000-8000-000000000091', slug: 'outdoors-hiking', label: 'Hiking', category: 'outdoors', order: 90 },
      { id: '10000000-0000-4000-8000-000000000092', slug: 'outdoors-camping', label: 'Camping', category: 'outdoors', order: 91 },
      { id: '10000000-0000-4000-8000-000000000093', slug: 'outdoors-climbing', label: 'Climbing', category: 'outdoors', order: 92 },
    ];

    for (const r of rows) {
      this.addSql(
        `insert into "interests" ("id", "slug", "label", "category", "display_order", "is_active")
         values ('${r.id}', '${r.slug}', '${r.label.replace(/'/g, "''")}', '${r.category}', ${r.order}, true)
         on conflict ("slug") do nothing;`,
      );
    }
  }

  override async down(): Promise<void> {
    this.addSql(`delete from "interests" where "id" like '10000000-0000-4000-8000-%';`);
  }
}
