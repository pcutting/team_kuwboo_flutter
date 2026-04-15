import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String contentId,
    required String authorId,
    required String text,
    @Default(0) int likeCount,
    @Default(0) int replyCount,
    String? parentCommentId,
    required DateTime createdAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}

/// Request payload for creating a comment.
///
/// Hand-written (no build_runner). Backend enforces `text` length <= 2000.
class CreateCommentDto {
  const CreateCommentDto({required this.text, this.parentCommentId})
      : assert(text.length <= 2000, 'text must be <= 2000 chars');

  final String text;
  final String? parentCommentId;

  Map<String, dynamic> toJson() => {
        'text': text,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreateCommentDto &&
          other.text == text &&
          other.parentCommentId == parentCommentId);

  @override
  int get hashCode => Object.hash(text, parentCommentId);
}
