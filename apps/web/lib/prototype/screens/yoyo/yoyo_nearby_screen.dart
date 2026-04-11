import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../../data/demo_data.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import 'inner_circle_nearby.dart';

// ─── Logarithmic range slider helpers ─────────────────────────────────
// Maps 0.0–1.0 slider position to 200 m (0.2 km) → 40,000 km range
double _logSliderToKm(double t) => 0.2 * pow(200000, t.clamp(0.0, 1.0));
double _kmToLogSlider(double km) => (log(km / 0.2) / log(200000)).clamp(0.0, 1.0);

// ─── Stop-button thumb shape for range slider ─────────────────────────

class _StopButtonThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Outer circle
    canvas.drawCircle(
      center,
      10,
      Paint()..color = sliderTheme.thumbColor ?? Colors.blue,
    );
    // Inner rounded stop square
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 8, height: 8),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white);
  }
}

// ─── Organic avatar (asymmetric border radius) ────────────────────────

/// Organic-shaped avatar using asymmetric [BorderRadius.only].
/// Opposing diagonal corners share the same radius — tight (33%) on
/// top-left / bottom-right, loose (50%) on top-right / bottom-left —
/// producing a distinctive pebble / organic silhouette.
class _OrganicAvatar extends StatelessWidget {
  final double size;
  final String imageUrl;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow> boxShadow;

  const _OrganicAvatar({
    required this.size,
    required this.imageUrl,
    this.borderColor,
    this.borderWidth = 0,
    this.boxShadow = const [],
  });

  @override
  Widget build(BuildContext context) {
    final total = size + borderWidth * 2;
    final tight = size * 0.33;
    final loose = size * 0.5;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(tight),
      topRight: Radius.circular(loose),
      bottomLeft: Radius.circular(loose),
      bottomRight: Radius.circular(tight),
    );
    return Container(
      width: total,
      height: total,
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: radius,
        boxShadow: boxShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
  }
}

/// Interest tag → Material icon mapping for radar markers.
const _interestIcons = <String, IconData>{
  'hiking': Icons.hiking_rounded,
  'tech': Icons.computer_rounded,
  'beer': Icons.sports_bar_rounded,
  'music': Icons.music_note_rounded,
  'design': Icons.palette_rounded,
  'coffee': Icons.coffee_rounded,
  'photography': Icons.camera_alt_rounded,
  'nature': Icons.park_rounded,
  'cooking': Icons.restaurant_rounded,
  'wine': Icons.wine_bar_rounded,
  'travel': Icons.flight_rounded,
  'yoga': Icons.self_improvement_rounded,
  'reading': Icons.menu_book_rounded,
  'art': Icons.brush_rounded,
};

/// YoYo Nearby — toggles between vertical card list and area (proximity) view.
/// The view mode is controlled by PrototypeStateProvider.isYoyoAreaView,
/// toggled via the YoYo icon in the top bar.
class YoyoNearbyScreen extends StatefulWidget {
  const YoyoNearbyScreen({super.key});

  @override
  State<YoyoNearbyScreen> createState() => _YoyoNearbyScreenState();
}

class _YoyoNearbyScreenState extends State<YoyoNearbyScreen> {
  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    // Inner Circle mode shows the map-based family view
    if (state.yoyoMode == 1) {
      return const InnerCircleNearbyView();
    }

    return ProtoScaffold(
      activeModule: ProtoModule.yoyo,
      tabBadges: const {2: 2}, // 2 unread waves on Wave tab
      body: const _YoyoV2NearbyView(),
    );
  }
}

// ─── V2 Nearby View ─────────────────────────────────────────────────

class _YoyoV2NearbyView extends StatelessWidget {
  const _YoyoV2NearbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isYoyoAreaView
                ? _V2AreaView(key: const ValueKey('v2-area'))
                : _V2ListView(key: const ValueKey('v2-list')),
          ),
        ),
      ],
    );
  }
}

// ─── V2 Session Header ──────────────────────────────────────────────

class _V2SessionHeader extends StatefulWidget {
  const _V2SessionHeader();

  @override
  State<_V2SessionHeader> createState() => _V2SessionHeaderState();
}

class _V2SessionHeaderState extends State<_V2SessionHeader> {
  Timer? _timer;
  int _secondsRemaining = 0;

  static const _durations = [15 * 60, 30 * 60, 60 * 60, 120 * 60];
  static const _durationLabels = ['15m', '30m', '1h', '2h'];

