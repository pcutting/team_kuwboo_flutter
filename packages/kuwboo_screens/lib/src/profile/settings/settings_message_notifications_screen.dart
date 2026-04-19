import 'package:flutter/material.dart';

import '_settings_page.dart';

class SettingsMessageNotificationsScreen extends StatefulWidget {
  const SettingsMessageNotificationsScreen({super.key});

  @override
  State<SettingsMessageNotificationsScreen> createState() =>
      _SettingsMessageNotificationsScreenState();
}

class _SettingsMessageNotificationsScreenState
    extends State<SettingsMessageNotificationsScreen> {
  bool _dms = true;
  bool _group = true;
  bool _reactions = true;
  bool _previewContent = true;
  bool _sound = true;

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Message Notifications',
      children: [
        const SettingsSectionLabel('Deliver notifications for'),
        SettingsCard(
          children: [
            SettingsToggleRow(
              label: 'Direct messages',
              value: _dms,
              onChanged: (v) => setState(() => _dms = v),
            ),
            SettingsToggleRow(
              label: 'Group messages',
              value: _group,
              onChanged: (v) => setState(() => _group = v),
            ),
            SettingsToggleRow(
              label: 'Reactions to my messages',
              value: _reactions,
              onChanged: (v) => setState(() => _reactions = v),
            ),
          ],
        ),
        const SettingsSectionLabel('Preview'),
        SettingsCard(
          children: [
            SettingsToggleRow(
              label: 'Show message preview',
              caption:
                  'If off, notifications show "New message" instead of the text.',
              value: _previewContent,
              onChanged: (v) => setState(() => _previewContent = v),
            ),
            SettingsToggleRow(
              label: 'Play sound',
              value: _sound,
              onChanged: (v) => setState(() => _sound = v),
            ),
          ],
        ),
      ],
    );
  }
}
