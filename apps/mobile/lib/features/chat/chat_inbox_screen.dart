import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Conversation list screen showing all message threads.
class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  // Demo threads for UI scaffolding.
  static final _demoThreads = [
    Thread(
      id: 'thread_1',
      moduleKey: 'buy_sell',
      contextId: 'prod_0',
      lastMessageText: 'Is this still available?',
      lastMessageSenderId: 'user_2',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Thread(
      id: 'thread_2',
      moduleKey: 'buy_sell',
      contextId: 'prod_3',
      lastMessageText: 'Can you do \u00a340 for it?',
      lastMessageSenderId: 'user_3',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Thread(
      id: 'thread_3',
      lastMessageText: 'Thanks for the quick delivery!',
      lastMessageSenderId: 'user_1',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  static const _demoNames = {
    'thread_1': 'Sarah J.',
    'thread_2': 'Mike T.',
    'thread_3': 'Emily R.',
  };

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _demoThreads.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _demoThreads.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = _demoThreads[index];
                final name = _demoNames[thread.id] ?? 'Unknown';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      name[0],
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    thread.lastMessageText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTimestamp(thread.lastMessageAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => context.push('/chat/${thread.id}'),
                );
              },
            ),
    );
  }
}
