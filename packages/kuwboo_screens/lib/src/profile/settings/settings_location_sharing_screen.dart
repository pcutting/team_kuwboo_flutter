import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_settings_page.dart';

class SettingsLocationSharingScreen extends StatefulWidget {
  const SettingsLocationSharingScreen({super.key});

  @override
  State<SettingsLocationSharingScreen> createState() =>
      _SettingsLocationSharingScreenState();
}

class _SettingsLocationSharingScreenState
    extends State<SettingsLocationSharingScreen> {
  bool _master = true;
  bool _dating = true;
  bool _social = false;
  bool _yoyo = true;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final enabled = _master;
    return SettingsPage(
      title: 'Location Sharing',
      children: [
        SettingsCard(
          children: [
            SettingsToggleRow(
              icon: theme.icons.locationOff,
              label: 'Share my location',
              caption: 'Required for nearby-you features (YoYo, Dating, Shop).',
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
                const SettingsSectionLabel('Per-module sharing'),
                SettingsCard(
                  children: [
                    SettingsToggleRow(
                      icon: Icons.explore_outlined,
                      label: 'YoYo (nearby)',
                      value: _yoyo,
                      onChanged: (v) => setState(() => _yoyo = v),
                    ),
                    SettingsToggleRow(
                      icon: Icons.favorite_outline_rounded,
                      label: 'Dating',
                      value: _dating,
                      onChanged: (v) => setState(() => _dating = v),
                    ),
                    SettingsToggleRow(
                      icon: Icons.groups_outlined,
                      label: 'Social',
                      value: _social,
                      onChanged: (v) => setState(() => _social = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
          child: Text(
            'We use your coarse location (postcode area) for discovery. '
            'Turning this off limits some features.',
            style: theme.caption.copyWith(color: theme.textTertiary),
          ),
        ),
      ],
    );
  }
}
