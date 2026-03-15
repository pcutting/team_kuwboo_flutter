import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';

class SocialEventDetail extends StatefulWidget {
  final DemoEvent event;
  const SocialEventDetail({super.key, required this.event});

  @override
  State<SocialEventDetail> createState() => _SocialEventDetailState();
}

class _SocialEventDetailState extends State<SocialEventDetail> {
  int _rsvpIndex = -1; // -1=none, 0=Going, 1=Interested, 2=Can't Go

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);
    final event = widget.event;
    final costLabel = event.cost ?? 'Free';
    final isFree = event.cost == null;

    return Container(
      color: theme.background,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero image with floating back button and badges
                SizedBox(
                  height: 250,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProtoNetworkImage(imageUrl: event.imageUrl, height: 250, width: double.infinity),
                      // Gradient overlay at bottom of image
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                            ),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: 48,
                        left: 12,
                        child: ProtoPressButton(
                          onTap: () => state.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      // Share button
                      Positioned(
                        top: 48,
                        right: 12,
                        child: ProtoPressButton(
                          onTap: () => ProtoShareSheet.show(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(theme.icons.share, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      // Date pill
                      Positioned(
                        bottom: 12,
                        left: 12,
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
                      // Cost pill
                      Positioned(
                        bottom: 12,
                        right: 12,
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
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(event.title, style: theme.headline.copyWith(fontSize: 22)),
                      const SizedBox(height: 14),

                      // Host row
                      Row(
                        children: [
                          ProtoAvatar(radius: 18, imageUrl: event.hostAvatarUrl),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.hostName, style: theme.title.copyWith(fontSize: 14)),
                                Text('Organiser', style: theme.caption),
                              ],
                            ),
                          ),
                          ProtoPressButton(
                            onTap: () => ProtoToast.show(context, theme.icons.personAdd, 'Following ${event.hostName}'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.primary),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Follow',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Date/time row
                      _DetailRow(
                        icon: theme.icons.calendarToday,
                        text: '${event.date} · ${event.time}',
                        theme: theme,
                      ),
                      const SizedBox(height: 10),

                      // Location row
                      _DetailRow(
                        icon: theme.icons.locationOn,
                        text: event.location,
                        theme: theme,
                      ),
                      const SizedBox(height: 14),

                      // Static map placeholder
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.text.withValues(alpha: 0.08)),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(theme.icons.locationOn, size: 32, color: theme.primary.withValues(alpha: 0.6)),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.location,
                                    style: theme.caption.copyWith(fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: ProtoPressButton(
                                onTap: () => ProtoToast.show(context, theme.icons.locationOn, 'Opening maps...'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Get Directions',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Description
                      Text('About', style: theme.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(event.description, style: theme.body),
                      const SizedBox(height: 18),

                      // Cost section (if paid)
                      if (!isFree) ...[
                        Row(
                          children: [
                            Icon(Icons.local_offer_outlined, size: 16, color: theme.textSecondary),
                            const SizedBox(width: 8),
                            Text(costLabel, style: theme.title.copyWith(fontSize: 15)),
                            if (event.ticketUrl != null) ...[
                              const Spacer(),
                              ProtoPressButton(
                                onTap: () => ProtoToast.show(context, theme.icons.linkIcon, 'Opening ticket page...'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    'Get Tickets',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Attendees section
                      Row(
                        children: [
                          if (event.attendeeAvatars.isNotEmpty) ...[
                            SizedBox(
                              width: 24.0 + (event.attendeeAvatars.length - 1) * 16.0,
                              height: 24,
                              child: Stack(
                                children: [
                                  for (var j = 0; j < event.attendeeAvatars.length; j++)
                                    Positioned(
                                      left: j * 16.0,
                                      child: Container(
                                        width: 24,
                                        height: 24,
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
                            const SizedBox(width: 10),
                          ],
                          Text(
                            '${event.goingCount} going',
                            style: theme.title.copyWith(fontSize: 14, color: theme.primary),
                          ),
                          const Spacer(),
                          ProtoPressButton(
                            onTap: () => ProtoToast.show(context, theme.icons.peopleOutline, 'Attendees list'),
                            child: Text('See All', style: TextStyle(fontSize: 13, color: theme.primary, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom sticky RSVP bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(top: BorderSide(color: theme.text.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                _RsvpButton(label: 'Going', index: 0, activeIndex: _rsvpIndex, theme: theme, onTap: () => _onRsvp(0)),
                const SizedBox(width: 8),
                _RsvpButton(label: 'Interested', index: 1, activeIndex: _rsvpIndex, theme: theme, onTap: () => _onRsvp(1)),
                const SizedBox(width: 8),
                _RsvpButton(label: "Can't Go", index: 2, activeIndex: _rsvpIndex, theme: theme, onTap: () => _onRsvp(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onRsvp(int index) {
    setState(() => _rsvpIndex = _rsvpIndex == index ? -1 : index);
    final labels = ['Going', 'Interested', "Can't Go"];
    if (_rsvpIndex >= 0) {
      ProtoToast.show(context, Icons.check_circle_rounded, 'Marked as ${labels[_rsvpIndex]}');
    }
  }
}

// ─── Detail info row ──────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ProtoTheme theme;
  const _DetailRow({required this.icon, required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.body.copyWith(fontSize: 14))),
      ],
    );
  }
}

// ─── RSVP segmented button ────────────────────────────────────────────────

class _RsvpButton extends StatelessWidget {
  final String label;
  final int index;
  final int activeIndex;
  final ProtoTheme theme;
  final VoidCallback onTap;

  const _RsvpButton({
    required this.label,
    required this.index,
    required this.activeIndex,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == activeIndex;
    return Expanded(
      child: ProtoPressButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? theme.primary : theme.background,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? null : Border.all(color: theme.text.withValues(alpha: 0.1)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : theme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
