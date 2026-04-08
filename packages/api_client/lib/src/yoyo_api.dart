import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// YoYo proximity discovery endpoints.
class YoyoApi {
  YoyoApi(this._client);

  final KuwbooApiClient _client;

  /// Report the user's current location.
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _client.dio.post(
      '/yoyo/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  /// Fetch users within proximity.
  Future<List<NearbyUser>> getNearbyUsers({
    required double latitude,
    required double longitude,
    int? radiusKm,
  }) async {
    final response = await _client.dio.get(
      '/yoyo/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        if (radiusKm != null) 'radiusKm': radiusKm,
      },
    );
    return _client.unwrapList(response, NearbyUser.fromJson);
  }

  /// Get the user's YoYo discovery settings.
  Future<YoyoSettings> getSettings() async {
    final response = await _client.dio.get('/yoyo/settings');
    return _client.unwrap(response, YoyoSettings.fromJson);
  }

  /// Update discovery settings.
  Future<YoyoSettings> updateSettings({
    bool? isVisible,
    int? radiusKm,
    int? ageMin,
    int? ageMax,
    String? genderFilter,
  }) async {
    final response = await _client.dio.patch(
      '/yoyo/settings',
      data: {
        if (isVisible != null) 'isVisible': isVisible,
        if (radiusKm != null) 'radiusKm': radiusKm,
        if (ageMin != null) 'ageMin': ageMin,
        if (ageMax != null) 'ageMax': ageMax,
        if (genderFilter != null) 'genderFilter': genderFilter,
      },
    );
    return _client.unwrap(response, YoyoSettings.fromJson);
  }

  /// Send a wave to another user.
  Future<Wave> sendWave({
    required String toUserId,
    String? message,
  }) async {
    final response = await _client.dio.post(
      '/yoyo/waves',
      data: {
        'toUserId': toUserId,
        if (message != null) 'message': message,
      },
    );
    return _client.unwrap(response, Wave.fromJson);
  }

  /// Get incoming waves.
  Future<List<Wave>> getIncomingWaves() async {
    final response = await _client.dio.get('/yoyo/waves/incoming');
    return _client.unwrapList(response, Wave.fromJson);
  }

  /// Get sent waves.
  Future<List<Wave>> getSentWaves() async {
    final response = await _client.dio.get('/yoyo/waves/sent');
    return _client.unwrapList(response, Wave.fromJson);
  }

  /// Accept or decline a wave.
  Future<void> respondToWave({
    required String waveId,
    required bool accept,
  }) async {
    await _client.dio.post(
      '/yoyo/waves/$waveId/respond',
      data: {'accept': accept},
    );
  }
}
