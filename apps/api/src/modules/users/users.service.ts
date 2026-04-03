import { Injectable, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { User } from './entities/user.entity';
import { UserPreferences } from './entities/user-preferences.entity';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';

@Injectable()
export class UsersService {
  constructor(private readonly em: EntityManager) {}

  async findById(id: string): Promise<User> {
    const user = await this.em.findOne(User, { id }, { populate: ['preferences'] });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async findByPhone(phone: string): Promise<User | null> {
    return this.em.findOne(User, { phone });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.em.findOne(User, { email });
  }

  async findByGoogleId(googleId: string): Promise<User | null> {
    return this.em.findOne(User, { googleId });
  }

  async findByAppleId(appleId: string): Promise<User | null> {
    return this.em.findOne(User, { appleId });
  }

  async create(data: { name: string } & Partial<User>): Promise<User> {
    const user = this.em.create(User, data as any);
    const preferences = this.em.create(UserPreferences, { user });
    user.preferences = preferences;
    await this.em.flush();
    return user;
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.findById(id);

    if (dto.name !== undefined) user.name = dto.name;
    if (dto.avatarUrl !== undefined) user.avatarUrl = dto.avatarUrl;
    if (dto.dateOfBirth !== undefined) user.dateOfBirth = new Date(dto.dateOfBirth);
    if (dto.latitude !== undefined && dto.longitude !== undefined) {
      user.lastLocation = { latitude: dto.latitude, longitude: dto.longitude };
    }

    await this.em.flush();
    return user;
  }

  async updatePreferences(userId: string, dto: UpdatePreferencesDto): Promise<UserPreferences> {
    const user = await this.findById(userId);

    if (!user.preferences) {
      user.preferences = this.em.create(UserPreferences, { user });
    }

    const prefs = user.preferences;
    if (dto.notifications) {
      prefs.notifications = { ...prefs.notifications, ...dto.notifications };
    }
    if (dto.privacy) {
      prefs.privacy = { ...prefs.privacy, ...dto.privacy };
    }
    if (dto.feedWeights !== undefined) {
      prefs.feedWeights = dto.feedWeights;
    }

    await this.em.flush();
    return prefs;
  }

  async softDelete(id: string): Promise<void> {
    const user = await this.findById(id);
    user.deletedAt = new Date();
    await this.em.flush();
  }
}
