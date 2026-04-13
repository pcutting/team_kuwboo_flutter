import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/feed_provider.dart';
import '../data/feed_models.dart';
import 'feed_common.dart';

/// Mobile-side marketplace grid wired to `GET /products`.
class ShopFeedMobileScreen extends ConsumerWidget {
  const ShopFeedMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(shopFeedProvider);
    final notifier = ref.read(shopFeedProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: FeedAsyncBuilder<FeedListState>(
        snapshot: AsyncSnapshotLike(
          value: async.valueOrNull,
          error: async.hasError ? async.error : null,
          isLoading: async.isLoading,
        ),
        onRefresh: notifier.refresh,
        isEmpty: (s) => s.items.isEmpty,
        emptyLabel: 'No listings yet',
        builder: (context, state) {
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 300) {
                notifier.loadMore();
              }
              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount:
                  state.items.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _ProductCard(item: state.items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final FeedItem item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.black12,
              child: const Icon(Icons.image_outlined,
                  size: 48, color: Colors.black45),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? 'Untitled',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(item.priceCents, item.currency),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700),
                ),
                if (item.condition != null)
                  Text(
                    item.condition!.toLowerCase(),
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
