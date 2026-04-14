// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isNewUser: json['isNewUser'] as bool? ?? false,
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
      'isNewUser': instance.isNewUser,
    };

_TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => _TokenPair(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$TokenPairToJson(_TokenPair instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

_PendingSsoChallenge _$PendingSsoChallengeFromJson(Map<String, dynamic> json) =>
    _PendingSsoChallenge(
      code: json['code'] as String,
      challengeId: json['challenge_id'] as String,
      email: json['email'] as String,
      requireVerifyEmail: json['require_verify_email'] as bool? ?? true,
    );

Map<String, dynamic> _$PendingSsoChallengeToJson(
  _PendingSsoChallenge instance,
) => <String, dynamic>{
  'code': instance.code,
  'challenge_id': instance.challengeId,
  'email': instance.email,
  'require_verify_email': instance.requireVerifyEmail,
};
