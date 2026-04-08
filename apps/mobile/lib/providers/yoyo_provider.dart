import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

// ─── Nearby Users ───────────────────────────────────────────────────────

/// Fetches nearby users using placeholder coordinates.
///
/// Real geolocator integration is deferred — uses fixed London coordinates.
final nearbyUsersProvider = FutureProvider<List<NearbyUser>>((ref) async {
  // Placeholder: real implementation will use device location
  await Future<void>.delayed(const Duration(milliseconds: 300));

  return List.generate(
    8,
    (i) => NearbyUser(
      id: 'user_$i',
      name: _demoNames[i % _demoNames.length],
      distanceKm: 0.3 + i * 0.7,
      onlineStatus: i % 3 == 0 ? 'ONLINE' : (i % 3 == 1 ? 'AWAY' : null),
    ),
  );
});

const _demoNames = [
  'Alex Chen',
  'Jordan Taylor',
  'Sam Patel',
  'Morgan Lee',
  'Casey Rivera',
  'Riley Quinn',
  'Avery Brooks',
  'Dakota Reeves',
];

// ─── YoYo Settings ──────────────────────────────────────────────────────

/// Manages YoYo discovery settings with local state.
class YoyoSettingsNotifier extends StateNotifier<YoyoSettings> {
  YoyoSettingsNotifier() : super(const YoyoSettings());

  void setVisible(bool value) {
    state = state.copyWith(isVisible: value);
  }

  void setRadius(int km) {
    state = state.copyWith(radiusKm: km);
  }

  void setAgeRange({int? min, int? max}) {
    state = state.copyWith(ageMin: min, ageMax: max);
  }

  void setGenderFilter(String? filter) {
    state = state.copyWith(genderFilter: filter);
  }
}

final yoyoSettingsProvider =
    StateNotifierProvider<YoyoSettingsNotifier, YoyoSettings>(
  (ref) => YoyoSettingsNotifier(),
);

// ─── Waves ──────────────────────────────────────────────────────────────

/// Fetches incoming waves (demo data).
final incomingWavesProvider = FutureProvider<List<Wave>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));

  return [
    Wave(
      id: 'wave_1',
      fromUserId: 'user_2',
      toUserId: 'me',
      fromUserName: 'Sam Patel',
      message: 'Hey! Saw you nearby',
      status: 'PENDING',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Wave(
      id: 'wave_2',
      fromUserId: 'user_5',
      toUserId: 'me',
      fromUserName: 'Riley Quinn',
      status: 'PENDING',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];
});

/// Fetches sent waves (demo data).
final sentWavesProvider = FutureProvider<List<Wave>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));

  return [
    Wave(
      id: 'wave_3',
      fromUserId: 'me',
      toUserId: 'user_0',
      fromUserName: 'You',
      message: 'Nice to meet you!',
      status: 'ACCEPTED',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
});
