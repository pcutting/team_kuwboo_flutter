import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AppleAuthModule } from './apple/apple.module';
import { UsersModule } from '../users/users.module';
import { SessionsModule } from '../sessions/sessions.module';
import { VerificationModule } from '../verification/verification.module';
import { CredentialsModule } from '../credentials/credentials.module';
import { TrustModule } from '../trust/trust.module';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.register({}),
    AppleAuthModule,
    UsersModule,
    SessionsModule,
    VerificationModule,
    CredentialsModule,
    TrustModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}
