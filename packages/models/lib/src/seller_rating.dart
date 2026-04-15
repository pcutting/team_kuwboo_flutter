import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_rating.freezed.dart';
part 'seller_rating.g.dart';

/// A buyer's rating of a seller for a specific product purchase.
///
/// Backend field is `rating` (1-5 smallint) not `stars` — kept as-is
/// to match `SellerRating.rating` on the NestJS entity.
@freezed
abstract class SellerRating with _$SellerRating {
  const factory SellerRating({
    required String id,
    required String buyerId,
    required String sellerId,
    required String productId,
    required int rating,
    String? review,
    required DateTime createdAt,
  }) = _SellerRating;

  factory SellerRating.fromJson(Map<String, dynamic> json) =>
      _$SellerRatingFromJson(json);
}

/// Paginated seller-rating response. Backend also returns an
/// `averageRating` summary alongside the cursor page.
@freezed
abstract class SellerRatingPage with _$SellerRatingPage {
  const factory SellerRatingPage({
    @Default(<SellerRating>[]) List<SellerRating> items,
    String? nextCursor,
    @Default(0) double averageRating,
  }) = _SellerRatingPage;

  const SellerRatingPage._();

  factory SellerRatingPage.fromJson(Map<String, dynamic> json) =>
      _$SellerRatingPageFromJson(json);

  bool get hasMore => nextCursor != null;
}
