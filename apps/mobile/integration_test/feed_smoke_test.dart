import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kuwboo_api_client/kuwboo_api_client.dart' as shared;
import 'package:kuwboo_models/kuwboo_models.dart' show TokenPair;

import 'package:kuwboo_mobile/app/test_app.dart';
import 'package:kuwboo_mobile/config/environment.dart';
import 'package:kuwboo_mobile/features/feed/application/feed_provider.dart';
import 'package:kuwboo_mobile/features/feed/data/feed_api.dart';
import 'package:kuwboo_mobile/features/feed/data/feed_models.dart';

/// E2E smoke for the boot-with-existing-session path on a real device.
///
/// Per-screen rendering is covered by widget tests in `test/feed_screens_test.dart`
/// which mock the API. This file covers the one thing those can't:
/// pre-seed auth tokens in the iOS Keychain / Android EncryptedSharedPreferences,
/// boot the real app, and confirm the router redirect lands the user past `/login`.
///
/// Network is stubbed with [_EmptyFeedApi] so the test doesn't depend on the
/// backend being reachable from the CI runner.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots authenticated when tokens exist in secure storage',
      (tester) async {
    final client = shared.KuwbooApiClient(baseUrl: Environment.apiBaseUrl);
    await client.clearTokens();
    await client.saveTokens(const TokenPair(
      accessToken: 'smoke-test-token',
      refreshToken: 'smoke-test-refresh',
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedApiProvider.overrideWithValue(_EmptyFeedApi()),
        ],
        child: const KuwbooTestApp(),
      ),
    );

    // AuthNotifier._init() reads the keychain async, then the router redirect
    // runs. Don't pumpAndSettle — landing screens may have animations.
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    while (tester.takeException() != null) {}

    expect(find.text('Welcome to Kuwboo'), findsNothing,
        reason: 'should have skipped login');
    expect(find.text('Verify your number'), findsNothing,
        reason: 'should have skipped OTP');
    expect(find.text('Nearby'), findsWidgets,
        reason: 'should have landed on the yoyo nearby screen');

    await client.clearTokens();
  });
}

/// Minimal stub that short-circuits every feed call with an empty response.
/// We only care that screens mount post-auth — content rendering is covered
/// by the widget tests in `test/feed_screens_test.dart`.
class _EmptyFeedApi implements FeedApi {
  @override
  Future<FeedPage> getFeed({
    required String tab,
    String? cursor,
    int limit = 20,
  }) async =>
      const FeedPage(items: [], hasMore: false);

  @override
  Future<FeedPage> getFollowing({
    required String tab,
    String? cursor,
    int limit = 20,
  }) async =>
      const FeedPage(items: [], hasMore: false);

  @override
  Future<List<FeedItem>> getDiscover({required String tab, int limit = 20}) async => const [];

  @override
  Future<List<FeedItem>> getTrending({required String tab, int limit = 20}) async => const [];

  @override
  Future<FeedPage> getProducts({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String? cursor,
    int limit = 20,
  }) async =>
      const FeedPage(items: [], hasMore: false);

  @override
  Future<FeedPage> getDeals({String? cursor, int limit = 20}) async =>
      const FeedPage(items: [], hasMore: false);

  @override
  Future<FeedItem> getProductDetail(String id) async => throw UnimplementedError();

  @override
  Future<FeedItem> getContentDetail(String id) async => throw UnimplementedError();

  @override
  Future<List<NearbyUser>> getYoyoNearby({
    required double lat,
    required double lng,
    int? radiusKm,
  }) async =>
      const [];
}
