import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Social connection endpoints (follow, friend, block).
class ConnectionsApi {
  ConnectionsApi(this._client);

  final KuwbooApiClient _client;

  /// Follow a user.
  Future<Connection> follow(String userId, {ModuleScope? moduleScope}) async {
    final response = await _client.dio.post(
      '/connections/follow',
      data: {
        'targetUserId': userId,
        if (moduleScope != null) 'moduleScope': moduleScope.value,
      },
    );
    return _client.unwrap(response, Connection.fromJson);
  }

  /// Unfollow a user.
  Future<void> unfollow(String userId) async {
    await _client.dio.delete('/connections/follow/$userId');
  }

  /// Send a friend request.
  Future<Connection> sendFriendRequest(String userId) async {
    final response = await _client.dio.post(
      '/connections/friend-request',
      data: {'targetUserId': userId},
    );
    return _client.unwrap(response, Connection.fromJson);
  }

  /// Accept a friend request.
  Future<Connection> acceptFriendRequest(String connectionId) async {
    final response = await _client.dio.post(
      '/connections/friend-request/$connectionId/accept',
    );
    return _client.unwrap(response, Connection.fromJson);
  }

  /// Get followers of the current user.
  Future<List<Connection>> getFollowers({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/connections/followers',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrapList(response, Connection.fromJson);
  }

  /// Get users the current user is following.
  Future<List<Connection>> getFollowing({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/connections/following',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrapList(response, Connection.fromJson);
  }

  /// Block a user.
  Future<void> block(String userId) async {
    await _client.dio.post('/blocks', data: {'targetUserId': userId});
  }

  /// Unblock a user.
  Future<void> unblock(String userId) async {
    await _client.dio.delete('/blocks/$userId');
  }

  /// Get the current user's block list.
  Future<List<Map<String, dynamic>>> getBlocks({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/blocks',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final wrapped = response.data as Map<String, dynamic>;
    final list = wrapped['data'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
