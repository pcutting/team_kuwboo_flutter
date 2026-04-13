import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kuwboo_mobile/features/feed/application/feed_provider.dart';
import 'package:kuwboo_mobile/features/feed/data/feed_api.dart';
import 'package:kuwboo_mobile/features/feed/data/feed_models.dart';
import 'package:kuwboo_mobile/features/feed/presentation/shop_feed_mobile_screen.dart';
import 'package:kuwboo_mobile/features/feed/presentation/social_feed_mobile_screen.dart';
import 'package:kuwboo_mobile/features/feed/presentation/video_feed_mobile_screen.dart';
import 'package:kuwboo_mobile/features/feed/presentation/yoyo_nearby_mobile_screen.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────

class _FakeFeedApi implements FeedApi {
  _FakeFeedApi({
    this.feedPage,
    this.products,
    this.nearby = const [],
  });

  FeedPage? feedPage;
  FeedPage? products;
  FeedPage? deals;
  List<NearbyUser> nearby;
  String? lastFeedTab;

  @override
  Future<FeedPage> getFeed({
    required String tab,
    String? cursor,
    int limit = 20,
  }) async {
    lastFeedTab = tab;
    return feedPage ?? const FeedPage(items: [], hasMore: false);
  }

  @override
  Future<List<FeedItem>> getDiscover({required String tab, int limit = 20}) async => [];

  @override
  Future<List<FeedItem>> getTrending({required String tab, int limit = 20}) async => [];

  @override
  Future<FeedPage> getFollowing({
    required String tab,
    String? cursor,
    int limit = 20,
  }) async =>
      const FeedPage(items: [], hasMore: false);

  @override
  Future<FeedPage> getProducts({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String? cursor,
    int limit = 20,
  }) async =>
      products ?? const FeedPage(items: [], hasMore: false);

  @override
  Future<FeedPage> getDeals({String? cursor, int limit = 20}) async =>
      deals ?? const FeedPage(items: [], hasMore: false);

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
      nearby;
}

// ─── Helpers ────────────────────────────────────────────────────────────

FeedItem _video({
  String id = 'v1',
  String creator = 'alice',
  String caption = 'hello world',
  int likes = 10,
}) {
  return FeedItem.fromJson({
    'id': id,
    'type': 'VIDEO',
    'creator': {'id': 'u1', 'name': creator},
    'caption': caption,
    'likeCount': likes,
    'commentCount': 2,
    'shareCount': 0,
    'viewCount': 100,
    'createdAt': DateTime.now().toIso8601String(),
    'thumbnailUrl': null,
  });
}

FeedItem _post({String text = 'a social post'}) {
  return FeedItem.fromJson({
    'id': 'p1',
    'type': 'POST',
    'creator': {'id': 'u1', 'name': 'bob'},
    'text': text,
    'likeCount': 1,
    'commentCount': 0,
    'shareCount': 0,
    'viewCount': 0,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

FeedItem _product({String title = 'Vintage chair', int price = 4999}) {
  return FeedItem.fromJson({
    'id': 'pr1',
    'type': 'PRODUCT',
    'creator': {'id': 'u1', 'name': 'seller'},
    'title': title,
    'priceCents': price,
    'currency': 'GBP',
    'condition': 'USED',
    'likeCount': 0,
    'commentCount': 0,
    'shareCount': 0,
    'viewCount': 0,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

Widget _wrap(Widget screen, ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: screen),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────

void main() {
  testWidgets('VideoFeedMobileScreen renders API-backed videos', (tester) async {
    final api = _FakeFeedApi(
      feedPage: FeedPage(
        items: [_video(caption: 'first video'), _video(id: 'v2', caption: 'second')],
        hasMore: false,
      ),
    );
    final container = ProviderContainer(
      overrides: [feedApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(const VideoFeedMobileScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('first video'), findsOneWidget);
    expect(api.lastFeedTab, 'video');
  });

  testWidgets('SocialFeedMobileScreen renders API-backed posts', (tester) async {
    final api = _FakeFeedApi(
      feedPage: FeedPage(items: [_post(text: 'hello social')], hasMore: false),
    );
    final container = ProviderContainer(
      overrides: [feedApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(const SocialFeedMobileScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('hello social'), findsOneWidget);
    expect(api.lastFeedTab, 'social');
  });

  testWidgets('ShopFeedMobileScreen renders products with prices', (tester) async {
    final api = _FakeFeedApi(
      products: FeedPage(items: [_product(title: 'Chair A')], hasMore: false),
    );
    final container = ProviderContainer(
      overrides: [feedApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(const ShopFeedMobileScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('Chair A'), findsOneWidget);
    expect(find.text('\u00a349.99'), findsOneWidget);
  });

  testWidgets('YoyoNearbyMobileScreen renders nearby users', (tester) async {
    final api = _FakeFeedApi(
      nearby: const [
        NearbyUser(id: '1', name: 'Charlie', distanceMeters: 250),
        NearbyUser(id: '2', name: 'Dana', distanceMeters: 1500),
      ],
    );
    final container = ProviderContainer(
      overrides: [feedApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(const YoyoNearbyMobileScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('Charlie'), findsOneWidget);
    expect(find.text('Dana'), findsOneWidget);
    expect(find.text('250m'), findsOneWidget);
    expect(find.text('1.5km'), findsOneWidget);
  });

  testWidgets('shows empty state when API returns no items', (tester) async {
    final api = _FakeFeedApi(feedPage: const FeedPage(items: [], hasMore: false));
    final container = ProviderContainer(
      overrides: [feedApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(const VideoFeedMobileScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('No videos yet'), findsOneWidget);
  });
}
