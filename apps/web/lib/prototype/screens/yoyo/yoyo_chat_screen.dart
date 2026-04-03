import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import 'inner_circle_chat.dart';

/// Filtered chat inbox showing only YoYo conversations.
/// V2 adds encryption indicator, encounter badges, data retention timer.
class YoyoChatScreen extends StatefulWidget {
  const YoyoChatScreen({super.key});

  @override
  State<YoyoChatScreen> createState() => _YoyoChatScreenState();
}

class _YoyoChatScreenState extends State<YoyoChatScreen> {
  bool _searchFocused = false;

  void _handleSearchTap() {
    setState(() => _searchFocused = true);
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, theme.icons.search, 'Search keyboard would open');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _searchFocused = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final yoyoConvos = ProtoDemoData.conversations
        .where((c) => c.moduleContext == 'YoYo')
        .toList();

    if (state.yoyoMode == 1) {
      return const InnerCircleChatView();
    }

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
                Text('YoYo Chat', style: theme.headline.copyWith(fontSize: 24)),
              ],
            ),
          ),
          // Search bar with tap highlight
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
                        ? theme.primary.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(theme.icons.search, size: 20, color: _searchFocused ? theme.primary : theme.textTertiary),
                    const SizedBox(width: 10),
                    Text('Search conversations...', style: theme.body.copyWith(color: theme.textTertiary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: yoyoConvos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_rounded, size: 48, color: theme.textTertiary),
                        const SizedBox(height: 12),
                        Text('No YoYo conversations yet', style: theme.body.copyWith(color: theme.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Connect with nearby people to start chatting', style: theme.caption),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: yoyoConvos.length,
                    itemBuilder: (context, i) {
                      final conv = yoyoConvos[i];
                      return ProtoPressButton(
                        duration: const Duration(milliseconds: 100),
                        onTap: () => state.push(ProtoRoutes.chatConversation),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: theme.cardDecoration,
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ProtoAvatar(radius: 24, imageUrl: conv.avatarUrl),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: i == 0 ? theme.successColor : theme.textTertiary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: theme.surface, width: 2),
                                      ),
                                    ),
                                  ),
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
                                          border: Border.all(color: theme.surface, width: 2),
                                        ),
                                        child: Center(
                                          child: Text('${conv.unreadCount}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  // Encryption indicator
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
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(conv.name, style: theme.title.copyWith(fontSize: 14)),
                                        // "How you met" badge
                                        const SizedBox(width: 6),
                                        Icon(Icons.pin_drop_rounded, size: 12, color: theme.secondary),
                                        const SizedBox(width: 2),
                                        Text('Nearby', style: TextStyle(fontSize: 9, color: theme.secondary, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(conv.lastMessage, style: theme.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    // Data retention timer
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_delete_rounded,
                                          size: 11,
                                          color: i == 0 ? Colors.orange.shade700 : theme.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          i == 0 ? 'Expires in 4h' : 'Expires in 28h',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: i == 0 ? Colors.orange.shade700 : theme.textTertiary,
                                            fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
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
