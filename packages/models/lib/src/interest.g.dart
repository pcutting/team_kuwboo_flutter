// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Interest _$InterestFromJson(Map<String, dynamic> json) => _Interest(
  id: json['id'] as String,
  slug: json['slug'] as String,
  label: json['label'] as String,
  category: json['category'] as String?,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$InterestToJson(_Interest instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'label': instance.label,
  'category': instance.category,
  'displayOrder': instance.displayOrder,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_UserInterest _$UserInterestFromJson(Map<String, dynamic> json) =>
    _UserInterest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      interestId: json['interestId'] as String,
      selectedAt: DateTime.parse(json['selectedAt'] as String),
    );

Map<String, dynamic> _$UserInterestToJson(_UserInterest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'interestId': instance.interestId,
      'selectedAt': instance.selectedAt.toIso8601String(),
    };

_InterestSignal _$InterestSignalFromJson(Map<String, dynamic> json) =>
    _InterestSignal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      interestId: json['interestId'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
    );

Map<String, dynamic> _$InterestSignalToJson(_InterestSignal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'interestId': instance.interestId,
      'weight': instance.weight,
      'eventCount': instance.eventCount,
      'lastSeenAt': instance.lastSeenAt.toIso8601String(),
    };
