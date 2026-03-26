import 'package:flutter/material.dart';
import '../../v6-minimal-swiss/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V6: Minimal Swiss Yoyo Nearby Screen (Set B - Notched FAB Nav)
/// Grid-based, typography-driven, extreme clarity

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MinimalSwissTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KuwbooTopBar(
              backgroundColor: MinimalSwissTheme.background,
              accentColor: MinimalSwissTheme.primary,
              textColor: MinimalSwissTheme.text,
            ),
            MinimalSwissTheme.horizontalDivider,
            _buildStats(),
            MinimalSwissTheme.horizontalDivider,
            Expanded(child: _buildList()),
            MinimalSwissTheme.horizontalDivider,
            _buildFooter(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final nearbyUsers = DemoData.nearbyUsers;
    final newCount = nearbyUsers.where((u) => u.isNew).length;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('RADIUS', '2.0 km'),
          ),
          MinimalSwissTheme.verticalDivider,
          Expanded(
            child: _buildStatItem('NEW', '$newCount'),
          ),
          MinimalSwissTheme.verticalDivider,
          Expanded(
            child: _buildStatItem('ACTIVE', '${nearbyUsers.length}'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(MinimalSwissTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: MinimalSwissTheme.label),
          const SizedBox(height: MinimalSwissTheme.spacingXs),
          Text(value, style: MinimalSwissTheme.title),
        ],
      ),
    );
  }

  Widget _buildList() {
    final nearbyUsers = DemoData.nearbyUsers;

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: nearbyUsers.length,
      separatorBuilder: (context, index) => MinimalSwissTheme.horizontalDivider,
      itemBuilder: (context, index) {
        final user = nearbyUsers[index];
        return _buildListItem(user);
      },
    );
  }

  Widget _buildListItem(NearbyUser user) {
    return Padding(
      padding: const EdgeInsets.all(MinimalSwissTheme.spacingMd),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: MinimalSwissTheme.borderedDecoration,
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              user.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  user.name[0],
                  style: MinimalSwissTheme.subheadline,
                ),
              ),
            ),
          ),
          const SizedBox(width: MinimalSwissTheme.spacingMd),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: MinimalSwissTheme.title),
                    if (user.isNew) ...[
                      const SizedBox(width: MinimalSwissTheme.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MinimalSwissTheme.spacingXs,
                          vertical: 2,
                        ),
                        color: MinimalSwissTheme.primary,
                        child: Text(
                          'NEW',
                          style: MinimalSwissTheme.label.copyWith(
                            color: MinimalSwissTheme.background,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: MinimalSwissTheme.spacingXs),
                Text(
                  user.distance,
                  style: MinimalSwissTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Action
          Container(
            width: 40,
            height: 40,
            decoration: MinimalSwissTheme.outlineButtonDecoration,
            child: Icon(
              Icons.waving_hand_outlined,
              size: 18,
              color: MinimalSwissTheme.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(MinimalSwissTheme.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: MinimalSwissTheme.primaryButtonDecoration,
              child: Center(
                child: Text('Wave to all', style: MinimalSwissTheme.button),
              ),
            ),
          ),
          const SizedBox(width: MinimalSwissTheme.spacingSm),
          Container(
            width: 48,
            height: 48,
            decoration: MinimalSwissTheme.outlineButtonDecoration,
            child: Icon(
              Icons.visibility_off_outlined,
              size: 20,
              color: MinimalSwissTheme.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: MinimalSwissTheme.background,
      activeColor: MinimalSwissTheme.primary,
      inactiveColor: MinimalSwissTheme.textSecondary,
      fabColor: MinimalSwissTheme.primary,
      fabIconColor: MinimalSwissTheme.background,
      borderColor: MinimalSwissTheme.divider,
      labelStyle: MinimalSwissTheme.caption.copyWith(fontSize: 8),
    );
  }
}
