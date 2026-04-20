import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { Request } from 'express';
import { AccountService } from './account.service';
import { DeleteAccountDto } from './dto/delete-account.dto';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { FreshTokenGuard } from '../../common/guards/fresh-token.guard';

/**
 * Account-lifecycle endpoints, split out from UsersController so the
 * destructive routes sit behind their own `FreshTokenGuard` and
 * throttle profile without polluting every other `/users/*` handler.
 *
 * Both endpoints return 204 so mobile clients can wire them to a
 * simple "sign-out and route to welcome" UX regardless of server-side
 * branching.
 */
@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
@UseGuards(FreshTokenGuard)
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  /**
   * Soft-delete. Sets `users.deleted_at`, revokes sessions, and
   * schedules a 30-day PII anonymize job. Throttled to 3 attempts per
   * 5 minutes per requester.
   */
  @Delete('me')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle({ default: { limit: 3, ttl: 5 * 60 * 1000 } })
  async softDeleteMe(
    @CurrentUser('id') userId: string,
    @Body() dto: DeleteAccountDto,
    @Req() req: Request,
  ): Promise<void> {
    await this.accountService.softDelete(userId, req.ip, dto);
  }

  /**
   * Hard-purge. Full GDPR erasure right now. Throttled tighter at 2
   * attempts per 5 minutes — this is the irreversible path.
   */
  @Post('me/purge')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle({ default: { limit: 2, ttl: 5 * 60 * 1000 } })
  async purgeMe(
    @CurrentUser('id') userId: string,
    @Body() dto: DeleteAccountDto,
    @Req() req: Request,
  ): Promise<void> {
    await this.accountService.hardPurge(userId, req.ip, dto);
  }
}
