import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class DatingMatchesList extends StatelessWidget {
  const DatingMatchesList({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return ProtoDemoData.matches.isEmpty
        ? const ProtoEmptyState(
              icon: Icons.favorite_outline_rounded,
              title: 'No matches yet',
              subtitle: 'Keep swiping to find your people',
              actionLabel: 'Start Swiping',
            )
          : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // New matches (horizontal scroll)
          const SizedBox(height: 12),
          Text('New Matches', style: theme.title),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ProtoDemoData.matches.where((m) => m.isNew).map((match) {
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ProtoPressButton(
                    onTap: () => state.push(ProtoRoutes.datingProfile),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.primary, width: 2.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ProtoAvatar(imageUrl: match.imageUrl),
                              ),
                            ),
                            // Online indicator
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: theme.successColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.surface, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(match.name, style: theme.caption.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Messages list
          Text('Messages', style: theme.title),
          const SizedBox(height: 8),
          ...ProtoDemoData.matches.where((m) => m.lastMessage != null).map((match) {
            return ProtoPressButton(
              onTap: () => state.push(ProtoRoutes.chatConversation),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: theme.cardDecoration,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ProtoAvatar(radius: 24, imageUrl: match.imageUrl),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: match.isNew ? theme.successColor : theme.textTertiary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.surface, width: 2),
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
                          Text(match.name, style: theme.title.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(match.lastMessage!, style: theme.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(match.timeAgo, style: theme.caption),
                  ],
                ),
              ),
            );
          }),
        ],
      );
  }
}
