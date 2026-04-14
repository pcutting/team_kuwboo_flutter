// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  username: json['username'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  birthdaySkipped: json['birthdaySkipped'] as bool? ?? false,
  onboardingProgress:
      $enumDecodeNullable(
        _$OnboardingProgressEnumMap,
        json['onboardingProgress'],
      ) ??
      OnboardingProgress.welcome,
  profileCompletenessPct:
      (json['profileCompletenessPct'] as num?)?.toInt() ?? 0,
  tutorialVersion: (json['tutorialVersion'] as num?)?.toInt() ?? 0,
  tutorialCompletedAt: json['tutorialCompletedAt'] == null
      ? null
      : DateTime.parse(json['tutorialCompletedAt'] as String),
  ageVerificationStatus:
      $enumDecodeNullable(
        _$AgeVerificationStatusEnumMap,
        json['ageVerificationStatus'],
      ) ??
      AgeVerificationStatus.selfDeclared,
  role: $enumDecodeNullable(_$RoleEnumMap, json['role']) ?? Role.user,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  onlineStatus:
      $enumDecodeNullable(_$OnlineStatusEnumMap, json['onlineStatus']) ??
      OnlineStatus.offline,
  isBot: json['isBot'] as bool? ?? false,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'email': instance.email,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'username': instance.username,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'birthdaySkipped': instance.birthdaySkipped,
  'onboardingProgress':
      _$OnboardingProgressEnumMap[instance.onboardingProgress]!,
  'profileCompletenessPct': instance.profileCompletenessPct,
  'tutorialVersion': instance.tutorialVersion,
  'tutorialCompletedAt': instance.tutorialCompletedAt?.toIso8601String(),
  'ageVerificationStatus':
      _$AgeVerificationStatusEnumMap[instance.ageVerificationStatus]!,
  'role': _$RoleEnumMap[instance.role]!,
  'status': _$UserStatusEnumMap[instance.status]!,
  'onlineStatus': _$OnlineStatusEnumMap[instance.onlineStatus]!,
  'isBot': instance.isBot,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$OnboardingProgressEnumMap = {
  OnboardingProgress.welcome: 'welcome',
  OnboardingProgress.method: 'method',
  OnboardingProgress.phone: 'phone',
  OnboardingProgress.otp: 'otp',
  OnboardingProgress.birthday: 'birthday',
  OnboardingProgress.profile: 'profile',
  OnboardingProgress.interests: 'interests',
  OnboardingProgress.tutorial: 'tutorial',
  OnboardingProgress.complete: 'complete',
};

const _$AgeVerificationStatusEnumMap = {
  AgeVerificationStatus.unverified: 'unverified',
  AgeVerificationStatus.selfDeclared: 'self_declared',
  AgeVerificationStatus.providerVerified: 'provider_verified',
  AgeVerificationStatus.failed: 'failed',
};

const _$RoleEnumMap = {
  Role.user: 'USER',
  Role.moderator: 'MODERATOR',
  Role.admin: 'ADMIN',
  Role.superAdmin: 'SUPER_ADMIN',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'ACTIVE',
  UserStatus.suspended: 'SUSPENDED',
  UserStatus.banned: 'BANNED',
  UserStatus.deactivated: 'DEACTIVATED',
};

const _$OnlineStatusEnumMap = {
  OnlineStatus.online: 'ONLINE',
  OnlineStatus.away: 'AWAY',
  OnlineStatus.offline: 'OFFLINE',
};
