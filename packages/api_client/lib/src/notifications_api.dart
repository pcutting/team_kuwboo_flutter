import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Paginated page of notifications.
class NotificationPage {
  const NotificationPage({required this.items, this.nextCursor});

  final List<NotificationModel> items;
  final String? nextCursor;

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List<dynamic>? ?? const [])
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return NotificationPage(
      items: list,
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Notifications + per-module notification preferences endpoints.
///
/// Routes (see `docs/team/internal/API_SURFACE.md` — `notifications`):
///   GET    /notifications                    list (cursor pagination)
///   GET    /notifications/unread-count       unread count
///   PATCH  /notifications/:id/read           mark one read
///   PATCH  /notifications/read-all           mark all read
///   GET    /notifications/preferences        list preferences
///   PATCH  /notifications/preferences        update preferences
class NotificationsApi {
  NotificationsApi(this._client);

  final KuwbooApiClient _client;

  /// List notifications for the current user, newest first, cursor-paginated.
  Future<NotificationPage> list({String? cursor, int limit = 20}) async {
    final response = await _client.dio.get(
      '/notifications',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return _client.unwrap(response, NotificationPage.fromJson);
  }

  /// Unread notification count for the current user.
  Future<int> getUnreadCount() async {
    final response = await _client.dio.get('/notifications/unread-count');
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['count'] as num).toInt();
  }

  /// Mark a single notification as read. Returns the server's message.
  Future<String> markRead(String id) async {
    final response = await _client.dio.patch('/notifications/$id/read');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['message'] as String;
  }

  /// Mark all notifications as read. Returns the server's message.
  Future<String> markAllRead() async {
    final response = await _client.dio.patch('/notifications/read-all');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['message'] as String;
  }

  /// Current preferences (one row per module + event type that the user
  /// has explicitly configured). Missing rows default to enabled on both
  /// channels.
  Future<List<NotificationPreference>> getPreferences() async {
    final response = await _client.dio.get('/notifications/preferences');
    return _client.unwrapList(response, NotificationPreference.fromJson);
  }

  /// Upsert a batch of preferences. Server returns the full current list.
  Future<List<NotificationPreference>> updatePreferences(
    UpdatePreferencesDto dto,
  ) async {
    final response = await _client.dio.patch(
      '/notifications/preferences',
      data: dto.toJson(),
    );
    return _client.unwrapList(response, NotificationPreference.fromJson);
  }
}
