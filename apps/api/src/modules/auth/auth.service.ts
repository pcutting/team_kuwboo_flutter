import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'crypto';
import { OAuth2Client } from 'google-auth-library';
import { UsersService } from '../users/users.service';
import { SessionsService } from '../sessions/sessions.service';
import { VerificationService } from '../verification/verification.service';
import { AppleJwksService } from './apple/apple-jwks.service';
import { User } from '../users/entities/user.entity';

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

@Injectable()
export class AuthService {
  private readonly googleClient: OAuth2Client;

  constructor(
    private readonly config: ConfigService,
    private readonly jwtService: JwtService,
    private readonly usersService: UsersService,
    private readonly sessionsService: SessionsService,
    private readonly verificationService: VerificationService,
    private readonly appleJwks: AppleJwksService,
  ) {
    this.googleClient = new OAuth2Client();
  }

  async sendPhoneOtp(phone: string): Promise<void> {
    await this.verificationService.sendPhoneOtp(phone);
  }

  async verifyPhoneOtp(
    phone: string,
    code: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    await this.verificationService.verifyPhoneOtp(phone, code);

    let user = await this.usersService.findByPhone(phone);
    let isNewUser = false;

    if (!user) {
      user = await this.usersService.create({
        phone,
        name: phone, // Default name; user updates in onboarding
      });
      isNewUser = true;
    }

    const tokens = await this.issueTokens(user, meta);

    return { ...tokens, user, isNewUser };
  }

  async googleLogin(
    idToken: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    const ticket = await this.googleClient.verifyIdToken({
      idToken,
      audience: this.config.get<string>('GOOGLE_CLIENT_ID'),
    });
    const payload = ticket.getPayload();
    if (!payload || !payload.sub) {
      throw new UnauthorizedException('Invalid Google token');
    }

    let user = await this.usersService.findByGoogleId(payload.sub);
    let isNewUser = false;

    if (!user) {
      // Check if email already exists
      if (payload.email) {
        user = await this.usersService.findByEmail(payload.email);
      }
      if (user) {
        // Link Google to existing account
        await this.usersService.update(user.id, {} as any);
        user.googleId = payload.sub;
      } else {
        user = await this.usersService.create({
          googleId: payload.sub,
          email: payload.email || undefined,
          name: payload.name || 'User',
          avatarUrl: payload.picture || undefined,
        });
        isNewUser = true;
      }
    }

    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser };
  }

  async appleLogin(
    identityToken: string,
    fullName?: string,
    meta?: { userAgent?: string; ipAddress?: string },
  ): Promise<AuthResponse> {
    // Verify Apple identity token signature + claims against Apple's JWKS.
    // This throws UnauthorizedException on:
    //   - bad signature
    //   - wrong issuer (not https://appleid.apple.com)
    //   - wrong audience (aud does not match APPLE_BUNDLE_ID / APPLE_SERVICE_ID)
    //   - expired exp / future nbf
    //   - non-ES256 algorithm
    const claims = await this.appleJwks.verify(identityToken);

    let user = await this.usersService.findByAppleId(claims.sub);
    let isNewUser = false;

    if (!user) {
      if (claims.email) {
        user = await this.usersService.findByEmail(claims.email);
      }
      if (user) {
        user.appleId = claims.sub;
      } else {
        user = await this.usersService.create({
          appleId: claims.sub,
          email: claims.email || undefined,
          name: fullName || 'User',
        });
        isNewUser = true;
      }
    }

    const tokens = await this.issueTokens(user, meta);
    return { ...tokens, user, isNewUser };
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
      // Potential token theft — revoke all sessions
      await this.sessionsService.revokeAllForUser(userId);
      throw new UnauthorizedException('Token reuse detected. All sessions revoked.');
    }

    // Rotate: revoke old, create new
    await this.sessionsService.revoke(session);

    const user = await this.usersService.findById(userId);
    return this.issueTokens(user, meta);
  }

  async logout(userId: string): Promise<void> {
    const session = await this.sessionsService.findValidSession(userId);
    if (session) {
      await this.sessionsService.revoke(session);
    }
  }

  /**
   * Development-only login. Skips OTP entirely — find-or-creates a user by
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
