import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Credential } from './entities/credential.entity';
import { CredentialsService } from './credentials.service';
import { CredentialsController } from './credentials.controller';
import { AdminCredentialsController } from './admin-credentials.controller';
import { VerificationModule } from '../verification/verification.module';
import { TrustModule } from '../trust/trust.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([Credential]),
    VerificationModule,
    TrustModule,
  ],
  providers: [CredentialsService],
  controllers: [CredentialsController, AdminCredentialsController],
  exports: [CredentialsService],
})
export class CredentialsModule {}
