import {
  Controller,
  Post,
  Body,
  Req,
  HttpCode,
  HttpStatus,
  ForbiddenException,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { Throttle } from '@nestjs/throttler';
import { AuthService, EmailOwnedChallenge } from './auth.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { SendEmailOtpDto, VerifyEmailOtpDto } from './dto/email-otp.dto';
import { GoogleLoginDto, AppleLoginDto } from './dto/social-login.dto';
import { GoogleConfirmDto, AppleConfirmDto } from './dto/sso-confirm.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { Public } from '../../common/decorators/public.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Throttle({ default: { limit: 5, ttl: 15 * 60 * 1000 } })
  @Post('phone/send-otp')
  @HttpCode(HttpStatus.OK)
  async sendPhoneOtp(@Body() dto: SendOtpDto) {
    await this.authService.sendPhoneOtp(dto.phone);
    return { sent: true };
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 15 * 60 * 1000 } })
  @Post('phone/verify-otp')
  @HttpCode(HttpStatus.OK)
  async verifyPhoneOtp(@Body() dto: VerifyOtpDto, @Req() req: Request) {
    return this.authService.verifyPhoneOtp(dto.phone, dto.code, reqMeta(req));
  }

  @Public()
  @Throttle({ default: { limit: 5, ttl: 15 * 60 * 1000 } })
  @Post('email/send-otp')
  @HttpCode(HttpStatus.OK)
  async sendEmailOtp(@Body() dto: SendEmailOtpDto) {
    await this.authService.sendEmailOtp(dto.email);
    return { sent: true };
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 15 * 60 * 1000 } })
  @Post('email/verify-otp')
  @HttpCode(HttpStatus.OK)
  async verifyEmailOtp(@Body() dto: VerifyEmailOtpDto, @Req() req: Request) {
    return this.authService.verifyEmailOtp(dto.email, dto.code, reqMeta(req));
  }

  @Public()
  @Throttle({ default: { limit: 30, ttl: 15 * 60 * 1000 } })
  @Post('google')
  @HttpCode(HttpStatus.OK)
  async googleLogin(@Body() dto: GoogleLoginDto, @Req() req: Request) {
    const result = await this.authService.googleLogin(dto.idToken, reqMeta(req));
    return unwrapChallenge(result);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 15 * 60 * 1000 } })
  @Post('google/confirm')
  @HttpCode(HttpStatus.OK)
  async googleConfirm(@Body() dto: GoogleConfirmDto, @Req() req: Request) {
    return this.authService.googleConfirm(
      dto.idToken,
      dto.emailOtp,
      dto.challengeId,
      reqMeta(req),
    );
  }

  @Public()
  @Throttle({ default: { limit: 30, ttl: 15 * 60 * 1000 } })
  @Post('apple')
  @HttpCode(HttpStatus.OK)
  async appleLogin(@Body() dto: AppleLoginDto, @Req() req: Request) {
    const result = await this.authService.appleLogin(
      dto.identityToken,
      dto.authorizationCode,
      dto.fullName,
      reqMeta(req),
    );
    return unwrapChallenge(result);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 15 * 60 * 1000 } })
  @Post('apple/confirm')
  @HttpCode(HttpStatus.OK)
  async appleConfirm(@Body() dto: AppleConfirmDto, @Req() req: Request) {
    return this.authService.appleConfirm(
      dto.identityToken,
      dto.emailOtp,
      dto.challengeId,
      reqMeta(req),
    );
  }

  /**
   * Refresh endpoint. Contract §4.7: access token in Authorization header
   * (expired OK), refresh token in body. Reuse triggers family-wide
   * revocation + trust signal.
   */
  @Public()
  @Throttle({ default: { limit: 60, ttl: 15 * 60 * 1000 } })
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() dto: RefreshTokenDto, @Req() req: Request) {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedException({
        code: 'missing_access_token',
        message: 'Authorization header with the expired access token is required.',
      });
    }
    const userId = AuthService.extractUserIdFromExpiredAccess(authHeader.slice(7));
    if (!userId) {
      throw new UnauthorizedException({
        code: 'invalid_access_token',
        message: 'Access token is malformed.',
      });
    }
    return this.authService.refreshTokens(userId, dto.refreshToken, reqMeta(req));
  }

  /**
   * Dev-only login. Gated by `DEV_LOGIN_ENABLED=1`.
   */
  @Public()
  @Post('dev-login')
  @HttpCode(HttpStatus.OK)
  async devLogin(@Body() dto: SendOtpDto, @Req() req: Request) {
    if (process.env.DEV_LOGIN_ENABLED !== '1') {
      throw new ForbiddenException('Dev login is disabled');
    }
    return this.authService.devLogin(dto.phone, reqMeta(req));
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logout(@CurrentUser('id') userId: string) {
    await this.authService.logout(userId);
    return { ok: true };
  }
}

function reqMeta(req: Request): { userAgent?: string; ipAddress?: string } {
  return {
    userAgent: typeof req.headers['user-agent'] === 'string' ? req.headers['user-agent'] : undefined,
    ipAddress: req.ip,
  };
}

/**
 * Turn an `email_owned` challenge (non-error business outcome) into a 409
 * with the canonical contract code + challenge id. Normal auth responses
 * pass through unchanged.
 */
function unwrapChallenge<T>(result: T): Exclude<T, EmailOwnedChallenge> {
  if (
    result &&
    typeof result === 'object' &&
    (result as unknown as { status?: string }).status === 'email_owned'
  ) {
    const c = result as unknown as EmailOwnedChallenge;
    throw new ConflictException({
      code: 'email_owned',
      challenge_id: c.challengeId,
      email: c.email,
      require_verify_email: true,
    });
  }
  return result as Exclude<T, EmailOwnedChallenge>;
}
