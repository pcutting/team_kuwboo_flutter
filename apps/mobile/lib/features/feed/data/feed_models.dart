/// Data models for the live feed endpoints.
///
/// Shapes mirror the NestJS DTO / entity serialization (snake-case is not
/// used — the backend returns camelCase JSON via class-transformer defaults).
///
/// The backend's `Content` entity uses Single Table Inheritance with a
/// `type` discriminator. Concrete subtypes (Video, Post, Product) are
/// serialized with their subclass fields alongside the common Content
/// columns (id, creator, counts, timestamps).

/// Slim creator info attached to every content item.
class FeedCreator {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool? isBot;

  const FeedCreator({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isBot,
  });

  factory FeedCreator.fromJson(Map<String, dynamic> json) => FeedCreator(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        isBot: json['isBot'] as bool?,
      );
}

/// Common fields shared by every feed item.
class FeedItem {
  final String id;
  final String type; // VIDEO | POST | PRODUCT
  final FeedCreator creator;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final DateTime createdAt;
  final Map<String, dynamic> raw;

  const FeedItem({
    required this.id,
    required this.type,
    required this.creator,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.viewCount,
    required this.createdAt,
    required this.raw,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'];
    return FeedItem(
      id: json['id'] as String,
      type: (json['type'] as String?) ?? 'POST',
      creator: creator is Map<String, dynamic>
          ? FeedCreator.fromJson(creator)
          : const FeedCreator(id: '', name: ''),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      raw: json,
    );
  }

  /// Convenience: the video URL if this item is a VIDEO, else null.
  String? get videoUrl => raw['videoUrl'] as String?;

  /// Convenience: thumbnail for videos.
  String? get thumbnailUrl => raw['thumbnailUrl'] as String?;

  /// Convenience: caption (videos) / text (posts).
  String? get caption => (raw['caption'] as String?) ?? (raw['text'] as String?);

  /// Convenience: product title.
  String? get title => raw['title'] as String?;

  /// Convenience: price in minor units (pence).
  int? get priceCents {
    final p = raw['priceCents'];
    return p is num ? p.toInt() : null;
  }

  /// Convenience: product currency.
  String get currency => (raw['currency'] as String?) ?? 'GBP';

  /// Convenience: product condition enum value as-is.
  String? get condition => raw['condition'] as String?;
}

/// Paginated feed response — matches `FeedResult` in `feed.service.ts`.
class FeedPage {
  final List<FeedItem> items;
  final String? nextCursor;
  final bool hasMore;

  const FeedPage({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  factory FeedPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return FeedPage(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(FeedItem.fromJson)
          .toList(growable: false),
      nextCursor: json['nextCursor'] as String?,
      hasMore: (json['hasMore'] as bool?) ?? false,
    );
  }
}

/// A nearby user returned by `GET /yoyo/nearby`.
class NearbyUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final int distanceMeters;

  const NearbyUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.distanceMeters,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) => NearbyUser(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
      );
}
