import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// YoYo proximity discovery endpoints.
///
/// Mirrors `apps/api/src/modules/yoyo/yoyo.controller.ts` (8 HTTP routes).
/// The corresponding Socket.io gateway (`proximity.gateway.ts`) is wired
/// in a later phase — this class is HTTP-only for now.
///
/// All request shapes are modelled by the `*Dto` classes in
/// `kuwboo_models` so callers can stage payloads as typed objects.
class YoyoApi {
  YoyoApi(this._client);

  final KuwbooApiClient _client;

  /// `POST /yoyo/location` — report the user's current location.
  ///
  /// Returns void; the backend responds `{message: 'Location updated'}`.
  Future<void> updateLocation(UpdateLocationDto dto) async {
    await _client.dio.post('/yoyo/location', data: dto.toJson());
  }

  /// `GET /yoyo/nearby?lat=&lng=&radius=` — fetch users within proximity.
  ///
  /// Backend expects short-form `lat` / `lng` on the query string (unlike
  /// the POST body, which uses `latitude` / `longitude`). `radius` is in
  /// kilometres and falls back to the caller's saved [YoyoSettings.radiusKm].
  Future<List<NearbyUser>> getNearby({
    required double lat,
    required double lng,
    int? radius,
  }) async {
    final response = await _client.dio.get(
      '/yoyo/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        if (radius != null) 'radius': radius,
      },
    );
    return _client.unwrapList(response, NearbyUser.fromJson);
  }

  /// `GET /yoyo/settings` — get the user's discovery settings.
  ///
  /// If no row exists server-side, the backend creates defaults and
  /// returns them (`isVisible: true`, `radiusKm: 10`).
  Future<YoyoSettings> getSettings() async {
    final response = await _client.dio.get('/yoyo/settings');
    return _client.unwrap(response, YoyoSettings.fromJson);
  }

  /// `PATCH /yoyo/settings` — partial update of discovery settings.
  Future<YoyoSettings> updateSettings(UpdateYoyoSettingsDto dto) async {
    final response = await _client.dio.patch(
      '/yoyo/settings',
      data: dto.toJson(),
    );
    return _client.unwrap(response, YoyoSettings.fromJson);
  }

  /// `POST /yoyo/overrides` — explicitly allow or block another user.
  ///
  /// Idempotent: upserts on (user, targetUser).
  Future<YoyoOverride> createOverride(CreateOverrideDto dto) async {
    final response = await _client.dio.post(
      '/yoyo/overrides',
      data: dto.toJson(),
    );
    return _client.unwrap(response, YoyoOverride.fromJson);
  }

  /// `POST /yoyo/wave` — send an interest signal to another user.
  ///
  /// Backend rejects (409) if a pending wave already exists between the
  /// two users, and (403) if the recipient has blocked the sender.
  Future<Wave> sendWave(SendWaveDto dto) async {
    final response = await _client.dio.post(
      '/yoyo/wave',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Wave.fromJson);
  }

  /// `GET /yoyo/waves` — incoming pending waves for the current user.
  Future<List<Wave>> getWaves() async {
    final response = await _client.dio.get('/yoyo/waves');
    return _client.unwrapList(response, Wave.fromJson);
  }

  /// `POST /yoyo/waves/:id/respond` — accept or decline a pending wave.
  ///
  /// On `accept: true`, the backend additionally creates a messaging
  /// thread (moduleKey: SOCIAL_STUMBLE) between the two users.
  Future<WaveResponse> respondToWave(String id, RespondWaveDto dto) async {
    final response = await _client.dio.post(
      '/yoyo/waves/$id/respond',
      data: dto.toJson(),
    );
    return _client.unwrap(response, WaveResponse.fromJson);
  }
}
