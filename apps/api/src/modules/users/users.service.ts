import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { User } from './entities/user.entity';
import { UserPreferences } from './entities/user-preferences.entity';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';
import { PatchMeDto } from './dto/patch-me.dto';
import { Credential } from '../credentials/entities/credential.entity';
import { CredentialType, OnboardingProgress } from '../../common/enums';

/**
 * Username rules: 3–30 chars, [a-zA-Z0-9_.], case-insensitive uniqueness
 * enforced at the DB via the `users_username_unique` constraint.
 */
const USERNAME_REGEX = /^[a-zA-Z0-9_.]{3,30}$/;

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

  /**
   * Contract-correct PATCH /users/me. Applies a partial update,
   * recomputes onboarding_progress + profile_completeness_pct, and
   * persists atomically.
   */
  async patchMe(userId: string, dto: PatchMeDto): Promise<User> {
    const user = await this.findById(userId);

    if (dto.displayName !== undefined) user.name = dto.displayName;
    if (dto.avatarUrl !== undefined) user.avatarUrl = dto.avatarUrl;
    if (dto.bio !== undefined) user.bio = dto.bio;

    if (dto.username !== undefined) {
      if (!USERNAME_REGEX.test(dto.username)) {
        throw new ConflictException({
          code: 'invalid_username',
          message: 'Usernames are 3–30 characters, letters/digits/_/. only.',
        });
      }
      const clash = await this.em.findOne(User, { username: dto.username });
      if (clash && clash.id !== userId) {
        throw new ConflictException({
          code: 'username_taken',
          message: 'That username is already taken.',
        });
      }
      user.username = dto.username;
    }

    if (dto.dateOfBirth !== undefined) {
      user.dateOfBirth = dto.dateOfBirth ? new Date(dto.dateOfBirth) : undefined;
      user.birthdaySkipped = false;
    }
    if (dto.birthdaySkipped === true) {
      user.birthdaySkipped = true;
    }

    if (dto.onboardingProgress !== undefined) {
      user.onboardingProgress = dto.onboardingProgress;
    } else {
      user.onboardingProgress = this.deriveOnboardingProgress(user);
    }

    const credentials = await this.em.find(Credential, {
      user: userId,
      revokedAt: null,
    });
    user.profileCompletenessPct = UsersService.computeCompleteness(user, credentials);

    await this.em.flush();
    return user;
  }

  /**
   * Profile completeness formula per IDENTITY_CONTRACT §8. Pure function
   * exposed as a static so it is trivially unit-testable.
   *
   * Inputs: partial user state + active credentials list. `interests`
   * count is injected by the caller if available; for now we pass 0 to
   * keep this function independent of the D1b interests module.
   */
  static computeCompleteness(
    user: Pick<
      User,
      'dateOfBirth' | 'name' | 'username' | 'avatarUrl' | 'tutorialCompletedAt'
    >,
    credentials: Array<Pick<Credential, 'type'>>,
    interestsCount: number = 0,
  ): number {
    let pct = 0;
    if (user.dateOfBirth) pct += 10;
    if (user.name && user.name.trim().length > 0) pct += 15;
    if (user.username) pct += 15;
    if (user.avatarUrl) pct += 15;
    if (interestsCount >= 3) pct += 15;
    if (credentials.some((c) => c.type === CredentialType.PHONE)) pct += 10;
    if (credentials.some((c) => c.type === CredentialType.EMAIL)) pct += 10;
    if (user.tutorialCompletedAt) pct += 10;
    return Math.min(100, pct);
  }

  async usernameAvailable(handle: string): Promise<boolean> {
    if (!USERNAME_REGEX.test(handle)) return false;
    const existing = await this.em.findOne(User, { username: handle });
    return !existing;
  }

  async markTutorialComplete(userId: string, version: number): Promise<User> {
    const user = await this.findById(userId);
    user.tutorialVersion = version;
    user.tutorialCompletedAt = new Date();
    user.onboardingProgress = OnboardingProgress.COMPLETE;
    const credentials = await this.em.find(Credential, {
      user: userId,
      revokedAt: null,
    });
    user.profileCompletenessPct = UsersService.computeCompleteness(user, credentials);
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

  /**
   * Walk the onboarding ladder per IDENTITY_CONTRACT §5. We never step
   * backwards — a user who has already reached `profile` doesn't regress
   * to `birthday` if they clear their DOB.
   */
  private deriveOnboardingProgress(user: User): OnboardingProgress {
    const current = user.onboardingProgress ?? OnboardingProgress.WELCOME;
    const order = [
      OnboardingProgress.WELCOME,
      OnboardingProgress.METHOD,
      OnboardingProgress.PHONE,
      OnboardingProgress.OTP,
      OnboardingProgress.BIRTHDAY,
      OnboardingProgress.PROFILE,
      OnboardingProgress.INTERESTS,
      OnboardingProgress.TUTORIAL,
      OnboardingProgress.COMPLETE,
    ];

    let next = current;
    if (
      (user.dateOfBirth || user.birthdaySkipped) &&
      order.indexOf(next) < order.indexOf(OnboardingProgress.BIRTHDAY)
    ) {
      next = OnboardingProgress.BIRTHDAY;
    }
    if (
      user.name &&
      user.username &&
      user.avatarUrl &&
      order.indexOf(next) < order.indexOf(OnboardingProgress.PROFILE)
    ) {
      next = OnboardingProgress.PROFILE;
    }
    return next;
  }
}
