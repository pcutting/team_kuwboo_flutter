import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../application/feed_provider.dart';
import 'feed_common.dart';

/// Mobile-side YoYo nearby list wired to `GET /yoyo/nearby`.
class YoyoNearbyMobileScreen extends ConsumerWidget {
  const YoyoNearbyMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(yoyoNearbyProvider);
    final notifier = ref.read(yoyoNearbyProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FeedAsyncBuilder<List<NearbyUser>>(
        snapshot: AsyncSnapshotLike(
          value: async.valueOrNull,
          error: async.hasError ? async.error : null,
          isLoading: async.isLoading,
        ),
        onRefresh: notifier.refresh,
        isEmpty: (list) => list.isEmpty,
        emptyLabel: 'No one nearby',
        builder: (context, users) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: u.avatarUrl != null
                      ? NetworkImage(u.avatarUrl!)
                      : null,
                  child: u.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(u.name),
                subtitle: Text(formatDistance(u.distanceMeters)),
                trailing: const Icon(Icons.waving_hand_outlined),
              );
            },
          );
        },
      ),
    );
  }
}
