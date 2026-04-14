// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_signal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrustSignal _$TrustSignalFromJson(Map<String, dynamic> json) => _TrustSignal(
  id: json['id'] as String,
  userId: json['userId'] as String,
  signalType: json['signalType'] as String,
  delta: (json['delta'] as num).toInt(),
  source: json['source'] as String?,
  reason: json['reason'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TrustSignalToJson(_TrustSignal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'signalType': instance.signalType,
      'delta': instance.delta,
      'source': instance.source,
      'reason': instance.reason,
      'metadata': instance.metadata,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
