// Riverpod providers that wire YoYo screens to the live backend.
//
// This file deliberately avoids a direct import of `package:kuwboo_api_client`
// because `kuwboo_screens`' pubspec.yaml must not change. Instead we declare a
// narrow abstract facade (`YoyoApiFacade`) matching the real `YoyoApi`'s method
// shapes. The host app (`apps/mobile`) constructs a real `YoyoApi`, wraps it in
// a thin adapter that implements `YoyoApiFacade`, and overrides
// [yoyoApiProvider] via `ProviderScope(overrides: [...])`.
//
// All data types flowing through these providers are the real production
// models from `kuwboo_models` (`NearbyUser`, `Wave`, `YoyoSettings`) — the
// prototype's demo `NearbyUser` in `kuwboo_shell/lib/src/data/demo_data.dart`
// is unrelated.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Default location until geolocator wiring lands (Phase 8).
/// Hardcoded to central London per brief.
const double kDefaultYoyoLat = 51.5074;
const double kDefaultYoyoLng = -0.1278;

/// Narrow facade over the real `YoyoApi` so this package can depend on it
/// without importing `kuwboo_api_client`. Method signatures mirror the
/// production client 1-for-1.
abstract class YoyoApiFacade {
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  });

  Future<List<NearbyUser>> getNearbyUsers({
    required double lat,
    required double lng,
    int? radiusKm,
  });

  Future<YoyoSettings> getSettings();

  Future<YoyoSettings> updateSettings({
    bool? isVisible,
    int? radiusKm,
    int? ageMin,
    int? ageMax,
    String? genderFilter,
  });

  Future<Wave> sendWave({
    required String toUserId,
    String? message,
  });

  Future<List<Wave>> getIncomingWaves();

  Future<List<Wave>> getSentWaves();

  Future<void> respondToWave({
    required String waveId,
    required bool accept,
  });
}

/// Host app overrides this with a live [YoyoApiFacade] adapter wrapping the
/// real `YoyoApi`. Default throws so accidental un-overridden usage is loud.
final yoyoApiProvider = Provider<YoyoApiFacade>((ref) {
  throw UnimplementedError(
    'yoyoApiProvider must be overridden by the host app via ProviderScope. '
    'See apps/mobile/lib/providers for the adapter wiring.',
  );
});

/// Nearby users within the configured radius, around a hardcoded London
/// lat/lng. Phase 8 replaces the location with real geolocator output.
final yoyoNearbyProvider = FutureProvider<List<NearbyUser>>((ref) async {
  final api = ref.watch(yoyoApiProvider);
  return api.getNearbyUsers(
    lat: kDefaultYoyoLat,
    lng: kDefaultYoyoLng,
  );
});

/// User's current YoYo discovery settings.
final yoyoSettingsProvider = FutureProvider<YoyoSettings>((ref) async {
  final api = ref.watch(yoyoApiProvider);
  return api.getSettings();
});

/// Incoming waves (people who waved at you).
final yoyoIncomingWavesProvider = FutureProvider<List<Wave>>((ref) async {
  final api = ref.watch(yoyoApiProvider);
  return api.getIncomingWaves();
});

/// Sent waves (people you waved at).
final yoyoSentWavesProvider = FutureProvider<List<Wave>>((ref) async {
  final api = ref.watch(yoyoApiProvider);
  return api.getSentWaves();
});
