import 'package:freezed_annotation/freezed_annotation.dart';

part 'auction.freezed.dart';
part 'auction.g.dart';

@freezed
abstract class Auction with _$Auction {
  const factory Auction({
    required String id,
    required String productId,
    required int startPriceCents,
    required int currentPriceCents,
    required int minIncrementCents,
    required DateTime startsAt,
    required DateTime endsAt,
    required String status,
    String? winnerId,
    required DateTime createdAt,
  }) = _Auction;

  factory Auction.fromJson(Map<String, dynamic> json) =>
      _$AuctionFromJson(json);
}
