import 'package:freezed_annotation/freezed_annotation.dart';
import 'content.dart';

part 'feed.freezed.dart';
part 'feed.g.dart';

@freezed
abstract class FeedResponse with _$FeedResponse {
  const factory FeedResponse({
    required List<Content> items,
    String? nextCursor,
    @Default(false) bool hasMore,
  }) = _FeedResponse;

  factory FeedResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedResponseFromJson(json);
}
