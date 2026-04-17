import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Canonical Kuwboo user profile. Mirrors `apps/api/src/modules/users/
/// entities/user.entity.ts`. Fields marked optional on the backend
/// (nullable or with defaults) are nullable / `@Default`-ed here.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    String? phone,
    String? email,
    String? name,
    String? avatarUrl,
    String? bio,
    String? username,
    DateTime? dateOfBirth,
    @Default(false) bool birthdaySkipped,
    @Default(OnboardingProgress.welcome) OnboardingProgress onboardingProgress,
    @Default(0) int profileCompletenessPct,
    @Default(0) int tutorialVersion,
    DateTime? tutorialCompletedAt,
    @Default(AgeVerificationStatus.selfDeclared)
    AgeVerificationStatus ageVerificationStatus,
    @Default(Role.user) Role role,
    @Default(UserStatus.active) UserStatus status,
    @Default(OnlineStatus.offline) OnlineStatus onlineStatus,
    @Default(false) bool isBot,
    String? googleId,
    String? appleId,
    @Default(false) bool appleEmailIsPrivateRelay,
    DateTime? appleConsentRevokedAt,
    DateTime? appleAccountDeletedAt,
    DateTime? lastReminderAt,
    DateTime? lastProfileReminderAt,
    DateTime? lastLoginAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Partial update of the authenticated user's own profile (PATCH /users/me).
/// Mirrors `PatchMeDto` in `apps/api/src/modules/users/dto/patch-me.dto.ts`.
///
/// `dobChoice` is sent as the enum's lowercase-snake string; the backend
/// applies the lockstep ageVerificationStatus + birthdaySkipped transitions
/// (see `UsersService.applyDobChoice`).
@freezed
abstract class PatchMeDto with _$PatchMeDto {
  const factory PatchMeDto({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? dateOfBirth,
    bool? birthdaySkipped,
    String? dobChoice,
    OnboardingProgress? onboardingProgress,
  }) = _PatchMeDto;

  factory PatchMeDto.fromJson(Map<String, dynamic> json) =>
      _$PatchMeDtoFromJson(json);
}

/// Tutorial completion marker (POST /users/me/tutorial-complete).
@freezed
abstract class TutorialCompleteDto with _$TutorialCompleteDto {
  const factory TutorialCompleteDto({
    required int version,
  }) = _TutorialCompleteDto;

  factory TutorialCompleteDto.fromJson(Map<String, dynamic> json) =>
      _$TutorialCompleteDtoFromJson(json);
}

/// Admin-style user update (PATCH /users/:id). Distinct from PatchMeDto —
/// this is the legacy-style update used by operators / self for non-
/// identity fields.
@freezed
abstract class UpdateUserDto with _$UpdateUserDto {
  const factory UpdateUserDto({
    String? name,
    String? avatarUrl,
    String? dateOfBirth,
    double? latitude,
    double? longitude,
  }) = _UpdateUserDto;

  factory UpdateUserDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDtoFromJson(json);
}

/// Notification preference toggles. Mirrors `NotificationPreferences` in
/// `apps/api/src/modules/users/entities/user-preferences.entity.ts`.
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    bool? likes,
    bool? comments,
    bool? follows,
    bool? messages,
    bool? marketing,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

/// Privacy preference toggles. Mirrors `PrivacyPreferences` in the same
/// backend entity file.
@freezed
abstract class PrivacyPreferences with _$PrivacyPreferences {
  const factory PrivacyPreferences({
    bool? showOnlineStatus,
    bool? showLastActive,
    bool? showLocation,
    bool? allowStrangerMessages,
  }) = _PrivacyPreferences;

  factory PrivacyPreferences.fromJson(Map<String, dynamic> json) =>
      _$PrivacyPreferencesFromJson(json);
}

/// Partial update of user preferences (PATCH /users/:id/preferences).
@freezed
abstract class UpdateUserPreferencesDto with _$UpdateUserPreferencesDto {
  const factory UpdateUserPreferencesDto({
    NotificationPreferences? notifications,
    PrivacyPreferences? privacy,
    Map<String, double>? feedWeights,
  }) = _UpdateUserPreferencesDto;

  factory UpdateUserPreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserPreferencesDtoFromJson(json);
}
