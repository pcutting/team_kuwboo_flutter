import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import '../../shared/proto_states.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'Messages',
          ),

          // Search bar + mark all read
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
                          borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Icon(theme.icons.search,
                              size: 20, color: theme.textTertiary),
                          const SizedBox(width: 10),
                          Text('Search messages...',
                              style: theme.body
                                  .copyWith(color: theme.textTertiary)),
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
            child: ProtoDemoData.conversations.isEmpty
                ? const ProtoEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No conversations yet',
                    subtitle: 'Start a chat to connect with others',
                    actionLabel: 'New Message',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ProtoDemoData.conversations.length,
                    itemBuilder: (context, i) {
                      final conv = ProtoDemoData.conversations[i];
                      return _buildConversationCard(context, state, theme, conv, i);
                    },
                  ),
          ),

          // Swipe hint at bottom
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

  Widget _buildConversationCard(
    BuildContext context,
    PrototypeStateProvider state,
    ProtoTheme theme,
    DemoConversation conv,
    int i,
  ) {
    final card = GestureDetector(
      onTap: () => state.push(ProtoRoutes.chatConversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            // Avatar with badges
            Stack(
              children: [
                ProtoAvatar(
                    radius: 24,
                    imageUrl: conv.avatarUrl),
                if (conv.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                          color: theme.accent,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: theme.surface, width: 2)),
                      child: Center(
                          child: Text('${conv.unreadCount}',
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))),
                    ),
                  ),
                // Online indicator
                if (i < 3)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.successColor,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: theme.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Pinned icon on first conversation
                      if (i == 0) ...[
                        Icon(Icons.push_pin_rounded,
                            size: 12, color: theme.textTertiary),
                        const SizedBox(width: 4),
                      ],
                      Text(conv.name,
                          style: theme.title.copyWith(fontSize: 14)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color:
                                theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(conv.moduleContext,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: theme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Typing preview on first conversation
                  if (i == 0)
                    Text(
                      '${conv.name} is typing...',
                      style: theme.body.copyWith(
                        color: theme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(conv.lastMessage,
                        style: theme.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(conv.timeAgo, style: theme.caption),
                // Read receipt on second conversation
                if (i == 1) ...[
                  const SizedBox(height: 2),
                  const Icon(Icons.done_all_rounded,
                      size: 14, color: Color(0xFF4FC3F7)),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    // Swipe to delete — both v1 and v2
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
        child: Icon(Icons.delete_outline_rounded, color: theme.accent, size: 22),
      ),
      child: card,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
