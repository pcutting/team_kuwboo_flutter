import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// Declared-interest endpoints. See IDENTITY_CONTRACT §11 and
/// `apps/api/src/modules/interests/interests.controller.ts`.
class InterestsApi {
  InterestsApi(this._client);

  final KuwbooApiClient _client;

  /// Public catalogue — active interests only, sorted by display order.
  Future<List<Interest>> listAll() async {
    final response = await _client.dio.get('/interests');
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }

  /// Interests selected by the authenticated user.
  Future<List<Interest>> listMine() async {
    final response = await _client.dio.get('/users/me/interests');
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }

  /// Replace the authenticated user's selection with [interestIds]. The
  /// backend returns the resulting set.
  Future<List<Interest>> selectMany(List<String> interestIds) async {
    final response = await _client.dio.post(
      '/users/me/interests',
      data: {'interest_ids': interestIds},
    );
    return _client.unwrap(response, (json) {
      final list = (json['interests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return list.map(Interest.fromJson).toList();
    });
  }

  Future<void> deselect(String id) async {
    await _client.dio.delete('/users/me/interests/$id');
  }
}
