// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Credential _$CredentialFromJson(Map<String, dynamic> json) => _Credential(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$CredentialTypeEnumMap, json['type']),
  identifier: json['identifier'] as String,
  providerData: json['providerData'] as Map<String, dynamic>?,
  verifiedAt: DateTime.parse(json['verifiedAt'] as String),
  isPrimary: json['isPrimary'] as bool? ?? false,
  revokedAt: json['revokedAt'] == null
      ? null
      : DateTime.parse(json['revokedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
);

Map<String, dynamic> _$CredentialToJson(_Credential instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$CredentialTypeEnumMap[instance.type]!,
      'identifier': instance.identifier,
      'providerData': instance.providerData,
      'verifiedAt': instance.verifiedAt.toIso8601String(),
      'isPrimary': instance.isPrimary,
      'revokedAt': instance.revokedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
    };

const _$CredentialTypeEnumMap = {
  CredentialType.phone: 'phone',
  CredentialType.email: 'email',
  CredentialType.google: 'google',
  CredentialType.apple: 'apple',
};
