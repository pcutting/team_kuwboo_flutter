// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerRating _$SellerRatingFromJson(Map<String, dynamic> json) =>
    _SellerRating(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      productId: json['productId'] as String,
      rating: (json['rating'] as num).toInt(),
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SellerRatingToJson(_SellerRating instance) =>
    <String, dynamic>{
      'id': instance.id,
      'buyerId': instance.buyerId,
      'sellerId': instance.sellerId,
      'productId': instance.productId,
      'rating': instance.rating,
      'review': instance.review,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_SellerRatingPage _$SellerRatingPageFromJson(Map<String, dynamic> json) =>
    _SellerRatingPage(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => SellerRating.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SellerRating>[],
      nextCursor: json['nextCursor'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$SellerRatingPageToJson(_SellerRatingPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
      'averageRating': instance.averageRating,
    };
