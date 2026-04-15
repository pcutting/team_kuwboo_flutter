import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Messaging / direct-messages HTTP API.
///
/// Mirrors the canonical backend at
/// `apps/api/src/modules/messaging/messaging.controller.ts` — 5 HTTP routes
/// mounted at `/threads`. WebSocket events (12) are Phase 8 and not
/// implemented here.
///
/// Endpoints:
///   POST   /threads                    → [createThread]
///   GET    /threads                    → [listThreads]
///   GET    /threads/:id/messages       → [listMessages]
///   POST   /threads/:id/messages       → [sendMessage]
///   PATCH  /threads/:id/read           → [markThreadRead]
class MessagingApi {
  MessagingApi(this._client);

  final KuwbooApiClient _client;

  /// Create (or return existing) thread with another user. Idempotent for a
  /// given `(recipientId, moduleKey, contextId)` tuple.
  Future<Thread> createThread(CreateThreadDto dto) async {
    final response = await _client.dio.post(
      '/threads',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Thread.fromJson);
  }

  /// List the current user's threads, cursor-paginated (default limit 20,
  /// ordered by `updatedAt DESC`).
  Future<ThreadListResponse> listThreads({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/threads',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, ThreadListResponse.fromJson);
  }

  /// List messages for a thread, cursor-paginated newest-first (default
  /// limit 50). Requires the caller to be a participant (enforced server-
  /// side — 403 otherwise).
  Future<MessageListResponse> listMessages(
    String threadId, {
    String? cursor,
    int limit = 50,
  }) async {
    final response = await _client.dio.get(
      '/threads/$threadId/messages',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, MessageListResponse.fromJson);
  }

  /// Send a message in a thread. `text` is required and must be <= 5000
  /// chars; `mediaId` is optional (uploaded separately via media API).
  Future<Message> sendMessage(String threadId, SendMessageDto dto) async {
    final response = await _client.dio.post(
      '/threads/$threadId/messages',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Message.fromJson);
  }

  /// Mark the thread read — updates the caller's participant
  /// `lastReadAt`. Returns the server's `{ message }` envelope string.
  Future<String> markThreadRead(String threadId) async {
    final response = await _client.dio.patch('/threads/$threadId/read');
    final wrapped = response.data as Map<String, dynamic>;
    final data = wrapped['data'] as Map<String, dynamic>;
    return data['message'] as String;
  }
}
