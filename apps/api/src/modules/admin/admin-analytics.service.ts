import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { User } from '../users/entities/user.entity';
import { Content } from '../content/entities/content.entity';
import { Comment } from '../comments/entities/comment.entity';
import { Connection } from '../connections/entities/connection.entity';
import { Wave } from '../yoyo/entities/wave.entity';
import { InteractionState } from '../interactions/entities/interaction-state.entity';
import { InteractionEvent } from '../interactions/entities/interaction-event.entity';
import { Session } from '../sessions/entities/session.entity';
import { ContentType, InteractionStateType, InteractionEventType } from '../../common/enums';

@Injectable()
export class AdminAnalyticsService {
  constructor(private readonly em: EntityManager) {}

  async getGrowthMetrics(days: number): Promise<{ date: string; count: number }[]> {
    const knex = this.em.getKnex();

    const rows = await knex('users')
      .select(knex.raw("DATE(created_at) as date"))
      .count('* as count')
      .where('created_at', '>=', knex.raw(`NOW() - INTERVAL '${days} days'`))
      .groupByRaw('DATE(created_at)')
      .orderByRaw('DATE(created_at) ASC');

    return rows.map((row: any) => ({
      date: row.date instanceof Date
        ? row.date.toISOString().split('T')[0]
        : String(row.date),
      count: Number(row.count),
    }));
  }

  async getEngagementMetrics(): Promise<Record<string, number>> {
    const [
      totalContent,
      totalPosts,
      totalVideos,
      totalProducts,
      totalComments,
      totalLikes,
      totalViews,
      totalWaves,
      totalConnections,
    ] = await Promise.all([
      this.em.count(Content, {}, { filters: { notDeleted: false } }),
      this.em.count(Content, { type: ContentType.POST }, { filters: { notDeleted: false } }),
      this.em.count(Content, { type: ContentType.VIDEO }, { filters: { notDeleted: false } }),
      this.em.count(Content, { type: ContentType.PRODUCT }, { filters: { notDeleted: false } }),
      this.em.count(Comment, {}, { filters: { notDeleted: false } }),
      this.em.count(InteractionState, { type: InteractionStateType.LIKE }),
      this.em.count(InteractionEvent, { type: InteractionEventType.VIEW }),
      this.em.count(Wave, {}),
      this.em.count(Connection, {}),
    ]);

    return {
      totalContent,
      totalPosts,
      totalVideos,
      totalProducts,
      totalComments,
      totalLikes,
      totalViews,
      totalWaves,
      totalConnections,
    };
  }

  async getContentBreakdown(): Promise<{
    byType: Record<string, number>;
    byStatus: Record<string, number>;
  }> {
    const knex = this.em.getKnex();

    const byTypeRows = await knex('content')
      .select('type')
      .count('* as count')
      .groupBy('type');

    const byStatusRows = await knex('content')
      .select('status')
      .count('* as count')
      .groupBy('status');

    const byType: Record<string, number> = {};
    for (const row of byTypeRows) {
      byType[row.type] = Number(row.count);
    }

    const byStatus: Record<string, number> = {};
    for (const row of byStatusRows) {
      byStatus[row.status] = Number(row.count);
    }

    return { byType, byStatus };
  }

  async getActiveUsers(days: number): Promise<{ activeUsers: number }> {
    const knex = this.em.getKnex();
    const cutoff = knex.raw(`NOW() - INTERVAL '${days} days'`);

    const result = await knex.raw(`
      SELECT COUNT(DISTINCT user_id) as count FROM (
        SELECT creator_id as user_id FROM content WHERE created_at >= ${cutoff}
        UNION
        SELECT author_id as user_id FROM comments WHERE created_at >= ${cutoff}
        UNION
        SELECT user_id FROM interaction_states WHERE created_at >= ${cutoff}
        UNION
        SELECT user_id FROM interaction_events WHERE created_at >= ${cutoff}
      ) active
    `);

    return { activeUsers: Number(result.rows[0]?.count ?? 0) };
  }

  async getSessionStats(): Promise<{
    totalActiveSessions: number;
    sessionsByPlatform: Record<string, number>;
  }> {
    const totalActiveSessions = await this.em.count(Session, {
      isRevoked: false,
      expiresAt: { $gt: new Date() },
    });

    const knex = this.em.getKnex();

    const rows = await knex('sessions')
      .select('user_agent')
      .count('* as count')
      .where('is_revoked', false)
      .andWhere('expires_at', '>', new Date())
      .groupBy('user_agent');

    const sessionsByPlatform: Record<string, number> = {};
    for (const row of rows) {
      const platform = this.parseUserAgentPlatform(row.user_agent);
      sessionsByPlatform[platform] = (sessionsByPlatform[platform] ?? 0) + Number(row.count);
    }

    return { totalActiveSessions, sessionsByPlatform };
  }

  private parseUserAgentPlatform(userAgent?: string): string {
    if (!userAgent) return 'unknown';
    const ua = userAgent.toLowerCase();
    if (ua.includes('iphone') || ua.includes('ipad') || ua.includes('ios')) return 'iOS';
    if (ua.includes('android')) return 'Android';
    if (ua.includes('windows')) return 'Windows';
    if (ua.includes('mac')) return 'macOS';
    if (ua.includes('linux')) return 'Linux';
    return 'other';
  }
}
