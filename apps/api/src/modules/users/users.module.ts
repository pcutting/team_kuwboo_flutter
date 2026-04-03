import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { User } from './entities/user.entity';
import { UserPreferences } from './entities/user-preferences.entity';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';

@Module({
  imports: [MikroOrmModule.forFeature([User, UserPreferences])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
