// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'creatorId': instance.creatorId,
  'creator': instance.creator,
  'title': instance.title,
  'description': instance.description,
  'priceCents': instance.priceCents,
  'currency': instance.currency,
  'condition': instance.condition,
  'isDeal': instance.isDeal,
  'originalPriceCents': instance.originalPriceCents,
  'thumbnailUrl': instance.thumbnailUrl,
  'status': instance.status,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'createdAt': instance.createdAt?.toIso8601String(),
};

Map<String, dynamic> _$ProductPageToJson(_ProductPage instance) =>
    <String, dynamic>{
      'hasMore': instance.hasMore,
      'items': instance.items,
      'nextCursor': instance.nextCursor,
    };
