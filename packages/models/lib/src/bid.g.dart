// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bid _$BidFromJson(Map<String, dynamic> json) => _Bid(
  id: json['id'] as String,
  auctionId: json['auctionId'] as String,
  bidderId: json['bidderId'] as String,
  amountCents: (json['amountCents'] as num).toInt(),
  placedAt: DateTime.parse(json['placedAt'] as String),
);

Map<String, dynamic> _$BidToJson(_Bid instance) => <String, dynamic>{
  'id': instance.id,
  'auctionId': instance.auctionId,
  'bidderId': instance.bidderId,
  'amountCents': instance.amountCents,
  'placedAt': instance.placedAt.toIso8601String(),
};

_AuctionWithBids _$AuctionWithBidsFromJson(Map<String, dynamic> json) =>
    _AuctionWithBids(
      auction: Auction.fromJson(json['auction'] as Map<String, dynamic>),
      bids:
          (json['bids'] as List<dynamic>?)
              ?.map((e) => Bid.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Bid>[],
    );

Map<String, dynamic> _$AuctionWithBidsToJson(_AuctionWithBids instance) =>
    <String, dynamic>{'auction': instance.auction, 'bids': instance.bids};
