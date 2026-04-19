import 'package:flutter/material.dart';

import '_settings_page.dart';

class SettingsPushNotificationsScreen extends StatefulWidget {
  const SettingsPushNotificationsScreen({super.key});

  @override
  State<SettingsPushNotificationsScreen> createState() =>
      _SettingsPushNotificationsScreenState();
}

class _SettingsPushNotificationsScreenState
    extends State<SettingsPushNotificationsScreen> {
  bool _master = true;
  bool _matches = true;
  bool _messages = true;
  bool _likes = true;
  bool _comments = true;
  bool _follows = false;
  bool _system = true;

  @override
  Widget build(BuildContext context) {
    final enabled = _master;
    return SettingsPage(
      title: 'Push Notifications',
      children: [
        SettingsCard(
          children: [
            SettingsToggleRow(
              label: 'Allow push notifications',
              caption: 'Master switch for all categories.',
              value: _master,
              onChanged: (v) => setState(() => _master = v),
            ),
          ],
        ),
        Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: !enabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SettingsSectionLabel('Categories'),
                SettingsCard(
                  children: [
                    SettingsToggleRow(
                      label: 'New matches',
                      value: _matches,
                      onChanged: (v) => setState(() => _matches = v),
                    ),
                    SettingsToggleRow(
                      label: 'Messages',
                      value: _messages,
                      onChanged: (v) => setState(() => _messages = v),
                    ),
                    SettingsToggleRow(
                      label: 'Likes',
                      value: _likes,
                      onChanged: (v) => setState(() => _likes = v),
                    ),
                    SettingsToggleRow(
                      label: 'Comments',
                      value: _comments,
                      onChanged: (v) => setState(() => _comments = v),
                    ),
                    SettingsToggleRow(
                      label: 'New followers',
                      value: _follows,
                      onChanged: (v) => setState(() => _follows = v),
                    ),
                    SettingsToggleRow(
                      label: 'System & account',
                      caption: 'Security alerts, policy updates.',
                      value: _system,
                      onChanged: (v) => setState(() => _system = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
