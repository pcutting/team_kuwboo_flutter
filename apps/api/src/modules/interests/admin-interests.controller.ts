import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { InterestsService } from './interests.service';
import { CreateInterestDto } from './dto/create-interest.dto';
import { UpdateInterestDto } from './dto/update-interest.dto';
import { ReorderInterestsDto } from './dto/reorder-interests.dto';
import { Roles } from '../../common/decorators/roles.decorator';
import { Role } from '../../common/enums';

@ApiTags('admin-interests')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/interests')
export class AdminInterestsController {
  constructor(private readonly service: InterestsService) {}

  @Get()
  async list() {
    const interests = await this.service.adminList();
    return { interests };
  }

  @Post()
  async create(@Body() dto: CreateInterestDto) {
    return this.service.adminCreate(dto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateInterestDto,
  ) {
    return this.service.adminUpdate(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    await this.service.adminSoftDelete(id);
  }

  @Post('reorder')
  async reorder(@Body() dto: ReorderInterestsDto) {
    const interests = await this.service.adminReorder(dto.ordered_ids);
    return { interests };
  }
}
