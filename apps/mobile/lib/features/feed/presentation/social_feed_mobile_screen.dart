import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../application/feed_provider.dart';
import 'feed_common.dart';

/// Mobile-side social feed wired to `GET /feed?tab=social`.
class SocialFeedMobileScreen extends ConsumerWidget {
  const SocialFeedMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(socialFeedProvider);
    final notifier = ref.read(socialFeedProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Social')),
      body: FeedAsyncBuilder<FeedListState>(
        snapshot: AsyncSnapshotLike(
          value: async.valueOrNull,
          error: async.hasError ? async.error : null,
          isLoading: async.isLoading,
        ),
        onRefresh: notifier.refresh,
        isEmpty: (s) => s.items.isEmpty,
        emptyLabel: 'No posts yet',
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
                return _PostCard(item: state.items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Content item;
  const _PostCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final creator = item.creator;
    final body = item.text ?? item.caption;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: creator?.avatarUrl != null
                      ? NetworkImage(creator!.avatarUrl!)
                      : null,
                  child: creator?.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator?.name ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _relativeTime(item.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (body != null) ...[
              const SizedBox(height: 12),
              Text(body),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite_border,
                    size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text('${item.likeCount}',
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(width: 14),
                const Icon(Icons.chat_bubble_outline,
                    size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text('${item.commentCount}',
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts);
    if (diff.isNegative) return '';
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 30) return '${diff.inDays}d';
    return '${(diff.inDays / 30).floor()}mo';
  }
}
