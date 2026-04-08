// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedResponse _$FeedResponseFromJson(Map<String, dynamic> json) =>
    _FeedResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Content.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );

Map<String, dynamic> _$FeedResponseToJson(_FeedResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
      'hasMore': instance.hasMore,
    };
