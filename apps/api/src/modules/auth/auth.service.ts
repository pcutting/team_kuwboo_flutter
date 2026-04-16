import {
  BadRequestException,
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'crypto';
import * as jwt from 'jsonwebtoken';
import { OAuth2Client } from 'google-auth-library';
import { UsersService } from '../users/users.service';
import { SessionsService } from '../sessions/sessions.service';
import { VerificationService } from '../verification/verification.service';
import { AppleJwksService } from './apple/apple-jwks.service';
import { CredentialsService } from '../credentials/credentials.service';
import { TrustService } from '../trust/trust.service';
import { User } from '../users/entities/user.entity';
import { CredentialType, OnboardingProgress, TrustSignalType } from '../../common/enums';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
  isNewUser: boolean;
}

export interface EmailOwnedChallenge {
  status: 'email_owned';
  challengeId: string;
  email: string;
}

@Injectable()
export class AuthService {
  private readonly googleClient: OAuth2Client;

  /**
   * In-memory store for the short-lived SSO prove-ownership challenges.
   * This is deliberately ephemeral — challenges live 10 minutes, and
   * losing them on API restart is acceptable (user retries SSO). For
   * multi-instance deployments this will move to Redis in D3.
   */
  private readonly emailOwnedChallenges = new Map<
    string,
    {
      email: string;
      provider: CredentialType.GOOGLE | CredentialType.APPLE;
      providerSub: string;
      providerData: Record<string, unknown>;
      targetUserId: string;
      createdAt: number;
    }
  >();

  constructor(
    private readonly config: ConfigService,
    private readonly jwtService: JwtService,
    private readonly usersService: UsersService,
    private readonly sessionsService: SessionsService,
    private readonly verificationService: VerificationService,
    private readonly appleJwks: AppleJwksService,
    private readonly credentialsService: CredentialsService,
    private readonly trustService: TrustService,
  ) {
    this.googleClient = new OAuth2Client();
  }

  async sendPhoneOtp(phone: string): Promise<{ devCode?: string }> {
    return this.verificationService.sendPhoneOtp(phone);
  }

  async sendEmailOtp(email: string): Promise<{ devCode?: string }> {
    return this.verificationService.sendEmailOtp(this.normaliseEmail(email));
  }

