import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';

/// Notifications screen — Waves section + Activity section with v1/v2 toggle.
class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() =>
      _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState
    extends State<ProfileNotificationsScreen> {
  int _variant = 0; // 0 = v1 (simple), 1 = v2 (search + mark read)

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

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'Notifications',
            actions: [_buildVariantToggle(theme)],
          ),

          // V2: search bar + mark all read
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
                          borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Icon(theme.icons.search,
                              size: 20, color: theme.textTertiary),
                          const SizedBox(width: 10),
                          Text('Search notifications...',
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
                      'All notifications marked as read',
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

          // V1: no search bar

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 16),

                // ── Waves section ──
                Text('Waves', style: theme.title),
                const SizedBox(height: 10),
                for (int i = 0; i < _waveNotifications.length; i++)
                  _swipeableItem(
                    context,
                    theme,
                    'wave-$i',
                    _waveNotifications[i].name,
                    _NotificationItem(
                      imageUrl: _waveNotifications[i].imageUrl,
                      title: _waveNotifications[i].name,
                      description: _waveNotifications[i].isIncoming
                          ? 'Waved at you'
                          : 'You waved back',
                      timeAgo: _waveNotifications[i].timeAgo,
                      icon: theme.icons.wavingHand,
                      iconColor: theme.primary,
                      theme: theme,
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Activity section ──
                Text('Activity', style: theme.title),
                const SizedBox(height: 10),
                for (int i = 0;
                    i < _activityNotifications(theme).length;
                    i++)
                  _swipeableItem(
                    context,
                    theme,
                    'activity-$i',
                    _activityNotifications(theme)[i].title,
                    _NotificationItem(
                      imageUrl: _activityNotifications(theme)[i].imageUrl,
                      title: _activityNotifications(theme)[i].title,
                      description:
                          _activityNotifications(theme)[i].description,
                      timeAgo: _activityNotifications(theme)[i].timeAgo,
                      icon: _activityNotifications(theme)[i].icon,
                      iconColor:
                          _activityNotifications(theme)[i].iconColor ??
                              theme.secondary,
                      theme: theme,
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeableItem(
    BuildContext context,
    ProtoTheme theme,
    String key,
    String name,
    Widget child,
  ) {
    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteSheet(context, theme, name),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Icon(Icons.delete_outline_rounded, color: theme.accent, size: 22),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Delete notification from $name?',
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
                    'Notification removed');
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 22, color: theme.accent),
                    const SizedBox(width: 14),
                    Text(
                      'Delete notification',
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

// ── Demo data ──

class _WaveNotification {
  final String name;
  final String timeAgo;
  final String imageUrl;
  final bool isIncoming;
  const _WaveNotification(
      this.name, this.timeAgo, this.imageUrl, this.isIncoming);
}

const _waveNotifications = [
  _WaveNotification(
    'Maya',
    '2m ago',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
    true,
  ),
  _WaveNotification(
    'Priya',
    '28m ago',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
    true,
  ),
];

class _ActivityNotification {
  final String title;
  final String description;
  final String timeAgo;
  final String imageUrl;
  final IconData icon;
  final Color? iconColor;
  const _ActivityNotification({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.imageUrl,
    required this.icon,
    this.iconColor,
  });
}

List<_ActivityNotification> _activityNotifications(ProtoTheme theme) => [
      _ActivityNotification(
        title: 'Jordan',
        description: 'Started following you',
        timeAgo: '1h ago',
        imageUrl:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
        icon: theme.icons.personAdd,
      ),
      _ActivityNotification(
        title: 'Sam',
        description: 'Liked your post',
        timeAgo: '3h ago',
        imageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
        icon: theme.icons.favoriteFilled,
        iconColor: Colors.redAccent,
      ),
      _ActivityNotification(
        title: 'Kai',
        description: 'Commented on your photo',
        timeAgo: '5h ago',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
        icon: theme.icons.comment,
      ),
      _ActivityNotification(
        title: 'Riley',
        description: 'Started following you',
        timeAgo: '1d ago',
        imageUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
        icon: theme.icons.personAdd,
      ),
    ];

class _NotificationItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final ProtoTheme theme;

  const _NotificationItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: theme.cardDecoration,
      child: Row(
        children: [
          // Avatar with activity icon overlay
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              children: [
                ProtoAvatar(
                  radius: 20,
                  imageUrl: imageUrl,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, size: 11, color: iconColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.title.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(description, style: theme.caption),
              ],
            ),
          ),
          Text(timeAgo, style: theme.caption),
        ],
      ),
    );
  }
}
