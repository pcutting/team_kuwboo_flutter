import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Finder that matches the [Semantics] *widget* element with the given
/// identifier. We assert against the widget tree (not the rendered
/// SemanticsNode) so the tests stay deterministic across the heavy
/// provider stacks the screens depend on. The platform a11y tree at
/// runtime reads from `Semantics.properties` — what we assert here is
/// what Maestro / Patrol see at runtime.
Finder _bySemId(String id) {
  return find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.identifier == id,
    description: 'Semantics widget with identifier "$id"',
  );
}

/// Wraps a screen in the providers / theme it expects:
/// ProviderScope (Riverpod), ProtoThemeProvider, ProtoStateAccess, and
/// MaterialApp + Material. The screen-specific providers (yoyoNearby,
/// shopBrowse, socialFeed, etc.) hit the live API — for these smoke
/// tests we only need to render far enough that the static identifiers
/// (filter button, search input, etc.) reach the widget tree, so we
/// pump and tolerate loading/error states.
Widget _host(Widget child) {
  return ProviderScope(
    child: Consumer(
      builder: (context, ref, _) {
        final shell = ref.watch(shellStateProvider);
        final yoyo = ref.watch(yoyoStateProvider);
        final shellNotifier = ref.read(shellStateProvider.notifier);
        final yoyoNotifier = ref.read(yoyoStateProvider.notifier);
        return ProtoThemeProvider(
          theme: ProtoTheme.v0UrbanWarmth(),
          child: ProtoStateAccess(
            shell: shell,
            yoyo: yoyo,
            shellNotifier: shellNotifier,
            yoyoNotifier: yoyoNotifier,
            child: MaterialApp(
              home: Material(child: child),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> _pumpAtPhoneSize(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(414, 896));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_host(child));
  // Don't pumpAndSettle — most screens kick off async API loads via
  // Riverpod that never resolve in a unit test. Pumping a few frames
  // is enough to render the synchronous chrome (filter buttons,
  // search inputs) which is what we assert on.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('ScreensIds constant format', () {
    test('shopBrowseCategoryChip lowercases the name', () {
      expect(
        ScreensIds.shopBrowseCategoryChip('Food'),
        'shop.browse.chip_category_food',
      );
      expect(
        ScreensIds.shopBrowseCategoryChip('Electronics'),
        'shop.browse.chip_category_electronics',
      );
    });

    test('videoFeedCard interpolates index', () {
      expect(ScreensIds.videoFeedCard(0), 'video.feed.card_video_0');
      expect(ScreensIds.videoFeedCard(7), 'video.feed.card_video_7');
    });

    test('socialFeedLike interpolates per-post index', () {
      expect(ScreensIds.socialFeedLike(0), 'social.feed.btn_like_post_0');
      expect(ScreensIds.socialFeedLike(3), 'social.feed.btn_like_post_3');
    });

    test('profileMyStat slots the kind', () {
      expect(ScreensIds.profileMyStat('posts'), 'profile.my.stat_posts');
      expect(
        ScreensIds.profileMyStat('followers'),
        'profile.my.stat_followers',
      );
    });

    test('shopBrowseSearch is the fixed string Maestro flows expect', () {
      expect(ScreensIds.shopBrowseSearch, 'shop.browse.input_search');
    });

    test('yoyoNearbyFilter is the fixed string Maestro flows expect', () {
      expect(ScreensIds.yoyoNearbyFilter, 'yoyo.nearby.btn_filter');
    });
  });

  group('ShopBrowseScreen smoke', () {
    testWidgets('search bar identifier is in the widget tree',
        (tester) async {
      await _pumpAtPhoneSize(tester, const ShopBrowseScreen());
      // Search bar is in the synchronous chrome (above the async list).
      expect(_bySemId(ScreensIds.shopBrowseSearch), findsOneWidget);
    });

    testWidgets('category chip "All" is in the widget tree', (tester) async {
      await _pumpAtPhoneSize(tester, const ShopBrowseScreen());
      expect(
        _bySemId(ScreensIds.shopBrowseCategoryChip('All')),
        findsOneWidget,
      );
    });
  });
}
