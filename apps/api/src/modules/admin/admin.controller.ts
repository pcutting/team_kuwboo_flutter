import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Query,
  Body,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { AdminAuditService } from './admin-audit.service';
import { AdminAnalyticsService } from './admin-analytics.service';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';
import { UpdateUserRoleDto } from './dto/update-user-role.dto';
import { UpdateContentStatusDto } from './dto/update-content-status.dto';
import { SuspendUserDto } from './dto/suspend-user.dto';
import { WarnUserDto } from './dto/warn-user.dto';
import { SearchUsersDto } from './dto/search-users.dto';
import { EnforceReportDto } from './dto/enforce-report.dto';
import { UpdateProductStatusDto } from './dto/update-product-status.dto';
import { UpdateCampaignStatusDto } from './dto/update-campaign-status.dto';
import { BroadcastNotificationDto } from './dto/broadcast-notification.dto';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role, UserStatus, ContentStatus, ContentType } from '../../common/enums';

@ApiTags('admin')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly auditService: AdminAuditService,
    private readonly analyticsService: AdminAnalyticsService,
  ) {}

  @Get('users')
  async listUsers(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: UserStatus,
    @Query('role') role?: Role,
    @Query('isBot') isBot?: string,
  ) {
    return this.adminService.listUsers(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      status,
      role,
      isBot !== undefined ? isBot === 'true' : undefined,
    );
  }

  @Get('users/:id/detail')
  async getUserDetail(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.getUserDetail(id);
  }

  @Get('users/:id/content')
  async getUserContent(
    @Param('id', ParseUUIDPipe) id: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.adminService.getUserContent(
      id,
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
  }

  @Get('users/:id/reports')
  async getUserReports(
    @Param('id', ParseUUIDPipe) id: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.adminService.getUserReports(
      id,
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
  }

  @Post('users/:id/suspend')
  async suspendUser(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SuspendUserDto,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.suspendUser(id, dto.reason, adminUserId, dto.durationDays);
  }

  @Post('users/:id/warn')
  async warnUser(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: WarnUserDto,
    @CurrentUser('id') adminUserId: string,
  ) {
    await this.adminService.warnUser(id, dto.message, adminUserId);
    return { message: 'Warning issued' };
  }

  @Delete('users/:id/sessions')
  async revokeUserSessions(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.revokeUserSessions(id, adminUserId);
  }

  @Post('users/search')
  async searchUsers(@Body() dto: SearchUsersDto) {
    return this.adminService.searchUsers(
      dto.query,
      dto.page ? parseInt(dto.page, 10) : 1,
      dto.limit ? parseInt(dto.limit, 10) : 20,
    );
  }

  @Patch('users/:id/status')
  async updateUserStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserStatusDto,
    @CurrentUser('role') adminRole: Role,
  ) {
    return this.adminService.updateUserStatus(id, dto.status, adminRole);
  }

  @Patch('users/:id/role')
  @Roles(Role.SUPER_ADMIN)
  async updateUserRole(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserRoleDto,
    @CurrentUser('role') adminRole: Role,
  ) {
    return this.adminService.updateUserRole(id, dto.role, adminRole);
  }

  @Delete('media/:id')
  async deleteMedia(@Param('id', ParseUUIDPipe) id: string) {
    await this.adminService.deleteMedia(id);
    return { message: 'Media deleted' };
  }

  @Get('stats')
  async getStats() {
    return this.adminService.getStats();
  }

  // --- Content Moderation ---

  @Get('content')
  async listContent(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: ContentStatus,
    @Query('type') type?: ContentType,
    @Query('creatorId') creatorId?: string,
  ) {
    return this.adminService.listContent(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      status,
      type,
      creatorId,
    );
  }

  @Get('content/flagged')
  async listFlaggedContent(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.adminService.listFlaggedContent(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
  }

  @Patch('content/:id/status')
  async updateContentStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateContentStatusDto,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.updateContentStatus(id, dto.status, adminUserId);
  }

  @Post('content/:id/restore')
  async restoreContent(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.restoreContent(id, adminUserId);
  }

  @Post('users/:id/restore')
  async restoreUser(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.restoreUser(adminUserId, id);
  }

  // --- Comment Moderation ---

  @Get('comments')
  async listComments(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('contentId') contentId?: string,
    @Query('authorId') authorId?: string,
  ) {
    return this.adminService.listComments(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      contentId,
      authorId,
    );
  }

  @Delete('comments/:id')
  async deleteComment(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') adminUserId: string,
  ) {
    await this.adminService.deleteComment(id, adminUserId);
    return { message: 'Comment deleted' };
  }

  // --- Report Enforcement ---

  @Post('reports/:id/enforce')
  async enforceReport(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: EnforceReportDto,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.enforceReport(id, dto.action, adminUserId, dto.reason);
  }

  // --- Audit Log ---

  @Get('audit-log')
  async listAuditLog(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('adminUserId') adminUserId?: string,
    @Query('actionType') actionType?: string,
    @Query('targetType') targetType?: string,
  ) {
    return this.auditService.findAll(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      adminUserId,
      actionType,
      targetType,
    );
  }

  // --- Analytics ---

  @Get('analytics/growth')
  async getGrowthMetrics(@Query('days') days?: string) {
    return this.analyticsService.getGrowthMetrics(
      days ? parseInt(days, 10) : 30,
    );
  }

  @Get('analytics/engagement')
  async getEngagementMetrics() {
    return this.analyticsService.getEngagementMetrics();
  }

  @Get('analytics/content')
  async getContentBreakdown() {
    return this.analyticsService.getContentBreakdown();
  }

  @Get('analytics/active-users')
  async getActiveUsers(@Query('days') days?: string) {
    return this.analyticsService.getActiveUsers(
      days ? parseInt(days, 10) : 30,
    );
  }

  // --- Sessions ---

  @Get('sessions/stats')
  async getSessionStats() {
    return this.analyticsService.getSessionStats();
  }

  // --- System Health ---

  @Get('system/health')
  async getSystemHealth() {
    return this.adminService.getSystemHealth();
  }

  // --- Marketplace Moderation ---

  @Get('marketplace/products')
  async listProducts(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
  ) {
    return this.adminService.listProducts(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      status,
    );
  }

  @Patch('marketplace/products/:id/status')
  async updateProductStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateProductStatusDto,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.updateProductStatus(id, dto.status, adminUserId);
  }

  @Get('marketplace/auctions')
  async listAuctions(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
  ) {
    return this.adminService.listAuctions(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      status,
    );
  }

  @Post('marketplace/auctions/:id/cancel')
  async cancelAuction(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.cancelAuction(id, adminUserId);
  }

  // --- Sponsored Campaign Management ---

  @Get('sponsored/campaigns')
  async listCampaigns(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
  ) {
    return this.adminService.listCampaigns(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      status,
    );
  }

  @Patch('sponsored/campaigns/:id/status')
  async updateCampaignStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCampaignStatusDto,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.updateCampaignStatus(id, dto.status, adminUserId);
  }

  // --- Broadcast Notification ---

  @Post('notifications/broadcast')
  async broadcastNotification(
    @Body() dto: BroadcastNotificationDto,
    @CurrentUser('id') adminUserId: string,
  ) {
    return this.adminService.broadcastNotification(
      dto.title,
      dto.message,
      adminUserId,
      dto.targetRole,
    );
  }
}
