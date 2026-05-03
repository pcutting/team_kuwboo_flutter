// Web-prototype Riverpod overrides.
//
// The shared screens packages each declare their own `apiClientProvider`
// (and a few API-specific ones for dating/yoyo) that `throw
// UnimplementedError` by default. The mobile app overrides them with a
// real authenticated `KuwbooApiClient`. The web prototype installs the
// same shaped overrides but routes every Dio call through
// [MockApiInterceptor] so screens render canned demo data.
//
// Mirrors `apps/mobile/lib/providers/package_overrides.dart` deliberately —
// keep the two in sync when new shared providers are introduced.
//
// The barrels (`kuwboo_chat.dart`, `kuwboo_screens.dart`) deliberately do
// not re-export the per-feature `*_providers.dart` files because multiple
// declare identical symbol names (`apiClientProvider`). We import each via
// `src/` with a unique library alias.
// ignore_for_file: implementation_imports

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_chat/src/chat_providers.dart' as chat;
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_screens/src/dating/dating_providers.dart' as dating;
import 'package:kuwboo_screens/src/profile/profile_providers.dart' as profile;
import 'package:kuwboo_screens/src/shop/shop_providers.dart' as shop;
import 'package:kuwboo_screens/src/social/social_providers.dart' as social;
import 'package:kuwboo_screens/src/video/video_providers.dart' as video;
import 'package:kuwboo_screens/src/yoyo/yoyo_providers.dart' as yoyo;

import '../providers/api_provider.dart';
import 'mock_api_interceptor.dart';

/// Adapter implementing the narrow [yoyo.YoyoApiFacade] in terms of the
/// real [YoyoApi]. The `kuwboo_screens` package intentionally avoids
/// importing `kuwboo_api_client`, so the host (web or mobile) supplies
/// this glue. Mirrors the private adapter in the mobile app.
class _MockYoyoApiAdapter implements yoyo.YoyoApiFacade {
  _MockYoyoApiAdapter(this._api);

  final YoyoApi _api;

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) => _api.updateLocation(UpdateLocationDto(lat: latitude, lng: longitude));

  @override
  Future<List<NearbyUser>> getNearbyUsers({
    required double lat,
    required double lng,
    int? radiusKm,
  }) => _api.getNearby(lat: lat, lng: lng, radius: radiusKm);

  @override
  Future<YoyoSettings> getSettings() => _api.getSettings();

  @override
  Future<YoyoSettings> updateSettings({
    bool? isVisible,
    int? radiusKm,
    int? ageMin,
    int? ageMax,
    String? genderFilter,
  }) => _api.updateSettings(
    UpdateYoyoSettingsDto(
      isVisible: isVisible,
      radiusKm: radiusKm,
      ageMin: ageMin,
      ageMax: ageMax,
      genderFilter: genderFilter,
    ),
  );

  @override
  Future<Wave> sendWave({required String toUserId, String? message}) =>
      _api.sendWave(SendWaveDto(toUserId: toUserId, message: message));

  @override
  Future<List<Wave>> getIncomingWaves() => _api.getWaves();

  @override
  Future<List<Wave>> getSentWaves() async => <Wave>[];

  @override
  Future<void> respondToWave({
    required String waveId,
    required bool accept,
  }) async {
    await _api.respondToWave(waveId, RespondWaveDto(accept: accept));
  }
}

/// Single mocked [KuwbooApiClient] reused across every package override.
/// Lazy so we only build one Dio instance per app.
final mockApiClientProvider = Provider<KuwbooApiClient>((ref) {
  return KuwbooApiClient(
    baseUrl: 'https://mock.kuwboo.local',
    dio: buildMockDio(),
  );
});

/// All overrides the web prototype needs to wire shared-package providers
/// onto the mocked client. Mirrors the mobile version — every entry there
/// has a counterpart here.
List<Override> buildWebPackageOverrides() {
  return [
    // ── kuwboo_screens: social ──
    // Social feed + Stumble are de-mocked. Both hit the live backend
    // through the same KuwbooApiClient so the auth interceptor and
    // token refresh logic apply.
    social.kuwbooApiClientProvider.overrideWith(
      (ref) => ref.watch(realApiClientProvider),
    ),

    // ── kuwboo_chat ──
    chat.apiClientProvider.overrideWith(
      (ref) => ref.watch(mockApiClientProvider),
    ),

    // ── kuwboo_screens: profile ──
    // Profile hits the real backend so the signed-in user sees their
    // own /users/me data; non-auth content modules below stay on the
    // mock interceptor until those endpoints are wired.
    profile.apiClientProvider.overrideWith(
      (ref) => ref.watch(realApiClientProvider),
    ),

    // ── kuwboo_screens: video ──
    // Video feed + comments + interactions are de-mocked.
    video.apiClientProvider.overrideWith(
      (ref) => ref.watch(realApiClientProvider),
    ),

    // ── kuwboo_screens: shop ──
    shop.apiClientProvider.overrideWith(
      (ref) => ref.watch(mockApiClientProvider),
    ),

    // ── kuwboo_screens: dating ──
    dating.datingApiProvider.overrideWith(
      (ref) => DatingApi(ref.watch(mockApiClientProvider)),
    ),
    dating.datingInteractionsApiProvider.overrideWith(
      (ref) => InteractionsApi(ref.watch(mockApiClientProvider)),
    ),
    dating.usersApiForDatingProvider.overrideWith(
      (ref) => UsersApi(ref.watch(mockApiClientProvider)),
    ),

    // ── kuwboo_screens: yoyo ──
    yoyo.yoyoApiProvider.overrideWith(
      (ref) => _MockYoyoApiAdapter(YoyoApi(ref.watch(mockApiClientProvider))),
    ),
  ];
}
