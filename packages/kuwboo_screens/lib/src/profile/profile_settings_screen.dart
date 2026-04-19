import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  _AppearanceSection(theme: theme),
                  _SettingsSection(
                    title: 'Account',
                    items: [
                      _SettingsItem(
                        icon: theme.icons.personOutline,
                        label: 'Account Info',
                      ),
                      _SettingsItem(
                        icon: theme.icons.lockOutline,
                        label: 'Password',
                      ),
                      _SettingsItem(
                        icon: theme.icons.phoneOutline,
                        label: 'Phone Number',
                      ),
                      _SettingsItem(
                        icon: theme.icons.emailOutline,
                        label: 'Email',
                      ),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Privacy',
                    items: [
                      _SettingsItem(
                        icon: theme.icons.visibilityOff,
                        label: 'Profile Visibility',
                      ),
                      _SettingsItem(
                        icon: theme.icons.blockOutline,
                        label: 'Blocked Users',
                      ),
                      _SettingsItem(
                        icon: theme.icons.locationOff,
                        label: 'Location Sharing',
                      ),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Notifications',
                    items: [
                      _SettingsItem(
                        icon: theme.icons.notificationsOutline,
                        label: 'Push Notifications',
                      ),
                      _SettingsItem(
                        icon: Icons.message_outlined,
                        label: 'Message Notifications',
                      ),
                      _SettingsItem(
                        icon: theme.icons.favoriteOutline,
                        label: 'Match Notifications',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Material(
                    color: theme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final callbacks = AuthCallbacksScope.maybeOf(context);
                        final onLogout = callbacks?.onLogout;
                        if (onLogout != null) {
                          await onLogout();
                        } else {
                          if (!context.mounted) return;
                          context.go(ProtoRoutes.authWelcome);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text('Kuwboo v1.0.0', style: theme.caption)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.title.copyWith(
              fontSize: 13,
              color: theme.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: theme.cardDecoration,
            child: Column(children: items),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SettingsItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.text.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.textSecondary),
          const SizedBox(width: 14),
          Text(
            label,
            style: theme.body.copyWith(
              color: theme.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(theme.icons.chevronRight, size: 20, color: theme.textTertiary),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  final ProtoTheme theme;
  const _AppearanceSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: theme.title.copyWith(
              fontSize: 13,
              color: theme.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: theme.cardDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.dark_mode_outlined,
                  size: 20,
                  color: state.isDarkMode
                      ? theme.secondary
                      : theme.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: theme.body.copyWith(
                      color: theme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: state.isDarkMode,
                  onChanged: state.onDarkModeChanged,
                  activeThumbColor: theme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
