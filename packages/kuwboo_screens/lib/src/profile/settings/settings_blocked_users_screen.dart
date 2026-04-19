import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_settings_page.dart';

class SettingsBlockedUsersScreen extends StatefulWidget {
  const SettingsBlockedUsersScreen({super.key});

  @override
  State<SettingsBlockedUsersScreen> createState() =>
      _SettingsBlockedUsersScreenState();
}

class _SettingsBlockedUsersScreenState
    extends State<SettingsBlockedUsersScreen> {
  // Demo data — in the real app this comes from
  // GET /users/me/blocked.
  final List<_BlockedUser> _blocked = [];

  void _unblock(_BlockedUser u) {
    setState(() => _blocked.remove(u));
    // TODO(api): DELETE /users/me/blocked/{id}
    showSettingsSaved(context, 'Unblocked @${u.username}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return SettingsPage(
      title: 'Blocked Users',
      children: [
        if (_blocked.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: theme.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No blocked users',
                  style: theme.title.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'People you block won\'t be able to see your profile, '
                  'message you, or interact with your posts.',
                  textAlign: TextAlign.center,
                  style: theme.body.copyWith(color: theme.textSecondary),
                ),
              ],
            ),
          )
        else
          SettingsCard(
            children: [
              for (final u in _blocked)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.text.withValues(alpha: 0.08),
                        child: Icon(
                          theme.icons.personOutline,
                          size: 20,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.name,
                              style: theme.body.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '@${u.username}',
                              style: theme.caption.copyWith(
                                color: theme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _unblock(u),
                        child: const Text('Unblock'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _BlockedUser {
  const _BlockedUser(this.name, this.username);
  final String name;
  final String username;
}
