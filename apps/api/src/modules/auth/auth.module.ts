import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AppleAuthModule } from './apple/apple.module';
import { UsersModule } from '../users/users.module';
import { SessionsModule } from '../sessions/sessions.module';
import { VerificationModule } from '../verification/verification.module';
import { CredentialsModule } from '../credentials/credentials.module';
import { TrustModule } from '../trust/trust.module';
import { ConsentModule } from '../consent/consent.module';
import { LoginAttempt } from './login-throttle/login-attempt.entity';
import { LoginAttemptLogger } from './login-throttle/login-attempt-logger.service';
import { LoginThrottleService } from './login-throttle/login-throttle.service';
import { DelayProvider, RealDelayProvider } from './login-throttle/delay.provider';
import { loginThrottleRedisProvider } from './login-throttle/redis.provider';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.register({}),
    MikroOrmModule.forFeature([LoginAttempt]),
    AppleAuthModule,
    UsersModule,
    SessionsModule,
    VerificationModule,
    CredentialsModule,
    TrustModule,
    ConsentModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    LoginAttemptLogger,
    LoginThrottleService,
    { provide: DelayProvider, useClass: RealDelayProvider },
    loginThrottleRedisProvider,
  ],
  exports: [AuthService],
})
export class AuthModule {}
