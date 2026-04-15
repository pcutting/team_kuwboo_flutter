/// Content interaction response models.
///
/// Hand-written immutable classes (no build_runner). Values returned
/// from Kuwboo's interactions endpoints: like/save toggle responses and
/// the combined interaction-state projection.
library;

/// Response from `POST /content/:id/like`.
class LikeResponse {
  const LikeResponse({required this.liked, required this.likeCount});

  factory LikeResponse.fromJson(Map<String, dynamic> json) => LikeResponse(
        liked: json['liked'] as bool,
        likeCount: (json['likeCount'] as num).toInt(),
      );

  final bool liked;
  final int likeCount;

  Map<String, dynamic> toJson() => {'liked': liked, 'likeCount': likeCount};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LikeResponse &&
          other.liked == liked &&
          other.likeCount == likeCount);

  @override
  int get hashCode => Object.hash(liked, likeCount);

  @override
  String toString() => 'LikeResponse(liked: $liked, likeCount: $likeCount)';
}

/// Response from `POST /content/:id/save`.
class SaveResponse {
  const SaveResponse({required this.saved, required this.saveCount});

  factory SaveResponse.fromJson(Map<String, dynamic> json) => SaveResponse(
        saved: json['saved'] as bool,
        saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
      );

  final bool saved;
  final int saveCount;

  Map<String, dynamic> toJson() => {'saved': saved, 'saveCount': saveCount};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveResponse &&
          other.saved == saved &&
          other.saveCount == saveCount);

  @override
  int get hashCode => Object.hash(saved, saveCount);

  @override
  String toString() => 'SaveResponse(saved: $saved, saveCount: $saveCount)';
}

/// Response from `GET /content/:id/interactions` — the current user's
/// interaction state with a content item plus aggregate counts.
class InteractionState {
  const InteractionState({
    required this.liked,
    required this.saved,
    required this.likeCount,
    required this.saveCount,
    required this.viewCount,
    required this.shareCount,
    required this.commentCount,
  });

  factory InteractionState.fromJson(Map<String, dynamic> json) =>
      InteractionState(
        liked: json['liked'] as bool? ?? false,
        saved: json['saved'] as bool? ?? false,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      );

  final bool liked;
  final bool saved;
  final int likeCount;
  final int saveCount;
  final int viewCount;
  final int shareCount;
  final int commentCount;

  Map<String, dynamic> toJson() => {
        'liked': liked,
        'saved': saved,
        'likeCount': likeCount,
        'saveCount': saveCount,
        'viewCount': viewCount,
        'shareCount': shareCount,
        'commentCount': commentCount,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractionState &&
          other.liked == liked &&
          other.saved == saved &&
          other.likeCount == likeCount &&
          other.saveCount == saveCount &&
          other.viewCount == viewCount &&
          other.shareCount == shareCount &&
          other.commentCount == commentCount);

  @override
  int get hashCode => Object.hash(
        liked,
        saved,
        likeCount,
        saveCount,
        viewCount,
        shareCount,
        commentCount,
      );

  @override
  String toString() =>
      'InteractionState(liked: $liked, saved: $saved, likeCount: $likeCount, '
      'saveCount: $saveCount, viewCount: $viewCount, shareCount: $shareCount, '
      'commentCount: $commentCount)';
}
