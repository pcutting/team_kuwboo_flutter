import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'content.freezed.dart';
part 'content.g.dart';

@freezed
abstract class Content with _$Content {
  const factory Content({
    required String id,
    required ContentType type,
    required String creatorId,
    @Default(Visibility.public_) Visibility visibility,
    @Default(ContentTier.free) ContentTier tier,
    @Default(ContentStatus.active) ContentStatus status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int viewCount,
    @Default(0) int shareCount,
    @Default(0) int saveCount,
    required DateTime createdAt,
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
