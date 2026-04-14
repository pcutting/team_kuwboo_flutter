import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'inner_circle_shared.dart';

/// Inner Circle Chat: Persistent family/friend conversations (no expiry).
class InnerCircleChatView extends StatefulWidget {
  const InnerCircleChatView({super.key});

  @override
  State<InnerCircleChatView> createState() => _InnerCircleChatViewState();
}

class _InnerCircleChatViewState extends State<InnerCircleChatView> {
  bool _searchFocused = false;

  void _handleSearchTap() {
    setState(() => _searchFocused = true);
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, Icons.search_rounded, 'Search keyboard would open');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _searchFocused = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final conversations = ProtoDemoData.familyConversations;

    return ProtoScaffold(
      activeModule: ProtoModule.yoyo,
      activeTab: 3,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text('Family Chat', style: theme.headline.copyWith(fontSize: 24, color: warmAmber)),
                const SizedBox(width: 8),
                innerCircleBadge(theme),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GestureDetector(
              onTap: _handleSearchTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _searchFocused
                        ? warmAmber.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: _searchFocused ? warmAmber : theme.textTertiary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Search family chats...',
                      style: theme.body.copyWith(color: theme.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: conversations.length,
              itemBuilder: (context, i) {
                final conv = conversations[i];
                return ProtoPressButton(
                  duration: const Duration(milliseconds: 100),
                  onTap: () => state.push(ProtoRoutes.chatConversation),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: warmAmber.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: warmAmber.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(conv.avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Online status
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: i < 2
                                      ? theme.successColor
                                      : theme.textTertiary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.surface, width: 2),
                                ),
                              ),
                            ),
                            // Unread badge
                            if (conv.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: warmAmber,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.surface, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${conv.unreadCount}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
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
                              Text(conv.name, style: theme.title.copyWith(fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(
                                conv.lastMessage,
                                style: theme.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // No expiry timer — persistent chats
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.all_inclusive_rounded,
                                    size: 11,
                                    color: warmAmber.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Persistent',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: warmAmber.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(conv.timeAgo, style: theme.caption),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
