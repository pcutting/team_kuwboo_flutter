import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'dating_providers.dart';

/// Discovery filters: age range, distance (km), interest tags.
///
/// Backend surface: `GET /dating/discover` currently accepts only `cursor`
/// (PR #98 scaffolds the endpoint; filter query params arrive with the
/// full dating SOW). Until then we capture the filters locally and
/// invalidate [datingCardsProvider] on apply so the stack refetches —
/// the server-side filter wiring is a single query-param extension that
/// doesn't change this UI.
class DatingFiltersSheet extends ConsumerStatefulWidget {
  const DatingFiltersSheet({super.key});

  @override
  ConsumerState<DatingFiltersSheet> createState() => _DatingFiltersSheetState();
}

class _DatingFiltersSheetState extends ConsumerState<DatingFiltersSheet> {
  double _distanceKm = 25;
  RangeValues _ageRange = const RangeValues(22, 35);
  final Set<String> _interests = {};

  static const _candidateInterests = [
    'Music',
    'Travel',
    'Photography',
    'Food',
    'Fitness',
    'Art',
    'Gaming',
    'Books',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    // Modal route — wrap in Material so RangeSlider's ink layer can mount.
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters', style: theme.title),
              const SizedBox(height: 16),
              Text(
                'Age: ${_ageRange.start.round()}–${_ageRange.end.round()}',
                style: theme.body,
              ),
              RangeSlider(
                min: 18,
                max: 70,
                divisions: 52,
                values: _ageRange,
                onChanged: (v) => setState(() => _ageRange = v),
              ),
              const SizedBox(height: 8),
              Text('Within ${_distanceKm.round()} km', style: theme.body),
              Slider(
                min: 1,
                max: 200,
                divisions: 199,
                value: _distanceKm,
                onChanged: (v) => setState(() => _distanceKm = v),
              ),
              const SizedBox(height: 8),
              Text('Interests', style: theme.body),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _candidateInterests.map((tag) {
                  final selected = _interests.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _interests.add(tag);
                        } else {
                          _interests.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Refetch the discover page — filter query params land
                    // with the dating SOW; the backend ignores extras now.
                    ref.invalidate(datingCardsProvider);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
