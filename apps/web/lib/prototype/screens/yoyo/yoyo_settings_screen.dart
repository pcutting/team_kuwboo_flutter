import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../prototype_state.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
/// YoYo settings — ghost mode toggle, range slider, show filters, notifications.
/// V2 adds session scheduling, data retention, visibility, DND, transparency.
class YoyoSettingsScreen extends StatefulWidget {
  const YoyoSettingsScreen({super.key});

  @override
  State<YoyoSettingsScreen> createState() => _YoyoSettingsScreenState();
}

class _YoyoSettingsScreenState extends State<YoyoSettingsScreen> {
  bool _waveNotifications = true;
  bool _connectionNotifications = true;
  bool _dndEnabled = false;
  bool _backgroundDiscovery = false;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'YoYo Settings',
            actions: [],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Session Scheduling
                _V2SessionSchedulingCard(theme: theme),
                  const SizedBox(height: 12),
                  // Data Retention
                  _V2DataRetentionCard(theme: theme, state: state),
                  const SizedBox(height: 12),
                  // Visibility
                  _V2VisibilityCard(theme: theme, state: state),
                  const SizedBox(height: 12),
                  // Do Not Disturb
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: theme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: _dndEnabled ? theme.accent.withValues(alpha: 0.1) : theme.background, shape: BoxShape.circle),
                          child: Icon(Icons.do_not_disturb_rounded, size: 20, color: _dndEnabled ? theme.accent : theme.textTertiary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Do Not Disturb', style: theme.title),
                              const SizedBox(height: 2),
                              Text(_dndEnabled ? '10:00 PM – 7:00 AM' : 'Pause all YoYo alerts', style: theme.caption),
                            ],
                          ),
                        ),
                        Switch(
                          value: _dndEnabled,
                          onChanged: (v) {
                            setState(() => _dndEnabled = v);
                            ProtoToast.show(context, Icons.do_not_disturb_rounded, v ? 'DND enabled' : 'DND disabled');
                          },
                          activeThumbColor: theme.accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Encounter Transparency
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: theme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: theme.background, shape: BoxShape.circle),
                          child: Icon(Icons.visibility_rounded, size: 20, color: state.yoyoV2EncounterTransparency ? theme.secondary : theme.textTertiary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Who Saw Me', style: theme.title),
                              const SizedBox(height: 2),
                              Text('See who viewed your teaser', style: theme.caption),
                            ],
                          ),
                        ),
                        Switch(
                          value: state.yoyoV2EncounterTransparency,
                          onChanged: state.onYoyoV2EncounterTransparencyChanged,
                          activeThumbColor: theme.secondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Background Discovery
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: theme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: theme.background, shape: BoxShape.circle),
                          child: Icon(Icons.bluetooth_searching_rounded, size: 20, color: _backgroundDiscovery ? theme.primary : theme.textTertiary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Background Discovery', style: theme.title),
                              const SizedBox(height: 2),
                              Text('May increase battery usage', style: theme.caption.copyWith(color: Colors.orange.shade700)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _backgroundDiscovery,
                          onChanged: (v) {
                            setState(() => _backgroundDiscovery = v);
                            ProtoToast.show(context, Icons.bluetooth_searching_rounded, v ? 'Background discovery on' : 'Background discovery off');
                          },
                          activeThumbColor: theme.primary,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                // Ghost mode
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: theme.cardDecoration,
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: state.isYoyoHidden
                              ? theme.accent.withValues(alpha: 0.1)
                              : theme.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          theme.icons.visibilityOff,
                          size: 20,
                          color: state.isYoyoHidden ? theme.accent : theme.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ghost Mode', style: theme.title),
                            const SizedBox(height: 2),
                            Text('Hide from nearby users', style: theme.caption),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.isYoyoHidden,
                        onChanged: (_) {
                          state.onYoyoHiddenToggle();
                          ProtoToast.show(
                            context,
                            state.isYoyoHidden ? theme.icons.visibilityOn : theme.icons.visibilityOff,
                            state.isYoyoHidden ? 'You are now visible' : 'Ghost mode enabled',
                          );
                        },
                        activeThumbColor: theme.accent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Range slider
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: theme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(theme.icons.radar, size: 20, color: theme.primary),
                          const SizedBox(width: 10),
                          Text('Discovery Range', style: theme.title),
                          const Spacer(),
                          Text(
                            '${state.yoyoRange.toInt()} km',
                            style: theme.title.copyWith(color: theme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: theme.primary,
                          inactiveTrackColor: theme.primary.withValues(alpha: 0.1),
                          thumbColor: theme.primary,
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: state.yoyoRange,
                          min: 1,
                          max: 30,
                          divisions: 29,
                          onChanged: state.onYoyoRangeChanged,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 km', style: theme.caption),
                          Text('30 km', style: theme.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Show filters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: theme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Show on Profile', style: theme.title),
                      const SizedBox(height: 12),
                      _ToggleRow(
                        icon: Icons.circle_rounded,
                        label: 'Online status',
                        value: state.yoyoShowOnline,
                        onChanged: state.onYoyoShowOnlineChanged,
                        theme: theme,
                      ),
                      const SizedBox(height: 10),
                      _ToggleRow(
                        icon: theme.icons.locationOn,
                        label: 'Distance',
                        value: state.yoyoShowDistance,
                        onChanged: state.onYoyoShowDistanceChanged,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Notifications
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: theme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifications', style: theme.title),
                      const SizedBox(height: 12),
                      _ToggleRow(
                        icon: theme.icons.wavingHand,
                        label: 'Wave notifications',
                        value: _waveNotifications,
                        onChanged: (v) {
                          setState(() => _waveNotifications = v);
                          ProtoToast.show(context, theme.icons.notifications, v ? 'Wave notifications on' : 'Wave notifications off');
                        },
                        theme: theme,
                      ),
                      const SizedBox(height: 10),
                      _ToggleRow(
                        icon: theme.icons.group,
                        label: 'Connection requests',
                        value: _connectionNotifications,
                        onChanged: (v) {
                          setState(() => _connectionNotifications = v);
                          ProtoToast.show(context, theme.icons.notifications, v ? 'Connection notifications on' : 'Connection notifications off');
                        },
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ProtoTheme theme;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: value ? theme.secondary : theme.textTertiary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: theme.body)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.secondary,
        ),
      ],
    );
  }
}

// ─── V2 Settings cards ──────────────────────────────────────────────

class _V2SessionSchedulingCard extends StatefulWidget {
  final ProtoTheme theme;
  const _V2SessionSchedulingCard({required this.theme});

  @override
  State<_V2SessionSchedulingCard> createState() => _V2SessionSchedulingCardState();
}

class _V2SessionSchedulingCardState extends State<_V2SessionSchedulingCard> {
  final _selectedTimes = <String>{};
  final _selectedDays = <String>{'Mon', 'Wed', 'Fri'};

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: theme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 20, color: theme.primary),
              const SizedBox(width: 10),
              Text('Session Scheduling', style: theme.title),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Morning', 'Lunch', 'Evening', 'Commute'].map((t) {
              final sel = _selectedTimes.contains(t);
              return ProtoPressButton(
                onTap: () => setState(() => sel ? _selectedTimes.remove(t) : _selectedTimes.add(t)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? theme.primary.withValues(alpha: 0.15) : theme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? theme.primary : theme.textTertiary.withValues(alpha: 0.2)),
                  ),
                  child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? theme.primary : theme.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) {
              final sel = _selectedDays.contains(d);
              return ProtoPressButton(
                onTap: () => setState(() => sel ? _selectedDays.remove(d) : _selectedDays.add(d)),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: sel ? theme.primary : theme.background,
                    shape: BoxShape.circle,
                    border: sel ? null : Border.all(color: theme.textTertiary.withValues(alpha: 0.2)),
                  ),
                  child: Center(child: Text(d[0], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : theme.textSecondary))),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _V2DataRetentionCard extends StatelessWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _V2DataRetentionCard({required this.theme, required this.state});

  static const _stops = [1, 12, 24, 32, 72, 168]; // hours
  static const _labels = ['1h', '12h', '24h', '32h', '3d', '7d'];

  @override
  Widget build(BuildContext context) {
    final idx = _stops.indexOf(state.yoyoV2DataRetentionHours).clamp(0, _stops.length - 1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: theme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_delete_rounded, size: 20, color: theme.primary),
              const SizedBox(width: 10),
              Text('Data Retention', style: theme.title),
              const Spacer(),
              Text(_labels[idx], style: theme.title.copyWith(color: theme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.primary,
              inactiveTrackColor: theme.primary.withValues(alpha: 0.1),
              thumbColor: theme.primary,
              trackHeight: 4,
            ),
            child: Slider(
              value: idx.toDouble(),
              min: 0,
              max: (_stops.length - 1).toDouble(),
              divisions: _stops.length - 1,
              onChanged: (v) => state.onYoyoV2DataRetentionChanged(_stops[v.round()]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('1h', style: theme.caption), Text('7d', style: theme.caption)],
          ),
        ],
      ),
    );
  }
}

