import 'package:flutter/material.dart';
import 'design_nav.dart' show ScreenChangeNotification, ScreenType;

/// Shared top bar for all design cards
/// Left: Yoyo explore icon (tappable — navigates to Yoyo screen)
/// Right: Round profile photo with notification badge

class KuwbooTopBar extends StatelessWidget {
  final Color backgroundColor;
  final Color accentColor;
  final Color textColor;
  final double avatarRadius;
  final EdgeInsets padding;
  final BoxDecoration? decoration;
  final bool showNotificationBadge;
  final int badgeCount;

  const KuwbooTopBar({
    super.key,
    required this.backgroundColor,
    required this.accentColor,
    required this.textColor,
    this.avatarRadius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.decoration,
    this.showNotificationBadge = true,
    this.badgeCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: decoration ??
          BoxDecoration(
            color: backgroundColor,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildYoyoIcon(context),
          _buildProfileAvatar(context),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: PopupMenuButton<String>(
        offset: Offset(0, avatarRadius * 2 + 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: backgroundColor,
        onSelected: (_) {},
        itemBuilder: (context) => [
          _buildMenuItem(Icons.person_outline_rounded, 'My Profile'),
          _buildMenuItem(Icons.settings_outlined, 'Settings'),
          _buildMenuItem(Icons.notifications_outlined, 'Notifications'),
          _buildMenuItem(Icons.account_balance_wallet_outlined, 'Wallet'),
          _buildMenuItem(Icons.help_outline_rounded, 'Help'),
        ],
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: accentColor.withValues(alpha: 0.2),
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
              ),
              onBackgroundImageError: (_, __) {},
              child: Icon(
                Icons.person,
                size: avatarRadius,
                color: accentColor,
              ),
            ),
            if (showNotificationBadge && badgeCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: backgroundColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String label) {
    return PopupMenuItem<String>(
      value: label,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoyoIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => ScreenChangeNotification(ScreenType.yoyo).dispatch(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore_rounded,
              size: avatarRadius * 1.1,
              color: accentColor,
            ),
          ),
          if (showNotificationBadge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: backgroundColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.near_me_rounded,
                    size: 7,
                    color: backgroundColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
