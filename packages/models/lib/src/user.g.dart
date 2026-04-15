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
  googleId: json['googleId'] as String?,
  appleId: json['appleId'] as String?,
  appleEmailIsPrivateRelay: json['appleEmailIsPrivateRelay'] as bool? ?? false,
  appleConsentRevokedAt: json['appleConsentRevokedAt'] == null
      ? null
      : DateTime.parse(json['appleConsentRevokedAt'] as String),
  appleAccountDeletedAt: json['appleAccountDeletedAt'] == null
      ? null
      : DateTime.parse(json['appleAccountDeletedAt'] as String),
  lastReminderAt: json['lastReminderAt'] == null
      ? null
      : DateTime.parse(json['lastReminderAt'] as String),
  lastProfileReminderAt: json['lastProfileReminderAt'] == null
      ? null
      : DateTime.parse(json['lastProfileReminderAt'] as String),
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
  'googleId': instance.googleId,
  'appleId': instance.appleId,
  'appleEmailIsPrivateRelay': instance.appleEmailIsPrivateRelay,
  'appleConsentRevokedAt': instance.appleConsentRevokedAt?.toIso8601String(),
  'appleAccountDeletedAt': instance.appleAccountDeletedAt?.toIso8601String(),
  'lastReminderAt': instance.lastReminderAt?.toIso8601String(),
  'lastProfileReminderAt': instance.lastProfileReminderAt?.toIso8601String(),
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

_PatchMeDto _$PatchMeDtoFromJson(Map<String, dynamic> json) => _PatchMeDto(
  displayName: json['displayName'] as String?,
  username: json['username'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  dateOfBirth: json['dateOfBirth'] as String?,
  birthdaySkipped: json['birthdaySkipped'] as bool?,
  onboardingProgress: $enumDecodeNullable(
    _$OnboardingProgressEnumMap,
    json['onboardingProgress'],
  ),
);

Map<String, dynamic> _$PatchMeDtoToJson(_PatchMeDto instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'dateOfBirth': instance.dateOfBirth,
      'birthdaySkipped': instance.birthdaySkipped,
      'onboardingProgress':
          _$OnboardingProgressEnumMap[instance.onboardingProgress],
    };

_TutorialCompleteDto _$TutorialCompleteDtoFromJson(Map<String, dynamic> json) =>
    _TutorialCompleteDto(version: (json['version'] as num).toInt());

Map<String, dynamic> _$TutorialCompleteDtoToJson(
  _TutorialCompleteDto instance,
) => <String, dynamic>{'version': instance.version};

_UpdateUserDto _$UpdateUserDtoFromJson(Map<String, dynamic> json) =>
    _UpdateUserDto(
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UpdateUserDtoToJson(_UpdateUserDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'dateOfBirth': instance.dateOfBirth,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  likes: json['likes'] as bool?,
  comments: json['comments'] as bool?,
  follows: json['follows'] as bool?,
  messages: json['messages'] as bool?,
  marketing: json['marketing'] as bool?,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'likes': instance.likes,
  'comments': instance.comments,
  'follows': instance.follows,
  'messages': instance.messages,
  'marketing': instance.marketing,
};

_PrivacyPreferences _$PrivacyPreferencesFromJson(Map<String, dynamic> json) =>
    _PrivacyPreferences(
      showOnlineStatus: json['showOnlineStatus'] as bool?,
      showLastActive: json['showLastActive'] as bool?,
      showLocation: json['showLocation'] as bool?,
      allowStrangerMessages: json['allowStrangerMessages'] as bool?,
    );

Map<String, dynamic> _$PrivacyPreferencesToJson(_PrivacyPreferences instance) =>
    <String, dynamic>{
      'showOnlineStatus': instance.showOnlineStatus,
      'showLastActive': instance.showLastActive,
      'showLocation': instance.showLocation,
      'allowStrangerMessages': instance.allowStrangerMessages,
    };

_UpdateUserPreferencesDto _$UpdateUserPreferencesDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateUserPreferencesDto(
  notifications: json['notifications'] == null
      ? null
      : NotificationPreferences.fromJson(
          json['notifications'] as Map<String, dynamic>,
        ),
  privacy: json['privacy'] == null
      ? null
      : PrivacyPreferences.fromJson(json['privacy'] as Map<String, dynamic>),
  feedWeights: (json['feedWeights'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$UpdateUserPreferencesDtoToJson(
  _UpdateUserPreferencesDto instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'privacy': instance.privacy,
  'feedWeights': instance.feedWeights,
};