class _V2VisibilityCard extends StatelessWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _V2VisibilityCard({required this.theme, required this.state});

  static const _tiers = [
    ('Public', 'Everyone can see your teaser', Icons.public_rounded),
    ('Friends only', 'Only friends see your card', Icons.group_rounded),
    ('Family only', 'Only family members', Icons.home_rounded),
    ('Private', 'Invisible to everyone', Icons.lock_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: theme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, size: 20, color: theme.primary),
              const SizedBox(width: 10),
              Text('Visibility', style: theme.title),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _tiers.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            ProtoPressButton(
              onTap: () => state.onYoyoV2VisibilityTierChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: state.yoyoV2VisibilityTier == i ? theme.primary.withValues(alpha: 0.1) : theme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: state.yoyoV2VisibilityTier == i ? theme.primary : theme.textTertiary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(_tiers[i].$3, size: 18, color: state.yoyoV2VisibilityTier == i ? theme.primary : theme.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_tiers[i].$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: state.yoyoV2VisibilityTier == i ? theme.primary : theme.text)),
                          Text(_tiers[i].$2, style: theme.caption),
                        ],
                      ),
                    ),
                    if (state.yoyoV2VisibilityTier == i)
                      Icon(Icons.check_circle_rounded, size: 18, color: theme.primary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
