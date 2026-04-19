import { Controller, Get, Post, Delete, Body, Param, Req } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Request } from 'express';
import { ConsentService } from './consent.service';
import { GrantConsentDto } from './dto/grant-consent.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';
import { ConsentType } from '../../common/enums';

@ApiTags('consent')
@ApiBearerAuth()
@Controller('consent')
export class ConsentController {
  constructor(
    private readonly consentService: ConsentService,
    private readonly usersService: UsersService,
  ) {}

  @Get()
  async list(@CurrentUser('id') userId: string) {
    return this.consentService.getActiveConsents(userId);
  }

  /**
   * Per-user acceptance summary for the two audited legal documents
   * (TERMS + PRIVACY). Clients fetch this on cold start and after the
   * session wakes from background to decide whether to show the
   * "legal updated, please review" banner.
   *
   * Auth: relies on the globally-registered JwtAuthGuard
   * (`app.module.ts` wires it as `APP_GUARD`), so no explicit
   * `@UseGuards(JwtAuthGuard)` is needed — a missing / invalid token
   * returns 401 the same as the other endpoints in this controller.
   */
  @Get('summary')
  async summary(@CurrentUser('id') userId: string) {
    return this.consentService.getSummary(userId);
  }

  @Post()
  async grant(
    @CurrentUser('id') userId: string,
    @Body() dto: GrantConsentDto,
    @Req() req: Request,
  ) {
    const user = await this.usersService.findById(userId);
    return this.consentService.grant(user, dto, req.ip);
  }

  @Delete(':consentType')
  async revoke(
    @CurrentUser('id') userId: string,
    @Param('consentType') consentType: ConsentType,
  ) {
    await this.consentService.revoke(userId, consentType);
    return { message: 'Consent revoked' };
  }
}
