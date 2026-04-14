import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  BadRequestException,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CredentialsService } from './credentials.service';
import { AttachCredentialDto } from './dto/attach-credential.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { CredentialType } from '../../common/enums';
import { VerificationService } from '../verification/verification.service';

@ApiTags('credentials')
@ApiBearerAuth()
@Controller('credentials')
export class CredentialsController {
  constructor(
    private readonly credentialsService: CredentialsService,
    private readonly verificationService: VerificationService,
  ) {}

  @Get()
  async list(@CurrentUser('id') userId: string) {
    const credentials = await this.credentialsService.listForUser(userId);
    return { credentials };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async attach(
    @CurrentUser('id') userId: string,
    @Body() dto: AttachCredentialDto,
  ) {
    // Phone and email attaches require a fresh OTP verification against the
    // `verifications` table — see IDENTITY_CONTRACT §4.8.
    if (dto.type === CredentialType.PHONE || dto.type === CredentialType.EMAIL) {
      if (!dto.otp) {
        throw new BadRequestException({
          code: 'otp_required',
          message: 'OTP is required to attach a phone or email credential.',
        });
      }
      if (dto.type === CredentialType.PHONE) {
        await this.verificationService.verifyPhoneOtp(dto.identifier, dto.otp);
      } else {
        await this.verificationService.verifyEmailOtp(dto.identifier, dto.otp);
      }
    }

    const credential = await this.credentialsService.attach({
      userId,
      type: dto.type,
      identifier: dto.identifier,
    });
    return { credential };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async revoke(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.credentialsService.revoke(id, userId);
  }
}