  void _startSession(PrototypeStateProvider state) {
    state.onYoyoV2SessionToggle();
    _secondsRemaining = _durations[state.yoyoV2SessionDuration];
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _endSession(state);
      }
    });
  }

  void _endSession(PrototypeStateProvider state) {
    _timer?.cancel();
    _timer = null;
    if (state.yoyoV2SessionActive) state.onYoyoV2SessionToggle();
    setState(() => _secondsRemaining = 0);
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: state.yoyoV2SessionActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primary, theme.secondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sensors_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const Spacer(),
                  ProtoPressButton(
                    onTap: () {
                      _endSession(state);
                      ProtoToast.show(context, Icons.stop_circle_rounded, 'Session ended');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('End', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Nearby', style: theme.headline.copyWith(fontSize: 24)),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (int i = 0; i < _durationLabels.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      ProtoPressButton(
                        onTap: () => state.onYoyoV2SessionDurationChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: state.yoyoV2SessionDuration == i
                                ? theme.primary.withValues(alpha: 0.15)
                                : theme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: state.yoyoV2SessionDuration == i
                                  ? theme.primary
                                  : theme.textTertiary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            _durationLabels[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: state.yoyoV2SessionDuration == i ? theme.primary : theme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    Expanded(
                      child: ProtoPressButton(
                        onTap: () {
                          _startSession(state);
                          ProtoToast.show(context, Icons.sensors_rounded, 'Session started — ${_durationLabels[state.yoyoV2SessionDuration]}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.primary, theme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('Start YoYo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ─── V2 List View ───────────────────────────────────────────────────

class _V2ListView extends StatelessWidget {
  const _V2ListView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final encounters = _filteredV2Encounters(state);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        // Encounter type filter chips
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (final label in ['all', 'passby', 'nearby']) ...[
                if (label != 'all') const SizedBox(width: 6),
                ProtoPressButton(
                  onTap: () => state.onYoyoV2EncounterFilterChanged(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.yoyoV2EncounterFilter == label ? theme.primary : theme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: state.yoyoV2EncounterFilter == label
                          ? null
                          : Border.all(color: theme.textTertiary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (label == 'passby') ...[
                          Icon(Icons.flash_on_rounded, size: 12, color: state.yoyoV2EncounterFilter == label ? Colors.white : theme.textSecondary),
                          const SizedBox(width: 4),
                        ] else if (label == 'nearby') ...[
                          Icon(Icons.pin_drop_rounded, size: 12, color: state.yoyoV2EncounterFilter == label ? Colors.white : theme.textSecondary),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          label == 'all' ? 'All' : label == 'passby' ? 'Pass-by' : 'Nearby',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: state.yoyoV2EncounterFilter == label ? Colors.white : theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        for (final enc in encounters)
          enc.consentStatus == ConsentStatus.shared
              ? _V2RevealedCard(encounter: enc)
              : _V2TeaserCard(encounter: enc),
      ],
    );
  }
}

/// Filter V2 encounters based on state filters.
List<DemoV2Encounter> _filteredV2Encounters(PrototypeStateProvider state) {
  return ProtoDemoData.v2Encounters.where((enc) {
    if (state.yoyoV2EncounterFilter == 'passby' && enc.encounterType != EncounterType.passby) return false;
    if (state.yoyoV2EncounterFilter == 'nearby' && enc.encounterType != EncounterType.nearby) return false;
    if (state.yoyoV2RelationshipFilter == 'friends' && enc.relationship != RelationshipType.friend) return false;
    if (state.yoyoV2RelationshipFilter == 'family' && enc.relationship != RelationshipType.family) return false;
    if (state.yoyoV2RelationshipFilter == 'strangers' && enc.relationship != RelationshipType.stranger) return false;
    return true;
  }).toList();
}

// ─── V2 Teaser Card (pre-consent) ───────────────────────────────────

class _V2TeaserCard extends StatelessWidget {
  final DemoV2Encounter encounter;
  const _V2TeaserCard({required this.encounter});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return ProtoPressButton(
      duration: const Duration(milliseconds: 100),
      onTap: () => _showConsentSheet(context, encounter),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            // Grey silhouette
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded, size: 30, color: theme.textTertiary.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('YoYo User', style: theme.title),
                      const SizedBox(width: 6),
                      // Encounter type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: encounter.encounterType == EncounterType.passby
                              ? Colors.amber.withValues(alpha: 0.15)
                              : theme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              encounter.encounterType == EncounterType.passby
                                  ? Icons.flash_on_rounded
                                  : Icons.pin_drop_rounded,
                              size: 10,
                              color: encounter.encounterType == EncounterType.passby
                                  ? Colors.amber.shade700
                                  : theme.secondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              encounter.encounterType == EncounterType.passby ? 'Pass-by' : 'Nearby',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: encounter.encounterType == EncounterType.passby
                                    ? Colors.amber.shade700
                                    : theme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (encounter.relationship == RelationshipType.friend) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Interest chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: encounter.interests.map((i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        i[0].toUpperCase() + i.substring(1),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: theme.primary),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _distanceCategoryLabel(encounter.distanceCategory),
                        style: theme.caption.copyWith(color: theme.textTertiary),
                      ),
                      if (encounter.ageRange != null) ...[
                        const SizedBox(width: 8),
                        Text(encounter.ageRange!, style: theme.caption.copyWith(color: theme.textTertiary)),
                      ],
                      const SizedBox(width: 8),
                      Text(encounter.encounterTime, style: theme.caption),
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

String _distanceCategoryLabel(DistanceCategory cat) {
  switch (cat) {
    case DistanceCategory.veryNear: return 'Very Near';
    case DistanceCategory.nearby: return 'Nearby';
    case DistanceCategory.passing: return 'Passing';
  }
}

// ─── V2 Revealed Card (post-consent) ────────────────────────────────

class _V2RevealedCard extends StatelessWidget {
  final DemoV2Encounter encounter;
  const _V2RevealedCard({required this.encounter});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return ProtoPressButton(
      duration: const Duration(milliseconds: 100),
      onTap: () => state.push(ProtoRoutes.yoyoProfile),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            Stack(
              children: [
                _OrganicAvatar(size: 52, imageUrl: encounter.imageUrl),
                if (encounter.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(encounter.name, style: theme.title),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Connected', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: theme.secondary)),
                      ),
                      if (encounter.relationship == RelationshipType.partner) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.favorite_rounded, size: 14, color: Colors.red),
                      ] else if (encounter.relationship == RelationshipType.friend) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${encounter.encounterType == EncounterType.nearby ? "Nearby" : "Pass-by"} encounter, ${encounter.encounterTime}',
                    style: theme.caption.copyWith(color: theme.textTertiary),
                  ),
                ],
              ),
            ),
            // Wave + message actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProtoPressButton(
                  onTap: () => ProtoToast.show(context, theme.icons.wavingHand, 'Waved at ${encounter.name}!'),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(theme.icons.wavingHand, size: 16, color: theme.primary),
                  ),
                ),
                const SizedBox(width: 6),
                ProtoPressButton(
                  onTap: () => state.push(ProtoRoutes.chatConversation),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.textTertiary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(theme.icons.chatBubbleOutline, size: 16, color: theme.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── V2 Consent Handshake Sheet ─────────────────────────────────────

void _showConsentSheet(BuildContext context, DemoV2Encounter encounter) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _V2ConsentHandshakeSheet(encounter: encounter),
  );
}

class _V2ConsentHandshakeSheet extends StatelessWidget {
  final DemoV2Encounter encounter;
  const _V2ConsentHandshakeSheet({required this.encounter});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                encounter.encounterType == EncounterType.passby
                    ? Icons.flash_on_rounded
                    : Icons.pin_drop_rounded,
                size: 20,
                color: theme.primary,
              ),
              const SizedBox(width: 8),
              Text('A YoYo user nearby', style: theme.headline.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          // Teaser info
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: encounter.interests.map((i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                i[0].toUpperCase() + i.substring(1),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.primary),
              ),
            )).toList(),
          ),
          if (encounter.ageRange != null) ...[
            const SizedBox(height: 8),
            Text('Age range: ${encounter.ageRange}', style: theme.caption.copyWith(color: theme.textSecondary)),
          ],
          const SizedBox(height: 20),
          // Actions
          SizedBox(
            width: double.infinity,
            child: ProtoPressButton(
              onTap: () {
                Navigator.pop(context);
                // Simulate consent handshake
                final random = Random();
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (random.nextBool()) {
                    ProtoToast.show(context, Icons.celebration_rounded, 'Profiles revealed! Say hello');
                  } else {
                    ProtoToast.show(context, Icons.schedule_rounded, 'Looks like the moment passed');
                  }
                });
                ProtoToast.show(context, Icons.hourglass_top_rounded, 'Waiting for response...');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Share my card', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ProtoPressButton(
                  onTap: () {
                    Navigator.pop(context);
                    ProtoToast.show(context, Icons.schedule_rounded, 'Maybe next time');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.textTertiary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('Not now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProtoPressButton(
                  onTap: () {
                    Navigator.pop(context);
                    ProtoToast.show(context, Icons.do_not_disturb_rounded, 'Marked as busy');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.textTertiary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('Busy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ProtoPressButton(
                onTap: () {
                  Navigator.pop(context);
                  ProtoToast.show(context, Icons.block_rounded, 'User blocked');
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.block_rounded, size: 18, color: theme.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── V2 Area View ───────────────────────────────────────────────────

class _V2AreaView extends StatelessWidget {
  const _V2AreaView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    return Column(
      children: [
        _V2RadarControlBar(theme: theme, state: state),
        Expanded(
          child: state.yoyoLiveActive
              ? _V2RadarArea(theme: theme)
              : _HiddenV2RadarArea(theme: theme),
        ),
        state.yoyoLiveActive
            ? _V2EncounterCardRow(theme: theme)
            : _AnonymousCardRow(theme: theme),
        _V2ActionBar(theme: theme),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── V2 Radar Control Bar ───────────────────────────────────────────

class _V2RadarControlBar extends StatelessWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _V2RadarControlBar({required this.theme, required this.state});

  @override
  Widget build(BuildContext context) {
    final sliderValue = _kmToLogSlider(state.yoyoRange);

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
      child: Row(
        children: [
          // Inline live button
          _InlineLiveButton(theme: theme),
          const SizedBox(width: 6),
          // Radar icon + range label
          Icon(Icons.radar_rounded, size: 14, color: theme.primary),
          const SizedBox(width: 3),
          Text(
            _formatRange(state.yoyoRange),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
          const SizedBox(width: 4),
          // Logarithmic range slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                activeTrackColor: theme.primary,
                inactiveTrackColor: theme.textTertiary.withValues(alpha: 0.15),
                thumbShape: _StopButtonThumbShape(),
                thumbColor: theme.primary,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                overlayColor: theme.primary.withValues(alpha: 0.12),
              ),
              child: Slider(
                value: sliderValue,
                onChanged: (t) {
                  state.onYoyoRangeChanged(_logSliderToKm(t));
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Filter button
          ProtoPressButton(
            onTap: () => state.push(ProtoRoutes.yoyoFilters),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.textTertiary.withValues(alpha: 0.2)),
              ),
              child: Icon(theme.icons.tune, size: 14, color: theme.textSecondary),
            ),
          ),
          const SizedBox(width: 6),
          // Settings gear
          ProtoPressButton(
            onTap: () => state.push(ProtoRoutes.yoyoSettings),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.textTertiary.withValues(alpha: 0.2)),
              ),
              child: Icon(theme.icons.settings, size: 14, color: theme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── V2 Radar Area ──────────────────────────────────────────────────

class _V2RadarArea extends StatelessWidget {
  final ProtoTheme theme;
  const _V2RadarArea({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final encounters = _filteredV2Encounters(state);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w / 2;
        final cy = h * 0.46;
        final maxRadius = min(w, h) * 0.45;

        final positions = _generateV2Positions(encounters, cx, cy, maxRadius);

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.08),
                    radius: 0.9,
                    colors: [
                      theme.secondary.withValues(alpha: 0.06),
                      theme.background,
                    ],
                  ),
                ),
              ),
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(80),
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  children: [
                    // Range rings with dynamic distance labels
                    ..._buildV2RangeRings(cx, cy, maxRadius, theme, state.yoyoRange),

                    // "You" marker
                    Positioned(
                      left: cx - 29,
                      top: cy - 29,
                      child: Column(
                        children: [
                          _OrganicAvatar(
                            size: 52,
                            imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
                            borderColor: theme.surface,
                            borderWidth: 3,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('You', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),

                    // Encounter markers
                    for (int i = 0; i < encounters.length && i < positions.length; i++)
                      Positioned(
                        left: positions[i].dx - 35,
                        top: positions[i].dy - 35,
                        child: ProtoPressButton(
                          onTap: () {
                            if (encounters[i].consentStatus == ConsentStatus.shared) {
                              state.push(ProtoRoutes.yoyoProfile);
                            } else {
                              _showConsentSheet(context, encounters[i]);
                            }
                          },
                          child: _V2AreaMarker(encounter: encounters[i], theme: theme),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Count badge
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_rounded, size: 16, color: theme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        '${encounters.length} encounters',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static List<Offset> _generateV2Positions(
    List<DemoV2Encounter> encounters, double cx, double cy, double maxRadius,
  ) {
    final rng = Random(42);
    return List.generate(encounters.length, (i) {
      final cat = encounters[i].distanceCategory;
      final double fraction;
      switch (cat) {
        case DistanceCategory.veryNear: fraction = 0.25 + rng.nextDouble() * 0.1;
        case DistanceCategory.nearby: fraction = 0.50 + rng.nextDouble() * 0.15;
        case DistanceCategory.passing: fraction = 0.75 + rng.nextDouble() * 0.15;
      }
      final angle = (i * 137.5 * pi / 180) + rng.nextDouble() * 0.4;
      final r = maxRadius * fraction;
      return Offset(
        (cx + r * cos(angle)).clamp(35, cx * 2 - 35),
        (cy + r * sin(angle)).clamp(35, cy * 2 - 35),
      );
    });
  }

  static List<Widget> _buildV2RangeRings(
    double cx, double cy, double maxRadius, ProtoTheme theme, double range,
  ) {
    final List<int> labels;
    if (range <= 5) {
      labels = [1, 2, 5];
    } else if (range <= 10) {
      labels = [2, 5, 10];
    } else if (range <= 30) {
      labels = [5, 10, 30];
    } else if (range <= 200) {
      labels = [20, 50, range.round()];
    } else if (range <= 2000) {
      labels = [100, 500, range.round()];
    } else {
      labels = [1000, 5000, range.round()];
    }

    final maxLabel = labels.last.toDouble();
    final fractions = labels.map((l) => l / maxLabel).toList();

    return [
      for (int i = 0; i < 3; i++) ...[
        Positioned(
          left: cx - maxRadius * fractions[i],
          top: cy - maxRadius * fractions[i],
          child: Container(
            width: maxRadius * 2 * fractions[i],
            height: maxRadius * 2 * fractions[i],
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.textTertiary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          left: cx + maxRadius * fractions[i] + 4,
          top: cy - 7,
          child: Text(
            _formatRange(labels[i].toDouble()),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: theme.textTertiary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    ];
  }
}

// ─── Hidden V2 Radar Area (anonymous markers with friend badges) ────

class _HiddenV2RadarArea extends StatelessWidget {
  final ProtoTheme theme;
  const _HiddenV2RadarArea({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final encounters = _filteredV2Encounters(state);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w / 2;
        final cy = h * 0.46;
        final maxRadius = min(w, h) * 0.45;

        final positions = _V2RadarArea._generateV2Positions(encounters, cx, cy, maxRadius);

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.08),
                    radius: 0.9,
                    colors: [
                      theme.secondary.withValues(alpha: 0.06),
                      theme.background,
                    ],
                  ),
                ),
              ),
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(80),
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  children: [
                    // Range rings
                    ..._V2RadarArea._buildV2RangeRings(cx, cy, maxRadius, theme, state.yoyoRange),

                    // "You" marker with hidden badge
                    Positioned(
                      left: cx - 29,
                      top: cy - 29,
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Opacity(
                                opacity: 0.6,
                                child: _OrganicAvatar(
                                  size: 52,
                                  imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
                                  borderColor: theme.surface,
                                  borderWidth: 3,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primary.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              // Hidden badge overlay (eye-off icon)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: theme.textSecondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.surface,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    theme.icons.visibilityOff,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Anonymous markers — friends get a subtle star badge
                    for (int i = 0; i < encounters.length && i < positions.length; i++)
                      Positioned(
                        left: positions[i].dx - 35,
                        top: positions[i].dy - 35,
                        child: _AnonymousV2Marker(
                          size: 30.0 + (i % 3) * 10.0,
                          theme: theme,
                          isFriend: encounters[i].relationship == RelationshipType.friend
                              || encounters[i].relationship == RelationshipType.partner
                              || encounters[i].relationship == RelationshipType.family,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Count badge
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_rounded, size: 16, color: theme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        '${encounters.length} nearby',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Anonymous V2 Marker (friend-aware) ─────────────────────────────

class _AnonymousV2Marker extends StatelessWidget {
  final double size;
  final ProtoTheme theme;
  final bool isFriend;

  const _AnonymousV2Marker({
    required this.size,
    required this.theme,
    required this.isFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.textTertiary.withValues(alpha: 0.2),
            border: Border.all(
              color: isFriend
                  ? theme.secondary.withValues(alpha: 0.3)
                  : theme.textTertiary.withValues(alpha: 0.1),
              width: isFriend ? 1.5 : 1,
            ),
          ),
        ),
        // Friend star badge
        if (isFriend)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: theme.surface, width: 1),
              ),
              child: Icon(Icons.star_rounded, size: 8, color: Colors.amber.shade700),
            ),
          ),
      ],
    );
  }
}

// ─── V2 Area Marker ─────────────────────────────────────────────────

class _V2AreaMarker extends StatelessWidget {
  final DemoV2Encounter encounter;
  final ProtoTheme theme;
  const _V2AreaMarker({required this.encounter, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isRevealed = encounter.consentStatus == ConsentStatus.shared;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            if (isRevealed)
              _OrganicAvatar(
                size: 52,
                imageUrl: encounter.imageUrl,
                borderColor: encounter.isOnline ? theme.secondary : theme.textTertiary.withValues(alpha: 0.3),
                borderWidth: 2,
                boxShadow: [
                  if (encounter.isOnline)
                    BoxShadow(color: theme.secondary.withValues(alpha: 0.25), blurRadius: 8),
                ],
              )
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.textTertiary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.textTertiary.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(Icons.person_rounded, size: 28, color: theme.textTertiary.withValues(alpha: 0.5)),
              ),
            // Relationship icon overlay
            Positioned(
              right: -4,
              top: -4,
              child: _relationshipIcon(encounter.relationship, theme),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isRevealed ? encounter.name : _distanceCategoryLabel(encounter.distanceCategory),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.text),
          ),
        ),
      ],
    );
  }

  static Widget _relationshipIcon(RelationshipType rel, ProtoTheme theme) {
    switch (rel) {
      case RelationshipType.partner:
        return Container(
          width: 18, height: 18,
          decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle),
          child: const Icon(Icons.favorite_rounded, size: 11, color: Colors.red),
        );
      case RelationshipType.friend:
        return Container(
          width: 18, height: 18,
          decoration: BoxDecoration(color: Colors.amber.shade100, shape: BoxShape.circle),
          child: Icon(Icons.star_rounded, size: 11, color: Colors.amber.shade700),
        );
      case RelationshipType.family:
        return Container(
          width: 18, height: 18,
          decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
          child: Icon(Icons.home_rounded, size: 11, color: Colors.blue.shade700),
        );
      case RelationshipType.stranger:
        return const SizedBox.shrink();
    }
  }
}

// ─── V2 Encounter Card Carousel ─────────────────────────────────────

class _V2EncounterCardRow extends StatelessWidget {
  final ProtoTheme theme;
  const _V2EncounterCardRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final encounters = _filteredV2Encounters(state);

    return SizedBox(
      height: 100,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: encounters.length,
          itemBuilder: (context, index) {
            final enc = encounters[index];
            final isRevealed = enc.consentStatus == ConsentStatus.shared;

            return ProtoPressButton(
              onTap: () {
                if (isRevealed) {
                  state.push(ProtoRoutes.yoyoProfile);
                } else {
                  _showConsentSheet(context, enc);
                }
              },
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: theme.text.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRevealed)
                      _OrganicAvatar(size: 40, imageUrl: enc.imageUrl)
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.textTertiary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded, size: 22, color: theme.textTertiary.withValues(alpha: 0.5)),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      isRevealed ? enc.name : 'User',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.text),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _distanceCategoryLabel(enc.distanceCategory),
                      style: TextStyle(fontSize: 9, color: theme.textTertiary),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── V2 Action Bar ──────────────────────────────────────────────────

class _V2ActionBar extends StatelessWidget {
  final ProtoTheme theme;
  const _V2ActionBar({required this.theme});

  static const _durationLabels = ['30m', '2h', '8h', 'Always On'];

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    if (state.yoyoLiveActive) {
      return _buildLiveBar(context, state);
    }
    return _buildHiddenBar(context, state);
  }

  /// Live mode — "Wave All Nearby" gradient button.
  Widget _buildLiveBar(BuildContext context, PrototypeStateProvider state) {
    final encounterCount = _filteredV2Encounters(state).length;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 80),
      child: SizedBox(
        height: 52,
        child: ProtoPressButton(
          onTap: () {
            ProtoToast.show(context, theme.icons.wavingHand, 'Waved to $encounterCount people nearby!');
          },
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(theme.icons.wavingHand, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Wave All Nearby', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hidden mode — duration chips + "Go Live" button.
  Widget _buildHiddenBar(BuildContext context, PrototypeStateProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration chips row
          Row(
            children: [
              for (int i = 0; i < _durationLabels.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                ProtoPressButton(
                  onTap: () => state.onYoyoLiveDurationChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.yoyoLiveDuration == i
                          ? theme.primary.withValues(alpha: 0.15)
                          : theme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: state.yoyoLiveDuration == i
                            ? theme.primary
                            : theme.textTertiary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _durationLabels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: state.yoyoLiveDuration == i ? theme.primary : theme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Go Live gradient button
          SizedBox(
            width: double.infinity,
            child: ProtoPressButton(
              onTap: () {
                state.onYoyoLiveToggle();
                final label = _durationLabels[state.yoyoLiveDuration];
                ProtoToast.show(
                  context,
                  Icons.sensors_rounded,
                  label == 'Always On' ? 'You\'re now live' : 'Live for $label',
                );
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(theme.icons.wavingHand, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Wave All Nearby', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter DemoData.nearbyUsers based on current state (range, friends, interests).
/// Format range for display — "200 m", "5 km", "5,000 km", or "Global"
String _formatRange(double range) {
  if (range >= 39000) return 'Global';
  if (range < 1) {
    return '${(range * 1000).round()} m';
  }
  final km = range.round();
  if (km >= 1000) {
    final thousands = km ~/ 1000;
    final remainder = km % 1000;
    if (remainder == 0) return '${thousands},000 km';
    return '${thousands},${remainder.toString().padLeft(3, '0')} km';
  }
  return '$km km';
}

List<NearbyUser> _filteredUsers(PrototypeStateProvider state) {
  return DemoData.nearbyUsers.where((user) {
    if (user.distanceKm > state.yoyoRange) return false;
    if (state.yoyoFriendsOnly && !user.isFriend) return false;
    if (state.yoyoSelectedInterests.isNotEmpty) {
      final hasMatch =
          user.interests.any((i) => state.yoyoSelectedInterests.contains(i));
      if (!hasMatch) return false;
    }
    return true;
  }).toList();
}

/// List view — vertical card list with tappable wave buttons
class _YoyoListView extends StatefulWidget {
  const _YoyoListView({super.key});

  @override
  State<_YoyoListView> createState() => _YoyoListViewState();
}

class _YoyoListViewState extends State<_YoyoListView> {
  final Set<int> _wavedIndices = {};

  void _handleWave(int index, String name) {
    setState(() => _wavedIndices.add(index));
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, theme.icons.wavingHand, 'Waved at $name!');
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _wavedIndices.remove(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final users = _filteredUsers(state);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Header row
        Row(
          children: [
            Text('Nearby', style: theme.headline.copyWith(fontSize: 24)),
            const Spacer(),
            Icon(theme.icons.radar, size: 14, color: theme.secondary),
            const SizedBox(width: 4),
            Text(
              _formatRange(state.yoyoRange),
              style: theme.caption.copyWith(
                color: theme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        // Range slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.primary,
            thumbColor: theme.primary,
            inactiveTrackColor: theme.textTertiary.withValues(alpha: 0.15),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            min: 1,
            max: 30,
            divisions: 29,
            value: state.yoyoRange,
            onChanged: state.onYoyoRangeChanged,
          ),
        ),

        // Vertical user cards
        for (int i = 0; i < users.length; i++)
          ProtoPressButton(
            duration: const Duration(milliseconds: 100),
            onTap: () => state.push(ProtoRoutes.yoyoProfile),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: theme.cardDecoration,
              child: Row(
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      ProtoAvatar(
                        radius: 28,
                        imageUrl: users[i].imageUrl,
                      ),
                      if (users[i].isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: theme.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.surface, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(users[i].name, style: theme.title),
                            if (users[i].isNew) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('NEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: theme.primary, letterSpacing: 0.5)),
                              ),
                            ],
                            if (users[i].isFriend) ...[
                              const SizedBox(width: 6),
                              Icon(theme.icons.group, size: 14, color: theme.secondary),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(theme.icons.locationOn, size: 14, color: theme.textTertiary),
                            const SizedBox(width: 4),
                            Text(users[i].distance, style: theme.caption),
                            if (users[i].isOnline) ...[
                              const SizedBox(width: 12),
                              Text('Online now', style: theme.caption.copyWith(color: theme.secondary)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Wave button with check animation
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _handleWave(i, users[i].name),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _wavedIndices.contains(i)
                            ? theme.secondary.withValues(alpha: 0.15)
                            : theme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _wavedIndices.contains(i)
                            ? Icon(theme.icons.check, key: const ValueKey('check'), size: 18, color: theme.secondary)
                            : Icon(theme.icons.wavingHand, key: const ValueKey('wave'), size: 18, color: theme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Area view ─────────────────────────────────────────────────────────

/// Area view — organic avatars on a proximity radar with card carousel
/// and action bar.
class _YoyoAreaView extends StatelessWidget {
  const _YoyoAreaView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);
    final isLive = state.yoyoLiveActive;

    return Column(
      children: [
        // Control bar with inline live status replacing the old eye icon
        _RadarControlBar(theme: theme, state: state),
        // Radar area (anonymous circles when hidden, real markers when live)
        Expanded(child: _RadarArea(theme: theme)),
        // Card carousel (anonymous when hidden)
        isLive ? _NearbyUserCardRow(theme: theme) : _AnonymousCardRow(theme: theme),
        // Bottom: Go Live panel when hidden, wave bar when live
        isLive ? _YoyoActionBar(theme: theme) : _GoLivePanel(theme: theme),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Compact control bar above the radar: visibility toggle + range slider + filter + settings.
class _RadarControlBar extends StatelessWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _RadarControlBar({required this.theme, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 4, bottom: 0),
      child: Row(
        children: [
          // Inline live status — replaces the old eye toggle
          _InlineLiveButton(theme: theme),
          const SizedBox(width: 8),
          Icon(theme.icons.radar, size: 16, color: theme.secondary),
          const SizedBox(width: 4),
          Text(
            _formatRange(state.yoyoRange),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.secondary,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: theme.primary,
                thumbColor: theme.primary,
                inactiveTrackColor: theme.textTertiary.withValues(alpha: 0.15),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                min: 1,
                max: 20000,
                value: state.yoyoRange,
                onChanged: state.onYoyoRangeChanged,
              ),
            ),
          ),
          // Filter button
          ProtoPressButton(
            onTap: () => state.push(ProtoRoutes.yoyoFilters),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (state.yoyoFriendsOnly || state.yoyoSelectedInterests.isNotEmpty)
                    ? theme.primary.withValues(alpha: 0.15)
                    : theme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.textTertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                theme.icons.tune,
                size: 16,
                color: (state.yoyoFriendsOnly || state.yoyoSelectedInterests.isNotEmpty)
                    ? theme.primary
                    : theme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Settings gear
          ProtoPressButton(
            onTap: () => state.push(ProtoRoutes.yoyoSettings),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.textTertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                theme.icons.settings,
                size: 16,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The proximity radar with rings, "You" marker, and user markers.
/// Shows a bottom sheet explaining the radar legend — marker types, colors, icons.
void _showRadarLegend(BuildContext context, ProtoTheme theme) {
  showModalBottomSheet(
    context: context,
    backgroundColor: theme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Radar Legend',
              style: theme.headline.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            // Connected
            _LegendRow(
              theme: theme,
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primary, width: 2),
                ),
                child: Icon(Icons.check, size: 12, color: theme.primary),
              ),
              label: 'Connected',
              description: 'People you\'ve matched or connected with',
            ),
            const SizedBox(height: 12),
            // Unknown — online
            _LegendRow(
              theme: theme,
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.secondary, width: 2),
                ),
              ),
              label: 'Nearby (online)',
              description: 'People nearby who are currently active',
            ),
            const SizedBox(height: 12),
            // Unknown — offline
            _LegendRow(
              theme: theme,
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.textTertiary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.textTertiary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              label: 'Nearby (offline)',
              description: 'People seen recently but not currently active',
            ),
            const SizedBox(height: 12),
            // Anonymous (hidden mode)
            _LegendRow(
              theme: theme,
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.textTertiary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Anonymous',
              description: 'Hidden mode — you can see presence but not identity',
            ),
            const SizedBox(height: 12),
            // Range rings
            _LegendRow(
              theme: theme,
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.textTertiary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.radar, size: 14, color: theme.secondary),
              ),
              label: 'Range rings',
              description: 'Concentric circles show distance from you',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _LegendRow extends StatelessWidget {
  final ProtoTheme theme;
  final Widget icon;
  final String label;
  final String description;

  const _LegendRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RadarArea extends StatelessWidget {
  final ProtoTheme theme;
  const _RadarArea({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final users = _filteredUsers(state);
    final userCount = users.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w / 2;
        final cy = h * 0.46;
        final maxRadius = min(w, h) * 0.45;

        final positions = _generatePositions(
          users, cx, cy, maxRadius, state.yoyoRange,
        );

        return Stack(
          children: [
            // Background radial gradient (fixed, outside InteractiveViewer)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.08),
                    radius: 0.9,
                    colors: [
                      theme.secondary.withValues(alpha: 0.06),
                      theme.background,
                    ],
                  ),
                ),
              ),
            ),

            // Zoomable radar content
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(80),
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  children: [
                    // Range rings with labels
                    ..._buildRangeRings(cx, cy, maxRadius, theme, state.yoyoRange),

                    // "You" organic marker at center (with hidden badge)
                    Positioned(
                      left: cx - 29,
                      top: cy - 29,
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Opacity(
                                opacity: state.isYoyoHidden ? 0.6 : 1.0,
                                child: _OrganicAvatar(
                                  size: 52,
                                  imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
                                  borderColor: theme.surface,
                                  borderWidth: 3,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primary.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              // Hidden badge overlay
                              if (state.isYoyoHidden)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: theme.textSecondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.surface,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      theme.icons.visibilityOff,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Nearby markers — anonymous circles when hidden, full markers when live
                    for (int i = 0; i < users.length && i < positions.length; i++)
                      Positioned(
                        left: positions[i].dx - 36,
                        top: positions[i].dy - 36,
                        child: state.yoyoLiveActive
                            ? ProtoPressButton(
                                onTap: () => state.push(ProtoRoutes.yoyoProfile),
                                child: _AreaUserMarker(
                                  user: users[i],
                                  theme: theme,
                                  userCount: userCount,
                                ),
                              )
                            : _AnonymousMarker(
                                size: 30.0 + (i % 3) * 10.0,
                                theme: theme,
                              ),
                      ),
                  ],
                ),
              ),
            ),

            // People count badge + info button (fixed, outside InteractiveViewer)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: theme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(theme.icons.radar, size: 16, color: theme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        '$userCount people within ${_formatRange(state.yoyoRange)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showRadarLegend(context, theme),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.textTertiary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: theme.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Distance-proportional positioning on the radar.
  static List<Offset> _generatePositions(
    List<NearbyUser> users,
    double cx,
    double cy,
    double maxRadius,
    double maxKm,
  ) {
    final rng = Random(42);

    return List.generate(users.length, (i) {
      final km = users[i].distanceKm;
      // Square-root mapping spreads close users further out while keeping
      // distant users near the edge — makes differences more visible.
      final fraction = (sqrt(km / maxKm) * 0.75 + 0.20).clamp(0.20, 0.95);
      // Golden-angle spread with slight randomness
      final angle = (i * 137.5 * pi / 180) + rng.nextDouble() * 0.4;
      final r = maxRadius * fraction + rng.nextDouble() * 12 - 6;
      return Offset(
        (cx + r * cos(angle)).clamp(35, cx * 2 - 35),
        (cy + r * sin(angle)).clamp(35, cy * 2 - 35),
      );
    });
  }

  /// Builds 3 concentric range rings with distance labels.
  /// Rings adapt to the selected range dynamically.
  static List<Widget> _buildRangeRings(
    double cx,
    double cy,
    double maxRadius,
    ProtoTheme theme,
    double range,
  ) {
    final List<int> labels;
    if (range <= 5) {
      labels = [1, 2, 5];
    } else if (range <= 10) {
      labels = [2, 5, 10];
    } else if (range <= 30) {
      labels = [5, 10, 30];
    } else if (range <= 200) {
      labels = [20, 50, range.round()];
    } else if (range <= 2000) {
      labels = [100, 500, range.round()];
    } else {
      labels = [1000, 5000, range.round()];
    }

    final maxLabel = labels.last.toDouble();
    final fractions = labels.map((l) => l / maxLabel).toList();

    return [
      for (int i = 0; i < 3; i++) ...[
        // Ring
        Positioned(
          left: cx - maxRadius * fractions[i],
          top: cy - maxRadius * fractions[i],
          child: Container(
            width: maxRadius * 2 * fractions[i],
            height: maxRadius * 2 * fractions[i],
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.textTertiary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
        ),
        // Distance label at right edge of ring
        Positioned(
          left: cx + maxRadius * fractions[i] + 4,
          top: cy - 7,
          child: Text(
            '${labels[i]} km',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: theme.textTertiary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    ];
  }
}

/// Single user marker on the radar — organic avatar + name/distance chip
/// + interest icon row (hidden when crowded).
class _AreaUserMarker extends StatelessWidget {
  final NearbyUser user;
  final ProtoTheme theme;
  final int userCount;

  const _AreaUserMarker({
    required this.user,
    required this.theme,
    required this.userCount,
  });

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    // Scale avatar — 25% smaller at close range vs. previous sizes
    final double baseSize;
    if (state.yoyoRange <= 2) {
      baseSize = 84.0; // was 112 → 25% smaller
    } else if (state.yoyoRange <= 5) {
      baseSize = 72.0; // was 96 → 25% smaller
    } else {
      baseSize = 66.0; // was 88 → 25% smaller
    }
    // Shrink when crowded
    final avatarSize = userCount > 15 ? 48.0 : baseSize;
    final showInterests = userCount <= 8;
    final isConnected = user.isFriend;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Organic avatar — connected users get primary border, unknowns get grey
        Stack(
          clipBehavior: Clip.none,
          children: [
            _OrganicAvatar(
              size: avatarSize,
              imageUrl: user.imageUrl,
              borderColor: isConnected
                  ? theme.primary
                  : user.isOnline
                      ? theme.secondary
                      : theme.textTertiary.withValues(alpha: 0.3),
              borderWidth: isConnected ? 3 : 2,
              boxShadow: [
                if (isConnected)
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                  )
                else if (user.isOnline)
                  BoxShadow(
                    color: theme.secondary.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
              ],
            ),
            // Connection badge — small checkmark for connected users
            if (isConnected)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.surface, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        // Name + distance chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isConnected ? FontWeight.w700 : FontWeight.w600,
                  color: theme.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user.distance,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (showInterests && user.interests.isNotEmpty) ...[
          const SizedBox(height: 2),
          _InterestIconRow(
            interests: user.interests.take(3).toList(),
            theme: theme,
          ),
        ],
      ],
    );
  }
}

/// Overlapping row of tiny interest icons beneath a marker.
class _InterestIconRow extends StatelessWidget {
  final List<String> interests;
  final ProtoTheme theme;

  const _InterestIconRow({required this.interests, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: interests.length * 12.0 + 4,
      height: 16,
      child: Stack(
        children: [
          for (int i = 0; i < interests.length; i++)
            Positioned(
              left: i * 12.0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.surface,
                  border: Border.all(
                    color: theme.textTertiary.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.text.withValues(alpha: 0.08),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _interestIcons[interests[i]] ?? theme.icons.starFilled,
                  size: 9,
                  color: theme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Card carousel ─────────────────────────────────────────────────────

/// Horizontal scrolling row of nearby user mini-cards.
class _NearbyUserCardRow extends StatelessWidget {
  final ProtoTheme theme;
  const _NearbyUserCardRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final users = _filteredUsers(state);

    return SizedBox(
      height: 120,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ProtoPressButton(
              onTap: () => state.push(ProtoRoutes.yoyoProfile),
              child: Container(
                width: 92,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.text.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Organic avatar with online dot
                    Stack(
                      children: [
                        _OrganicAvatar(
                          size: 50,
                          imageUrl: user.imageUrl,
                        ),
                        if (user.isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: theme.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.surface, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      user.distance,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTertiary,
                      ),
                    ),
                  ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}

// ─── Action bar ────────────────────────────────────────────────────────

/// Full-width action button — dual-purpose: "Wave all" when visible,
/// "Hidden" when the user has toggled visibility off.
class _YoyoActionBar extends StatelessWidget {
  final ProtoTheme theme;
  const _YoyoActionBar({required this.theme});

  void _showWaveOverlay(BuildContext context, int userCount) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _WaveOverlay(
        theme: theme,
        userCount: userCount,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final isHidden = state.isYoyoHidden;
    final userCount = _filteredUsers(state).length;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 80),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Expanded(
              child: ProtoPressButton(
                onTap: isHidden
                    ? state.onYoyoHiddenToggle
                    : () => _showWaveOverlay(context, userCount),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44,
                  decoration: BoxDecoration(
                    color: isHidden
                        ? theme.surface
                        : theme.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: isHidden
                        ? Border.all(color: theme.textTertiary.withValues(alpha: 0.2))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isHidden ? theme.icons.visibilityOff : theme.icons.wavingHand,
                        size: 18,
                        color: isHidden ? theme.textSecondary : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isHidden ? 'Hidden' : 'Wave all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isHidden ? theme.textSecondary : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brief animated wave confirmation overlay (1.5s auto-dismiss).
class _WaveOverlay extends StatefulWidget {
  final ProtoTheme theme;
  final int userCount;
  final VoidCallback onDismiss;
  const _WaveOverlay({required this.theme, required this.userCount, required this.onDismiss});

  @override
  State<_WaveOverlay> createState() => _WaveOverlayState();
}

class _WaveOverlayState extends State<_WaveOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_controller);

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: widget.theme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.theme.icons.wavingHand,
                  size: 48,
                  color: widget.theme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Waved to ${widget.userCount} people nearby!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.theme.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Inline Live Button (replaces eye icon in control bar) ────────────

/// Compact dual-state button that sits where the eye icon was:
/// - Hidden: grey pill "Go Live" → tap expands duration picker below
/// - Live: gradient pill with countdown → tap ends session
class _InlineLiveButton extends StatefulWidget {
  final ProtoTheme theme;
  const _InlineLiveButton({required this.theme});

  @override
  State<_InlineLiveButton> createState() => _InlineLiveButtonState();
}

class _InlineLiveButtonState extends State<_InlineLiveButton> {
  bool _pickerOpen = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _timerStarted = false; // tracks whether we've started timer for this live session

  static const _durations = [30 * 60, 2 * 60 * 60, 8 * 60 * 60, -1];
  static const _labels = ['30m', '2h', '8h', 'Always'];

  /// Start the countdown timer for the current duration.
  void _startTimer(PrototypeStateProvider state) {
    final dur = _durations[state.yoyoLiveDuration];
    _timerStarted = true;
    if (dur > 0) {
      _secondsRemaining = dur;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _endSession(state);
        }
      });
    }
  }

  void _goLive(PrototypeStateProvider state) {
    state.onYoyoLiveToggle();
    setState(() => _pickerOpen = false);
    _startTimer(state);
    final dur = _durations[state.yoyoLiveDuration];
    ProtoToast.show(
      context,
      Icons.sensors_rounded,
      dur < 0 ? 'You\'re now live' : 'Live for ${_labels[state.yoyoLiveDuration]}',
    );
  }

  void _endSession(PrototypeStateProvider state) {
    _timer?.cancel();
    _timer = null;
    _timerStarted = false;
    if (state.yoyoLiveActive) state.onYoyoLiveToggle();
    ProtoToast.show(context, Icons.visibility_off_rounded, 'Back to hidden');
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h${m}m';
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = widget.theme;
    final isLive = state.yoyoLiveActive;
    final isAlways = state.yoyoLiveDuration == 3;

    // Auto-start timer if live was toggled externally (e.g. from GoLivePanel)
    if (isLive && !_timerStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer(state));
    }
    if (!isLive && _timerStarted) {
      _timerStarted = false;
      _timer?.cancel();
    }

    if (isLive) {
      // ─── Live state: gradient pill with countdown ───
      return ProtoPressButton(
        onTap: () => _endSession(state),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isAlways ? 'LIVE' : _formatTime(_secondsRemaining),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ─── Hidden state: tappable — tap to go live with selected duration ───
    return ProtoPressButton(
      onTap: () => _goLive(state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.textTertiary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.textTertiary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              theme.icons.visibilityOff,
              size: 12,
              color: theme.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'Hidden',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Anonymous Marker (hidden mode — replaces user avatars) ───────────

class _AnonymousMarker extends StatelessWidget {
  final double size;
  final ProtoTheme theme;

  const _AnonymousMarker({required this.size, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.textTertiary.withValues(alpha: 0.2),
        border: Border.all(
          color: theme.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
    );
  }
}

// ─── Anonymous Card Row (hidden mode — replaces user card carousel) ───

class _AnonymousCardRow extends StatelessWidget {
  final ProtoTheme theme;
  const _AnonymousCardRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final count = _filteredUsers(state).length;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: count,
        itemBuilder: (context, index) {
          final size = 40.0 + (index % 3) * 6.0;
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.textTertiary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: theme.textTertiary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: size * 0.5,
                    color: theme.textTertiary.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.textTertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Go Live Panel (hidden mode — replaces action bar) ────────────────

class _GoLivePanel extends StatelessWidget {
  final ProtoTheme theme;
  const _GoLivePanel({required this.theme});

  static const _durationLabels = ['30m', '2h', '8h', 'Always On'];

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final userCount = _filteredUsers(state).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + count
          Row(
            children: [
              Icon(
                theme.icons.visibilityOff,
                size: 14,
                color: theme.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Hidden',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                '$userCount nearby',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTertiary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Duration chips
          Row(
            children: [
              for (int i = 0; i < _durationLabels.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                ProtoPressButton(
                  onTap: () => state.onYoyoLiveDurationChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.yoyoLiveDuration == i
                          ? theme.primary.withValues(alpha: 0.15)
                          : theme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: state.yoyoLiveDuration == i
                            ? theme.primary
                            : theme.textTertiary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _durationLabels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: state.yoyoLiveDuration == i ? theme.primary : theme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Go Live button
          SizedBox(
            width: double.infinity,
            child: ProtoPressButton(
              onTap: () {
                state.onYoyoLiveToggle();
                final label = _durationLabels[state.yoyoLiveDuration];
                ProtoToast.show(
                  context,
                  Icons.sensors_rounded,
                  label == 'Always On' ? 'You\'re now live' : 'Live for $label',
                );
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Go Live',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Live Session Bar (countdown header when visible) ─────────────────

class _LiveSessionBar extends StatefulWidget {
  final ProtoTheme theme;
  const _LiveSessionBar({required this.theme});

  @override
  State<_LiveSessionBar> createState() => _LiveSessionBarState();
}

class _LiveSessionBarState extends State<_LiveSessionBar> {
  Timer? _timer;
  int _secondsRemaining = 0;

  static const _durations = [30 * 60, 2 * 60 * 60, 8 * 60 * 60, -1]; // -1 = Always On

  void _startTimer(PrototypeStateProvider state) {
    final duration = _durations[state.yoyoLiveDuration];
    if (duration < 0) return; // Always On — no countdown
    _secondsRemaining = duration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _endSession(state);
      }
    });
  }

  void _endSession(PrototypeStateProvider state) {
    _timer?.cancel();
    _timer = null;
    if (state.yoyoLiveActive) state.onYoyoLiveToggle();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = PrototypeStateProvider.of(context);
      _startTimer(state);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = widget.theme;
    final isAlwaysOn = state.yoyoLiveDuration == 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primary, theme.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.sensors_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              isAlwaysOn ? 'Live' : 'Live \u00B7 ${_formatTime(_secondsRemaining)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            ProtoPressButton(
              onTap: () {
                _endSession(state);
                ProtoToast.show(context, Icons.visibility_off_rounded, 'Back to hidden');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'End',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
