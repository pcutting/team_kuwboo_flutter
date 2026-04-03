import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  Query,
  Body,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';
import { UpdateUserRoleDto } from './dto/update-user-role.dto';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role, UserStatus } from '../../common/enums';

@ApiTags('admin')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('users')
  async listUsers(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: UserStatus,
    @Query('role') role?: Role,
  ) {
    return this.adminService.listUsers(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      status,
      role,
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
}
