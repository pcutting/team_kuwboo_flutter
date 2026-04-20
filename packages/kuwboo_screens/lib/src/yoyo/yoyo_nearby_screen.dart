import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../screens_test_ids.dart';
import 'yoyo_providers.dart';

// ─── Logarithmic range slider helpers ─────────────────────────────────
// Maps 0.0–1.0 slider position to 200 m (0.2 km) → 40,000 km range
double _logSliderToKm(double t) => 0.2 * pow(200000, t.clamp(0.0, 1.0));
double _kmToLogSlider(double km) => (log(km / 0.2) / log(200000)).clamp(0.0, 1.0);

// ─── Stop-button thumb shape for range slider ─────────────────────────

class _StopButtonThumbShape extends SliderComponentShape {
  const _StopButtonThumbShape();

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
///
/// If [imageBytes] is non-null it's used instead of [imageUrl]; this lets
/// the current user's registration-picked photo render without a network
/// round-trip (see [_YouAvatar]).
class _OrganicAvatar extends StatelessWidget {
  final double size;
  final String imageUrl;
  final Uint8List? imageBytes;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow> boxShadow;

  const _OrganicAvatar({
    required this.size,
    required this.imageUrl,
    this.imageBytes,
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
    final ImageProvider image = imageBytes != null
        ? MemoryImage(imageBytes!)
        : NetworkImage(imageUrl);
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
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
  }
}

/// The current-user "You" marker on the radar. Watches
/// [localAvatarProvider] so a registration-picked (or settings-picked)
/// photo surfaces here without any backend round-trip. Falls back to the
/// demo unsplash avatar when no bytes are available — this keeps the
/// unauthenticated prototype walkthroughs visually populated.
class _YouAvatar extends ConsumerWidget {
  const _YouAvatar({
    required this.size,
    this.borderColor,
    this.borderWidth = 0,
    this.boxShadow = const [],
  });

  final double size;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow> boxShadow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(localAvatarProvider);
    return _OrganicAvatar(
      size: size,
      imageBytes: bytes,
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      borderColor: borderColor,
      borderWidth: borderWidth,
      boxShadow: boxShadow,
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
class YoyoNearbyScreen extends ConsumerStatefulWidget {
  const YoyoNearbyScreen({super.key});

  @override
  ConsumerState<YoyoNearbyScreen> createState() => _YoyoNearbyScreenState();
}

class _YoyoNearbyScreenState extends ConsumerState<YoyoNearbyScreen> {
  @override
  Widget build(BuildContext context) {
    // Prime the live nearby-user fetch so child screens and the wave action
    // can read `yoyoNearbyProvider.valueOrNull` synchronously. Errors surface
    // where the list is rendered (currently the Connect screen); the radar
    // UI keeps its prototype data until the backend model carries the
    // richer encounter metadata the radar needs.
    ref.watch(yoyoNearbyProvider);

    // The outer ProtoScaffold is provided by the app shell (router).
    // This screen just returns its body. The shell reads the
    // `isRadarFullscreen` flag to hide the top bar + bottom nav and passes
    // overlayTopBar for the transparent-over-radar layout.
    return const _YoyoNearbyView();
  }
}

// ─── Nearby View ────────────────────────────────────────────────────

class _YoyoNearbyView extends StatelessWidget {
  const _YoyoNearbyView();

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isYoyoAreaView
                ? _AreaView(key: const ValueKey('nearby-area'))
                : _ListView(key: const ValueKey('nearby-list')),
          ),
        ),
      ],
    );
  }
}

// ─── Session Header ─────────────────────────────────────────────────

class _SessionHeader extends StatefulWidget {
  const _SessionHeader();

  @override
  State<_SessionHeader> createState() => _SessionHeaderState();
}

class _SessionHeaderState extends State<_SessionHeader> {
  Timer? _timer;
  int _secondsRemaining = 0;

