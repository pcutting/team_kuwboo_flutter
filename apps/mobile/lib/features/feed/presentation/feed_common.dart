import 'package:flutter/material.dart';

/// Shared helpers used by the mobile feed screens.
///
/// Kept deliberately minimal — the rich prototype widgets in
/// `packages/kuwboo_screens` still drive the web prototype where demo data
/// is appropriate. Mobile wrappers render the live API response with
/// Material list tiles / cards so the wire-up is obvious and easy to test.

/// Render one of Loading / Error / Empty / Data for an AsyncValue-backed
/// list screen, with pull-to-refresh.
class FeedAsyncBuilder<T> extends StatelessWidget {
  final AsyncSnapshotLike<T> snapshot;
  final Future<void> Function() onRefresh;
  final bool Function(T) isEmpty;
  final Widget Function(BuildContext, T) builder;
  final String emptyLabel;

  const FeedAsyncBuilder({
    super.key,
    required this.snapshot,
    required this.onRefresh,
    required this.isEmpty,
    required this.builder,
    this.emptyLabel = 'Nothing here yet',
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.isLoading && snapshot.value == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.error != null && snapshot.value == null) {
      return _ErrorView(
        error: snapshot.error!,
        onRetry: onRefresh,
      );
    }
    final data = snapshot.value;
    if (data == null || isEmpty(data)) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Text(
                emptyLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: builder(context, data),
    );
  }
}

/// Minimal snapshot adapter so tests can pass synchronous state without
/// dragging in Riverpod's `AsyncValue` typing.
class AsyncSnapshotLike<T> {
  final T? value;
  final Object? error;
  final bool isLoading;

  const AsyncSnapshotLike({
    this.value,
    this.error,
    this.isLoading = false,
  });
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: Colors.black45),
            const SizedBox(height: 12),
            Text(
              'Couldn\u2019t load feed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Formats a price in minor units (pence / cents) to a display string.
String formatPrice(int? cents, String currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  final symbol = switch (currency) {
    'GBP' => '\u00a3',
    'USD' => '\$',
    'EUR' => '\u20ac',
    _ => '$currency ',
  };
  return '$symbol$amount';
}

/// Formats a distance in metres for the YoYo nearby list.
String formatDistance(int meters) {
  if (meters < 1000) return '${meters}m';
  return '${(meters / 1000).toStringAsFixed(1)}km';
}
