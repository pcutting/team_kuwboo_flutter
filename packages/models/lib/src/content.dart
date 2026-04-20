import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'content.freezed.dart';
part 'content.g.dart';

// The backend serializes MikroORM rows with a populated `creator: {id, ...}`
// object and no flat `creatorId` field. Accept either shape.
Object? _readCreatorId(Map input, String key) {
  final direct = input['creatorId'];
  if (direct != null) return direct;
  final creator = input['creator'];
  if (creator is Map) return creator['id'];
  return null;
}

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
    // `id`, `creatorId`, and `createdAt` are nullable because the backend
    // occasionally returns rows where these columns are null on the feed
    // endpoints (`/feed?tab=video`, `/feed?tab=social`). Keeping them
    // required crashed the whole feed as a cast error during
    // `_$ContentFromJson`. Rows with a null id are filtered out upstream
    // in the mobile feed provider because they can't be liked, opened,
    // or used as a stable widget key.
    String? id,
    required ContentType type,
    @JsonKey(readValue: _readCreatorId) String? creatorId,
    FeedCreator? creator,
    @Default(Visibility.public_) Visibility visibility,
    @Default(ContentTier.free) ContentTier tier,
    @Default(ContentStatus.active) ContentStatus status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int viewCount,
    @Default(0) int shareCount,
    @Default(0) int saveCount,
    DateTime? createdAt,
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
    @JsonKey(readValue: _readCreatorId) required String creatorId,
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
    @JsonKey(readValue: _readCreatorId) required String creatorId,
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

// ─── DTOs ────────────────────────────────────────────────────────────
//
// Plain request payload classes (no Freezed / build_runner) matching the
// canonical backend DTOs:
//   apps/api/src/modules/content/dto/create-video.dto.ts
//   apps/api/src/modules/content/dto/create-post.dto.ts
//   apps/api/src/modules/content/dto/set-interest-tags.dto.ts

/// POST `/content/videos` body.
class CreateVideoDto {
  const CreateVideoDto({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    this.caption,
    this.musicId,
    this.visibility,
    this.latitude,
    this.longitude,
    this.locationName,
    this.tags,
  });

  final String videoUrl;
  final String thumbnailUrl;

  /// 1..300 (seconds) per backend validation.
  final int durationSeconds;
  final String? caption;
  final String? musicId;
  final Visibility? visibility;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final List<String>? tags;

  Map<String, dynamic> toJson() => {
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'durationSeconds': durationSeconds,
        if (caption != null) 'caption': caption,
        if (musicId != null) 'musicId': musicId,
        if (visibility != null) 'visibility': visibility!.value,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationName != null) 'locationName': locationName,
        if (tags != null) 'tags': tags,
      };
}

/// POST `/content/posts` body.
class CreatePostDto {
  const CreatePostDto({
    required this.text,
    this.subType,
    this.isPinned,
    this.visibility,
    this.latitude,
    this.longitude,
    this.locationName,
    this.tags,
  });

  final String text;
  final PostSubType? subType;
  final bool? isPinned;
  final Visibility? visibility;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final List<String>? tags;

  Map<String, dynamic> toJson() => {
        'text': text,
        if (subType != null) 'subType': subType!.value,
        if (isPinned != null) 'isPinned': isPinned,
        if (visibility != null) 'visibility': visibility!.value,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationName != null) 'locationName': locationName,
        if (tags != null) 'tags': tags,
      };
}

/// POST `/content/:id/interest-tags` and
/// POST `/admin/content/:id/interest-tags` body.
///
/// Note: backend uses snake_case `interest_ids` (not camelCase) — matches
/// `SetInterestTagsDto` in `apps/api`.
class SetInterestTagsDto {
  const SetInterestTagsDto({required this.interestIds});

  /// Up to 20 Interest UUIDs (backend enforces `ArrayMaxSize(20)`).
  final List<String> interestIds;

  Map<String, dynamic> toJson() => {
        'interest_ids': interestIds,
      };
}

/// Row in the `{interest_tags: [...]}` response from
/// GET `/content/:id/interest-tags`. All keys are snake_case on the wire.
class ContentInterestTag {
  const ContentInterestTag({
    required this.interestId,
    required this.slug,
    required this.label,
    this.confidence,
    this.assignedAt,
  });

  final String interestId;
  final String slug;
  final String label;
  final double? confidence;
  final DateTime? assignedAt;

  factory ContentInterestTag.fromJson(Map<String, dynamic> json) {
    final conf = json['confidence'];
    final assigned = json['assigned_at'];
    return ContentInterestTag(
      interestId: json['interest_id'] as String,
      slug: json['slug'] as String,
      label: json['label'] as String,
      confidence: conf == null ? null : (conf as num).toDouble(),
      assignedAt: assigned == null ? null : DateTime.parse(assigned as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'interest_id': interestId,
        'slug': slug,
        'label': label,
        if (confidence != null) 'confidence': confidence,
        if (assignedAt != null) 'assigned_at': assignedAt!.toIso8601String(),
      };
}