  static const _durations = [15 * 60, 30 * 60, 60 * 60, 120 * 60];
  static const _durationLabels = ['15m', '30m', '1h', '2h'];

  void _startSession(PrototypeStateProvider state) {
    state.onYoyoSessionToggle();
    _secondsRemaining = _durations[state.yoyoSessionDuration];
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
    if (state.yoyoSessionActive) state.onYoyoSessionToggle();
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
      child: state.yoyoSessionActive
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
                        onTap: () => state.onYoyoSessionDurationChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: state.yoyoSessionDuration == i
                                ? theme.primary.withValues(alpha: 0.15)
                                : theme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: state.yoyoSessionDuration == i
                                  ? theme.primary
                                  : theme.textTertiary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            _durationLabels[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: state.yoyoSessionDuration == i ? theme.primary : theme.textSecondary,
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
                          ProtoToast.show(context, Icons.sensors_rounded, 'Session started — ${_durationLabels[state.yoyoSessionDuration]}');
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

// ─── List View ──────────────────────────────────────────────────────

class _ListView extends StatelessWidget {
  const _ListView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final encounters = _filteredEncounters(state);

    return Stack(
      children: [
        // Radar gradient background (shows through transparent nav)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 0.8,
                colors: [
                  theme.secondary.withValues(alpha: 0.04),
                  theme.background,
                ],
              ),
            ),
          ),
        ),
        ListView(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 52),
      children: [
        // Encounter type filter chips
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (final label in ['all', 'passby', 'nearby']) ...[
                if (label != 'all') const SizedBox(width: 6),
                ProtoPressButton(
                  onTap: () => state.onYoyoEncounterFilterChanged(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.yoyoEncounterFilter == label ? theme.primary : theme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: state.yoyoEncounterFilter == label
                          ? null
                          : Border.all(color: theme.textTertiary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (label == 'passby') ...[
                          Icon(Icons.flash_on_rounded, size: 12, color: state.yoyoEncounterFilter == label ? Colors.white : theme.textSecondary),
                          const SizedBox(width: 4),
                        ] else if (label == 'nearby') ...[
                          Icon(Icons.pin_drop_rounded, size: 12, color: state.yoyoEncounterFilter == label ? Colors.white : theme.textSecondary),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          label == 'all' ? 'All' : label == 'passby' ? 'Pass-by' : 'Nearby',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: state.yoyoEncounterFilter == label ? Colors.white : theme.textSecondary),
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
              ? _RevealedCard(encounter: enc)
              : _TeaserCard(encounter: enc),
      ],
    ),
      ],
    );
  }
}

/// Filter encounters based on state filters.
List<DemoEncounter> _filteredEncounters(PrototypeStateProvider state) {
  final range = state.yoyoRange; // km

  return ProtoDemoData.encounters.where((enc) {
    if (state.yoyoEncounterFilter == 'passby' && enc.encounterType != EncounterType.passby) return false;
    if (state.yoyoEncounterFilter == 'nearby' && enc.encounterType != EncounterType.nearby) return false;
    if (state.yoyoRelationshipFilter == 'friends' && enc.relationship != RelationshipType.friend) return false;
    if (state.yoyoRelationshipFilter == 'family' && enc.relationship != RelationshipType.family) return false;
    if (state.yoyoRelationshipFilter == 'strangers' && enc.relationship != RelationshipType.stranger) return false;
    // Simulate range filtering: veryNear always visible, nearby needs >= 2km, passing needs >= 10km
    if (enc.distanceCategory == DistanceCategory.nearby && range < 2) return false;
    if (enc.distanceCategory == DistanceCategory.passing && range < 10) return false;
    return true;
  }).toList();
}

/// Marker scale factor — smaller avatars at wider ranges (more people, less detail).
double _markerScale(double rangeKm) {
  if (rangeKm <= 1) return 1.0;
  if (rangeKm <= 5) return 0.9;
  if (rangeKm <= 20) return 0.8;
  if (rangeKm <= 100) return 0.7;
  return 0.6;
}

// ─── Teaser Card (pre-consent) ──────────────────────────────────────

class _TeaserCard extends StatelessWidget {
  final DemoEncounter encounter;
  const _TeaserCard({required this.encounter});

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

// ─── Revealed Card (post-consent) ───────────────────────────────────

class _RevealedCard extends StatelessWidget {
  final DemoEncounter encounter;
  const _RevealedCard({required this.encounter});

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

// ─── Consent Handshake Sheet ────────────────────────────────────────

void _showConsentSheet(BuildContext context, DemoEncounter encounter) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ConsentHandshakeSheet(encounter: encounter),
  );
}

class _ConsentHandshakeSheet extends StatelessWidget {
  final DemoEncounter encounter;
  const _ConsentHandshakeSheet({required this.encounter});

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

// ─── Area View ──────────────────────────────────────────────────────

class _AreaView extends StatelessWidget {
  const _AreaView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    if (state.isRadarFullscreen) {
      return _FullscreenRadarView(theme: theme);
    }

