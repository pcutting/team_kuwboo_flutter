import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_settings_page.dart';

enum _Visibility { public, friends, private }

class SettingsProfileVisibilityScreen extends StatefulWidget {
  const SettingsProfileVisibilityScreen({super.key});

  @override
  State<SettingsProfileVisibilityScreen> createState() =>
      _SettingsProfileVisibilityScreenState();
}

class _SettingsProfileVisibilityScreenState
    extends State<SettingsProfileVisibilityScreen> {
  _Visibility _value = _Visibility.public;

  void _save() {
    // TODO(api): PATCH /users/me { profileVisibility: <value> }
    saveAndPop(context, 'Visibility saved');
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Profile Visibility',
      footer: SettingsPrimaryButton(label: 'Save', onTap: _save),
      children: [
        _RadioTile(
          label: 'Public',
          caption: 'Anyone can see your profile and posts.',
          icon: Icons.public_rounded,
          selected: _value == _Visibility.public,
          onTap: () => setState(() => _value = _Visibility.public),
        ),
        _RadioTile(
          label: 'Friends only',
          caption: 'Only people you follow back can see full details.',
          icon: Icons.group_outlined,
          selected: _value == _Visibility.friends,
          onTap: () => setState(() => _value = _Visibility.friends),
        ),
        _RadioTile(
          label: 'Private',
          caption: 'Nobody sees your profile until you approve.',
          icon: Icons.lock_outline_rounded,
          selected: _value == _Visibility.private,
          onTap: () => setState(() => _value = _Visibility.private),
        ),
      ],
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.label,
    required this.caption,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(theme.radiusLg),
            border: Border.all(
              color: selected
                  ? theme.primary
                  : theme.text.withValues(alpha: 0.06),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? theme.primary : theme.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.title.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      caption,
                      style: theme.caption.copyWith(color: theme.textTertiary),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? theme.primary : theme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
