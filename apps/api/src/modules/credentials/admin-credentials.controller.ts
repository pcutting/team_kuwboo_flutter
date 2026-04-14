import {
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CredentialsService } from './credentials.service';
import { TrustService } from '../trust/trust.service';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Role } from '../../common/enums';

/**
 * Admin-scoped credential management. Mirrors the self-scoped endpoints in
 * CredentialsController but targets an arbitrary user by ID. Revocation
 * enforces the same "cannot revoke last active credential" invariant
 * (IDENTITY_CONTRACT §11.2). Each admin revoke appends an audit row to
 * `trust_signals` with signal_type = 'credential_revoked_by_admin'.
 */
@ApiTags('admin-credentials')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN, Role.SUPER_ADMIN)
@Controller('admin/users/:userId/credentials')
export class AdminCredentialsController {
  constructor(
    private readonly credentialsService: CredentialsService,
    private readonly trustService: TrustService,
  ) {}

  @Get()
  async list(@Param('userId', ParseUUIDPipe) userId: string) {
    const credentials = await this.credentialsService.listForUser(userId);
    return { credentials };
  }

  @Delete(':credentialId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async revoke(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Param('credentialId', ParseUUIDPipe) credentialId: string,
    @CurrentUser('id') adminId: string,
  ): Promise<void> {
    await this.credentialsService.revoke(credentialId, userId);
    await this.trustService.append({
      userId,
      type: 'credential_revoked_by_admin',
      delta: 0,
      source: 'admin',
      metadata: {
        reason: `credential ${credentialId} revoked by admin ${adminId}`,
        credentialId,
        adminId,
      },
    });
  }
}
