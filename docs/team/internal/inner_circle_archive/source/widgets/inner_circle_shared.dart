import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

const warmAmber = Color(0xFFD4A04A);
const warmGold = Color(0xFFE8C547);

/// Map placeholder with styled gradient and street-like lines.
class InnerCircleMapPlaceholder extends StatelessWidget {
  final List<DemoFamilyMember> members;
  final int? selectedIndex;
  final ValueChanged<int> onPinTapped;

  const InnerCircleMapPlaceholder({
    super.key,
    required this.members,
    this.selectedIndex,
    required this.onPinTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a2332),
            const Color(0xFF1e2a38),
            const Color(0xFF222e3a),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: _StreetMapPainter(),
        child: Stack(
          children: [
            // "You" pin (center)
            Align(
              alignment: const Alignment(0.0, 0.3),
              child: _YouPin(),
            ),
            // Family member pins
            for (int i = 0; i < members.length; i++)
              _FamilyPin(
                member: members[i],
                isSelected: selectedIndex == i,
                onTap: () => onPinTapped(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _StreetMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontal "streets"
    for (double y = 0.15; y < 1.0; y += 0.2) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        paint,
      );
    }
    // Vertical "streets"
    for (double x = 0.2; x < 1.0; x += 0.25) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * x, size.height),
        paint,
      );
    }

    // A few diagonal "paths"
    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.2),
      pathPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.9),
      Offset(size.width * 0.9, size.height * 0.4),
      pathPaint,
    );

    // "Park" area (rounded rect with fill)
    final parkPaint = Paint()
      ..color = const Color(0xFF2a3d2a).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.5),
          width: size.width * 0.15,
          height: size.height * 0.12,
        ),
        const Radius.circular(8),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _YouPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90D4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90D4).withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'You',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _FamilyPin extends StatelessWidget {
  final DemoFamilyMember member;
  final bool isSelected;
  final VoidCallback onTap;

  const _FamilyPin({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  Alignment get _alignment {
    // Position based on the last ping location
    final lastPing = member.pings.last;
    return Alignment(
      (lastPing.x * 2 - 1).clamp(-0.9, 0.9),
      (lastPing.y * 2 - 1).clamp(-0.9, 0.9),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 44 : 36,
              height: isSelected ? 44 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: warmAmber,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: warmAmber.withValues(alpha: isSelected ? 0.4 : 0.2),
                    blurRadius: isSelected ? 16 : 8,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(member.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                member.name,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            // Online indicator
            if (member.isOnline)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  member.currentPlace,
                  style: TextStyle(fontSize: 7, color: Colors.white.withValues(alpha: 0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Floating card shown when a family member pin is tapped.
class InnerCircleFloatingCard extends StatefulWidget {
  final DemoFamilyMember member;
  final VoidCallback onClose;

  const InnerCircleFloatingCard({
    super.key,
    required this.member,
    required this.onClose,
  });

  @override
  State<InnerCircleFloatingCard> createState() => _InnerCircleFloatingCardState();
}

class _InnerCircleFloatingCardState extends State<InnerCircleFloatingCard> {
  double _scrubberProgress = 1.0; // 0.0 = first ping, 1.0 = last ping

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final pings = widget.member.pings;
    final currentPingIndex = ((_scrubberProgress * (pings.length - 1)).round()).clamp(0, pings.length - 1);
    final currentPing = pings[currentPingIndex];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warmAmber.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: warmAmber, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(widget.member.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.member.name,
                          style: theme.title.copyWith(fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.member.isOnline
                                ? theme.successColor
                                : theme.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.member.lastUpdate,
                          style: theme.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'At: ${currentPing.placeName ?? "Unknown"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: warmAmber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onClose,
                child: Icon(Icons.close_rounded, size: 20, color: theme.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timeline scrubber
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  activeTrackColor: warmAmber,
                  inactiveTrackColor: warmAmber.withValues(alpha: 0.15),
                  thumbColor: warmAmber,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: _scrubberProgress,
                  onChanged: (value) => setState(() => _scrubberProgress = value),
                ),
              ),
              // Place markers along the timeline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pings.first.time, style: TextStyle(fontSize: 9, color: theme.textTertiary)),
                    // Place icons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final ping in pings)
                          if (ping.placeName != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Tooltip(
                                message: '${ping.placeName} (${ping.time})',
                                child: Icon(
                                  _placeIcon(ping.placeName!),
                                  size: 12,
                                  color: warmAmber.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                      ],
                    ),
                    Text(pings.last.time, style: TextStyle(fontSize: 9, color: theme.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _placeIcon(String placeName) {
    final lower = placeName.toLowerCase();
    if (lower.contains('home')) return Icons.home_rounded;
    if (lower.contains('school')) return Icons.school_rounded;
    if (lower.contains('office') || lower.contains('work')) return Icons.business_rounded;
    if (lower.contains('park')) return Icons.park_rounded;
    if (lower.contains('lunch') || lower.contains('restaurant')) return Icons.restaurant_rounded;
    if (lower.contains('friend')) return Icons.people_rounded;
    return Icons.place_rounded;
  }
}

/// Warm amber badge for Inner Circle mode (analogous to yoyoV2Badge).
Widget innerCircleBadge(ProtoTheme theme) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: warmAmber,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.shield_rounded, size: 8, color: Colors.white),
      SizedBox(width: 3),
      Text(
        'Circle',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ],
  ),
);
