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

  List<DemoConversation> _applyFilter(List<DemoConversation> all) {
    if (widget.moduleKey == null) return all;
    return all.where((c) => c.moduleContext == widget.moduleKey).toList();
  }

  /// Apply [_applyFilter] over `(thread, demo)` pairs so the live thread id
  /// stays attached to the rendered conversation card. Without this the
  /// conversation screen only knows the display data and falls back to the
  /// canned transactional prototype (no live input bar).
  List<(api.Thread, DemoConversation)> _applyFilterPairs(
    List<(api.Thread, DemoConversation)> all,
  ) {
    if (widget.moduleKey == null) return all;
    return all.where((p) => p.$2.moduleContext == widget.moduleKey).toList();
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final threadsAsync = ref.watch(threadsProvider);
    final showModuleBadge = widget.moduleKey == null;

    // Map live threads → DemoConversation view-models (paired with their
    // source `api.Thread` so we can pass the live id when navigating into
    // a conversation), then client-side filter by moduleKey. Fall back to
    // static demo data with `null` thread id when the backend is unreachable.
    final convoPairs = threadsAsync.when(
      data: (threads) => _applyFilterPairs(
        threads.items.map((t) => (t, _threadToDemo(t))).toList(),
      ),
      loading: () => const <(api.Thread, DemoConversation)>[],
      error: (_, __) => <(api.Thread, DemoConversation)>[],
    );
    // Offline / static fallback — DemoConversations without a backend id.
    final fallbackConvos = threadsAsync.when(
      data: (_) => const <DemoConversation>[],
      loading: () => const <DemoConversation>[],
      error: (_, __) => _applyFilter(ProtoDemoData.conversations),
    );
    final convos = [
      ...convoPairs.map((p) => p.$2),
      ...fallbackConvos,
    ];
    final isLoading = threadsAsync.isLoading;

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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : convos.isEmpty
                ? const ProtoEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No conversations yet',
                    subtitle: 'Start a chat to connect with others',
                    actionLabel: 'New Message',
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(threadsProvider),
                    child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: convos.length,
                    itemBuilder: (context, i) {
                      final conv = convos[i];
                      // Cards backed by a live thread carry the id forward
                      // so the conversation screen renders the live input
                      // bar (real TextField + functional Send). Fallback
                      // demo cards still navigate to the canned prototype.
                      final liveThreadId =
                          i < convoPairs.length ? convoPairs[i].$1.id : null;
                      return _buildDismissible(
                        context,
                        theme,
                        conv,
                        ProtoConversationCard(
                          conversation: conv,
                          index: i,
                          ornaments: widget.ornaments,
                          showModuleBadge: showModuleBadge,
                          onTap: () => liveThreadId == null
                              ? state.push(ProtoRoutes.chatConversation)
                              : state.pushWithArgs(
                                  ProtoRoutes.chatConversation,
                                  {'threadId': liveThreadId},
                                ),
                        ),
                      );
                    },
                  ),
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
