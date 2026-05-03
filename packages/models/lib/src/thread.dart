import 'package:freezed_annotation/freezed_annotation.dart';

part 'thread.freezed.dart';
part 'thread.g.dart';

/// Module key discriminator for threads.
///
/// Mirrors the backend `ThreadModuleKey` enum
/// (apps/api/src/common/enums/thread-module-key.enum.ts).
///
/// Note: there is no standalone `ContentModuleKey` enum in the models
/// package today (the content STI hierarchy uses string kinds such as
/// `video`, `product`, `yoyo`). The backend `ThreadModuleKey` is the
/// canonical cross-module chat discriminator and is a superset of the
/// content STI module keys used by the Flutter client (`video_making`,
/// `buy_sell`, `dating`, `social_stumble`) plus `yoyo`.
enum ThreadModuleKey {
  videoMaking('VIDEO_MAKING'),
  buySell('BUY_SELL'),
  dating('DATING'),
  socialStumble('SOCIAL_STUMBLE'),
  yoyo('YOYO');

  const ThreadModuleKey(this.value);
  final String value;

  static ThreadModuleKey? fromValue(String? raw) {
    if (raw == null) return null;
    for (final v in ThreadModuleKey.values) {
      if (v.value == raw) return v;
    }
    return null;
  }
}

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

  /// Normalises the backend response shape (nested `lastMessage: { text,
  /// sender, createdAt }`) into the flat fields this model exposes. Falls
  /// through cleanly when the JSON is already flat (older stubs, fixtures).
  factory Thread.fromJson(Map<String, dynamic> json) =>
      _$ThreadFromJson(_normaliseThreadJson(json));
}

Map<String, dynamic> _normaliseThreadJson(Map<String, dynamic> json) {
  final lastMessage = json['lastMessage'];
  if (lastMessage is! Map) return json;
  final lm = Map<String, dynamic>.from(lastMessage);
  return {
    ...json,
    'lastMessageText': json['lastMessageText'] ?? lm['text'],
    'lastMessageAt': json['lastMessageAt'] ?? lm['createdAt'],
    'lastMessageSenderId': json['lastMessageSenderId'] ??
        _extractId(lm['sender']) ??
        lm['senderId'],
  };
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

  /// Normalises the backend response shape (`thread` + `sender` as either
  /// nested objects or relation-id strings) into the flat `threadId` /
  /// `senderId` strings this model exposes.
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(_normaliseMessageJson(json));
}

Map<String, dynamic> _normaliseMessageJson(Map<String, dynamic> json) {
  return {
    ...json,
    'threadId': json['threadId'] ?? _extractId(json['thread']),
    'senderId': json['senderId'] ?? _extractId(json['sender']),
  };
}

/// Pulls an id out of a value that may be a `{id: ...}` map, a raw id
/// string, or null. Mirrors how MikroORM serializes relations: with
/// `populate` it's a nested object; without it's a UUID string.
String? _extractId(Object? rel) {
  if (rel == null) return null;
  if (rel is String) return rel;
  if (rel is Map && rel['id'] is String) return rel['id'] as String;
  return null;
}

// ---------------------------------------------------------------------------
// DTOs and response wrappers (plain Dart — no build_runner regeneration).
// ---------------------------------------------------------------------------

/// Request body for `POST /threads`.
///
/// Matches `apps/api/src/modules/messaging/dto/create-thread.dto.ts`.
class CreateThreadDto {
  const CreateThreadDto({
    required this.recipientId,
    this.moduleKey,
    this.contextId,
  });

  final String recipientId;
  final ThreadModuleKey? moduleKey;
  final String? contextId;

  Map<String, dynamic> toJson() => {
        'recipientId': recipientId,
        if (moduleKey != null) 'moduleKey': moduleKey!.value,
        if (contextId != null) 'contextId': contextId,
      };
}

/// Request body for `POST /threads/:id/messages`.
///
/// `text` must be <= 5000 chars (enforced server-side). Matches
/// `apps/api/src/modules/messaging/dto/send-message.dto.ts`.
class SendMessageDto {
  SendMessageDto({required this.text, this.mediaId})
      : assert(text.length <= 5000, 'Message text must be <= 5000 chars');

  final String text;
  final String? mediaId;

  Map<String, dynamic> toJson() => {
        'text': text,
        if (mediaId != null) 'mediaId': mediaId,
      };
}

/// Paginated response wrapper for `GET /threads`.
class ThreadListResponse {
  const ThreadListResponse({required this.items, this.nextCursor});

  final List<Thread> items;
  final String? nextCursor;

  factory ThreadListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return ThreadListResponse(
      items: rawItems.map(Thread.fromJson).toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Paginated response wrapper for `GET /threads/:id/messages`.
class MessageListResponse {
  const MessageListResponse({required this.items, this.nextCursor});

  final List<Message> items;
  final String? nextCursor;

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return MessageListResponse(
      items: rawItems.map(Message.fromJson).toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
