import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Verification } from './entities/verification.entity';
import { VerificationService } from './verification.service';
import { EmailModule } from '../email/email.module';

@Module({
  imports: [MikroOrmModule.forFeature([Verification]), EmailModule],
  providers: [VerificationService],
  exports: [VerificationService],
})
export class VerificationModule {}
