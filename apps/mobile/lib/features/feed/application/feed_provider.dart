import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../../../providers/api_provider.dart';
import '../../../providers/location_provider.dart';

/// Shared [FeedApi] backed by the authenticated [KuwbooApiClient].
final feedApiProvider = Provider<FeedApi>(
  (ref) => FeedApi(ref.watch(apiClientProvider)),
);

/// Products live on `MarketplaceApi` (backend `/products/*`), not `FeedApi`.
final marketplaceApiProvider = Provider<MarketplaceApi>(
  (ref) => MarketplaceApi(ref.watch(apiClientProvider)),
);

/// Nearby users live on `YoyoApi` (backend `/yoyo/nearby`), not `FeedApi`.
final yoyoApiProvider = Provider<YoyoApi>(
  (ref) => YoyoApi(ref.watch(apiClientProvider)),
);

// ─── Feed state ──────────────────────────────────────────────────────────

/// Snapshot of a paginated content feed screen.
class FeedListState {
  final List<Content> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  const FeedListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  FeedListState copyWith({
    List<Content>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return FeedListState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Snapshot of a paginated product grid (marketplace).
class ProductListState {
  final List<Product> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  ProductListState copyWith({
    List<Product>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductListState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Base notifier for a tab-filtered `/feed` endpoint (video / social).
abstract class _TabFeedNotifier extends AsyncNotifier<FeedListState> {
  String get tab;

  FeedApi get _api => ref.read(feedApiProvider);

  @override
  Future<FeedListState> build() async {
    final page = await _api.getHome(tab: tab);
    return FeedListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _api.getHome(tab: tab);
      return FeedListState(
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    final cursor = current.nextCursor;
    if (cursor == null) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final page = await _api.getHome(tab: tab, cursor: cursor);
      state = AsyncValue.data(FeedListState(
        items: [...current.items, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      state = AsyncValue.error(e, st);
    }
  }
}

class VideoFeedNotifier extends _TabFeedNotifier {
  @override
  String get tab => 'video';
}

class SocialFeedNotifier extends _TabFeedNotifier {
  @override
  String get tab => 'social';
}

/// Shop feed: calls `/products` so we get Product-typed rows with
/// `title`, `priceCents`, `condition`.
class ShopFeedNotifier extends AsyncNotifier<ProductListState> {
  MarketplaceApi get _api => ref.read(marketplaceApiProvider);

  @override
  Future<ProductListState> build() async {
    final page = await _api.listProducts();
    return ProductListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _api.listProducts();
      return ProductListState(
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    final cursor = current.nextCursor;
    if (cursor == null) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final page = await _api.listProducts(cursor: cursor);
      state = AsyncValue.data(ProductListState(
        items: [...current.items, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      state = AsyncValue.error(e, st);
    }
  }
}

/// YoYo nearby users at a fixed London location. Coordinates will be
/// replaced by real device location once the geolocation plugin is wired
/// up; for now we use the same seeded coords as the backend fixtures so
/// the UI can show data end-to-end.
class YoyoNearbyNotifier extends AsyncNotifier<List<NearbyUser>> {
  YoyoApi get _api => ref.read(yoyoApiProvider);

  Future<List<NearbyUser>> _fetch() async {
    final loc = await ref.watch(currentLocationProvider.future);
    return _api.getNearby(lat: loc.lat, lng: loc.lng, radius: 50);
  }

  @override
  Future<List<NearbyUser>> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ─── Providers ───────────────────────────────────────────────────────────

final videoFeedProvider =
    AsyncNotifierProvider<VideoFeedNotifier, FeedListState>(
  VideoFeedNotifier.new,
);

final socialFeedProvider =
    AsyncNotifierProvider<SocialFeedNotifier, FeedListState>(
  SocialFeedNotifier.new,
);

final shopFeedProvider =
    AsyncNotifierProvider<ShopFeedNotifier, ProductListState>(
  ShopFeedNotifier.new,
);

final yoyoNearbyProvider =
    AsyncNotifierProvider<YoyoNearbyNotifier, List<NearbyUser>>(
  YoyoNearbyNotifier.new,
);
