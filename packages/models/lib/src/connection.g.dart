// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Connection _$ConnectionFromJson(Map<String, dynamic> json) => _Connection(
  id: json['id'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  context: $enumDecode(_$ConnectionContextEnumMap, json['context']),
  status:
      $enumDecodeNullable(_$ConnectionStatusEnumMap, json['status']) ??
      ConnectionStatus.pending,
  moduleScope: $enumDecodeNullable(_$ModuleScopeEnumMap, json['moduleScope']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ConnectionToJson(_Connection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'context': _$ConnectionContextEnumMap[instance.context]!,
      'status': _$ConnectionStatusEnumMap[instance.status]!,
      'moduleScope': _$ModuleScopeEnumMap[instance.moduleScope],
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ConnectionContextEnumMap = {
  ConnectionContext.follow: 'FOLLOW',
  ConnectionContext.friend: 'FRIEND',
  ConnectionContext.match: 'MATCH',
  ConnectionContext.yoyo: 'YOYO',
};

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.pending: 'PENDING',
  ConnectionStatus.active: 'ACTIVE',
  ConnectionStatus.rejected: 'REJECTED',
};

const _$ModuleScopeEnumMap = {
  ModuleScope.video: 'VIDEO',
  ModuleScope.shop: 'SHOP',
  ModuleScope.social: 'SOCIAL',
  ModuleScope.dating: 'DATING',
};
