import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'social_providers.dart';

class SocialFriendsList extends ConsumerStatefulWidget {
  const SocialFriendsList({super.key});

  @override
  ConsumerState<SocialFriendsList> createState() => _SocialFriendsListState();
}

class _SocialFriendsListState extends ConsumerState<SocialFriendsList> {
  bool _showFollowing = false;

  static const _pageLimit = 20;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    final args = FriendsListArgs(
      limit: _pageLimit,
      offset: 0,
      following: _showFollowing,
    );
    final page = ref.watch(friendsListProvider(args));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Icon(theme.icons.search, size: 20, color: theme.textTertiary),
                const SizedBox(width: 10),
                Text('Search friends...', style: theme.body.copyWith(color: theme.textTertiary)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _ToggleChip(
                label: 'Followers',
                isActive: !_showFollowing,
                onTap: () => setState(() => _showFollowing = false),
                theme: theme,
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                label: 'Following',
                isActive: _showFollowing,
                onTap: () => setState(() => _showFollowing = true),
                theme: theme,
              ),
              const Spacer(),
              page.when(
                data: (p) => Text(
                  p.hasMore ? '${p.items.length}+' : '${p.items.length}',
                  style: theme.caption,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        Expanded(
          child: page.when(
            loading: () => const ProtoLoadingState(itemCount: 6),
            error: (err, _) => ProtoErrorState(
              message: 'Could not load friends',
              onRetry: () => ref.invalidate(friendsListProvider(args)),
            ),
            data: (p) {
              if (p.items.isEmpty) {
                return ProtoEmptyState(
                  icon: theme.icons.peopleOutline,
                  title: _showFollowing ? 'Not following anyone yet' : 'No followers yet',
                  subtitle: 'Discover people on the Stumble tab.',
                  actionLabel: 'Discover',
                  onAction: () => state.push(ProtoRoutes.socialStumble),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: p.items.length,
                itemBuilder: (context, i) {
                  final conn = p.items[i];
                  // Choose the "other" user depending on direction.
                  final otherUserId = _showFollowing ? conn.toUserId : conn.fromUserId;
                  return ProtoPressButton(
                    onTap: () => state.push(ProtoRoutes.chatConversation),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: theme.cardDecoration,
                      child: Row(
                        children: [
                          ProtoAvatar(radius: 22, imageUrl: ''),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherUserId,
                                  style: theme.title.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Connected ${_formatDate(conn.createdAt)}',
                                  style: theme.caption,
                                ),
                              ],
                            ),
                          ),
                          ProtoPressButton(
                            onTap: () {
                              ProtoToast.show(context, theme.icons.chatBubbleOutline, 'Chat');
                              state.push(ProtoRoutes.chatConversation);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(theme.icons.chatBubbleOutline, size: 20, color: theme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    return ProtoPressButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.primary : theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.text.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}
