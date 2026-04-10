import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'chat_ornaments.dart';
import 'proto_conversation_card.dart';

/// Canonical chat inbox screen.
///
/// When [moduleKey] is null, all conversations are shown (with module
/// context badges). When set (e.g. `'YoYo'`, `'Dating'`, `'Market'`),
/// only conversations whose `moduleContext` matches are shown.
///
/// Optional [ornaments] control per-module visual extras such as
/// encryption badges, retention timers, and online indicators.
class ChatInboxScreen extends StatefulWidget {
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
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  int _variant = 0;

  List<DemoConversation> get _conversations {
    final all = ProtoDemoData.conversations;
    if (widget.moduleKey == null) return all;
    return all.where((c) => c.moduleContext == widget.moduleKey).toList();
  }

  // ── Variant toggle (1/2 pills) ────────────────────────────────────────

  Widget _buildVariantToggle(ProtoTheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 2; i++) ...[
          GestureDetector(
            onTap: () => setState(() => _variant = i),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: i == _variant ? theme.primary : theme.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: i == _variant
                      ? theme.primary
                      : theme.textTertiary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: i == _variant ? Colors.white : theme.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          if (i < 1) const SizedBox(width: 4),
        ],
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final convos = _conversations;
    final showModuleBadge = widget.moduleKey == null;

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: widget.title,
            actions: [_buildVariantToggle(theme)],
          ),

          // V2: search bar + mark-all-read
          if (_variant == 1)
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
            child: convos.isEmpty
                ? const ProtoEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No conversations yet',
                    subtitle: 'Start a chat to connect with others',
                    actionLabel: 'New Message',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: convos.length,
                    itemBuilder: (context, i) {
                      final conv = convos[i];
                      return _buildDismissible(
                        context,
                        theme,
                        conv,
                        ProtoConversationCard(
                          conversation: conv,
                          index: i,
                          ornaments: widget.ornaments,
                          showModuleBadge: showModuleBadge,
                          onTap: () =>
                              state.push(ProtoRoutes.chatConversation),
                        ),
                      );
                    },
                  ),
          ),

          // V2: swipe hint
          if (_variant == 1)
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
