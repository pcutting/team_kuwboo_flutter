import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_scaffold.dart';

class ProfileMyScreen extends StatelessWidget {
  const ProfileMyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(title: 'Profile'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      ProtoAvatar(
                        radius: 48,
                        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.background, width: 3),
                          ),
                          child: Icon(theme.icons.cameraAlt, size: 14, color: theme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text('Alex Chen', style: theme.headline.copyWith(fontSize: 24))),
                Center(child: Text('@alexhikes', style: theme.body)),
                const SizedBox(height: 16),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: theme.cardDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(count: '234', label: 'Posts'),
                      Container(width: 1, height: 30, color: theme.text.withValues(alpha: 0.08)),
                      _Stat(count: '1.2K', label: 'Followers'),
                      Container(width: 1, height: 30, color: theme.text.withValues(alpha: 0.08)),
                      _Stat(count: '891', label: 'Following'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menu items
                _MenuItem(icon: theme.icons.editOutline, label: 'Edit Profile', onTap: () => state.push(ProtoRoutes.profileEdit)),
                _MenuItemWithBadge(
                  icon: theme.icons.notificationsOutline,
                  label: 'Notifications',
                  badgeCount: 4,
                  onTap: () => state.push(ProtoRoutes.profileNotifications),
                ),
                _MenuItem(icon: theme.icons.chatBubbleOutline, label: 'Messages', onTap: () => state.push(ProtoRoutes.chatInbox)),
                _MenuItem(icon: theme.icons.storefrontOutline, label: 'My Listings', onTap: () {}),
                _MenuItem(icon: theme.icons.favoriteOutline, label: 'Saved Items', onTap: () {}),
                _MenuItem(icon: theme.icons.campaign, label: 'Promote', onTap: () => state.push(ProtoRoutes.sponsoredHub)),
                _DarkModeToggle(),
                _MenuItem(icon: theme.icons.settings, label: 'Settings', onTap: () => state.push(ProtoRoutes.profileSettings)),

                // Demo convenience links — separated from main menu
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('Demo', style: theme.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ),
                _MenuItem(icon: Icons.explore_outlined, label: 'Onboarding', onTap: () => state.push(ProtoRoutes.authOnboarding)),
                _MenuItem(icon: Icons.waving_hand_outlined, label: 'Welcome Screen', onTap: () => state.push(ProtoRoutes.authWelcome)),
                _MenuItem(icon: Icons.touch_app_outlined, label: 'Interaction Tutorial', onTap: () => state.push(ProtoRoutes.authTutorial)),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('Registration Flow', style: theme.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ),
                _MenuItem(icon: Icons.how_to_reg_outlined, label: 'Sign Up Method', onTap: () => state.push(ProtoRoutes.authMethod)),
                _MenuItem(icon: Icons.phone_outlined, label: 'Phone / Email', onTap: () => state.push(ProtoRoutes.authPhone)),
                _MenuItem(icon: Icons.pin_outlined, label: 'OTP Verification', onTap: () => state.push(ProtoRoutes.authOtp)),
                _MenuItem(icon: Icons.cake_outlined, label: 'Birthday', onTap: () => state.push(ProtoRoutes.authBirthday)),
                _MenuItem(icon: Icons.person_outline, label: 'Create Profile', onTap: () => state.push(ProtoRoutes.authProfile)),
                _MenuItem(icon: Icons.block_outlined, label: 'Age Block (Under 13)', onTap: () => state.push(ProtoRoutes.authAgeBlock)),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('Login Flow', style: theme.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ),
                _MenuItem(icon: Icons.login_rounded, label: 'Login Screen', onTap: () => state.push(ProtoRoutes.authLogin)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String count;
  final String label;
  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: ProtoTheme.of(context).title.copyWith(fontSize: 18)),
        Text(label, style: ProtoTheme.of(context).caption),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.primary),
            const SizedBox(width: 14),
            Text(label, style: theme.title.copyWith(fontSize: 15)),
            const Spacer(),
            Icon(theme.icons.chevronRight, size: 22, color: theme.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _MenuItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;
  const _MenuItemWithBadge({
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.primary),
            const SizedBox(width: 14),
            Text(label, style: theme.title.copyWith(fontSize: 15)),
            if (badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.onPrimary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(theme.icons.chevronRight, size: 22, color: theme.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _DarkModeToggle extends StatelessWidget {
  const _DarkModeToggle();

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: theme.cardDecoration,
      child: Row(
        children: [
          Icon(
            state.isDarkMode ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
            size: 22,
            color: state.isDarkMode ? theme.secondary : theme.primary,
          ),
          const SizedBox(width: 14),
          Text('Dark Mode', style: theme.title.copyWith(fontSize: 15)),
          const Spacer(),
          Switch(
            value: state.isDarkMode,
            onChanged: state.onDarkModeChanged,
            activeThumbColor: theme.secondary,
          ),
        ],
      ),
    );
  }
}