    // Hidden mode: radar fills area, floating "Hidden" pill + count, controls at bottom
    if (!state.yoyoLiveActive) {
      final hiddenCount = _filteredEncounters(state).length;
      return Stack(
        children: [
          // Radar fills entire area
          Positioned.fill(
            child: _HiddenRadarArea(theme: theme),
          ),
          // Floating "Hidden" pill + count badge (top, below nav)
          Positioned(
            top: 56,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InlineLiveButton(theme: theme),
                const SizedBox(width: 8),
                _RadarCountBadge(count: hiddenCount, theme: theme, state: state),
              ],
            ),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BottomControlStrip(theme: theme, state: state),
                const SizedBox(height: 6),
                _ActionBar(theme: theme),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      );
    }

    // Live mode: radar-first, wave button + count badge top, controls at bottom
    final encounterCount = _filteredEncounters(state).length;
    return Stack(
      children: [
        // Radar fills the entire area (behind everything)
        Positioned.fill(
          child: _RadarArea(theme: theme),
        ),
        // Layered UI on top
        Column(
          children: [
            const SizedBox(height: 52), // status bar + transparent nav
            // Wave button + count badge row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WaveButton(theme: theme),
                  const SizedBox(width: 8),
                  _RadarCountBadge(count: encounterCount, theme: theme, state: state),
                ],
              ),
            ),
            const Spacer(),
            // Encounter card row (transparent background)
            _EncounterCardRow(theme: theme, transparent: true),
            // Slider + filter + settings — just above bottom nav
            _BottomControlStrip(theme: theme, state: state),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }
}

// ─── Bottom Control Strip ───────────────────────────────────────────

/// Bottom control strip: range slider + filter + settings in one row.
/// In live mode: left shows timer + stop icon. In hidden mode: left shows radar + range label.
/// Slider shows distance as a value indicator label above the thumb.
class _BottomControlStrip extends StatelessWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _BottomControlStrip({required this.theme, required this.state});

