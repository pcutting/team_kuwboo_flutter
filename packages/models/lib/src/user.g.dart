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
  role: $enumDecodeNullable(_$RoleEnumMap, json['role']) ?? Role.user,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  onlineStatus:
      $enumDecodeNullable(_$OnlineStatusEnumMap, json['onlineStatus']) ??
      OnlineStatus.offline,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'email': instance.email,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'role': _$RoleEnumMap[instance.role]!,
  'status': _$UserStatusEnumMap[instance.status]!,
  'onlineStatus': _$OnlineStatusEnumMap[instance.onlineStatus]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$RoleEnumMap = {
  Role.user: 'USER',
  Role.moderator: 'MODERATOR',
  Role.admin: 'ADMIN',
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
