import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'content.freezed.dart';
part 'content.g.dart';

/// Slim creator info attached to a feed item when the backend populates
/// `creator` on a Content row (feed, trending, discover endpoints).
@freezed
abstract class FeedCreator with _$FeedCreator {
  const factory FeedCreator({
    required String id,
    @Default('') String name,
    String? avatarUrl,
    @Default(false) bool isBot,
  }) = _FeedCreator;

  factory FeedCreator.fromJson(Map<String, dynamic> json) =>
      _$FeedCreatorFromJson(json);
}

/// A Content row from the backend's Single-Table-Inheritance `content`
/// table. All subtype-specific fields (`videoUrl`, `caption`, `text`,
/// `title`, `priceCents`, …) are optional on the shared shape so one
/// freezed class can represent rows across the feed / trending / discover
/// / product endpoints without a runtime type switch in UI code.
@freezed
abstract class Content with _$Content {
  const factory Content({
    required String id,
    required ContentType type,
    required String creatorId,
    FeedCreator? creator,
    @Default(Visibility.public_) Visibility visibility,
    @Default(ContentTier.free) ContentTier tier,
    @Default(ContentStatus.active) ContentStatus status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int viewCount,
    @Default(0) int shareCount,
    @Default(0) int saveCount,
    required DateTime createdAt,
    // Video subtype
    String? videoUrl,
    String? thumbnailUrl,
    int? durationSeconds,
    String? caption,
    // Post subtype
    String? text,
    PostSubType? subType,
    // Product subtype (also surfaced as `Product` for the marketplace API)
    String? title,
    int? priceCents,
    @Default('GBP') String currency,
    String? condition,
  }) = _Content;

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);
}

@freezed
abstract class Video with _$Video {
  const factory Video({
    required String id,
    @Default(ContentType.video) ContentType type,
    required String creatorId,
    @Default(Visibility.public_) Visibility visibility,
    @Default(ContentTier.free) ContentTier tier,
    @Default(ContentStatus.active) ContentStatus status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int viewCount,
    @Default(0) int shareCount,
    @Default(0) int saveCount,
    required String videoUrl,
    String? thumbnailUrl,
    required int durationSeconds,
    String? caption,
    required DateTime createdAt,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    @Default(ContentType.post) ContentType type,
    required String creatorId,
    @Default(Visibility.public_) Visibility visibility,
    @Default(ContentTier.free) ContentTier tier,
    @Default(ContentStatus.active) ContentStatus status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int viewCount,
    @Default(0) int shareCount,
    @Default(0) int saveCount,
    required String text,
    @Default(PostSubType.standard) PostSubType subType,
    required DateTime createdAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
