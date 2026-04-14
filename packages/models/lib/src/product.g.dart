// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  creatorId: json['creatorId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  priceCents: (json['priceCents'] as num).toInt(),
  currency: json['currency'] as String? ?? 'GBP',
  condition: json['condition'] as String,
  isDeal: json['isDeal'] as bool? ?? false,
  originalPriceCents: (json['originalPriceCents'] as num?)?.toInt(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
  status: json['status'] as String? ?? 'ACTIVE',
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'creatorId': instance.creatorId,
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
  'createdAt': instance.createdAt.toIso8601String(),
};

_ProductPage _$ProductPageFromJson(Map<String, dynamic> json) => _ProductPage(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Product>[],
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$ProductPageToJson(_ProductPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
    };
