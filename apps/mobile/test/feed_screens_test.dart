import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import 'package:kuwboo_mobile/features/feed/application/feed_provider.dart';
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

  FeedResponse? feedPage;
  ProductPage? products;
  ProductPage? deals;
  List<NearbyUser> nearby;
  String? lastFeedTab;

  @override
  Future<FeedResponse> getFeed({
    String? tab,
    String? cursor,
    int limit = 20,
  }) async {
    lastFeedTab = tab;
    return feedPage ?? const FeedResponse(items: [], hasMore: false);
  }

  @override
  Future<FeedResponse> getDiscover({String? tab, int limit = 20}) async =>
      const FeedResponse(items: [], hasMore: false);

  @override
  Future<FeedResponse> getTrending({String? tab, int limit = 20}) async =>
      const FeedResponse(items: [], hasMore: false);

  @override
  Future<FeedResponse> getFollowing({
    String? tab,
    String? cursor,
    int limit = 20,
  }) async =>
      const FeedResponse(items: [], hasMore: false);

  @override
  Future<ProductPage> getProducts({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String? cursor,
    int limit = 20,
  }) async =>
      products ?? const ProductPage();

  @override
  Future<ProductPage> getProductDeals({String? cursor, int limit = 20}) async =>
      deals ?? const ProductPage();

  @override
  Future<Product> getProductDetail(String id) async =>
      throw UnimplementedError();

  @override
  Future<Content> getContentDetail(String id) async =>
      throw UnimplementedError();

  @override
  Future<List<NearbyUser>> getYoyoNearby({
    required double lat,
    required double lng,
    int? radiusKm,
  }) async =>
      nearby;
}

// ─── Helpers ────────────────────────────────────────────────────────────

Content _video({
  String id = 'v1',
  String creatorName = 'alice',
  String caption = 'hello world',
  int likes = 10,
}) {
  return Content(
    id: id,
    type: ContentType.video,
    creatorId: 'u1',
    creator: FeedCreator(id: 'u1', name: creatorName),
    caption: caption,
    likeCount: likes,
    commentCount: 2,
    viewCount: 100,
    createdAt: DateTime.now(),
  );
}

Content _post({String text = 'a social post'}) {
  return Content(
    id: 'p1',
    type: ContentType.post,
    creatorId: 'u1',
    creator: const FeedCreator(id: 'u1', name: 'bob'),
    text: text,
    likeCount: 1,
    createdAt: DateTime.now(),
  );
}

Product _product({String title = 'Vintage chair', int price = 4999}) {
  return Product(
    id: 'pr1',
    creatorId: 'u1',
    title: title,
    description: 'A lovely chair',
    priceCents: price,
    currency: 'GBP',
    condition: 'USED',
    createdAt: DateTime.now(),
  );
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
      feedPage: FeedResponse(
        items: [
          _video(caption: 'first video'),
          _video(id: 'v2', caption: 'second'),
        ],
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
      feedPage: FeedResponse(
        items: [_post(text: 'hello social')],
        hasMore: false,
      ),
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
      products: ProductPage(items: [_product(title: 'Chair A')]),
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
    final api = _FakeFeedApi(
      feedPage: const FeedResponse(items: [], hasMore: false),
    );
    final container = ProviderContainer(
      overrides: [feedApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(const VideoFeedMobileScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('No videos yet'), findsOneWidget);
  });
}
