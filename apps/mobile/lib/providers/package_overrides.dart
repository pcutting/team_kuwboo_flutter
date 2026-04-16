// Shared-package provider files are intentionally imported via `src/`
// paths. Each file declares its own file-local `apiClientProvider` (or
// equivalent) marked `throw UnimplementedError(...)` until the host app
// wires them up — which is exactly what this file does. The barrels
// (`kuwboo_chat.dart`, `kuwboo_screens.dart`) deliberately do not
// re-export these files because multiple packages declare identical
// symbol names (`apiClientProvider`) that would otherwise collide at
// the barrel level. Library aliases here give each one a unique handle.
// ignore_for_file: implementation_imports

import 'package:flutter/foundation.dart';
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

import 'api_provider.dart';

/// Adapter between the narrow [yoyo.YoyoApiFacade] exposed by
/// `kuwboo_screens` and the concrete [YoyoApi] from `kuwboo_api_client`.
/// Keeping this on the host side lets the shared package declare the
/// facade without importing the api client (see `yoyo_providers.dart`
/// for rationale).
class _YoyoApiAdapter implements yoyo.YoyoApiFacade {
  _YoyoApiAdapter(this._api);

  final YoyoApi _api;

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) =>
      _api.updateLocation(
        UpdateLocationDto(lat: latitude, lng: longitude),
      );

  @override
  Future<List<NearbyUser>> getNearbyUsers({
    required double lat,
    required double lng,
    int? radiusKm,
  }) =>
      _api.getNearby(lat: lat, lng: lng, radius: radiusKm);

  @override
  Future<YoyoSettings> getSettings() => _api.getSettings();

  @override
  Future<YoyoSettings> updateSettings({
    bool? isVisible,
    int? radiusKm,
    int? ageMin,
    int? ageMax,
    String? genderFilter,
  }) =>
      _api.updateSettings(
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

  /// Backend currently has no `sent waves` endpoint — return empty until
  /// `GET /yoyo/waves/sent` lands. Screens that render the sent-waves
  /// tab will show an empty state rather than crash.
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

/// Providers in shared packages declared as `throw UnimplementedError(...)`
/// — all must be overridden here or the feature crashes on first read.
///
/// If you add a new `throw UnimplementedError` provider to a shared
/// package, add a matching entry here. The debug-mode assertion in
/// [assertNoUnoverriddenPackageProviders] will fail loudly at startup if
/// any of these slots is still wired to the placeholder.
List<Override> buildPackageOverrides() {
  return [
    // ── kuwboo_chat ───────────────────────────────────────────────────
    chat.apiClientProvider.overrideWith(
      (ref) => ref.watch(apiClientProvider),
    ),

    // ── kuwboo_screens: profile ───────────────────────────────────────
    profile.apiClientProvider.overrideWith(
      (ref) => ref.watch(apiClientProvider),
    ),

    // ── kuwboo_screens: video ─────────────────────────────────────────
    video.apiClientProvider.overrideWith(
      (ref) => ref.watch(apiClientProvider),
    ),

    // ── kuwboo_screens: shop ──────────────────────────────────────────
    shop.apiClientProvider.overrideWith(
      (ref) => ref.watch(apiClientProvider),
    ),

    // ── kuwboo_screens: social ────────────────────────────────────────
    // `social_providers.dart` exposes a base-URL provider and a constructed
    // client provider. We short-circuit the client directly to the shared
    // mobile `apiClientProvider` so the auth interceptor is preserved.
    social.kuwbooApiClientProvider.overrideWith(
      (ref) => ref.watch(apiClientProvider),
    ),

    // ── kuwboo_screens: dating ────────────────────────────────────────
    dating.datingApiProvider.overrideWith(
      (ref) => DatingApi(ref.watch(apiClientProvider)),
    ),
    dating.datingInteractionsApiProvider.overrideWith(
      (ref) => InteractionsApi(ref.watch(apiClientProvider)),
    ),
    dating.usersApiForDatingProvider.overrideWith(
      (ref) => UsersApi(ref.watch(apiClientProvider)),
    ),

    // ── kuwboo_screens: yoyo ──────────────────────────────────────────
    // The facade shields the screens package from a direct api_client
    // dependency; adapter is the private `_YoyoApiAdapter` above.
    yoyo.yoyoApiProvider.overrideWith(
      (ref) => _YoyoApiAdapter(YoyoApi(ref.watch(apiClientProvider))),
    ),
  ];
}

/// Debug-mode startup check: reads every package provider that the host
/// app is responsible for overriding, asserting none of them still throws
/// `UnimplementedError`. If a new `throw UnimplementedError` provider is
/// added to a shared package and the corresponding override is forgotten
/// in [buildPackageOverrides], this fires at startup in debug/profile
/// builds rather than at first user interaction.
///
/// The list below mirrors [buildPackageOverrides] — keep them in sync.
/// No-op in release builds (asserts are stripped).
void assertNoUnoverriddenPackageProviders(ProviderContainer container) {
  assert(() {
    final readers = <String, void Function()>{
      'chat.apiClientProvider': () => container.read(chat.apiClientProvider),
      'profile.apiClientProvider':
          () => container.read(profile.apiClientProvider),
      'video.apiClientProvider': () => container.read(video.apiClientProvider),
      'shop.apiClientProvider': () => container.read(shop.apiClientProvider),
      'social.kuwbooApiClientProvider':
          () => container.read(social.kuwbooApiClientProvider),
      'dating.datingApiProvider':
          () => container.read(dating.datingApiProvider),
      'dating.datingInteractionsApiProvider':
          () => container.read(dating.datingInteractionsApiProvider),
      'dating.usersApiForDatingProvider':
          () => container.read(dating.usersApiForDatingProvider),
      'yoyo.yoyoApiProvider': () => container.read(yoyo.yoyoApiProvider),
    };

    final missing = <String>[];
    for (final entry in readers.entries) {
      try {
        entry.value();
      } on UnimplementedError {
        missing.add(entry.key);
      } catch (_) {
        // Other errors (network, auth) are irrelevant here — we only
        // care about the sentinel throw declared in the placeholder.
      }
    }

    if (missing.isNotEmpty) {
      debugPrint(
        'ProviderScope is missing overrides for shared-package '
        'providers: ${missing.join(', ')}. See '
        'apps/mobile/lib/providers/package_overrides.dart.',
      );
      throw StateError(
        'Shared-package providers still throw UnimplementedError: '
        '${missing.join(', ')}',
      );
    }
    return true;
  }());
}
