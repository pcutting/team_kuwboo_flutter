import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart' as api;
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'chat_ornaments.dart';
import 'chat_providers.dart';
import 'proto_conversation_card.dart';

/// Canonical chat inbox screen.
///
/// When [moduleKey] is null, all conversations are shown (with module
/// context badges). When set (e.g. `'YoYo'`, `'Dating'`, `'Market'`),
/// only conversations whose `moduleContext` matches are shown.
///
/// Optional [ornaments] control per-module visual extras such as
/// encryption badges, retention timers, and online indicators.
class ChatInboxScreen extends ConsumerStatefulWidget {
  /// Filter conversations to this module. Null means show all.
  final String? moduleKey;

  /// Title shown in the header. Defaults to `'Messages'`.
  final String title;

  /// Per-module visual ornaments for conversation cards.
  final ChatOrnaments ornaments;

  const ChatInboxScreen({
    super.key,
    this.moduleKey,
    this.title = 'Messages',
    this.ornaments = const ChatOrnaments(),
  });

  @override
  ConsumerState<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends ConsumerState<ChatInboxScreen> {
  /// Adapt a live [api.Thread] into a [DemoConversation] for rendering.
  /// Real user/name/avatar resolution will land when the thread payload
  /// includes participant data (Phase 7+).
  DemoConversation _threadToDemo(api.Thread t) {
    final module = t.moduleKey ?? 'Social';
    final name = 'Thread ${t.id.length > 6 ? t.id.substring(0, 6) : t.id}';
    return DemoConversation(
      name: name,
      lastMessage: t.lastMessageText ?? '(no messages yet)',
      timeAgo: _timeAgo(t.lastMessageAt ?? t.createdAt),
      unreadCount: 0,
      moduleContext: module,
      avatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
    );
  }

  String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  /// Filter `(thread, demo)` pairs by [widget.moduleKey] so the live
  /// thread id stays attached to the rendered conversation card. Without
  /// this the conversation screen only knows the display data.
  ///
  /// The widget receives display-cased filter values like `'YoYo'`,
  /// `'Dating'`, `'Shop'`. The backend persists the canonical enum
  /// (`'YOYO'`, `'DATING'`, `'BUY_SELL'`, `'SOCIAL_STUMBLE'`,
  /// `'VIDEO_MAKING'`). Compare case-insensitively, ignoring underscores
  /// and the optional shared prefixes (`SOCIAL_`, `BUY_`), so both
  /// shapes match without forcing a backend-wide rename.
  List<(api.Thread, DemoConversation)> _applyFilterPairs(
    List<(api.Thread, DemoConversation)> all,
  ) {
    final filter = widget.moduleKey;
    if (filter == null) return all;
    final norm = _normaliseModuleKey(filter);
    return all
        .where((p) => _normaliseModuleKey(p.$2.moduleContext) == norm)
        .toList();
  }

  /// Lowercase, strip underscores, and drop common prefixes so display
  /// names ('YoYo') match enum values ('YOYO') and the marketplace alias
  /// ('Shop' ↔ 'BUY_SELL') resolves the same way as before.
  static String _normaliseModuleKey(String value) {
    final lower = value.toLowerCase().replaceAll('_', '');
    if (lower == 'buysell') return 'shop';
    if (lower == 'socialstumble') return 'social';
    if (lower == 'videomaking') return 'video';
    return lower;
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final threadsAsync = ref.watch(threadsProvider);
    final showModuleBadge = widget.moduleKey == null;

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: widget.title,
          ),

          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(theme.icons.search,
                              size: 20, color: theme.textTertiary),
                          const SizedBox(width: 10),
                          Text(
                            'Search messages...',
                            style:
                                theme.body.copyWith(color: theme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ProtoPressButton(
                    onTap: () => ProtoToast.show(
                      context,
                      Icons.done_all_rounded,
                      'All messages marked as read',
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.done_all_rounded,
                              size: 16, color: theme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Read all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: threadsAsync.when(
              loading: () => const ProtoLoadingState(itemCount: 6),
              error: (err, _) => ProtoErrorState(
                message: 'Could not load conversations',
                onRetry: () => ref.invalidate(threadsProvider),
              ),
              data: (response) {
                final pairs = _applyFilterPairs(
                  response.items
                      .map((t) => (t, _threadToDemo(t)))
                      .toList(),
                );
                if (pairs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(threadsProvider),
                    child: ListView(
                      // ListView so RefreshIndicator has a scrollable;
                      // single child is the empty state.
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        ProtoEmptyState(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'No conversations yet',
                          subtitle:
                              'Start a chat to connect with others',
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(threadsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pairs.length,
                    itemBuilder: (context, i) {
                      final pair = pairs[i];
                      final conv = pair.$2;
                      final liveThreadId = pair.$1.id;
                      return _buildDismissible(
                        context,
                        theme,
                        conv,
                        ProtoConversationCard(
                          conversation: conv,
                          index: i,
                          ornaments: widget.ornaments,
                          showModuleBadge: showModuleBadge,
                          onTap: () => state.pushWithArgs(
                            ProtoRoutes.chatConversation,
                            {'threadId': liveThreadId},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Swipe for actions',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTertiary.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Swipe-to-delete wrapper ────────────────────────────────────────────

  Widget _buildDismissible(
    BuildContext context,
    ProtoTheme theme,
    DemoConversation conv,
    Widget child,
  ) {
    return Dismissible(
      key: ValueKey('conv-${conv.name}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteSheet(context, theme, conv.name),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: theme.accent, size: 22),
      ),
      child: child,
    );
  }

  Future<bool> _showDeleteSheet(
      BuildContext context, ProtoTheme theme, String name) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Delete conversation with $name?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ProtoPressButton(
              onTap: () {
                Navigator.pop(ctx);
                ProtoToast.show(context, Icons.delete_outline_rounded,
                    'Deleted for you');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 22, color: theme.textSecondary),
                    const SizedBox(width: 14),
                    Text(
                      'Delete for me',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ProtoPressButton(
              onTap: () {
                Navigator.pop(ctx);
                ProtoToast.show(context, Icons.delete_forever_rounded,
                    'Deleted for everyone');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.group_outlined,
                        size: 22, color: theme.accent),
                    const SizedBox(width: 14),
                    Text(
                      'Delete for everyone',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    return false;
  }
}
