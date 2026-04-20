import {
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import * as bcrypt from 'bcrypt';
import { User } from './entities/user.entity';
import { SessionsService } from '../sessions/sessions.service';
import { AdminAuditService } from '../admin/admin-audit.service';
import { Content } from '../content/entities/content.entity';
import { Comment } from '../comments/entities/comment.entity';
import { Message } from '../messaging/entities/message.entity';
import { ThreadParticipant } from '../messaging/entities/thread-participant.entity';
import { UserConsent } from '../consent/entities/user-consent.entity';
import { Bid } from '../marketplace/entities/bid.entity';
import { SellerRating } from '../marketplace/entities/seller-rating.entity';
import { SponsoredCampaign } from '../sponsored/entities/sponsored-campaign.entity';
import { Connection } from '../connections/entities/connection.entity';
import { Block } from '../connections/entities/block.entity';
import { Report } from '../reports/entities/report.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { NotificationPreference } from '../notifications/entities/notification-preference.entity';
import { Device } from '../devices/entities/device.entity';
import { Wave } from '../yoyo/entities/wave.entity';
import { YoyoOverride } from '../yoyo/entities/yoyo-override.entity';
import { InteractionEvent } from '../interactions/entities/interaction-event.entity';
import { InteractionState } from '../interactions/entities/interaction-state.entity';
import { Auction } from '../marketplace/entities/auction.entity';
import { Session } from '../sessions/entities/session.entity';
import { Verification } from '../verification/entities/verification.entity';
import { BotProfile } from '../bots/entities/bot-profile.entity';
import { BotActivityLog } from '../bots/entities/bot-activity-log.entity';
import { DeleteAccountDto } from './dto/delete-account.dto';
import {
  CampaignStatus,
  ContentStatus,
  ReportTargetType,
} from '../../common/enums';
import {
  ACCOUNT_ANONYMIZE_DELAY_MS,
  ACCOUNT_ANONYMIZE_QUEUE,
  AccountAnonymizeJob,
} from './workers/account-anonymize.queue';

/**
 * Credential-verification outcome. Kept as a small enum so the
 * controller doesn't need to know the difference between "no password
 * on file" (SSO-only path, always OK once freshness passes) and
 * "password matched".
 */
type CredentialCheck = 'sso_only' | 'password_matched';

/**
 * Self-service account lifecycle. Two public entry points:
 *
 *   - `softDelete` — `DELETE /users/me`. Sets `deletedAt` on the user
 *     row, revokes all active sessions, soft-deletes their authored
 *     Content, cancels any running sponsored campaigns, and schedules
 *     a 30-day BullMQ job to anonymize PII. Everything else is kept
 *     so the user can restore if we ever expose a reactivation flow
 *     within the grace period (not in M3 scope).
 *
 *   - `hardPurge` — `POST /users/me/purge`. Full GDPR erasure right
 *     now: deep-cascade delete every dependent row (see the cascade
 *     map in PR body), then delete the user row. One transaction, so
 *     a failure mid-way rolls back and the caller can retry.
 *
 * Both flows:
 *   - require a `FreshTokenGuard`-approved request (JWT iat < 15min),
 *   - re-verify the password via bcrypt if the user has one,
 *   - write an AdminAuditLog row attributed to the user themself (the
 *     audit entity's adminUser FK is SET NULL on delete so the row
 *     survives a hard-purge in anonymous form, and `targetId` is the
 *     plain uuid — not an FK — so it stays valid after the row is
 *     gone).
 */
@Injectable()
export class AccountService {
  private readonly logger = new Logger(AccountService.name);

  constructor(
    private readonly em: EntityManager,
    private readonly sessionsService: SessionsService,
    private readonly adminAuditService: AdminAuditService,
    @InjectQueue(ACCOUNT_ANONYMIZE_QUEUE)
    private readonly anonymizeQueue: Queue<AccountAnonymizeJob>,
  ) {}

  async softDelete(
    userId: string,
    ipAddress: string | undefined,
    dto: DeleteAccountDto,
  ): Promise<void> {
    const user = await this.loadUserOrThrow(userId);
    const credentialCheck = await this.verifyDeletionCredential(user, dto);

    // Write the audit log FIRST. On soft-delete the user row is not
    // going anywhere, but we keep the ordering identical to hardPurge
    // so this code path is a subset of that one.
    await this.adminAuditService.log(
      user.id,
      'USER_DELETE_SELF',
      'user',
      user.id,
      {
        credentialCheck,
        hadPassword: Boolean(user.passwordHash),
      },
      ipAddress,
    );

    await this.em.transactional(async (em) => {
      // 1. Flip the soft-delete marker on the user.
      const managed = await em.findOneOrFail(User, { id: user.id });
      const deletedAt = new Date();
      managed.deletedAt = deletedAt;

      // 2. Soft-delete authored content.
      //    We use `filters: { notDeleted: false }` so the @Filter on
      //    Content doesn't hide already-deleted rows from our sweep.
      const content = await em.find(
        Content,
        { creator: user.id },
        { filters: { notDeleted: false } },
      );
      const now = new Date();
      for (const c of content) {
        if (!c.deletedAt) c.deletedAt = now;
      }

      // 3. End any sponsored campaigns so the ad surface stops
      //    showing ads for a disappeared user. CampaignStatus.ENDED is
      //    the terminal state in the current enum — there's no
      //    distinct CANCELLED value today (see blueprint note; treat
      //    "advertiser soft-deleted" as a synonym for "ended").
      await em.nativeUpdate(
        SponsoredCampaign,
        { advertiser: user.id },
        { status: CampaignStatus.ENDED },
      );

      // 4. Null the author/sender FKs on content the user authored
      //    against OTHER users' content so the visible threads stay
      //    coherent immediately (the 30-day job would eventually do
      //    this too via SET NULL cascade, but mobile clients need the
      //    "[deleted user]" placeholder to show up right away).
      await em.nativeUpdate(
        Comment,
        { author: user.id, deletedAt: null },
        { author: null as never },
      );
      await em.nativeUpdate(
        Message,
        { sender: user.id },
        { sender: null as never },
      );

      // 5. Drop pure presence-tier rows (devices, sessions, waves,
      //    blocks, etc.) outright — they have no downstream audit
      //    value.
      await em.nativeDelete(Device, { user: user.id });
      await em.nativeDelete(NotificationPreference, { user: user.id });
      await em.nativeDelete(Notification, { user: user.id });
      await em.nativeDelete(InteractionEvent, { user: user.id });
      await em.nativeDelete(InteractionState, { user: user.id });
      await em.nativeDelete(Wave, {
        $or: [{ fromUser: user.id }, { toUser: user.id }],
      });
      await em.nativeDelete(YoyoOverride, {
        $or: [{ user: user.id }, { targetUser: user.id }],
      });
      await em.nativeDelete(Connection, {
        $or: [{ fromUser: user.id }, { toUser: user.id }],
      });
      await em.nativeDelete(Block, {
        $or: [{ blocker: user.id }, { blocked: user.id }],
      });
      await em.nativeDelete(ThreadParticipant, { user: user.id });
      await em.nativeDelete(Report, { reporter: user.id });

      // 6. Revoke every active session. The sessions service also
      //    drops the Socket.io connection out-of-band so the mobile
      //    client kicks back to the welcome screen.
      //    (Running inside the transaction is intentional — session
      //     revocation is the thing that makes this endpoint
      //     user-visible.)
      await em.flush();
    });

    await this.sessionsService.revokeAllForUser(
      user.id,
      'account_delete_self',
    );

    // 7. Schedule the 30-day anonymize job. BullMQ dedupes by jobId,
    //    so a repeat call with the same userId replaces the in-flight
    //    schedule rather than queuing a second wipe.
    const scheduledDeletedAt = new Date().toISOString();
    await this.anonymizeQueue.add(
      'anonymize',
      { userId: user.id, deletedAtIso: scheduledDeletedAt },
      {
        delay: ACCOUNT_ANONYMIZE_DELAY_MS,
        jobId: `anon-${user.id}`,
        removeOnComplete: true,
        removeOnFail: false,
      },
    );

    this.logger.log(
      `Soft-delete complete for user ${user.id} (credentialCheck=${credentialCheck}).`,
    );
  }

  async hardPurge(
    userId: string,
    ipAddress: string | undefined,
    dto: DeleteAccountDto,
  ): Promise<void> {
    const user = await this.loadUserOrThrow(userId);
    const credentialCheck = await this.verifyDeletionCredential(user, dto);

    // Write the audit row BEFORE the user row goes away. AdminAuditLog
    // stores `targetId` as a plain uuid, and `adminUser` has ON DELETE
    // SET NULL, so the row survives even when the user they describe
    // is gone.
    await this.adminAuditService.log(
      user.id,
      'USER_PURGE_SELF',
      'user',
      user.id,
      {
        credentialCheck,
        hadPassword: Boolean(user.passwordHash),
        username: user.username ?? null,
      },
      ipAddress,
    );

    // Revoke sessions first so any in-flight requests fail before we
    // start mutating their owner's data. (We could do this inside the
    // transaction, but session revocation fires a Socket.io kill as a
    // side effect and we don't want that to run if the transaction
    // rolls back mid-purge.)
    await this.sessionsService.revokeAllForUser(
      user.id,
      'account_purge_self',
    );

    await this.em.transactional(async (em) => {
      await this.purgeAllDependents(em, user.id, user.username);

      // Finally, the user row itself. CASCADE FKs (credentials,
      // trust_signals, user_preferences) drop alongside.
      const deleted = await em.nativeDelete(User, { id: user.id });
      if (deleted === 0) {
        throw new Error(`User ${user.id} vanished mid-purge`);
      }
    });

    this.logger.log(
      `Hard-purge complete for user ${userId} (credentialCheck=${credentialCheck}).`,
    );
  }

  /**
   * Loads the user bypassing the notDeleted filter. A user who has
   * already soft-deleted hitting `POST /users/me/purge` should still
   * succeed — they're exercising their right to be forgotten, not
   * reactivating.
   */
  private async loadUserOrThrow(userId: string): Promise<User> {
    const user = await this.em.findOne(
      User,
      { id: userId },
      { filters: { notDeleted: false } },
    );
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  /**
   * Fresh-token check is handled upstream by FreshTokenGuard. Here we
   * only re-check the password for accounts that have one. SSO-only
   * users (no passwordHash) fall through on the fresh-token alone.
   */
  private async verifyDeletionCredential(
    user: User,
    dto: DeleteAccountDto,
  ): Promise<CredentialCheck> {
    if (!user.passwordHash) {
      // SSO-only user. The FreshTokenGuard already proved the JWT is
      // < 15 min old. No further check available on the server side.
      return 'sso_only';
    }

    if (!dto.password) {
      throw new UnauthorizedException({
        code: 'password_required',
        message:
          'Password is required to delete an account with a password credential.',
      });
    }
    const matches = await bcrypt.compare(dto.password, user.passwordHash);
    if (!matches) {
      throw new UnauthorizedException({
        code: 'invalid_password',
        message: 'Password does not match.',
      });
    }
    return 'password_matched';
  }

  /**
   * Deep-purge everything that points at `userId` so the final
   * `DELETE FROM users` succeeds. Order is deliberate: deepest
   * descendants first, then their parents, so every intermediate row
   * already has all its dependents cleared when we get to it.
   *
   * Content-authored transitive sweep mirrors `scripts/delete_user.sh`
   * Stage 1. Keeping the list in code (instead of driving it off
   * `information_schema` like the shell script does) means a
   * schema-change PR has to update this method — we want that forcing
   * function so the cascade story stays in the ORM's face.
   */
  private async purgeAllDependents(
    em: EntityManager,
    userId: string,
    username?: string,
  ): Promise<void> {
    void username; // currently no username-keyed FKs; reserved for later

    // Step A: sweep rows that point at the user's content before the
    // content rows go away. The Content rows themselves will be
    // deleted in step C.
    const ownContent = await em.find(
      Content,
      { creator: userId },
      { fields: ['id'], filters: { notDeleted: false } },
    );
    const contentIds = ownContent.map((c) => c.id);
    if (contentIds.length > 0) {
      // Auctions under the user's products.
      const auctions = await em.find(
        Auction,
        { product: { $in: contentIds } },
        { fields: ['id'] },
      );
      const auctionIds = auctions.map((a) => a.id);
      if (auctionIds.length > 0) {
        await em.nativeDelete(Bid, { auction: { $in: auctionIds } });
        await em.nativeDelete(Auction, { id: { $in: auctionIds } });
      }

      // Interactions / tags / campaigns / ratings on the user's content.
      await em.nativeDelete(InteractionEvent, {
        content: { $in: contentIds },
      });
      await em.nativeDelete(InteractionState, {
        content: { $in: contentIds },
      });
      await em.nativeDelete(SponsoredCampaign, {
        content: { $in: contentIds },
      });
      await em.nativeDelete(SellerRating, { product: { $in: contentIds } });

      // Comments on the user's content (foreign author_id is handled
      // separately in step B).
      await em.nativeDelete(Comment, { content: { $in: contentIds } });

      // Reports pointing at the user's content have SET NULL already.
      await em.nativeUpdate(
        Report,
        { reportedContent: { $in: contentIds } },
        { reportedContent: null as never },
      );
    }

    // Step B: rows that reference the user directly. Comments authored
    // by the user are hard-deleted on purge (spec requirement).
    // Messages too.
    const authoredComments = await em.find(
      Comment,
      { author: userId },
      { fields: ['id'], filters: { notDeleted: false } },
    );
    const commentIds = authoredComments.map((c) => c.id);
    if (commentIds.length > 0) {
      await em.nativeUpdate(
        Report,
        { reportedComment: { $in: commentIds } },
        { reportedComment: null as never },
      );
      await em.nativeDelete(Comment, { id: { $in: commentIds } });
    }

    // Messages, interactions, notifications, devices, waves, etc.
    await em.nativeDelete(Message, { sender: userId });
    await em.nativeDelete(InteractionEvent, { user: userId });
    await em.nativeDelete(InteractionState, { user: userId });
    await em.nativeDelete(Notification, { user: userId });
    await em.nativeDelete(NotificationPreference, { user: userId });
    await em.nativeDelete(Device, { user: userId });
    await em.nativeDelete(ThreadParticipant, { user: userId });
    await em.nativeDelete(Wave, {
      $or: [{ fromUser: userId }, { toUser: userId }],
    });
    await em.nativeDelete(YoyoOverride, {
      $or: [{ user: userId }, { targetUser: userId }],
    });
    await em.nativeDelete(Connection, {
      $or: [{ fromUser: userId }, { toUser: userId }],
    });
    await em.nativeDelete(Block, {
      $or: [{ blocker: userId }, { blocked: userId }],
    });
    await em.nativeDelete(Verification, { identifier: userId }); // no-op for most
    await em.nativeDelete(Bid, { bidder: userId });
    await em.nativeDelete(SellerRating, {
      $or: [{ seller: userId }, { buyer: userId }],
    });

    // Reports authored by the user — hard-delete.
    await em.nativeDelete(Report, {
      reporter: userId,
      targetType: { $ne: ReportTargetType.USER },
    });
    await em.nativeDelete(Report, { reporter: userId });
    // Reports about the user — SET NULL already in schema, but drop
    // the rows on purge to keep the moderation queue clean.
    await em.nativeDelete(Report, { reportedUser: userId });

    // SponsoredCampaigns where the user is the advertiser.
    await em.nativeDelete(SponsoredCampaign, { advertiser: userId });

    // Bot profiles + their activity logs. Bot activity logs have FK
    // to bot_profiles, so delete activity logs first.
    const botProfiles = await em.find(
      BotProfile,
      { user: userId },
      { fields: ['id'] },
    );
    const botIds = botProfiles.map((b) => b.id);
    if (botIds.length > 0) {
      await em.nativeDelete(BotActivityLog, {
        botProfile: { $in: botIds },
      });
      await em.nativeDelete(BotProfile, { id: { $in: botIds } });
    }

    // UserConsent rows stay — FK is SET NULL per the new migration.
    await em.nativeUpdate(
      UserConsent,
      { user: userId },
      { user: null as never },
    );

    // Revoke sessions (the earlier SessionsService call revoked them
    // out-of-transaction; here we delete the Session rows so there's
    // nothing pointing at the user row).
    await em.nativeDelete(Session, { user: userId });

    // Finally, the user's own content. By now nothing else references
    // these rows.
    if (contentIds.length > 0) {
      await em.nativeUpdate(
        Content,
        { id: { $in: contentIds } },
        { status: ContentStatus.REMOVED, deletedAt: new Date() },
      );
      await em.nativeDelete(Content, { id: { $in: contentIds } });
    }
  }
}
