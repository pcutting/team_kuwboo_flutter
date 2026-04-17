import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UsersService } from '../../users/users.service';

export interface JwtPayload {
  sub: string;
  role: string;
  jti: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    private readonly config: ConfigService,
    private readonly usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get<string>('jwt.accessSecret') || 'fallback-secret',
    });
  }

  async validate(payload: JwtPayload) {
    const user = await this.usersService.findById(payload.sub);
    if (!user || user.status !== 'ACTIVE') {
      throw new UnauthorizedException('User not found or inactive');
    }
    // Return the fields downstream guards / decorators rely on. In
    // particular the `DatingAgeGuard` reads `dateOfBirth`,
    // `ageVerificationStatus`, and `dobChoice` directly off req.user.
    return {
      id: user.id,
      role: user.role,
      email: user.email,
      emailVerified: user.emailVerified,
      dateOfBirth: user.dateOfBirth,
      ageVerificationStatus: user.ageVerificationStatus,
      dobChoice: user.dobChoice,
    };
  }
}
