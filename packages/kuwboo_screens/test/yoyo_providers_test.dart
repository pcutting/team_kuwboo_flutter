import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_screens/src/yoyo/yoyo_providers.dart';

/// Hand-rolled in-memory fake. We deliberately avoid a Dio mock here because
/// `kuwboo_screens` cannot depend on `kuwboo_api_client` / `dio` (pubspec is
/// frozen for this agent). The real `YoyoApi` gets its own dio-adapter test
/// in `packages/api_client/test/yoyo_api_test.dart`.
class _FakeYoyoApi implements YoyoApiFacade {
  final List<NearbyUser> nearby;
  final List<Wave> incoming;
  final List<Wave> sent;
  final YoyoSettings settings;

  final List<({double lat, double lng, int? radius})> nearbyCalls = [];
  final List<String> wavedUserIds = [];

  _FakeYoyoApi({
    this.nearby = const [],
    this.incoming = const [],
    // ignore: unused_element_parameter
    this.sent = const [],
    this.settings = const YoyoSettings(),
  });

  @override
  Future<List<NearbyUser>> getNearbyUsers({
    required double lat,
    required double lng,
    int? radiusKm,
  }) async {
    nearbyCalls.add((lat: lat, lng: lng, radius: radiusKm));
    return nearby;
  }

  @override
  Future<YoyoSettings> getSettings() async => settings;

  @override
  Future<List<Wave>> getIncomingWaves() async => incoming;

  @override
  Future<List<Wave>> getSentWaves() async => sent;

  @override
  Future<YoyoSettings> updateSettings({
    bool? isVisible,
    int? radiusKm,
    int? ageMin,
    int? ageMax,
    String? genderFilter,
  }) async =>
      settings;

  @override
  Future<Wave> sendWave({required String toUserId, String? message}) async {
    wavedUserIds.add(toUserId);
    return Wave(
      id: 'w-${wavedUserIds.length}',
      fromUserId: 'me',
      toUserId: toUserId,
      status: 'pending',
      createdAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<void> respondToWave({
    required String waveId,
    required bool accept,
  }) async {}

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {}
}

void main() {
  group('yoyo providers', () {
    test('yoyoNearbyProvider returns users from the facade', () async {
      final fake = _FakeYoyoApi(nearby: const [
        NearbyUser(id: 'u1', name: 'Maya', distanceMeters: 300),
        NearbyUser(id: 'u2', name: 'Jon', distanceMeters: 800),
      ]);
      final container = ProviderContainer(overrides: [
        yoyoApiProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);

      final users = await container.read(yoyoNearbyProvider.future);
      expect(users, hasLength(2));
      expect(users.first.name, 'Maya');
      // Default London coords are used.
      expect(fake.nearbyCalls.single.lat, closeTo(51.5074, 1e-6));
      expect(fake.nearbyCalls.single.lng, closeTo(-0.1278, 1e-6));
    });

    test('yoyoIncomingWavesProvider returns waves from the facade', () async {
      final fake = _FakeYoyoApi(incoming: [
        Wave(
          id: 'w1',
          fromUserId: 'u1',
          toUserId: 'me',
          fromUserName: 'Maya',
          status: 'pending',
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      final container = ProviderContainer(overrides: [
        yoyoApiProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);

      final waves = await container.read(yoyoIncomingWavesProvider.future);
      expect(waves.single.fromUserName, 'Maya');
    });

    test('yoyoSettingsProvider returns settings from the facade', () async {
      final fake = _FakeYoyoApi(
        settings: const YoyoSettings(isVisible: false, radiusKm: 15),
      );
      final container = ProviderContainer(overrides: [
        yoyoApiProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);

      final settings = await container.read(yoyoSettingsProvider.future);
      expect(settings.isVisible, false);
      expect(settings.radiusKm, 15);
    });

    test('yoyoApiProvider default throws until overridden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(() => container.read(yoyoApiProvider), throwsUnimplementedError);
    });
  });
}
