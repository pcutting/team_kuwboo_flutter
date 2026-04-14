import {
  Controller,
  Post,
  Body,
  Req,
  HttpCode,
  HttpStatus,
  ForbiddenException,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { AuthService } from './auth.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { GoogleLoginDto, AppleLoginDto } from './dto/social-login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { Public } from '../../common/decorators/public.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('phone/send-otp')
  @HttpCode(HttpStatus.OK)
  async sendOtp(@Body() dto: SendOtpDto) {
    await this.authService.sendPhoneOtp(dto.phone);
    return { message: 'OTP sent' };
  }

  @Public()
  @Post('phone/verify-otp')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(@Body() dto: VerifyOtpDto, @Req() req: Request) {
    return this.authService.verifyPhoneOtp(dto.phone, dto.code, {
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip,
    });
  }

  @Public()
  @Post('social/google')
  @HttpCode(HttpStatus.OK)
  async googleLogin(@Body() dto: GoogleLoginDto, @Req() req: Request) {
    return this.authService.googleLogin(dto.idToken, {
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip,
    });
  }

  @Public()
  @Post('social/apple')
  @HttpCode(HttpStatus.OK)
  async appleLogin(@Body() dto: AppleLoginDto, @Req() req: Request) {
    return this.authService.appleLogin(dto.identityToken, dto.fullName, {
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip,
    });
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() dto: RefreshTokenDto, @Req() req: Request) {
    // Extract userId from the expired access token in the Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return { message: 'Authorization header required for refresh' };
    }

    const token = authHeader.slice(7);
    // Decode without verification (token is expired)
    const jwt = require('jsonwebtoken');
    const decoded = jwt.decode(token) as { sub?: string };
    if (!decoded?.sub) {
      return { message: 'Invalid access token' };
    }

    return this.authService.refreshTokens(decoded.sub, dto.refreshToken, {
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip,
    });
  }

  /**
   * Dev-only login. Skips OTP, find-or-creates a user by phone, returns real
   * JWTs. Gated by `DEV_LOGIN_ENABLED=1` env flag — 403 otherwise. Mobile
   * client uses this when built with `--dart-define=KUWBOO_DEV_AUTH=1`.
   */
  @Public()
  @Post('dev-login')
  @HttpCode(HttpStatus.OK)
  async devLogin(@Body() dto: SendOtpDto, @Req() req: Request) {
    if (process.env.DEV_LOGIN_ENABLED !== '1') {
      throw new ForbiddenException('Dev login is disabled');
    }
    return this.authService.devLogin(dto.phone, {
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip,
    });
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logout(@CurrentUser('id') userId: string) {
    await this.authService.logout(userId);
    return { message: 'Logged out' };
  }
}
