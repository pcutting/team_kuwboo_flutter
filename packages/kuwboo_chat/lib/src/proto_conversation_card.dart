import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'chat_ornaments.dart';
import 'chat_test_ids.dart';

/// Shared conversation list tile used by [ChatInboxScreen].
///
/// Displays avatar, name, last message, time ago, unread badge, and
/// optional ornaments (online indicator, encryption badge, encounter pin,
/// retention timer) controlled by [ChatOrnaments].
class ProtoConversationCard extends StatelessWidget {
  final DemoConversation conversation;
  final VoidCallback onTap;
  final ChatOrnaments ornaments;

  /// Index within the list -- used for demo-quality online/offline logic
  /// (first item is "online", others are "offline").
  final int index;

  /// Whether to show the moduleContext badge next to the name.
  /// Typically true when the inbox shows all modules, false when filtered.
  final bool showModuleBadge;

  const ProtoConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    this.ornaments = const ChatOrnaments(),
    this.index = 0,
    this.showModuleBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Semantics(
      identifier: ChatIds.inboxCard(index),
      button: true,
      label: 'Conversation with ${conversation.name}',
      value: '${conversation.name}: ${conversation.lastMessage}',
      child: ProtoPressButton(
        duration: const Duration(milliseconds: 100),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: theme.cardDecoration,
          child: Row(
            children: [
              _buildAvatar(theme),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(theme)),
              _buildTrailing(theme),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar with badges ──────────────────────────────────────────────────

  Widget _buildAvatar(ProtoTheme theme) {
    return Stack(
      children: [
        ProtoAvatar(radius: 24, imageUrl: conversation.avatarUrl),

        // Online indicator (bottom-right)
        if (ornaments.showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: index == 0 ? theme.successColor : theme.textTertiary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.surface, width: 2),
              ),
            ),
          ),

        // Unread count (top-right)
        if (conversation.unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Semantics(
              identifier: ChatIds.inboxBadgeUnread(index),
              label: 'Unread',
              value: '${conversation.unreadCount}',
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.surface, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Encryption badge (top-left)
        if (ornaments.showEncryptionBadge)
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.surface, width: 2),
              ),
              child: const Icon(Icons.lock_rounded, size: 8, color: Colors.white),
            ),
          ),
      ],
    );
  }

  // ── Name + last message (+ optional ornaments) ──────────────────────────

  Widget _buildContent(ProtoTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(conversation.name, style: theme.title.copyWith(fontSize: 14)),

            // Module context badge (shown in unfiltered inbox)
            if (showModuleBadge) ...[
              const SizedBox(width: 6),
              Semantics(
                identifier: ChatIds.inboxBadgeModule(
                  conversation.moduleContext.toLowerCase(),
                ),
                label: '${conversation.moduleContext} module',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    conversation.moduleContext,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: theme.primary,
                    ),
                  ),
                ),
              ),
            ],

            // Encounter pin
            if (ornaments.showEncounterPin) ...[
              const SizedBox(width: 6),
              Icon(Icons.pin_drop_rounded, size: 12, color: theme.secondary),
              const SizedBox(width: 2),
              Text(
                'Nearby',
                style: TextStyle(
                  fontSize: 9,
                  color: theme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          conversation.lastMessage,
          style: theme.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Retention timer
        if (ornaments.showRetentionTimer) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.auto_delete_rounded,
                size: 11,
                color: index == 0 ? Colors.orange.shade700 : theme.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                index == 0 ? 'Expires in 4h' : 'Expires in 28h',
                style: TextStyle(
                  fontSize: 10,
                  color: index == 0 ? Colors.orange.shade700 : theme.textTertiary,
                  fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Trailing: time ──────────────────────────────────────────────────────

  Widget _buildTrailing(ProtoTheme theme) {
    return Text(conversation.timeAgo, style: theme.caption);
  }
}
