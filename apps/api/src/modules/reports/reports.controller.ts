import { Controller, Post, Get, Patch, Body, Param, Query, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { IsEnum, IsUUID, IsString, IsOptional, MaxLength } from 'class-validator';
import { ReportsService } from './reports.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { Role, ReportTargetType, ReportReason, ReportStatus } from '../../common/enums';

class CreateReportDto {
  @IsEnum(ReportTargetType)
  targetType!: ReportTargetType;

  @IsUUID()
  targetId!: string;

  @IsEnum(ReportReason)
  reason!: ReportReason;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string;
}

class ReviewReportDto {
  @IsEnum(ReportStatus)
  status!: ReportStatus.DISMISSED | ReportStatus.RESOLVED;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}

@ApiTags('reports')
@ApiBearerAuth()
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post()
  async create(@CurrentUser('id') userId: string, @Body() dto: CreateReportDto) {
    return this.reportsService.create(userId, dto.targetType, dto.targetId, dto.reason, dto.description);
  }

  @Get()
  @Roles(Role.MODERATOR)
  async getPending(@Query('page') page?: string, @Query('limit') limit?: string) {
    return this.reportsService.getPending(page ? parseInt(page, 10) : 1, limit ? parseInt(limit, 10) : 20);
  }

  @Patch(':id/review')
  @Roles(Role.MODERATOR)
  async review(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('id') reviewerId: string,
    @Body() dto: ReviewReportDto,
  ) {
    return this.reportsService.review(id, reviewerId, dto.status, dto.notes);
  }
}
