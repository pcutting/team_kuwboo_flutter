import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// User profile endpoints.
class UsersApi {
  UsersApi(this._client);

  final KuwbooApiClient _client;

  /// Get the current user's profile.
  Future<User> getProfile() async {
    final response = await _client.dio.get('/users/me');
    return _client.unwrap(response, User.fromJson);
  }

  /// Update the current user's profile fields.
  Future<User> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    final response = await _client.dio.patch(
      '/users/me',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    return _client.unwrap(response, User.fromJson);
  }

  /// Update the current user's preferences.
  Future<void> updatePreferences({
    required Map<String, dynamic> preferences,
  }) async {
    await _client.dio.patch('/users/me/preferences', data: preferences);
  }
}
