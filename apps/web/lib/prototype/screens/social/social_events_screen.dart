import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_demo_data.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';

class SocialEventsScreen extends StatefulWidget {
  const SocialEventsScreen({super.key});

  @override
  State<SocialEventsScreen> createState() => _SocialEventsScreenState();
}

class _SocialEventsScreenState extends State<SocialEventsScreen> {
  String _activeFilter = 'All';

  List<DemoEvent> get _filteredEvents {
    final events = ProtoDemoData.events;
    switch (_activeFilter) {
      case 'This Week':
        // Show first 4 as "this week"
        return events.take(4).toList();
      case 'Free':
        return events.where((e) => e.cost == null).toList();
      case 'Food':
      case 'Music':
      case 'Art':
      case 'Sports':
      case 'Nightlife':
      case 'Meetup':
        return events.where((e) => e.category == _activeFilter).toList();
      default:
        return events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);
    final events = _filteredEvents;

    return ProtoScaffold(
      activeModule: ProtoModule.social,
      activeTab: 2,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text('Events', style: theme.headline.copyWith(fontSize: 24)),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'This Week', 'Free', 'Food', 'Music', 'Art', 'Sports', 'Nightlife', 'Meetup']
                  .map((label) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _activeFilter = label),
                          child: _FilterChip(label: label, isActive: _activeFilter == label),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text('No events found', style: theme.body.copyWith(color: theme.textTertiary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, i) => _EventCard(
                      event: events[i],
                      onTap: () => state.pushWithArgs(ProtoRoutes.socialEventDetail, events[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chip ───────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _FilterChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isActive ? theme.primary : theme.background,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: theme.text.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : theme.textSecondary,
        ),
      ),
    );
  }
}

// ─── Modern event card ─────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final DemoEvent event;
  final VoidCallback onTap;
  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final costLabel = event.cost ?? 'Free';
    final isFree = event.cost == null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: theme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with floating badges
            SizedBox(
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProtoNetworkImage(imageUrl: event.imageUrl, height: 160, width: double.infinity),
                  // Date pill (top-left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.date,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  // Cost pill (top-right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isFree
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.85)
                            : Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        costLabel,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  // ⋯ menu (top-right, below cost)
                  Positioned(
                    top: 10,
                    right: event.cost != null ? 70 : 60,
                    child: ProtoPressButton(
                      onTap: () => ProtoPostMenu.show(context, authorName: event.hostName),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content below image
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: theme.title.copyWith(fontSize: 16)),
                  const SizedBox(height: 6),
                  // Location row
                  Row(
                    children: [
                      Icon(theme.icons.locationOn, size: 14, color: theme.textTertiary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.location,
                          style: theme.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Host row
                  Row(
                    children: [
                      ProtoAvatar(radius: 10, imageUrl: event.hostAvatarUrl),
                      const SizedBox(width: 6),
                      Text(
                        'Hosted by ${event.hostName}',
                        style: theme.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Bottom row: avatar stack + going count + interested button
                  Row(
                    children: [
                      // Avatar stack
                      if (event.attendeeAvatars.isNotEmpty) ...[
                        SizedBox(
                          width: 20.0 + (event.attendeeAvatars.length - 1) * 14.0,
                          height: 20,
                          child: Stack(
                            children: [
                              for (var j = 0; j < event.attendeeAvatars.length; j++)
                                Positioned(
                                  left: j * 14.0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.surface, width: 1.5),
                                      image: DecorationImage(
                                        image: NetworkImage(event.attendeeAvatars[j]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${event.goingCount} going',
                        style: theme.caption.copyWith(color: theme.primary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Interested',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
