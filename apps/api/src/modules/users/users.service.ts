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
import {
  AgeVerificationStatus,
  CredentialType,
  OnboardingProgress,
} from '../../common/enums';
import { DobChoice } from '../../common/enums/dob-choice.enum';

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

    if (dto.dobChoice !== undefined) {
      UsersService.applyDobChoice(user, dto.dobChoice);
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
   * Apply a DOB-choice transition to a user. Kept as a pure static so the
   * Dating guard and tests can share the mapping — the guard derives its
   * 403 code from `ageVerificationStatus` + `dobChoice`, so these two
   * fields must move in lockstep.
   *
   * `PROVIDED` is only valid alongside a real `dateOfBirth`; if the caller
   * sets the choice to PROVIDED without a DOB in the same patch, we leave
   * `ageVerificationStatus` untouched (the existing dateOfBirth branch
   * already set it correctly, or left UNVERIFIED if no DOB exists).
   */
  static applyDobChoice(user: User, choice: DobChoice): void {
    user.dobChoice = choice;
    switch (choice) {
      case DobChoice.PROVIDED:
        if (user.dateOfBirth) {
          user.ageVerificationStatus = AgeVerificationStatus.SELF_DECLARED;
          user.birthdaySkipped = false;
        }
        break;
      case DobChoice.ADULT_SELF_DECLARED:
        user.ageVerificationStatus = AgeVerificationStatus.SELF_DECLARED_ADULT;
        user.birthdaySkipped = false;
        break;
      case DobChoice.PREFER_NOT_TO_SAY:
        user.ageVerificationStatus = AgeVerificationStatus.PREFER_NOT_TO_SAY;
        user.birthdaySkipped = false;
        break;
      case DobChoice.SKIPPED:
        user.birthdaySkipped = true;
        break;
      case DobChoice.PENDING:
        break;
    }
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

  /**
   * Enumerates the human-readable field names missing for profile
   * completeness — one entry per component of the scoring formula that
   * currently contributes 0. Order mirrors the formula and provides a
   * stable, priority-ordered list for nudge body templating.
   *
   * See IDENTITY_CONTRACT §8.
   */
  static computeMissingFields(
    user: Pick<
      User,
      'dateOfBirth' | 'name' | 'username' | 'avatarUrl' | 'tutorialCompletedAt'
    >,
    credentials: Array<Pick<Credential, 'type'>>,
    interestsCount: number = 0,
  ): string[] {
    const missing: string[] = [];
    if (!user.dateOfBirth) missing.push('dob');
    if (!user.name || user.name.trim().length === 0) missing.push('display_name');
    if (!user.username) missing.push('username');
    if (!user.avatarUrl) missing.push('avatar_url');
    if (interestsCount < 3) missing.push('interests');
    if (!credentials.some((c) => c.type === CredentialType.PHONE)) {
      missing.push('primary_phone_verified');
    }
    if (!credentials.some((c) => c.type === CredentialType.EMAIL)) {
      missing.push('primary_email_verified');
    }
    if (!user.tutorialCompletedAt) missing.push('tutorial_completed');
    return missing;
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
   * Flush any pending changes on the given user's managed entity.
   * Narrow helper used by flows (e.g. email verification) that mutate
   * the user instance directly and need to persist without going
   * through one of the richer update methods.
   */
  async flushUser(userId: string): Promise<void> {
    // The caller holds a reference to the same managed User instance
    // this service loaded, so the identity map already tracks the
    // pending changes — a bare flush is enough.
    await this.em.flush();
    // Avoid unused-parameter lint; userId is part of the API for future
    // extension (e.g. partial-flush by ID).
    void userId;
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
