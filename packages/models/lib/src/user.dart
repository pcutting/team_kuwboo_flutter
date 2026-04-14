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
    DateTime? lastLoginAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
