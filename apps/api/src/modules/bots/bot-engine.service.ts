import { Injectable, Logger } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { BotProfile, BotBehaviorConfig } from './entities/bot-profile.entity';
import { BotActivityLog } from './entities/bot-activity-log.entity';
import { User } from '../users/entities/user.entity';
import { Content } from '../content/entities/content.entity';
import { ContentService } from '../content/content.service';
import { InteractionsService } from '../interactions/interactions.service';
import { CommentsService } from '../comments/comments.service';
import { ConnectionsService } from '../connections/connections.service';
import { YoyoService } from '../yoyo/yoyo.service';
import { MessagingService } from '../messaging/messaging.service';
import { BotMovementService } from './bot-movement.service';
import { InteractionState } from '../interactions/entities/interaction-state.entity';
import { ThreadParticipant } from '../messaging/entities/thread-participant.entity';
import {
  ContentStatus,
  InteractionStateType,
  ConnectionStatus,
  ConnectionContext,
} from '../../common/enums';
import { Connection } from '../connections/entities/connection.entity';

export interface BotActionResult {
  actionType: string;
  targetId?: string;
  success: boolean;
  metadata?: Record<string, unknown>;
  errorMessage?: string;
}

@Injectable()
export class BotEngineService {
  private readonly logger = new Logger(BotEngineService.name);

  constructor(
    private readonly em: EntityManager,
    private readonly contentService: ContentService,
    private readonly interactionsService: InteractionsService,
    private readonly commentsService: CommentsService,
    private readonly connectionsService: ConnectionsService,
    private readonly yoyoService: YoyoService,
    private readonly messagingService: MessagingService,
    private readonly movementService: BotMovementService,
  ) {}

  async executeRandomAction(profile: BotProfile): Promise<BotActionResult> {
    const config = profile.behaviorConfig;
    const actionType = this.selectWeightedAction(config);

    let result: BotActionResult;
    try {
      switch (actionType) {
        case 'createPost':
          result = await this.doCreatePost(profile);
          break;
        case 'createVideo':
          result = await this.doCreateVideo(profile);
          break;
        case 'likeContent':
          result = await this.doLikeContent(profile);
          break;
        case 'commentOnContent':
          result = await this.doCommentOnContent(profile);
          break;
        case 'viewContent':
          result = await this.doViewContent(profile);
          break;
        case 'followUser':
          result = await this.doFollowUser(profile);
          break;
        case 'sendWave':
          result = await this.doSendWave(profile);
          break;
        case 'respondToWave':
          result = await this.doRespondToWave(profile);
          break;
        case 'moveLocation':
          result = await this.doMoveLocation(profile);
          break;
        case 'sendMessage':
          result = await this.doSendMessage(profile);
          break;
        default:
          result = { actionType, success: false, errorMessage: 'Unknown action type' };
      }
    } catch (error: any) {
      this.logger.warn(`Bot ${profile.id} action ${actionType} failed: ${error.message}`);
      result = {
        actionType,
        success: false,
        errorMessage: error.message?.slice(0, 255),
      };
    }

    // Log the action
    await this.logAction(profile, result);

    // Update profile counters
    profile.lastSimulatedAt = new Date();
    if (result.success) profile.totalActions++;
    await this.em.flush();

    return result;
  }

  private selectWeightedAction(config: BotBehaviorConfig): string {
    const weights = config.actionWeights;
    const entries = Object.entries(weights);
    const totalWeight = entries.reduce((sum, [, w]) => sum + w, 0);

    let random = Math.random() * totalWeight;
    for (const [action, weight] of entries) {
      random -= weight;
      if (random <= 0) return action;
    }
    return entries[0][0];
  }

  private async doCreatePost(profile: BotProfile): Promise<BotActionResult> {
    const config = profile.behaviorConfig;
    const templates = config.postTemplates;
    if (!templates.length) {
      return { actionType: 'createPost', success: false, errorMessage: 'No post templates' };
    }

    const text = templates[Math.floor(Math.random() * templates.length)];
    const location = profile.user.lastLocation;

    const post = await this.contentService.createPost(profile.user, {
      text,
      latitude: location?.latitude,
      longitude: location?.longitude,
    } as any);

    return {
      actionType: 'createPost',
      targetId: post.id,
      success: true,
      metadata: { text: text.slice(0, 100) },
    };
  }

