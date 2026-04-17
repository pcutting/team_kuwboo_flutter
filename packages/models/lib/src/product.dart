import 'package:freezed_annotation/freezed_annotation.dart';

import 'content.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// A marketplace product row. Mirrors the `Product` STI subtype of the
/// shared `content` table on the backend — so the response shape on
/// `/products`, `/products/:id`, and `/auctions` carries the same top-
/// level fields as [Content] (id, type, creator, counts, status) plus
/// the product-specific columns (title, priceCents, condition, …).
///
/// `id`, `description`, `condition`, and `createdAt` are nullable for
/// the same reason [Content] made `id` / `creatorId` / `createdAt`
/// nullable in PR #128: the backend occasionally returns rows where one
/// of these columns is null, and Freezed's generated fromJson would
/// crash the whole list with a type-cast error during decode. Rows with
/// a null id are filtered out at the provider boundary because they
/// can't be tapped, liked, or used as a grid-item key.
///
/// There is no top-level `creatorId` field on the wire — the backend
/// nests the full creator as `creator: { id, name, avatarUrl, … }`.
/// We accept the nested shape via [FeedCreator] and derive
/// [creatorId] from it so call-sites that only need the id don't have
/// to null-check the whole creator object.
@Freezed(toJson: true, fromJson: false)
abstract class Product with _$Product {
  const factory Product({
    String? id,
    String? creatorId,
    FeedCreator? creator,
    String? title,
    String? description,
    @Default(0) int priceCents,
    @Default('GBP') String currency,
    String? condition,
    @Default(false) bool isDeal,
    int? originalPriceCents,
    String? thumbnailUrl,
    @Default('ACTIVE') String status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    DateTime? createdAt,
  }) = _Product;

  /// Hand-rolled decoder: the backend puts the creator under `creator`
  /// (not `creatorId`) on every product response, so we flatten
  /// `creator.id` onto [creatorId] while also keeping the full
  /// [FeedCreator] around for UI that needs the name / avatar.
  factory Product.fromJson(Map<String, dynamic> json) {
    final rawCreator = json['creator'];
    final creator = rawCreator is Map<String, dynamic>
        ? FeedCreator.fromJson(rawCreator)
        : null;
    final rawCreatorId = json['creatorId'];
    final creatorId = rawCreatorId is String
        ? rawCreatorId
        : creator?.id;

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt)
        : null;

    int _int(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    int? _intOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return Product(
      id: json['id'] is String ? json['id'] as String : null,
      creatorId: creatorId,
      creator: creator,
      title: json['title'] is String ? json['title'] as String : null,
      description:
          json['description'] is String ? json['description'] as String : null,
      priceCents: _int(json['priceCents']),
      currency: json['currency'] is String
          ? json['currency'] as String
          : 'GBP',
      condition:
          json['condition'] is String ? json['condition'] as String : null,
      isDeal: json['isDeal'] == true,
      originalPriceCents: _intOrNull(json['originalPriceCents']),
      thumbnailUrl:
          json['thumbnailUrl'] is String ? json['thumbnailUrl'] as String : null,
      status: json['status'] is String ? json['status'] as String : 'ACTIVE',
      likeCount: _int(json['likeCount']),
      commentCount: _int(json['commentCount']),
      createdAt: createdAt,
    );
  }
}

/// Cursor-paginated product list. Backend returns `{items, nextCursor}`
/// with no `hasMore` — the presence of a cursor implies more.
@Freezed(toJson: true, fromJson: false)
abstract class ProductPage with _$ProductPage {
  const factory ProductPage({
    @Default(<Product>[]) List<Product> items,
    String? nextCursor,
  }) = _ProductPage;

  const ProductPage._();

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList()
        : const <Product>[];
    return ProductPage(
      items: items,
      nextCursor:
          json['nextCursor'] is String ? json['nextCursor'] as String : null,
    );
  }

  bool get hasMore => nextCursor != null;
}
