import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Messaging/chat endpoints.
class MessagingApi {
  MessagingApi(this._client);

  final KuwbooApiClient _client;

  /// List the current user's threads.
  Future<List<Thread>> getThreads() async {
    final response = await _client.dio.get('/messaging/threads');
    return _client.unwrapList(response, Thread.fromJson);
  }

  /// Create a new thread with another user.
  Future<Thread> createThread({
    required String userId,
    String? moduleKey,
  }) async {
    final response = await _client.dio.post(
      '/messaging/threads',
      data: {
        'userId': userId,
        if (moduleKey != null) 'moduleKey': moduleKey,
      },
    );
    return _client.unwrap(response, Thread.fromJson);
  }

  /// Get messages for a thread with cursor-based pagination.
  Future<({List<Message> items, String? nextCursor})> getMessages({
    required String threadId,
    String? cursor,
    int limit = 30,
  }) async {
    final response = await _client.dio.get(
      '/messaging/threads/$threadId/messages',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final wrapped = response.data as Map<String, dynamic>;
    final data = wrapped['data'] as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>)
        .map((item) => Message.fromJson(item as Map<String, dynamic>))
        .toList();
    final nextCursor = data['nextCursor'] as String?;
    return (items: items, nextCursor: nextCursor);
  }

  /// Send a message in a thread.
  Future<Message> sendMessage({
    required String threadId,
    required String text,
  }) async {
    final response = await _client.dio.post(
      '/messaging/threads/$threadId/messages',
      data: {'text': text},
    );
    return _client.unwrap(response, Message.fromJson);
  }

  /// Mark all messages in a thread as read.
  Future<void> markRead(String threadId) async {
    await _client.dio.post('/messaging/threads/$threadId/read');
  }
}
