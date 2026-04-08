// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  contentId: json['contentId'] as String,
  authorId: json['authorId'] as String,
  text: json['text'] as String,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  parentCommentId: json['parentCommentId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'contentId': instance.contentId,
  'authorId': instance.authorId,
  'text': instance.text,
  'likeCount': instance.likeCount,
  'replyCount': instance.replyCount,
  'parentCommentId': instance.parentCommentId,
  'createdAt': instance.createdAt.toIso8601String(),
};
