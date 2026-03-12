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
import 'yoyo_shared.dart';
import 'inner_circle_nearby.dart';

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
  ValueNotifier<int>? _variantCount;
  ValueNotifier<int>? _variantIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = PrototypeStateProvider.maybeOf(context);
    if (provider != null && _variantIndex == null) {
      _variantCount = provider.screenVariantCount;
      _variantIndex = provider.screenVariantIndex;
      _variantIndex!.value = provider.yoyoVariant;
      _variantIndex!.addListener(_onExternalVariantChange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _variantCount!.value = 2;
      });
    }
  }

  void _onExternalVariantChange() {
    final idx = _variantIndex?.value ?? 0;
    final state = PrototypeStateProvider.maybeOf(context);
    if (state != null && idx != state.yoyoVariant && idx >= 0 && idx < 2) {
      state.onYoyoVariantChanged(idx);
    }
  }

  @override
  void dispose() {
    _variantIndex?.removeListener(_onExternalVariantChange);
    _variantCount?.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    // Sync floating button when global yoyoVariant changes (e.g. from tools sheet)
    if (_variantIndex != null && _variantIndex!.value != state.yoyoVariant) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _variantIndex!.value = state.yoyoVariant;
      });
    }

    // Inner Circle mode shows the map-based family view
    if (state.yoyoMode == 1) {
      return const InnerCircleNearbyView();
    }

    return ProtoScaffold(
      activeModule: ProtoModule.yoyo,
      tabBadges: const {2: 2}, // 2 unread waves on Wave tab
      body: state.yoyoVariant == 1
          ? const _YoyoV2NearbyView()
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: state.isYoyoAreaView
                  ? const _YoyoAreaView(key: ValueKey('area'))
                  : _YoyoListView(key: ValueKey('list-${state.yoyoRange}')),
            ),
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
        const _V2SessionHeader(),
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
                  const SizedBox(width: 6),
                  yoyoV2Badge(theme),
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
                    const SizedBox(width: 8),
                    yoyoV2Badge(theme),
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
        Expanded(child: _V2RadarArea(theme: theme)),
        _V2EncounterCardRow(theme: theme),
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
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 0, bottom: 0),
      child: Row(
        children: [
          // Encounter filter chips (compact)
          for (final label in ['all', 'passby', 'nearby']) ...[
            ProtoPressButton(
              onTap: () => state.onYoyoV2EncounterFilterChanged(label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: state.yoyoV2EncounterFilter == label
                      ? theme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label == 'all' ? 'All' : label == 'passby' ? 'Pass' : 'Near',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: state.yoyoV2EncounterFilter == label ? theme.primary : theme.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
          const Spacer(),
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
                    // Range rings with category labels
                    ..._buildV2RangeRings(cx, cy, maxRadius, theme),

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
    double cx, double cy, double maxRadius, ProtoTheme theme,
  ) {
    const labels = ['Very Near', 'Nearby', 'Passing'];
    const fractions = [0.33, 0.66, 1.0];

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
            labels[i],
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

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
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
}

/// Filter DemoData.nearbyUsers based on current state (range, friends, interests).
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
              '${state.yoyoRange.round()} km',
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

    return Column(
      children: [
        // Range slider + filter button + settings gear control bar
        _RadarControlBar(theme: theme, state: state),
        // Radar area
        Expanded(child: _RadarArea(theme: theme)),
        // Card carousel
        _NearbyUserCardRow(theme: theme),
        // Action bar
        _YoyoActionBar(theme: theme),
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
          // Visibility toggle
          ProtoPressButton(
            onTap: state.onYoyoHiddenToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: state.isYoyoHidden
                    ? theme.accent.withValues(alpha: 0.15)
                    : theme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.isYoyoHidden
                      ? theme.accent.withValues(alpha: 0.4)
                      : theme.textTertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                state.isYoyoHidden
                    ? theme.icons.visibilityOff
                    : theme.icons.visibilityOn,
                size: 16,
                color: state.isYoyoHidden ? theme.accent : theme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(theme.icons.radar, size: 16, color: theme.secondary),
          const SizedBox(width: 4),
          Text(
            '${state.yoyoRange.round()} km',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.secondary,
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
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
                  max: 30,
                  divisions: 29,
                  value: state.yoyoRange,
                  onChanged: state.onYoyoRangeChanged,
                ),
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

                    // Nearby user markers
                    for (int i = 0; i < users.length && i < positions.length; i++)
                      Positioned(
                        left: positions[i].dx - 44,
                        top: positions[i].dy - 44,
                        child: ProtoPressButton(
                          onTap: () => state.push(ProtoRoutes.yoyoProfile),
                          child: _AreaUserMarker(
                            user: users[i],
                            theme: theme,
                            userCount: userCount,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // People count badge + icon legend (fixed, outside InteractiveViewer)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: _RadarBadgeWithLegend(
                  theme: theme,
                  userCount: userCount,
                  rangeKm: state.yoyoRange.round(),
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
  /// Rings adapt to the selected range:
  ///   ≤5km → [1, 2, 5]   ≤10km → [2, 5, 10]   ≤30km → [5, 10, 30]
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
    } else {
      labels = [5, 10, 30];
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
    // Scale avatar larger when range is small (fewer, closer people)
    final double baseSize;
    if (state.yoyoRange <= 2) {
      baseSize = 112.0;
    } else if (state.yoyoRange <= 5) {
      baseSize = 96.0;
    } else {
      baseSize = 88.0;
    }
    // Shrink when crowded
    final avatarSize = userCount > 15 ? 64.0 : baseSize;
    final showInterests = userCount <= 8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Organic avatar
        _OrganicAvatar(
          size: avatarSize,
          imageUrl: user.imageUrl,
          borderColor: user.isOnline
              ? theme.secondary
              : theme.textTertiary.withValues(alpha: 0.3),
          borderWidth: 2,
          boxShadow: [
            if (user.isOnline)
              BoxShadow(
                color: theme.secondary.withValues(alpha: 0.25),
                blurRadius: 8,
              ),
          ],
        ),
        const SizedBox(height: 3),
        // Name + distance chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
              Text(
                user.distance,
                style: TextStyle(
                  fontSize: 14,
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

// ─── Radar badge with expandable icon legend ──────────────────────────

class _RadarBadgeWithLegend extends StatefulWidget {
  final ProtoTheme theme;
  final int userCount;
  final int rangeKm;

  const _RadarBadgeWithLegend({
    required this.theme,
    required this.userCount,
    required this.rangeKm,
  });

  @override
  State<_RadarBadgeWithLegend> createState() => _RadarBadgeWithLegendState();
}

class _RadarBadgeWithLegendState extends State<_RadarBadgeWithLegend> {
  bool _legendOpen = false;

  static const _legendItems = <String, IconData>{
    'Hiking': Icons.hiking_rounded,
    'Tech': Icons.computer_rounded,
    'Beer': Icons.sports_bar_rounded,
    'Music': Icons.music_note_rounded,
    'Design': Icons.palette_rounded,
    'Coffee': Icons.coffee_rounded,
    'Photo': Icons.camera_alt_rounded,
    'Nature': Icons.park_rounded,
    'Cooking': Icons.restaurant_rounded,
    'Wine': Icons.wine_bar_rounded,
    'Travel': Icons.flight_rounded,
    'Yoga': Icons.self_improvement_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expanded legend grid (above the badge)
        if (_legendOpen)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: _legendItems.entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(e.value, size: 10, color: theme.primary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        // Badge row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                '${widget.userCount} people within ${widget.rangeKm} km',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _legendOpen = !_legendOpen),
                child: Icon(
                  _legendOpen ? Icons.close_rounded : Icons.info_outline_rounded,
                  size: 16,
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
