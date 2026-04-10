import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class SocialEventsScreen extends StatelessWidget {
  const SocialEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),
          Text('Events', style: theme.headline.copyWith(fontSize: 24)),
          const SizedBox(height: 12),
          ...ProtoDemoData.events.map((event) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: theme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: ProtoNetworkImage(imageUrl: event.imageUrl, height: 120, width: double.infinity),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: theme.title),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(theme.icons.calendarToday, size: 14, color: theme.textTertiary),
                          const SizedBox(width: 6),
                          Text('${event.date} at ${event.time}', style: theme.caption),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(theme.icons.locationOn, size: 14, color: theme.textTertiary),
                          const SizedBox(width: 6),
                          Text('${event.location} • ${event.distance}', style: theme.caption),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('${event.goingCount} going', style: theme.caption.copyWith(color: theme.primary)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                            child: Text('Interested', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      );
  }
}
