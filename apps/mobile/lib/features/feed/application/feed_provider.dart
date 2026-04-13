import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/api_provider.dart';
import '../data/feed_api.dart';
import '../data/feed_models.dart';

/// Provides a live [FeedApi] backed by the authenticated Dio.
final feedApiProvider = Provider<FeedApi>(
  (ref) => FeedApi(ref.watch(dioProvider)),
);

// ─── Feed state ──────────────────────────────────────────────────────────

/// Snapshot of a paginated feed screen. Exposed to the UI via the various
/// async notifiers below so screens can render loading / error / data /
/// load-more / refresh.
class FeedListState {
  final List<FeedItem> items;
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
    List<FeedItem>? items,
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

/// Base notifier for a tab-filtered `/feed` endpoint (video / social).
abstract class _TabFeedNotifier extends AsyncNotifier<FeedListState> {
  String get tab;

  FeedApi get _api => ref.read(feedApiProvider);

  @override
  Future<FeedListState> build() async {
    final page = await _api.getFeed(tab: tab);
    return FeedListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  /// Pull-to-refresh — re-fetch first page and replace.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _api.getFeed(tab: tab);
      return FeedListState(
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    });
  }

  /// Infinite scroll — append next page.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    final cursor = current.nextCursor;
    if (cursor == null) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final page = await _api.getFeed(tab: tab, cursor: cursor);
      state = AsyncValue.data(FeedListState(
        items: [...current.items, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      // Keep existing items, drop the loading flag, surface the error.
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

/// Shop feed: calls `/products` (not `/feed?tab=shop`) so we get Product
/// fields (`title`, `priceCents`, `condition`, …) instead of the generic
/// content shape.
class ShopFeedNotifier extends AsyncNotifier<FeedListState> {
  FeedApi get _api => ref.read(feedApiProvider);

  @override
  Future<FeedListState> build() async {
    final page = await _api.getProducts();
    return FeedListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _api.getProducts();
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
      final page = await _api.getProducts(cursor: cursor);
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

/// YoYo nearby users at a fixed London location. Coordinates will be
/// replaced by real device location once the geolocation plugin is wired
/// up; for now we use the same seeded coords as the backend fixtures so
/// the UI can show data end-to-end.
class YoyoNearbyNotifier extends AsyncNotifier<List<NearbyUser>> {
  static const double _fallbackLat = 51.5074; // London
  static const double _fallbackLng = -0.1278;

  FeedApi get _api => ref.read(feedApiProvider);

  @override
  Future<List<NearbyUser>> build() {
    return _api.getYoyoNearby(
      lat: _fallbackLat,
      lng: _fallbackLng,
      radiusKm: 50,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _api.getYoyoNearby(
        lat: _fallbackLat,
        lng: _fallbackLng,
        radiusKm: 50,
      );
    });
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
    AsyncNotifierProvider<ShopFeedNotifier, FeedListState>(
  ShopFeedNotifier.new,
);

final yoyoNearbyProvider =
    AsyncNotifierProvider<YoyoNearbyNotifier, List<NearbyUser>>(
  YoyoNearbyNotifier.new,
);