  async verifyPhoneOtp(
    phone: string,
    code: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    await this.verificationService.verifyPhoneOtp(phone, code);

    let user: User;
    let isNewUser = false;
    const existingCredential = await this.credentialsService.findByIdentity(
      CredentialType.PHONE,
      phone,
    );

    if (existingCredential) {
      user = existingCredential.user;
      await this.credentialsService.markUsed(existingCredential.id);
    } else {
      user = await this.usersService.create({
        phone,
        name: phone,
        onboardingProgress: OnboardingProgress.OTP,
      } as any);
      await this.credentialsService.attach({
        userId: user.id,
        type: CredentialType.PHONE,
        identifier: phone,
      });
      await this.trustService.append({
        userId: user.id,
        type: TrustSignalType.PHONE_VERIFIED_MOBILE,
        delta: 40,
        source: 'onboarding',
      });
      isNewUser = true;
    }

    user.lastLoginAt = new Date();
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser };
  }

  async verifyEmailOtp(
    email: string,
    code: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    const normalised = this.normaliseEmail(email);
    await this.verificationService.verifyEmailOtp(normalised, code);

    let user: User;
    let isNewUser = false;
    const existingCredential = await this.credentialsService.findByIdentity(
      CredentialType.EMAIL,
      normalised,
    );

    if (existingCredential) {
      user = existingCredential.user;
      await this.credentialsService.markUsed(existingCredential.id);
    } else {
      user = await this.usersService.create({
        email: normalised,
        name: normalised,
        onboardingProgress: OnboardingProgress.OTP,
      } as any);
      await this.credentialsService.attach({
        userId: user.id,
        type: CredentialType.EMAIL,
        identifier: normalised,
      });
      await this.trustService.append({
        userId: user.id,
        type: TrustSignalType.EMAIL_VERIFIED,
        delta: 10,
        source: 'onboarding',
      });
      isNewUser = true;
    }

    user.lastLoginAt = new Date();
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser };
  }

  async googleLogin(
    idToken: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse | EmailOwnedChallenge> {
    const ticket = await this.googleClient.verifyIdToken({
      idToken,
      audience: this.config.get<string>('GOOGLE_CLIENT_ID'),
    });
    const payload = ticket.getPayload();
    if (!payload || !payload.sub) {
      throw new UnauthorizedException('Invalid Google token');
    }

    const email = payload.email ? this.normaliseEmail(payload.email) : undefined;

    const existing = await this.credentialsService.findByIdentity(
      CredentialType.GOOGLE,
      payload.sub,
    );

    if (existing) {
      await this.credentialsService.markUsed(existing.id);
      const user = existing.user;
      user.lastLoginAt = new Date();
      const tokens = await this.issueTokens(user, meta);
      return { ...tokens, user, isNewUser: false };
    }

    // No google credential. Check for an existing email credential.
    if (email) {
      const emailCred = await this.credentialsService.findByIdentity(
        CredentialType.EMAIL,
        email,
      );
      if (emailCred) {
        // Anti-takeover: require OTP on that email before attaching google.
        const challengeId = this.mintChallenge({
          email,
          provider: CredentialType.GOOGLE,
          providerSub: payload.sub,
          providerData: payload as unknown as Record<string, unknown>,
          targetUserId: emailCred.user.id,
        });
        await this.verificationService.sendEmailOtp(email);
        return { status: 'email_owned', challengeId, email };
      }
    }

    // First-time google user: create user + google credential (+ email if verified).
    const user = await this.usersService.create({
      name: payload.name || 'User',
      avatarUrl: payload.picture || undefined,
      onboardingProgress: OnboardingProgress.OTP,
    } as any);
    await this.credentialsService.attach({
      userId: user.id,
      type: CredentialType.GOOGLE,
      identifier: payload.sub,
      providerData: payload as unknown as Record<string, unknown>,
    });
    if (email && payload.email_verified) {
      await this.credentialsService.attach({
        userId: user.id,
        type: CredentialType.EMAIL,
        identifier: email,
      });
      await this.trustService.append({
        userId: user.id,
        type: TrustSignalType.EMAIL_VERIFIED,
        delta: 10,
        source: 'onboarding',
      });
    }
    await this.trustService.append({
      userId: user.id,
      type: TrustSignalType.SSO_GOOGLE_VERIFIED,
      delta: 5,
      source: 'onboarding',
    });

    user.lastLoginAt = new Date();
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser: true };
  }

  async googleConfirm(
    idToken: string,
    emailOtp: string,
    challengeId: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    return this.ssoConfirm('google', idToken, emailOtp, challengeId, meta);
  }

  async appleLogin(
    identityToken: string,
    authorizationCode: string | undefined,
    fullName?: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse | EmailOwnedChallenge> {
    const claims = await this.appleJwks.verify(identityToken);
    const email = claims.email ? this.normaliseEmail(claims.email) : undefined;

    const existing = await this.credentialsService.findByIdentity(
      CredentialType.APPLE,
      claims.sub,
    );
    if (existing) {
      await this.credentialsService.markUsed(existing.id);
      const user = existing.user;
      user.lastLoginAt = new Date();
      const tokens = await this.issueTokens(user, meta);
      return { ...tokens, user, isNewUser: false };
    }

    if (email) {
      const emailCred = await this.credentialsService.findByIdentity(
        CredentialType.EMAIL,
        email,
      );
      if (emailCred) {
        const challengeId = this.mintChallenge({
          email,
          provider: CredentialType.APPLE,
          providerSub: claims.sub,
          providerData: {
            ...(claims as unknown as Record<string, unknown>),
            authorizationCode,
          },
          targetUserId: emailCred.user.id,
        });
        await this.verificationService.sendEmailOtp(email);
        return { status: 'email_owned', challengeId, email };
      }
    }

    const user = await this.usersService.create({
      name: fullName || 'User',
      onboardingProgress: OnboardingProgress.OTP,
    } as any);
    await this.credentialsService.attach({
      userId: user.id,
      type: CredentialType.APPLE,
      identifier: claims.sub,
      providerData: {
        ...(claims as unknown as Record<string, unknown>),
        authorizationCode,
      },
    });
    if (email) {
      await this.credentialsService.attach({
        userId: user.id,
        type: CredentialType.EMAIL,
        identifier: email,
      });
      await this.trustService.append({
        userId: user.id,
        type: TrustSignalType.EMAIL_VERIFIED,
        delta: 10,
        source: 'onboarding',
      });
    }
    await this.trustService.append({
      userId: user.id,
      type: TrustSignalType.SSO_APPLE_VERIFIED,
      delta: 5,
      source: 'onboarding',
    });

    user.lastLoginAt = new Date();
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser: true };
  }

  async appleConfirm(
    identityToken: string,
    emailOtp: string,
    challengeId: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    return this.ssoConfirm('apple', identityToken, emailOtp, challengeId, meta);
  }

  async refreshTokens(
    userId: string,
    refreshToken: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthTokens> {
    const session = await this.sessionsService.findValidSession(userId);

    if (!session) {
      throw new UnauthorizedException('No valid session found');
    }

    const isValid = await this.sessionsService.validateRefreshToken(session, refreshToken);

    if (!isValid) {
      // Token theft: revoke family + append a trust signal.
      await this.sessionsService.revokeAllForUser(userId);
      await this.trustService.append({
        userId,
        type: TrustSignalType.REFRESH_REUSE_DETECTED,
        delta: -10,
        source: 'auth',
      });
      throw new UnauthorizedException({
        code: 'refresh_reuse_detected',
        message: 'Token reuse detected. All sessions revoked.',
      });
    }

    await this.sessionsService.revoke(session);
    const user = await this.usersService.findById(userId);
    return this.issueTokens(user, meta);
  }

  async logout(userId: string): Promise<void> {
    const session = await this.sessionsService.findValidSession(userId);
    if (session) await this.sessionsService.revoke(session);
  }

  /**
   * Dev-only login. Skips OTP entirely — find-or-creates a user by
   * phone and issues real JWTs. Gated at the controller level by
   * `DEV_LOGIN_ENABLED=1`. Never enable in production.
   */
  async devLogin(
    phone: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    let user = await this.usersService.findByPhone(phone);
    let isNewUser = false;
    if (!user) {
      user = await this.usersService.create({ phone, name: phone });
      isNewUser = true;
    }
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser };
  }

  private async ssoConfirm(
    provider: 'google' | 'apple',
    providerToken: string,
    emailOtp: string,
    challengeId: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    const challenge = this.emailOwnedChallenges.get(challengeId);
    if (!challenge) {
      throw new BadRequestException({
        code: 'invalid_challenge',
        message: 'Challenge expired or unknown.',
      });
    }
    if (Date.now() - challenge.createdAt > 10 * 60 * 1000) {
      this.emailOwnedChallenges.delete(challengeId);
      throw new BadRequestException({
        code: 'invalid_challenge',
        message: 'Challenge expired.',
      });
    }
    if (
      (provider === 'google' && challenge.provider !== CredentialType.GOOGLE) ||
      (provider === 'apple' && challenge.provider !== CredentialType.APPLE)
    ) {
      throw new BadRequestException({
        code: 'invalid_challenge',
        message: 'Challenge provider mismatch.',
      });
    }

    // Verify the provider token again — tokens may have been intercepted.
    let providerSub: string;
    if (provider === 'google') {
      const ticket = await this.googleClient.verifyIdToken({
        idToken: providerToken,
        audience: this.config.get<string>('GOOGLE_CLIENT_ID'),
      });
      const payload = ticket.getPayload();
      if (!payload?.sub) throw new UnauthorizedException('Invalid Google token');
      providerSub = payload.sub;
    } else {
      const claims = await this.appleJwks.verify(providerToken);
      providerSub = claims.sub;
    }
    if (providerSub !== challenge.providerSub) {
      throw new BadRequestException({
        code: 'invalid_challenge',
        message: 'Provider identity changed between challenge and confirm.',
      });
    }

    await this.verificationService.verifyEmailOtp(challenge.email, emailOtp);

    await this.credentialsService.attach({
      userId: challenge.targetUserId,
      type: challenge.provider,
      identifier: challenge.providerSub,
      providerData: challenge.providerData,
    });
    await this.trustService.append({
      userId: challenge.targetUserId,
      type:
        challenge.provider === CredentialType.GOOGLE
          ? TrustSignalType.SSO_GOOGLE_VERIFIED
          : TrustSignalType.SSO_APPLE_VERIFIED,
      delta: 5,
      source: 'onboarding',
    });

    this.emailOwnedChallenges.delete(challengeId);

    const user = await this.usersService.findById(challenge.targetUserId);
    user.lastLoginAt = new Date();
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser: false };
  }

  private mintChallenge(data: {
    email: string;
    provider: CredentialType.GOOGLE | CredentialType.APPLE;
    providerSub: string;
    providerData: Record<string, unknown>;
    targetUserId: string;
  }): string {
    const id = randomUUID();
    this.emailOwnedChallenges.set(id, { ...data, createdAt: Date.now() });
    // Opportunistic GC: trim any expired entries.
    for (const [k, v] of this.emailOwnedChallenges.entries()) {
      if (Date.now() - v.createdAt > 10 * 60 * 1000) {
        this.emailOwnedChallenges.delete(k);
      }
    }
    return id;
  }

  private normaliseEmail(raw: string): string {
    const [localRaw, domainRaw] = raw.trim().toLowerCase().split('@');
    if (!localRaw || !domainRaw) return raw.trim().toLowerCase();
    const local =
      domainRaw === 'gmail.com' ? localRaw.replace(/\./g, '') : localRaw;
    return `${local}@${domainRaw}`;
  }

  /**
   * Decodes an expired access token without verifying signature — used by
   * POST /auth/refresh per IDENTITY_CONTRACT §4.7. The refresh token in
   * the body is the cryptographic authenticator; the access token is a
   * user_id hint only.
   */
  static extractUserIdFromExpiredAccess(token: string): string | null {
    try {
      const decoded = jwt.decode(token) as { sub?: string } | null;
      return decoded?.sub ?? null;
    } catch {
      return null;
    }
  }

  private async issueTokens(
    user: User,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthTokens> {
    const jti = randomUUID();

    const accessToken = this.jwtService.sign(
      { sub: user.id, role: user.role, jti },
      {
        secret: this.config.get<string>('jwt.accessSecret'),
        expiresIn: this.config.get<string>('jwt.accessExpiry') as any,
      },
    );

    const refreshToken = randomUUID();
    await this.sessionsService.create(user, refreshToken, meta);

    return { accessToken, refreshToken };
  }
}
