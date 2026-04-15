import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'dating_providers.dart';

/// Likes received by the current user — backed by `GET /dating/likes`.
class DatingLikesScreen extends ConsumerWidget {
  const DatingLikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);
    final async = ref.watch(datingLikesProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => ProtoEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load likes',
        subtitle: err.toString(),
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(datingLikesProvider),
      ),
      data: (likes) {
        if (likes.isEmpty) {
          return const ProtoEmptyState(
            icon: Icons.favorite_outline_rounded,
            title: 'No likes yet',
            subtitle: "When someone likes you, they'll show up here",
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: likes.length,
          itemBuilder: (_, i) {
            final like = likes[i];
            final name = (like['name'] as String?) ?? 'Someone';
            final avatar = like['avatarUrl'] as String?;
            return Container(
              decoration: theme.cardDecoration,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (avatar != null)
                    ProtoNetworkImage(imageUrl: avatar, fit: BoxFit.cover)
                  else
                    Container(color: theme.surface),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Text(
                      name,
                      style: theme.title.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