  private async doCreateVideo(profile: BotProfile): Promise<BotActionResult> {
    const config = profile.behaviorConfig;
    const templates = config.videoTemplates;
    if (!templates || !templates.length) {
      return { actionType: 'createVideo', success: false, errorMessage: 'No video templates' };
    }

    const template = templates[Math.floor(Math.random() * templates.length)];
    const location = profile.user.lastLocation;

    const video = await this.contentService.createVideo(profile.user, {
      videoUrl: template.videoUrl,
      thumbnailUrl: template.thumbnailUrl,
      durationSeconds: template.durationSeconds,
      caption: template.caption,
      latitude: location?.latitude,
      longitude: location?.longitude,
    } as any);

    return {
      actionType: 'createVideo',
      targetId: video.id,
      success: true,
      metadata: {
        videoUrl: template.videoUrl,
        caption: template.caption?.slice(0, 100),
      },
    };
  }

  private async doLikeContent(profile: BotProfile): Promise<BotActionResult> {
    // Find content the bot hasn't liked yet
    const alreadyLiked = await this.em.find(InteractionState, {
      user: { id: profile.user.id },
      type: InteractionStateType.LIKE,
    }, { fields: ['content'], limit: 500 });

    const likedContentIds = alreadyLiked.map((s) => s.content.id);

    const where: any = { status: ContentStatus.ACTIVE };
    if (likedContentIds.length > 0) {
      where.id = { $nin: likedContentIds };
    }

    const candidates = await this.em.find(Content, where, {
      orderBy: { createdAt: 'DESC' },
      limit: 20,
    });

    if (!candidates.length) {
      return { actionType: 'likeContent', success: false, errorMessage: 'No content to like' };
    }

    const content = candidates[Math.floor(Math.random() * candidates.length)];
    await this.interactionsService.toggleLike(profile.user.id, content.id);

    return {
      actionType: 'likeContent',
      targetId: content.id,
      success: true,
    };
  }

  private async doCommentOnContent(profile: BotProfile): Promise<BotActionResult> {
    const config = profile.behaviorConfig;
    const templates = config.commentTemplates;
    if (!templates.length) {
      return { actionType: 'commentOnContent', success: false, errorMessage: 'No comment templates' };
    }

    const candidates = await this.em.find(Content, { status: ContentStatus.ACTIVE }, {
      orderBy: { createdAt: 'DESC' },
      limit: 20,
    });

    if (!candidates.length) {
      return { actionType: 'commentOnContent', success: false, errorMessage: 'No content to comment on' };
    }

    const content = candidates[Math.floor(Math.random() * candidates.length)];
    const text = templates[Math.floor(Math.random() * templates.length)];

    const comment = await this.commentsService.create(profile.user.id, content.id, text);

    return {
      actionType: 'commentOnContent',
      targetId: comment.id,
      success: true,
      metadata: { contentId: content.id, text: text.slice(0, 100) },
    };
  }

  private async doViewContent(profile: BotProfile): Promise<BotActionResult> {
    const candidates = await this.em.find(Content, { status: ContentStatus.ACTIVE }, {
      orderBy: { createdAt: 'DESC' },
      limit: 30,
    });

    if (!candidates.length) {
      return { actionType: 'viewContent', success: false, errorMessage: 'No content to view' };
    }

    const content = candidates[Math.floor(Math.random() * candidates.length)];
    await this.interactionsService.logView(profile.user.id, content.id);

    return {
      actionType: 'viewContent',
      targetId: content.id,
      success: true,
    };
  }

  private async doFollowUser(profile: BotProfile): Promise<BotActionResult> {
    // Find users the bot doesn't already follow
    const alreadyFollowing = await this.em.find(Connection, {
      fromUser: { id: profile.user.id },
      context: ConnectionContext.FOLLOW,
      status: ConnectionStatus.ACTIVE,
    }, { fields: ['toUser'], limit: 500 });

    const followingIds = alreadyFollowing.map((c) => c.toUser.id);
    followingIds.push(profile.user.id); // Exclude self

    const candidates = await this.em.find(User, {
      id: { $nin: followingIds },
      status: 'ACTIVE' as any,
      deletedAt: null,
    }, { limit: 20 });

    if (!candidates.length) {
      return { actionType: 'followUser', success: false, errorMessage: 'No users to follow' };
    }

    const target = candidates[Math.floor(Math.random() * candidates.length)];

    try {
      await this.connectionsService.follow(profile.user.id, target.id);
    } catch {
      return { actionType: 'followUser', success: false, errorMessage: 'Already following or conflict' };
    }

    return {
      actionType: 'followUser',
      targetId: target.id,
      success: true,
      metadata: { targetName: target.name },
    };
  }

