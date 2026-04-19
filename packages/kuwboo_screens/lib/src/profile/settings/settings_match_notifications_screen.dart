import 'package:flutter/material.dart';

import '_settings_page.dart';

class SettingsMatchNotificationsScreen extends StatefulWidget {
  const SettingsMatchNotificationsScreen({super.key});

  @override
  State<SettingsMatchNotificationsScreen> createState() =>
      _SettingsMatchNotificationsScreenState();
}

class _SettingsMatchNotificationsScreenState
    extends State<SettingsMatchNotificationsScreen> {
  bool _newMatch = true;
  bool _matchMessage = true;
  bool _matchExpiring = true;
  bool _likedYou = false;
  bool _superLike = true;

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Match Notifications',
      children: [
        const SettingsSectionLabel('Match activity'),
        SettingsCard(
          children: [
            SettingsToggleRow(
              label: 'New match',
              caption: 'Someone you liked liked you back.',
              value: _newMatch,
              onChanged: (v) => setState(() => _newMatch = v),
            ),
            SettingsToggleRow(
              label: 'Message from a match',
              value: _matchMessage,
              onChanged: (v) => setState(() => _matchMessage = v),
            ),
            SettingsToggleRow(
              label: 'Match about to expire',
              caption: 'Reminder ~6 hours before an unread match expires.',
              value: _matchExpiring,
              onChanged: (v) => setState(() => _matchExpiring = v),
            ),
          ],
        ),
        const SettingsSectionLabel('Interest signals'),
        SettingsCard(
          children: [
            SettingsToggleRow(
              label: 'Someone liked you',
              caption: 'Sent before you\'ve liked them back (premium feature).',
              value: _likedYou,
              onChanged: (v) => setState(() => _likedYou = v),
            ),
            SettingsToggleRow(
              label: 'Super Likes',
              value: _superLike,
              onChanged: (v) => setState(() => _superLike = v),
            ),
          ],
        ),
      ],
    );
  }
}
