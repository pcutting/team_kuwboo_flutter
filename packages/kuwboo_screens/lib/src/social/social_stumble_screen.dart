import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'social_providers.dart';

class SocialStumbleScreen extends ConsumerWidget {
  const SocialStumbleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);
    final stumble = ref.watch(socialStumbleProvider);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'Stumble',
            actions: [
              _FilterIcon(icon: Icons.wc_rounded, label: 'Gender', theme: theme),
              const SizedBox(width: 4),
              _FilterIcon(icon: theme.icons.locationOn, label: 'Nearby', theme: theme),
              const SizedBox(width: 4),
              _FilterIcon(icon: theme.icons.personAdd, label: 'New', theme: theme),
            ],
          ),
          Expanded(
            child: stumble.when(
              loading: () => const ProtoLoadingState(itemCount: 4),
              error: (err, _) => ProtoErrorState(
                message: 'Could not load discovery feed',
                onRetry: () => ref.invalidate(socialStumbleProvider),
              ),
              data: (feed) {
                if (feed.items.isEmpty) {
                  return const ProtoEmptyState(
                    icon: Icons.explore_outlined,
                    title: 'Nothing to discover yet',
                    subtitle: 'Check back soon for new people and posts.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Discover new posts', style: theme.body),
                    const SizedBox(height: 16),
                    ...feed.items.map((c) => _StumbleCard(content: c, theme: theme)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StumbleCard extends ConsumerWidget {
  const _StumbleCard({required this.content, required this.theme});

  final Content content;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorName = content.creator?.name ?? 'Someone';
    final avatarUrl = content.creator?.avatarUrl;
    final creatorId = content.creator?.id;
    final bodyText = content.text ?? content.caption ?? content.title ?? '';
    final isFollowing =
        creatorId != null && ref.watch(followedCreatorsProvider).contains(creatorId);

    Future<void> onFollow() async {
      if (creatorId == null) return;
      // Optimistic flip so the button feels instant; revert on failure.
      ref.read(followedCreatorsProvider.notifier).update((s) => {...s, creatorId});
      try {
        await ref
            .read(connectionsApiProvider)
            .follow(FollowDto(userId: creatorId));
        if (context.mounted) {
          ProtoToast.show(
            context,
            theme.icons.personAdd,
            'Following $creatorName',
          );
        }
      } catch (e) {
        ref
            .read(followedCreatorsProvider.notifier)
            .update((s) => s.where((id) => id != creatorId).toSet());
        if (context.mounted) {
          ProtoToast.show(
            context,
            Icons.error_outline,
            'Couldn\'t follow — try again',
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: theme.cardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProtoAvatar(radius: 20, imageUrl: avatarUrl ?? ''),
              const SizedBox(width: 12),
              Expanded(
                child: Text(creatorName, style: theme.title.copyWith(fontSize: 14)),
              ),
              ProtoPressButton(
                onTap: isFollowing || creatorId == null ? null : onFollow,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFollowing
                        ? theme.text.withValues(alpha: 0.08)
                        : theme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isFollowing ? theme.textSecondary : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (bodyText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(bodyText, style: theme.body, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(theme.icons.favoriteOutline, size: 16, color: theme.textTertiary),
              const SizedBox(width: 4),
              Text('${content.likeCount}', style: theme.caption),
              const SizedBox(width: 16),
              Icon(theme.icons.chatBubbleOutline, size: 16, color: theme.textTertiary),
              const SizedBox(width: 4),
              Text('${content.commentCount}', style: theme.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final ProtoTheme theme;

  const _FilterIcon({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ProtoPressButton(
      onTap: () => ProtoToast.show(context, icon, '$label filter'),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.textTertiary.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 16, color: theme.textSecondary),
      ),
    );
  }
}
