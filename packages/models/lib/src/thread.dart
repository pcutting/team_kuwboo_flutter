import 'package:freezed_annotation/freezed_annotation.dart';

part 'thread.freezed.dart';
part 'thread.g.dart';

@freezed
abstract class Thread with _$Thread {
  const factory Thread({
    required String id,
    String? moduleKey,
    String? contextId,
    String? lastMessageText,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    required DateTime createdAt,
  }) = _Thread;

  factory Thread.fromJson(Map<String, dynamic> json) =>
      _$ThreadFromJson(json);
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String threadId,
    required String senderId,
    required String text,
    String? mediaId,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
