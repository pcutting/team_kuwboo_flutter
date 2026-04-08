import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String creatorId,
    required String title,
    required String description,
    required int priceCents,
    @Default('GBP') String currency,
    required String condition,
    @Default(false) bool isDeal,
    int? originalPriceCents,
    String? thumbnailUrl,
    @Default('ACTIVE') String status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    required DateTime createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
