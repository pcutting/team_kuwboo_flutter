// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Auction _$AuctionFromJson(Map<String, dynamic> json) => _Auction(
  id: json['id'] as String,
  productId: json['productId'] as String,
  startPriceCents: (json['startPriceCents'] as num).toInt(),
  currentPriceCents: (json['currentPriceCents'] as num).toInt(),
  minIncrementCents: (json['minIncrementCents'] as num).toInt(),
  startsAt: DateTime.parse(json['startsAt'] as String),
  endsAt: DateTime.parse(json['endsAt'] as String),
  status: json['status'] as String,
  winnerId: json['winnerId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AuctionToJson(_Auction instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'startPriceCents': instance.startPriceCents,
  'currentPriceCents': instance.currentPriceCents,
  'minIncrementCents': instance.minIncrementCents,
  'startsAt': instance.startsAt.toIso8601String(),
  'endsAt': instance.endsAt.toIso8601String(),
  'status': instance.status,
  'winnerId': instance.winnerId,
  'createdAt': instance.createdAt.toIso8601String(),
};
