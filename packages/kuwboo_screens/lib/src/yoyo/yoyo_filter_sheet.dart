import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'yoyo_providers.dart';

/// All known interest tags used in demo data.
const _allInterests = [
  'hiking',
  'tech',
  'beer',
  'music',
  'design',
  'coffee',
  'photography',
  'nature',
  'cooking',
  'wine',
  'travel',
  'yoga',
  'reading',
  'art',
];

/// Display label for an interest key (capitalised).
String _interestLabel(String key) => key[0].toUpperCase() + key.substring(1);

/// YoYo filter bottom sheet — range slider, interest chips, friends-only toggle,
/// encounter type and relationship filter chips.
class YoyoFilterSheet extends ConsumerWidget {
  const YoyoFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    // Modal routes mount above the shell, so the parent ProtoScaffold's
    // Material is not in scope here. Slider requires a Material ancestor for
    // its ink/state layer — without it the entire sheet renders red error
    // blocks. Same fix is applied in `auth_phone_screen.dart` line 50–51.
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.surface,
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Filters', style: theme.headline.copyWith(fontSize: 22)),
                  const Spacer(),
                  ProtoPressButton(
                    onTap: () {
                      state.onYoyoRangeChanged(5);
                      state.onYoyoInterestsChanged({});
                      if (state.yoyoFriendsOnly)
                        state.onYoyoFriendsOnlyToggle();
                      ProtoToast.show(
                        context,
                        theme.icons.refresh,
                        'Filters reset',
                      );
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ProtoPressButton(
                    onTap: () async {
                      // Persist the range filter to backend settings.
                      try {
                        await ref
                            .read(yoyoApiProvider)
                            .updateSettings(radiusKm: state.yoyoRange.toInt());
                        ref.invalidate(yoyoSettingsProvider);
                        ref.invalidate(yoyoNearbyProvider);
                      } catch (_) {
                        /* swallow */
                      }
                      if (!context.mounted) return;
                      ProtoToast.show(
                        context,
                        theme.icons.checkCircle,
                        'Filters applied',
                      );
                      state.pop();
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // ── Encounter type filter ──
                  _FilterSection(
                    title: 'Encounter Type',
                    child: Row(
                      children: [
                        for (final label in ['all', 'passby', 'nearby']) ...[
                          if (label != 'all') const SizedBox(width: 8),
                          Expanded(
                            child: ProtoPressButton(
                              onTap: () =>
                                  state.onYoyoEncounterFilterChanged(label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: state.yoyoEncounterFilter == label
                                      ? theme.primary
                                      : theme.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: state.yoyoEncounterFilter == label
                                      ? null
                                      : Border.all(
                                          color: theme.text.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                ),
                                child: Center(
                                  child: Text(
                                    label == 'all'
                                        ? 'All'
                                        : label == 'passby'
                                        ? 'Pass-by'
                                        : 'Nearby',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: state.yoyoEncounterFilter == label
                                          ? Colors.white
                                          : theme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ── Relationship filter ──
                  _FilterSection(
                    title: 'Relationship',
                    child: Row(
                      children: [
                        for (final label in [
                          'all',
                          'friends',
                          'family',
                          'strangers',
                        ]) ...[
                          if (label != 'all') const SizedBox(width: 6),
                          Expanded(
                            child: ProtoPressButton(
                              onTap: () =>
                                  state.onYoyoRelationshipFilterChanged(label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: state.yoyoRelationshipFilter == label
                                      ? theme.primary
                                      : theme.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: state.yoyoRelationshipFilter == label
                                      ? null
                                      : Border.all(
                                          color: theme.text.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                ),
                                child: Center(
                                  child: Text(
                                    label[0].toUpperCase() + label.substring(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          state.yoyoRelationshipFilter == label
                                          ? Colors.white
                                          : theme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ── Range slider ──
                  _FilterSection(
                    title: 'Range',
                    trailing: '${state.yoyoRange.round()} km',
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: theme.primary,
                        thumbColor: theme.primary,
                        inactiveTrackColor: theme.background,
                      ),
                      child: Slider(
                        min: 1,
                        max: 30,
                        divisions: 29,
                        value: state.yoyoRange,
                        onChanged: state.onYoyoRangeChanged,
                      ),
                    ),
                  ),

                  // ── Friends only toggle ──
                  _FilterSection(
                    title: 'People',
                    child: ProtoPressButton(
                      onTap: state.onYoyoFriendsOnlyToggle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: state.yoyoFriendsOnly
                              ? theme.primary.withValues(alpha: 0.1)
                              : theme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: state.yoyoFriendsOnly
                                ? theme.primary
                                : theme.text.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              theme.icons.group,
                              size: 20,
                              color: state.yoyoFriendsOnly
                                  ? theme.primary
                                  : theme.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Friends only',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: state.yoyoFriendsOnly
                                    ? theme.primary
                                    : theme.text,
                              ),
                            ),
                            const Spacer(),
                            if (state.yoyoFriendsOnly)
                              Icon(
                                theme.icons.check,
                                size: 18,
                                color: theme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Interest chips ──
                  _FilterSection(
                    title: 'Interests',
                    trailing: state.yoyoSelectedInterests.isEmpty
                        ? 'All'
                        : '${state.yoyoSelectedInterests.length} selected',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allInterests.map((interest) {
                        final isSelected = state.yoyoSelectedInterests.contains(
                          interest,
                        );
                        return ProtoPressButton(
                          duration: const Duration(milliseconds: 100),
                          onTap: () {
                            final updated = Set<String>.from(
                              state.yoyoSelectedInterests,
                            );
                            if (isSelected) {
                              updated.remove(interest);
                            } else {
                              updated.add(interest);
                            }
                            state.onYoyoInterestsChanged(updated);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primary
                                  : theme.background,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: theme.text.withValues(alpha: 0.1),
                                    ),
                            ),
                            child: Text(
                              _interestLabel(interest),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : theme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;
  const _FilterSection({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: theme.title),
              if (trailing != null) ...[
                const Spacer(),
                Text(
                  trailing!,
                  style: theme.body.copyWith(
                    color: theme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