  private async doSendWave(profile: BotProfile): Promise<BotActionResult> {
    const location = profile.user.lastLocation;
    if (!location) {
      return { actionType: 'sendWave', success: false, errorMessage: 'Bot has no location' };
    }

    const nearbyUsers = await this.yoyoService.getNearbyUsers(
      profile.user.id,
      location.latitude,
      location.longitude,
    );

    if (!nearbyUsers.length) {
      return { actionType: 'sendWave', success: false, errorMessage: 'No nearby users' };
    }

    const target = nearbyUsers[Math.floor(Math.random() * nearbyUsers.length)];
    const config = profile.behaviorConfig;
    const message = config.waveMessages.length
      ? config.waveMessages[Math.floor(Math.random() * config.waveMessages.length)]
      : undefined;

    try {
      const wave = await this.yoyoService.sendWave(profile.user.id, target.id, message);
      return {
        actionType: 'sendWave',
        targetId: wave.id,
        success: true,
        metadata: { toUserId: target.id, message },
      };
    } catch {
      return { actionType: 'sendWave', success: false, errorMessage: 'Wave failed (blocked or pending)' };
    }
  }

  private async doRespondToWave(profile: BotProfile): Promise<BotActionResult> {
    const waves = await this.yoyoService.getIncomingWaves(profile.user.id);
    if (!waves.length) {
      return { actionType: 'respondToWave', success: false, errorMessage: 'No incoming waves' };
    }

    const wave = waves[0];
    // Acceptance rate varies by persona
    const acceptanceRates: Record<string, number> = {
      social_butterfly: 0.9,
      content_creator: 0.6,
      lurker: 0.2,
      explorer: 0.7,
      shopper: 0.5,
    };
    const rate = acceptanceRates[profile.displayPersona] ?? 0.5;
    const accept = Math.random() < rate;

    await this.yoyoService.respondToWave(wave.id, profile.user.id, accept);

    return {
      actionType: 'respondToWave',
      targetId: wave.id,
      success: true,
      metadata: { accepted: accept, fromUserId: wave.fromUser.id },
    };
  }

  private async doMoveLocation(profile: BotProfile): Promise<BotActionResult> {
    const current = profile.user.lastLocation;
    const home = profile.homeLocation;
    if (!current || !home) {
      return { actionType: 'moveLocation', success: false, errorMessage: 'Missing location data' };
    }

    const timeSinceLastMove = profile.lastSimulatedAt
      ? Date.now() - profile.lastSimulatedAt.getTime()
      : 60_000;

    const config = profile.behaviorConfig;
    const next = this.movementService.calculateNextPosition(
      current,
      home,
      profile.roamRadiusKm,
      config.movementStyle,
      config.movementSpeedKmH,
      timeSinceLastMove,
    );

    await this.yoyoService.updateLocation(profile.user.id, next.latitude, next.longitude);

    return {
      actionType: 'moveLocation',
      success: true,
      metadata: {
        from: { lat: current.latitude, lng: current.longitude },
        to: { lat: next.latitude, lng: next.longitude },
      },
    };
  }

  private async doSendMessage(profile: BotProfile): Promise<BotActionResult> {
    // Find threads the bot participates in
    const participations = await this.em.find(ThreadParticipant, {
      user: profile.user.id,
    }, { populate: ['thread'], limit: 10 });

    if (!participations.length) {
      return { actionType: 'sendMessage', success: false, errorMessage: 'No threads' };
    }

    const tp = participations[Math.floor(Math.random() * participations.length)];
    const config = profile.behaviorConfig;
    const text = config.commentTemplates.length
      ? config.commentTemplates[Math.floor(Math.random() * config.commentTemplates.length)]
      : 'Hey!';

    const message = await this.messagingService.sendMessage(
      profile.user,
      tp.thread.id,
      { text } as any,
    );

    return {
      actionType: 'sendMessage',
      targetId: message.id,
      success: true,
      metadata: { threadId: tp.thread.id, text: text.slice(0, 100) },
    };
  }

  private async logAction(profile: BotProfile, result: BotActionResult): Promise<void> {
    this.em.create(BotActivityLog, {
      botProfile: profile,
      actionType: result.actionType,
      targetId: result.targetId,
      metadata: result.metadata,
      success: result.success,
      errorMessage: result.errorMessage?.slice(0, 255),
    } as any);
    await this.em.flush();
  }
}
