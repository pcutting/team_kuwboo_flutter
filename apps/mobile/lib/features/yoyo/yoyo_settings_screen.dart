import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/yoyo_provider.dart';

/// Settings screen for YoYo proximity discovery.
class YoyoSettingsScreen extends ConsumerWidget {
  const YoyoSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(yoyoSettingsProvider);
    final notifier = ref.read(yoyoSettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('YoYo Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Visibility Toggle ──────────────────────────────────────
          SwitchListTile(
            title: const Text('Visible to others'),
            subtitle: const Text(
              'Allow nearby users to discover you',
            ),
            value: settings.isVisible,
            onChanged: (value) => notifier.setVisible(value),
          ),
          const Divider(),

          // ── Radius Slider ─────────────────────────────────────────
          ListTile(
            title: const Text('Discovery radius'),
            subtitle: Text('${settings.radiusKm} km'),
          ),
          Slider(
            min: 1,
            max: 50,
            divisions: 49,
            value: settings.radiusKm.toDouble(),
            label: '${settings.radiusKm} km',
            onChanged: (value) => notifier.setRadius(value.round()),
          ),
          const Divider(),

          // ── Age Range ─────────────────────────────────────────────
          ListTile(
            title: const Text('Age range'),
            subtitle: Text(
              _ageRangeLabel(settings.ageMin, settings.ageMax),
            ),
          ),
          RangeSlider(
            min: 18,
            max: 80,
            divisions: 62,
            values: RangeValues(
              (settings.ageMin ?? 18).toDouble(),
              (settings.ageMax ?? 80).toDouble(),
            ),
            labels: RangeLabels(
              '${settings.ageMin ?? 18}',
              '${settings.ageMax ?? 80}',
            ),
            onChanged: (values) => notifier.setAgeRange(
              min: values.start.round(),
              max: values.end.round(),
            ),
          ),
          const Divider(),

          // ── Gender Filter ─────────────────────────────────────────
          ListTile(
            title: const Text('Show me'),
            trailing: DropdownButton<String?>(
              value: settings.genderFilter,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: null, child: Text('Everyone')),
                DropdownMenuItem(value: 'MALE', child: Text('Men')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Women')),
                DropdownMenuItem(
                  value: 'NON_BINARY',
                  child: Text('Non-binary'),
                ),
              ],
              onChanged: (value) => notifier.setGenderFilter(value),
            ),
          ),
          const Divider(),

          // ── Save Button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                // TODO: call YoyoApi.updateSettings() when backend is ready
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  String _ageRangeLabel(int? min, int? max) {
    final lo = min ?? 18;
    final hi = max ?? 80;
    if (lo == 18 && hi == 80) return 'Any age';
    return '$lo - $hi';
  }
}
