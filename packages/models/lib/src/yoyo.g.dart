// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yoyo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NearbyUser _$NearbyUserFromJson(Map<String, dynamic> json) => _NearbyUser(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  distanceKm: (json['distanceKm'] as num).toDouble(),
  onlineStatus: json['onlineStatus'] as String?,
);

Map<String, dynamic> _$NearbyUserToJson(_NearbyUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'distanceKm': instance.distanceKm,
      'onlineStatus': instance.onlineStatus,
    };

_YoyoSettings _$YoyoSettingsFromJson(Map<String, dynamic> json) =>
    _YoyoSettings(
      isVisible: json['isVisible'] as bool? ?? true,
      radiusKm: (json['radiusKm'] as num?)?.toInt() ?? 10,
      ageMin: (json['ageMin'] as num?)?.toInt(),
      ageMax: (json['ageMax'] as num?)?.toInt(),
      genderFilter: json['genderFilter'] as String?,
    );

Map<String, dynamic> _$YoyoSettingsToJson(_YoyoSettings instance) =>
    <String, dynamic>{
      'isVisible': instance.isVisible,
      'radiusKm': instance.radiusKm,
      'ageMin': instance.ageMin,
      'ageMax': instance.ageMax,
      'genderFilter': instance.genderFilter,
    };

_Wave _$WaveFromJson(Map<String, dynamic> json) => _Wave(
  id: json['id'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  fromUserName: json['fromUserName'] as String?,
  fromUserAvatar: json['fromUserAvatar'] as String?,
  message: json['message'] as String?,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WaveToJson(_Wave instance) => <String, dynamic>{
  'id': instance.id,
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'fromUserName': instance.fromUserName,
  'fromUserAvatar': instance.fromUserAvatar,
  'message': instance.message,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
};
