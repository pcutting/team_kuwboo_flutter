import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../application/feed_provider.dart';
import 'feed_common.dart';

/// Mobile-side video feed wired to `GET /feed?tab=video`.
///
/// The web prototype still uses the rich `VideoFeedScreen` from
/// `kuwboo_screens`; this wrapper renders the live API response as a
/// vertical list of video thumbnails with caption + counts, which is
/// enough to prove the data flow end-to-end.
class VideoFeedMobileScreen extends ConsumerWidget {
  const VideoFeedMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(videoFeedProvider);
    final notifier = ref.read(videoFeedProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('For You')),
      body: FeedAsyncBuilder<FeedListState>(
        snapshot: AsyncSnapshotLike(
          value: async.valueOrNull,
          error: async.hasError ? async.error : null,
          isLoading: async.isLoading,
        ),
        onRefresh: notifier.refresh,
        isEmpty: (s) => s.items.isEmpty,
        emptyLabel: 'No videos yet',
        builder: (context, state) {
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                notifier.loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _VideoCard(item: state.items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Content item;
  const _VideoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final thumb = item.thumbnailUrl;
    final creator = item.creator;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: thumb != null
                ? Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _ThumbPlaceholder(),
                  )
                : _ThumbPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: creator?.avatarUrl != null
                          ? NetworkImage(creator!.avatarUrl!)
                          : null,
                      child: creator?.avatarUrl == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        creator?.name ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (item.caption != null) ...[
                  const SizedBox(height: 8),
                  Text(item.caption!, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Stat(icon: Icons.favorite_border, value: item.likeCount),
                    const SizedBox(width: 12),
                    _Stat(icon: Icons.chat_bubble_outline, value: item.commentCount),
                    const SizedBox(width: 12),
                    _Stat(icon: Icons.visibility_outlined, value: item.viewCount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 48, color: Colors.black45),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final int value;
  const _Stat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text('$value', style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}
