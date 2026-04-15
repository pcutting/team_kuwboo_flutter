import 'package:kuwboo_models/kuwboo_models.dart';

import 'api_client.dart';

/// FCM device registration endpoints.
///
/// Routes (see `docs/team/internal/API_SURFACE.md` — `devices`):
///   POST   /devices               register a device (fcmToken + platform)
///   DELETE /devices/:fcmToken     deactivate a device by fcm token
class DevicesApi {
  DevicesApi(this._client);

  final KuwbooApiClient _client;

  /// Register (or re-activate) an FCM device for the current user.
  Future<Device> register(RegisterDeviceDto dto) async {
    final response = await _client.dio.post(
      '/devices',
      data: dto.toJson(),
    );
    return _client.unwrap(response, Device.fromJson);
  }

  /// Deactivate a device by its FCM token.
  Future<String> deactivate(String fcmToken) async {
    final response = await _client.dio.delete('/devices/$fcmToken');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['message'] as String;
  }
}
