import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Events screen — backend has NO events module today, so this renders a
/// "Coming soon" empty state. TODO: wire to real endpoint when the backend
/// events module is added (tracked in docs/team/internal/TECHNICAL_DESIGN.md).
class SocialEventsScreen extends ConsumerWidget {
  const SocialEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);
    return Container(
      color: theme.background,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Events', style: theme.headline.copyWith(fontSize: 24)),
            ),
          ),
          const Expanded(
            child: ProtoEmptyState(
              icon: Icons.event_outlined,
              title: 'Events are coming soon',
              subtitle:
                  "We're building an events module. Check back once it's live — "
                  'you\'ll be able to discover and RSVP to events near you.',
            ),
          ),
        ],
      ),
    );
  }
}