  @override
  Widget build(BuildContext context) {
    final rangeLabel = _formatRange(state.yoyoRange);
    final isLive = state.yoyoLiveActive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 4, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Left: timer+stop in live mode, radar+label in hidden mode
            if (isLive)
              _LiveTimerChip(theme: theme, state: state)
            else ...[
              const SizedBox(width: 4),
              Icon(Icons.radar_rounded, size: 14, color: theme.secondary),
              const SizedBox(width: 4),
              Text(
                rangeLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.secondary),
              ),
            ],
            // Slider with value indicator showing distance
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: theme.primary,
                  thumbColor: theme.primary,
                  inactiveTrackColor: theme.textTertiary.withValues(alpha: 0.15),
                  trackHeight: 2,
                  thumbShape: const _StopButtonThumbShape(),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  valueIndicatorColor: theme.primary,
                  valueIndicatorTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                  showValueIndicator: ShowValueIndicator.onDrag,
                ),
                child: Slider(
                  min: 0,
                  max: 1,
                  value: _kmToLogSlider(state.yoyoRange),
                  label: rangeLabel,
                  onChanged: (t) => state.onYoyoRangeChanged(_logSliderToKm(t)),
                ),
              ),
            ),
            // Filter button (inline)
            Semantics(
              identifier: ScreensIds.yoyoNearbyFilter,
              button: true,
              label: 'Filter',
              child: ProtoPressButton(
                onTap: () => state.push(ProtoRoutes.yoyoFilters),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (state.yoyoFriendsOnly ||
                            state.yoyoSelectedInterests.isNotEmpty)
                        ? theme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    theme.icons.tune,
                    size: 14,
                    color: (state.yoyoFriendsOnly ||
                            state.yoyoSelectedInterests.isNotEmpty)
                        ? theme.primary
                        : theme.textTertiary,
                  ),
                ),
              ),
            ),
            // Settings button (inline)
            ProtoPressButton(
              onTap: () => state.push(ProtoRoutes.yoyoSettings),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(theme.icons.settings, size: 14, color: theme.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live timer chip with stop icon — shows countdown or "LIVE" for Always mode.
/// Tapping stops the live session.
class _LiveTimerChip extends StatefulWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _LiveTimerChip({required this.theme, required this.state});

  @override
  State<_LiveTimerChip> createState() => _LiveTimerChipState();
}

class _LiveTimerChipState extends State<_LiveTimerChip> {
  static const _durations = [-1, 15 * 60, 30 * 60, 60 * 60, 2 * 60 * 60, 4 * 60 * 60, 8 * 60 * 60, 12 * 60 * 60, 24 * 60 * 60];
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final idx = widget.state.yoyoLiveDuration;
    if (idx >= 0 && idx < _durations.length && _durations[idx] > 0) {
      _secondsRemaining = _durations[idx];
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          widget.state.onYoyoLiveToggle();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}m';
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isAlways = widget.state.yoyoLiveDuration == 0;

    return ProtoPressButton(
      onTap: () {
        _timer?.cancel();
        widget.state.onYoyoLiveToggle();
        ProtoToast.show(context, Icons.visibility_off_rounded, 'Back to hidden');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stop icon (filled square)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 4),
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
}

// ─── Wave Button (live mode — small centered button under nav) ──────

class _WaveButton extends StatelessWidget {
  final ProtoTheme theme;
  const _WaveButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final encounterCount = _filteredEncounters(state).length;

    return ProtoPressButton(
      onTap: () {
        ProtoToast.show(context, theme.icons.wavingHand, 'Waved to $encounterCount people nearby!');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(theme.icons.wavingHand, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            const Text('Wave All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ─── Radar Count Badge (floating, used near wave/hidden pill) ────────

class _RadarCountBadge extends StatelessWidget {
  final int count;
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  final bool isFullscreen;
  const _RadarCountBadge({required this.count, required this.theme, required this.state, this.isFullscreen = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors_rounded, size: 14, color: theme.secondary),
          const SizedBox(width: 5),
          Text(
            '$count nearby',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
          ),
          const SizedBox(width: 4),
          ProtoPressButton(
            onTap: state.onRadarFullscreenToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFullscreen ? Icons.close_fullscreen_rounded : Icons.open_in_full_rounded,
                size: 11,
                color: theme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full-Screen Radar View ─────────────────────────────────────────

class _FullscreenRadarView extends StatefulWidget {
  final ProtoTheme theme;
  const _FullscreenRadarView({required this.theme});

  @override
  State<_FullscreenRadarView> createState() => _FullscreenRadarViewState();
}

class _FullscreenRadarViewState extends State<_FullscreenRadarView> {
  double _chromeOpacity = 1.0;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _resetFadeTimer();
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  void _resetFadeTimer() {
    setState(() => _chromeOpacity = 1.0);
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _chromeOpacity = 0.2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = widget.theme;
    final encounterCount = _filteredEncounters(state).length;

    return GestureDetector(
      onTap: _resetFadeTimer,
      onPanStart: (_) => _resetFadeTimer(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Full-screen radar
          Positioned.fill(
            child: GestureDetector(
              onDoubleTap: state.onRadarFullscreenToggle,
              child: state.yoyoLiveActive
                  ? _RadarArea(theme: theme)
                  : _HiddenRadarArea(theme: theme),
            ),
          ),

          // Floating minimize button (top-right, fades)
          Positioned(
            top: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _chromeOpacity,
              duration: const Duration(seconds: 2),
              child: _FloatingMinimizeButton(theme: theme),
            ),
          ),

          // Wave button + count badge (just above slider, fades)
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _chromeOpacity,
              duration: const Duration(seconds: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.yoyoLiveActive)
                    _WaveButton(theme: theme),
                  if (state.yoyoLiveActive)
                    const SizedBox(width: 8),
                  _RadarCountBadge(count: encounterCount, theme: theme, state: state, isFullscreen: true),
                ],
              ),
            ),
          ),

          // Minimal floating range slider (bottom)
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: _FloatingRangeSlider(theme: theme, state: state),
          ),

          // Bottom edge swipe zone
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomEdgeSwipeZone(
              onExit: state.onRadarFullscreenToggle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Minimize Button ───────────────────────────────────────

class _FloatingMinimizeButton extends StatefulWidget {
  final ProtoTheme theme;
  const _FloatingMinimizeButton({required this.theme});

  @override
  State<_FloatingMinimizeButton> createState() => _FloatingMinimizeButtonState();
}

class _FloatingMinimizeButtonState extends State<_FloatingMinimizeButton> {
  double _opacity = 0.7;
  Timer? _fadeTimer;

  void _resetFadeTimer() {
    setState(() => _opacity = 0.7);
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _opacity = 0.3);
    });
  }

  @override
  void initState() {
    super.initState();
    _resetFadeTimer();
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    return GestureDetector(
      onTap: () {
        state.onRadarFullscreenToggle();
      },
      onTapDown: (_) => _resetFadeTimer(),
      child: Semantics(
        label: 'Exit full screen',
        button: true,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.theme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.close_fullscreen_rounded,
              size: 20,
              color: widget.theme.text,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Floating Range Slider (fullscreen mode) ────────────────────────

class _FloatingRangeSlider extends StatelessWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _FloatingRangeSlider({required this.theme, required this.state});

  @override
  Widget build(BuildContext context) {
    // Material ancestor required for Slider gesture handling
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.radar_rounded, size: 14, color: theme.secondary),
            const SizedBox(width: 6),
            Text(
              _formatRange(state.yoyoRange),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.secondary),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: theme.primary,
                  thumbColor: theme.primary,
                  inactiveTrackColor: theme.textTertiary.withValues(alpha: 0.15),
                  trackHeight: 2,
                  thumbShape: const _StopButtonThumbShape(),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  min: 0,
                  max: 1,
                  value: _kmToLogSlider(state.yoyoRange),
                  onChanged: (t) => state.onYoyoRangeChanged(_logSliderToKm(t)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Edge Swipe Zone ─────────────────────────────────────────

class _BottomEdgeSwipeZone extends StatelessWidget {
  final VoidCallback onExit;
  const _BottomEdgeSwipeZone({required this.onExit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Swipe up with velocity exits fullscreen
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          onExit();
        }
      },
      child: Container(
        height: 40,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Radar Area ─────────────────────────────────────────────────────

class _RadarArea extends StatelessWidget {
  final ProtoTheme theme;
  const _RadarArea({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final encounters = _filteredEncounters(state);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w / 2;
        final cy = h * 0.46;
        final maxRadius = min(w, h) * 0.45;

        final positions = _generatePositions(encounters, cx, cy, maxRadius);

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
                    ..._buildRangeRings(cx, cy, maxRadius, theme, state.yoyoRange),

                    // "You" marker
                    Positioned(
                      left: cx - 29,
                      top: cy - 29,
                      child: Column(
                        children: [
                          _YouAvatar(
                            size: 52,
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

                    // Encounter markers — scale with range
                    for (int i = 0; i < encounters.length && i < positions.length; i++)
                      Positioned(
                        left: positions[i].dx - 35 * _markerScale(state.yoyoRange),
                        top: positions[i].dy - 35 * _markerScale(state.yoyoRange),
                        child: Transform.scale(
                          scale: _markerScale(state.yoyoRange),
                          child: ProtoPressButton(
                            onTap: () {
                              if (encounters[i].consentStatus == ConsentStatus.shared) {
                                state.push(ProtoRoutes.yoyoProfile);
                              } else {
                                _showConsentSheet(context, encounters[i]);
                              }
                            },
                            child: _AreaMarker(encounter: encounters[i], theme: theme),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Count badge moved to _AreaView (top, near wave button)
          ],
        );
      },
    );
  }

  static List<Offset> _generatePositions(
    List<DemoEncounter> encounters, double cx, double cy, double maxRadius,
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

  static List<Widget> _buildRangeRings(
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

// ─── Hidden Radar Area (anonymous markers with friend badges) ───────

class _HiddenRadarArea extends StatelessWidget {
  final ProtoTheme theme;
  const _HiddenRadarArea({required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final encounters = _filteredEncounters(state);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w / 2;
        final cy = h * 0.46;
        final maxRadius = min(w, h) * 0.45;

        final positions = _RadarArea._generatePositions(encounters, cx, cy, maxRadius);

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
                    ..._RadarArea._buildRangeRings(cx, cy, maxRadius, theme, state.yoyoRange),

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
                                child: _YouAvatar(
                                  size: 52,
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

                    // Anonymous markers — scale with range, friends get star badge
                    for (int i = 0; i < encounters.length && i < positions.length; i++)
                      Positioned(
                        left: positions[i].dx - 35 * _markerScale(state.yoyoRange),
                        top: positions[i].dy - 35 * _markerScale(state.yoyoRange),
                        child: Transform.scale(
                          scale: _markerScale(state.yoyoRange),
                          child: _AnonymousMarker(
                            size: 30.0 + (i % 3) * 10.0,
                            theme: theme,
                            isFriend: encounters[i].relationship == RelationshipType.friend
                                || encounters[i].relationship == RelationshipType.partner
                                || encounters[i].relationship == RelationshipType.family,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Count badge moved to _AreaView (top, near hidden pill)
          ],
        );
      },
    );
  }
}

// ─── Anonymous Marker (friend-aware) ────────────────────────────────

class _AnonymousMarker extends StatelessWidget {
  final double size;
  final ProtoTheme theme;
  final bool isFriend;

  const _AnonymousMarker({
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

// ─── Area Marker ────────────────────────────────────────────────────

class _AreaMarker extends StatelessWidget {
  final DemoEncounter encounter;
  final ProtoTheme theme;
  const _AreaMarker({required this.encounter, required this.theme});

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

// ─── Encounter Card Carousel ────────────────────────────────────────

class _EncounterCardRow extends StatelessWidget {
  final ProtoTheme theme;
  final bool transparent;
  const _EncounterCardRow({required this.theme, this.transparent = false});

  /// Sort priority: partner > friend/family > stranger
  static int _relationshipPriority(RelationshipType r) {
    switch (r) {
      case RelationshipType.partner: return 0;
      case RelationshipType.friend: return 1;
      case RelationshipType.family: return 1;
      case RelationshipType.stranger: return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final encounters = _filteredEncounters(state);
    // Sort: love interests first, then friends/family, then strangers
    final sorted = List<DemoEncounter>.from(encounters)
      ..sort((a, b) => _relationshipPriority(a.relationship).compareTo(_relationshipPriority(b.relationship)));

    return SizedBox(
      height: 100,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final enc = sorted[index];
            final isRevealed = enc.consentStatus == ConsentStatus.shared;
            final displayName = isRevealed ? enc.name : 'User';
            final distanceLabel = _distanceCategoryLabel(enc.distanceCategory);

            return Semantics(
              identifier: ScreensIds.yoyoNearbyCard(index),
              button: true,
              label: '$displayName, $distanceLabel',
              child: ProtoPressButton(
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
                    color: theme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        identifier: ScreensIds.yoyoNearbyAvatar(index),
                        image: true,
                        label: '$displayName avatar',
                        child: isRevealed
                            ? _OrganicAvatar(size: 40, imageUrl: enc.imageUrl)
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.textTertiary
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person_rounded,
                                    size: 22,
                                    color: theme.textTertiary
                                        .withValues(alpha: 0.5)),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayName,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        distanceLabel,
                        style: TextStyle(
                            fontSize: 9, color: theme.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Action Bar ─────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final ProtoTheme theme;
  const _ActionBar({required this.theme});

  static const _durationLabels = ['Always', '15m', '30m', '1h', '2h', '4h', '8h', '12h', '24h'];

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
    final encounterCount = _filteredEncounters(state).length;

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

  /// Hidden mode — scrollable duration chips + "Go Live" button.
  Widget _buildHiddenBar(BuildContext context, PrototypeStateProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontally scrollable duration chips
          SizedBox(
            height: 32,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
            ),
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
                  label == 'Always' ? 'You\'re now live' : 'Live for $label',
                );
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.primary, theme.secondary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sensors_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Go Live', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
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
  const _YoyoListView();

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
  const _YoyoAreaView();

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);
    final isLive = state.yoyoLiveActive;

    return Column(
      children: [
        // Control bar with inline live status replacing the old eye icon
        _LegacyRadarControlBar(theme: theme, state: state),
        // Radar area (anonymous circles when hidden, real markers when live)
        Expanded(child: _LegacyRadarArea(theme: theme)),
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
class _LegacyRadarControlBar extends StatelessWidget {
  final ProtoTheme theme;
  final PrototypeStateProvider state;
  const _LegacyRadarControlBar({required this.theme, required this.state});

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

class _LegacyRadarArea extends StatelessWidget {
  final ProtoTheme theme;
  const _LegacyRadarArea({required this.theme});

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
                                child: _YouAvatar(
                                  size: 52,
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
                            : _LegacyAnonymousMarker(
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

  static const _durations = [-1, 15 * 60, 30 * 60, 60 * 60, 2 * 60 * 60, 4 * 60 * 60, 8 * 60 * 60, 12 * 60 * 60, 24 * 60 * 60];
  static const _labels = ['Always', '15m', '30m', '1h', '2h', '4h', '8h', '12h', '24h'];

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
    final isAlways = state.yoyoLiveDuration == 0; // index 0 = "Always"

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

class _LegacyAnonymousMarker extends StatelessWidget {
  final double size;
  final ProtoTheme theme;

  const _LegacyAnonymousMarker({required this.size, required this.theme});

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

  static const _durationLabels = ['Always', '15m', '30m', '1h', '2h', '4h', '8h', '12h', '24h'];

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
          // Duration chips — horizontally scrollable
          SizedBox(
            height: 32,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
            ),
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
                  label == 'Always' ? 'You\'re now live' : 'Live for $label',
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

  static const _durations = [-1, 15 * 60, 30 * 60, 60 * 60, 2 * 60 * 60, 4 * 60 * 60, 8 * 60 * 60, 12 * 60 * 60, 24 * 60 * 60]; // -1 = Always

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
