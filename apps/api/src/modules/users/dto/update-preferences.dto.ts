import { IsOptional, IsObject } from 'class-validator';
import { NotificationPreferences, PrivacyPreferences } from '../entities/user-preferences.entity';

export class UpdatePreferencesDto {
  @IsOptional()
  @IsObject()
  notifications?: Partial<NotificationPreferences>;

  @IsOptional()
  @IsObject()
  privacy?: Partial<PrivacyPreferences>;

  @IsOptional()
  @IsObject()
  feedWeights?: Record<string, number>;
}
