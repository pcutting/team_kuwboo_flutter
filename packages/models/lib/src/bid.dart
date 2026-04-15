import 'package:freezed_annotation/freezed_annotation.dart';

import 'auction.dart';

part 'bid.freezed.dart';
part 'bid.g.dart';

/// A bid placed on an auction.
@freezed
abstract class Bid with _$Bid {
  const factory Bid({
    required String id,
    required String auctionId,
    required String bidderId,
    required int amountCents,
    required DateTime placedAt,
  }) = _Bid;

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
}

/// Response from `GET /auctions/:id` — auction plus its bids, sorted
/// by amount descending (highest bid first).
@freezed
abstract class AuctionWithBids with _$AuctionWithBids {
  const factory AuctionWithBids({
    required Auction auction,
    @Default(<Bid>[]) List<Bid> bids,
  }) = _AuctionWithBids;

  factory AuctionWithBids.fromJson(Map<String, dynamic> json) =>
      _$AuctionWithBidsFromJson(json);
}
