import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class SocialFriendsList extends StatefulWidget {
  const SocialFriendsList({super.key});

  @override
  State<SocialFriendsList> createState() => _SocialFriendsListState();
}

class _SocialFriendsListState extends State<SocialFriendsList> {
  bool _onlineOnly = false;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    const allUsers = DemoData.nearbyUsers;
    final users = _onlineOnly
        ? allUsers.where((u) => u.isOnline).toList()
        : allUsers;
    final onlineCount = allUsers.where((u) => u.isOnline).length;

    return Column(
        children: [
          // Search
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

          // Header with filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('Friends', style: theme.title.copyWith(fontSize: 14)),
                const SizedBox(width: 8),
                Text('$onlineCount online', style: theme.caption.copyWith(color: theme.secondary)),
                const Spacer(),
                ProtoPressButton(
                  onTap: () => setState(() => _onlineOnly = !_onlineOnly),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _onlineOnly ? theme.secondary.withValues(alpha: 0.15) : theme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _onlineOnly ? theme.secondary : theme.text.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _onlineOnly ? theme.secondary : theme.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _onlineOnly ? theme.secondary : theme.textTertiary,
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: users.map((user) => ProtoPressButton(
                onTap: () => state.push(ProtoRoutes.chatConversation),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: theme.cardDecoration,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          ProtoAvatar(radius: 22, imageUrl: user.imageUrl),
                          if (user.isOnline) Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: theme.secondary, shape: BoxShape.circle, border: Border.all(color: theme.surface, width: 2)))),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: theme.title.copyWith(fontSize: 14)),
                            Text(user.isOnline ? 'Active now' : '${user.distance} away', style: theme.caption),
                          ],
                        ),
                      ),
                      ProtoPressButton(
                        onTap: () {
                          ProtoToast.show(context, theme.icons.chatBubbleOutline, 'Chat with ${user.name}');
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
              )).toList(),
            ),
          ),
        ],
      );
  }
}
