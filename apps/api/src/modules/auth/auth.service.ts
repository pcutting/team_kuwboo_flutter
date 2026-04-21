import {
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { UniqueConstraintViolationException } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { OAuth2Client } from 'google-auth-library';
import { UsersService } from '../users/users.service';
import { SessionsService } from '../sessions/sessions.service';
import { VerificationService } from '../verification/verification.service';
import { AppleJwksService } from './apple/apple-jwks.service';
import { CredentialsService } from '../credentials/credentials.service';
import { TrustService } from '../trust/trust.service';
import { ConsentService } from '../consent/consent.service';
import { LoginAttemptLogger } from './login-throttle/login-attempt-logger.service';
import { LoginThrottleService } from './login-throttle/login-throttle.service';
import { LoginAttemptOutcome } from './login-throttle/login-attempt.entity';
import { User } from '../users/entities/user.entity';
import {
  AgeVerificationStatus,
  CredentialType,
  DobChoice,
  OnboardingProgress,
  TrustSignalType,
} from '../../common/enums';
import { FRESH_TOKEN_MAX_AGE_SECONDS } from '../../common/guards/fresh-token.guard';

const PASSWORD_BCRYPT_ROUNDS = 10;

export interface EmailRegisterInput {
  email: string;
  password: string;
  name?: string;
  dateOfBirth?: string;
  dobChoice?: DobChoice;
  /**
   * Hard-gated at the DTO level — the service assumes these have
   * already been validated as `true`. Including them on the input
   * type keeps the call-site self-documenting and lets tests call
   * the service directly with the same shape the controller passes.
   */
  legalAccepted?: boolean;
  ageConfirmed?: boolean;
}

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

export interface ElevatedTokenResponse {
  /**
   * Short-lived JWT (same signing key + shape as a normal access token)
   * whose `iat` claim is wall-clock now, so it satisfies
   * `FreshTokenGuard` for the ~15 minutes following issuance.
   */
  elevatedToken: string;
  /**
   * ISO 8601 wall-clock timestamp at which `elevatedToken` ceases to be
   * considered "fresh" by `FreshTokenGuard`. The raw JWT `exp` claim
   * matches this value; exposing it as a formatted string means the
   * client doesn't have to decode the token to know when to re-prompt.
   */
  expiresAt: string;
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
    private readonly consentService: ConsentService,
    private readonly loginAttemptLogger: LoginAttemptLogger,
    private readonly loginThrottle: LoginThrottleService,
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
      try {
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
      } catch (e) {
        if (e instanceof UniqueConstraintViolationException) {
          throw new ConflictException({
            code: 'phone_already_registered',
            message: 'This phone is already registered; log in instead.',
          });
        }
        throw e;
      }
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
      try {
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
      } catch (e) {
        if (e instanceof UniqueConstraintViolationException) {
          throw new ConflictException({
            code: 'email_already_registered',
            message: 'This email is already registered; log in instead.',
          });
        }
        throw e;
      }
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

  /**
   * Email + password registration. Creates a new user with a bcrypt
   * password hash, attaches an EMAIL credential, and issues tokens.
   * Email verification is a separate step (`/auth/email/verify/send` +
   * `/auth/email/verify/confirm`) — we do not block registration on it.
   */
  async emailRegister(
    input: EmailRegisterInput,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    const email = this.normaliseEmail(input.email);

    const existingCredential = await this.credentialsService.findByIdentity(
      CredentialType.EMAIL,
      email,
    );
    const existingUser = await this.usersService.findByEmail(email);
    if (existingCredential || existingUser) {
      throw new ConflictException({
        code: 'email_taken',
        message: 'That email is already registered.',
      });
    }

    const passwordHash = await bcrypt.hash(input.password, PASSWORD_BCRYPT_ROUNDS);

    // Resolve DOB-related onboarding state.
    let dobChoice: DobChoice = input.dobChoice ?? DobChoice.PENDING;
    let ageVerificationStatus: AgeVerificationStatus | undefined;
    let dateOfBirth: Date | undefined;

    if (input.dateOfBirth) {
      dateOfBirth = new Date(input.dateOfBirth);
      dobChoice = DobChoice.PROVIDED;
      ageVerificationStatus = AgeVerificationStatus.SELF_DECLARED;
    } else if (input.dobChoice === DobChoice.ADULT_SELF_DECLARED) {
      ageVerificationStatus = AgeVerificationStatus.SELF_DECLARED_ADULT;
    } else if (input.dobChoice === DobChoice.PREFER_NOT_TO_SAY) {
      ageVerificationStatus = AgeVerificationStatus.PREFER_NOT_TO_SAY;
    }

    const user = await this.usersService.create({
      email,
      name: input.name || email,
      passwordHash,
      dateOfBirth,
      dobChoice,
      ...(ageVerificationStatus !== undefined ? { ageVerificationStatus } : {}),
      onboardingProgress: OnboardingProgress.OTP,
    } as any);

    await this.credentialsService.attach({
      userId: user.id,
      type: CredentialType.EMAIL,
      identifier: email,
    });

    // Stamp TERMS + PRIVACY consents for the legal-acceptance audit
    // trail. The DTO hard-gates `legalAccepted` / `ageConfirmed` to
    // true, so reaching this point implies both were affirmed — we
    // only persist the two real consent rows, not the age
    // self-attestation (IDENTITY_CONTRACT doesn't currently audit
    // the 18+ checkbox; can be added as its own ConsentType later).
    await this.consentService.recordRegistrationConsents(user, meta);

    user.lastLoginAt = new Date();
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser: true };
  }

  /**
   * Email + password login. Does not distinguish unknown-email from
   * wrong-password — both paths return `invalid_credentials` to avoid
   * user enumeration.
   *
   * Brute-force defence (issue #174):
   *   1. Pre-check the per-(email, ip) throttle counter AND the
   *      account-level soft-lock flag; either being set short-circuits
   *      to a generic 429 before bcrypt runs.
   *   2. Run the normal credential check. On failure, call
   *      `LoginThrottleService.registerFailure()` which applies the
   *      exponential backoff and, when the per-email distinct-IP set
   *      crosses the cross-IP threshold, tells us to trip the account
   *      soft lock via `user.authLockedAt`.
   *   3. On success, reset the per-(email, ip) counter. The account
   *      soft-lock is intentionally NOT cleared here — unlock is
   *      gated by a password reset.
   */
  async emailLogin(
    rawEmail: string,
    password: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    const email = this.normaliseEmail(rawEmail);
    const ipAddress = meta?.ipAddress;
    const userAgent = meta?.userAgent;

    // Pre-check: already-throttled callers never touch bcrypt.
    if (await this.loginThrottle.shouldBlockBeforeCheck(email, ipAddress)) {
      await this.loginAttemptLogger.log({
        email,
        ipAddress,
        userAgent,
        outcome: LoginAttemptOutcome.THROTTLED,
      });
      throw this.tooManyAttempts();
    }

    const user = await this.usersService.findByEmail(email);

    // Account-level soft-lock gate. Runs BEFORE the
    // unknown-email branch so a locked account can't be distinguished
    // from an unknown email in the response (both paths collapse to
    // the same generic 429).
    if (user?.authLockedAt) {
      await this.loginAttemptLogger.log({
        email,
        ipAddress,
        userAgent,
        outcome: LoginAttemptOutcome.LOCKED_OUT,
      });
      throw this.tooManyAttempts();
    }

    if (!user || !user.passwordHash) {
      await this.registerFailureAndMaybeLock({
        email,
        ipAddress,
        userAgent,
        outcome: LoginAttemptOutcome.UNKNOWN_EMAIL,
        user: null,
      });
      throw new UnauthorizedException({
        code: 'invalid_credentials',
        message: 'Email or password is incorrect.',
      });
    }

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) {
      await this.registerFailureAndMaybeLock({
        email,
        ipAddress,
        userAgent,
        outcome: LoginAttemptOutcome.WRONG_PASSWORD,
        user,
      });
      throw new UnauthorizedException({
        code: 'invalid_credentials',
        message: 'Email or password is incorrect.',
      });
    }

    // Password matched — reset the per-(email, ip) counter, log success,
    // issue tokens.
    await this.loginThrottle.registerSuccess(email, ipAddress);
    await this.loginAttemptLogger.log({
      email,
      ipAddress,
      userAgent,
      outcome: LoginAttemptOutcome.SUCCESS,
    });

    user.lastLoginAt = new Date();
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser: false };
  }

  /**
   * Shared post-failure path for `emailLogin`. Runs the throttle
   * service, persists the audit row, and — if the per-(email, ip)
   * counter tipped into the hard-throttle band — promotes the outcome
   * from WRONG_PASSWORD / UNKNOWN_EMAIL to THROTTLED so the audit row
   * reflects what the client actually saw.
   *
   * When the cross-IP detector flagged an account lock on this
   * failure AND we have a real user row, persist `authLockedAt` so
   * every subsequent attempt collapses to the generic 429 path.
   * We never lock on UNKNOWN_EMAIL because there is nothing to lock.
   */
  private async registerFailureAndMaybeLock(args: {
    email: string;
    ipAddress?: string;
    userAgent?: string;
    outcome: LoginAttemptOutcome;
    user: User | null;
  }): Promise<void> {
    const decision = await this.loginThrottle.registerFailure(
      args.email,
      args.ipAddress,
    );

    // Trip the account-level soft lock when the cross-IP detector
    // said so. Only meaningful when we actually have a user row —
    // UNKNOWN_EMAIL branches can't be locked.
    let lockJustTripped = false;
    if (
      decision.accountLockTriggered &&
      args.user &&
      !args.user.authLockedAt
    ) {
      args.user.authLockedAt = new Date();
      await this.usersService.flushUser(args.user.id);
      lockJustTripped = true;
    }

    let finalOutcome = args.outcome;
    if (lockJustTripped || decision.shouldThrottle) {
      finalOutcome = lockJustTripped
        ? LoginAttemptOutcome.LOCKED_OUT
        : LoginAttemptOutcome.THROTTLED;
    }

    await this.loginAttemptLogger.log({
      email: args.email,
      ipAddress: args.ipAddress,
      userAgent: args.userAgent,
      outcome: finalOutcome,
    });

    if (decision.shouldThrottle || lockJustTripped) {
      throw this.tooManyAttempts();
    }
  }

  /** Generic 429 used for every throttle / lock branch. Never leaks existence. */
  private tooManyAttempts(): HttpException {
    return new HttpException(
      {
        code: 'too_many_attempts',
        message: 'Too many attempts. Try again later.',
      },
      HttpStatus.TOO_MANY_REQUESTS,
    );
  }

  /**
   * Initiates password reset. Always returns 200 regardless of whether
   * the email exists — the response shape must not leak account
   * existence. When the user is unknown we return an empty data object
   * (or a fresh dev code mimicking a real send so dev tooling still
   * exhibits a code in the banner).
   */
  async emailForgotPassword(
    rawEmail: string,
  ): Promise<{ devCode?: string }> {
    const email = this.normaliseEmail(rawEmail);
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      // Burn cycles to keep timing roughly comparable. The returned
      // devCode is never usable because no verification row was created.
      if (process.env.NODE_ENV !== 'production') {
        return { devCode: '000000' };
      }
      return {};
    }
    return this.verificationService.sendPasswordResetOtp(email);
  }

  /**
   * Consumes a password-reset code, rotates the user's password,
   * revokes all existing sessions, and issues a fresh token pair.
   */
  async emailResetPassword(
    rawEmail: string,
    code: string,
    newPassword: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    const email = this.normaliseEmail(rawEmail);
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new BadRequestException({
        code: 'invalid_code',
        message: 'Invalid or expired code.',
      });
    }

    await this.verificationService.verifyPasswordResetOtp(email, code);

    user.passwordHash = await bcrypt.hash(newPassword, PASSWORD_BCRYPT_ROUNDS);
    user.lastLoginAt = new Date();
    // A completed password reset is the recovery path for the
    // cross-IP soft-lock set by the login-throttle subsystem. Clear
    // the flag + reset the Redis counters so the user can log in
    // again on the next request (issue #174 phase 2).
    if (user.authLockedAt) {
      user.authLockedAt = undefined;
    }
    await this.loginThrottle.registerSuccess(email, meta?.ipAddress);

    await this.sessionsService.revokeAllForUser(user.id);
    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser: false };
  }

  /**
   * Sends an email verification code to the authenticated user's email.
   * Reuses the phone/email OTP table via the EMAIL_VERIFY discriminator.
   */
  async emailVerifySend(userId: string): Promise<{ devCode?: string }> {
    const user = await this.usersService.findById(userId);
    if (!user.email) {
      throw new BadRequestException({
        code: 'no_email_on_file',
        message: 'This account has no email to verify.',
      });
    }
    return this.verificationService.sendEmailOtp(this.normaliseEmail(user.email));
  }

  /**
   * Consumes a code issued by `emailVerifySend` and marks the user's
   * email as verified. On success appends an EMAIL_VERIFIED trust
   * signal (idempotent: only the first successful verify earns the
   * delta).
   */
  async emailVerifyConfirm(
    userId: string,
    code: string,
  ): Promise<{ emailVerified: true }> {
    const user = await this.usersService.findById(userId);
    if (!user.email) {
      throw new BadRequestException({
        code: 'no_email_on_file',
        message: 'This account has no email to verify.',
      });
    }

    try {
      await this.verificationService.verifyEmailOtp(
        this.normaliseEmail(user.email),
        code,
      );
    } catch {
      throw new BadRequestException({
        code: 'invalid_code',
        message: 'Invalid or expired code.',
      });
    }

    const alreadyVerified = user.emailVerified;
    user.emailVerified = true;
    user.emailVerifiedAt = new Date();

    if (!alreadyVerified) {
      await this.trustService.append({
        userId: user.id,
        type: TrustSignalType.EMAIL_VERIFIED,
        delta: 10,
        source: 'email_verify',
      });
    }

    // Persist the email-verified flag on the user row.
    await this.usersService.flushUser(user.id);
    return { emailVerified: true };
  }

  /**
   * Re-prove ownership of an SSO-only account via an email OTP. Issues
   * an elevated access token (same signing key + shape as a normal
   * access token, wall-clock `iat`) that `FreshTokenGuard` will accept
   * for the next 15 minutes — the mobile client then substitutes it
   * into the `Authorization` header when calling a privileged endpoint
   * such as `DELETE /users/me`.
   *
   * The flow for a Google/Apple user who hit a `stale_token` 401:
   *   1. `POST /auth/email/send-otp` with their account email
   *   2. `POST /auth/confirm-identity` with `{ email, otpCode }`
   *   3. Retry the privileged request using the returned `elevatedToken`
   *
   * Anti-enumeration: unknown email, missing OTP row, expired row,
   * wrong code — all surface as the same 401 `invalid_otp` shape.
   * Leaking which branch failed would give callers an email-existence
   * oracle (mirrors the pattern in `emailLogin`, `emailForgotPassword`,
   * `emailResetPassword`).
   */
  async confirmIdentity(
    rawEmail: string,
    otpCode: string,
  ): Promise<ElevatedTokenResponse> {
    const email = this.normaliseEmail(rawEmail);

    const invalid = () =>
      new UnauthorizedException({
        code: 'invalid_otp',
        message: 'Invalid or expired code.',
      });

    // Locate the user by their EMAIL credential. Using the credential
    // table (not users.email) means we resolve the same row an SSO
    // flow attached — matches how `googleLogin` / `appleLogin` decide
    // whether an email is already owned.
    const emailCred = await this.credentialsService.findByIdentity(
      CredentialType.EMAIL,
      email,
    );
    if (!emailCred) {
      throw invalid();
    }

    try {
      await this.verificationService.verifyEmailOtp(email, otpCode);
    } catch {
      // verifyEmailOtp differentiates "no pending row" (400) from
      // "wrong code / too many attempts" (401); both collapse to the
      // same 401 shape here.
      throw invalid();
    }

    const user = emailCred.user;
    return this.issueElevatedToken(user);
  }

  private issueElevatedToken(user: User): ElevatedTokenResponse {
    const jti = randomUUID();
    const nowSeconds = Math.floor(Date.now() / 1000);
    const expSeconds = nowSeconds + FRESH_TOKEN_MAX_AGE_SECONDS;

    const elevatedToken = this.jwtService.sign(
      { sub: user.id, role: user.role, jti },
      {
        secret: this.config.get<string>('jwt.accessSecret'),
        expiresIn: FRESH_TOKEN_MAX_AGE_SECONDS,
      },
    );

    return {
      elevatedToken,
      expiresAt: new Date(expSeconds * 1000).toISOString(),
    };
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
