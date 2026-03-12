import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import 'yoyo_shared.dart';
import 'inner_circle_wave.dart';

/// Broadcast wave — wave confirmation + recent waves list.
/// V2 adds quick/full wave types, session context, reach indicator.
class YoyoWaveScreen extends StatefulWidget {
  const YoyoWaveScreen({super.key});

  static const _recentWaves = [
    _WaveData('Maya', '2m ago', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', true),
    _WaveData('Jordan', '15m ago', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', false),
    _WaveData('Sam', '1h ago', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', true),
    _WaveData('Riley', '3h ago', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', false),
  ];

  @override
  State<YoyoWaveScreen> createState() => _YoyoWaveScreenState();
}

class _YoyoWaveScreenState extends State<YoyoWaveScreen> {
  ValueNotifier<int>? _variantCount;
  ValueNotifier<int>? _variantIndex;
  bool _waveSent = false;
  final Set<int> _wavedBackIndices = {};
  int _v2WaveType = 0; // 0 = Quick Wave, 1 = Full Wave

  void _handleSendWave() {
    setState(() => _waveSent = true);
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, theme.icons.wavingHand, 'Wave sent to nearby users!');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _waveSent = false);
    });
  }

  void _handleWaveBack(int index, String name) {
    setState(() => _wavedBackIndices.add(index));
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, theme.icons.wavingHand, 'Waved back at $name!');
  }

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
    final theme = ProtoTheme.of(context);
    if (_variantIndex != null && _variantIndex!.value != state.yoyoVariant) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _variantIndex!.value = state.yoyoVariant;
      });
    }

    if (state.yoyoMode == 1) {
      return const InnerCircleWaveView();
    }

    return ProtoScaffold(
      activeModule: ProtoModule.yoyo,
      activeTab: 2,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Wave', style: theme.headline.copyWith(fontSize: 24)),
              const SizedBox(width: 8),
              if (state.yoyoVariant == 1) yoyoV2Badge(theme),
            ],
          ),
          const SizedBox(height: 8),
          Text('Broadcast your presence to nearby users', style: theme.body.copyWith(color: theme.textSecondary)),

          // V2: Wave type selector + session context
          if (state.yoyoVariant == 1) ...[
            const SizedBox(height: 12),
            // Session context badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: state.yoyoV2SessionActive
                    ? theme.secondary.withValues(alpha: 0.1)
                    : theme.textTertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    state.yoyoV2SessionActive ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                    size: 16,
                    color: state.yoyoV2SessionActive ? theme.secondary : theme.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.yoyoV2SessionActive ? 'Session active' : 'No active session',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: state.yoyoV2SessionActive ? theme.secondary : theme.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Wave type tabs
            Container(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.textTertiary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  for (int t = 0; t < 2; t++)
                    Expanded(
                      child: ProtoPressButton(
                        onTap: () => setState(() => _v2WaveType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _v2WaveType == t ? theme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                t == 0 ? Icons.flash_on_rounded : Icons.pin_drop_rounded,
                                size: 18,
                                color: _v2WaveType == t ? Colors.white : theme.textSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t == 0 ? 'Quick Wave' : 'Full Wave',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _v2WaveType == t ? Colors.white : theme.textSecondary),
                              ),
                              Text(
                                t == 0 ? 'Pass-by, no reveal' : 'Nearby, invites connect',
                                style: TextStyle(fontSize: 9, color: _v2WaveType == t ? Colors.white.withValues(alpha: 0.8) : theme.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Reach indicator
            Center(
              child: Text(
                _v2WaveType == 0 ? 'Reaches ~12 users passing by' : 'Reaches ~5 users within 500m',
                style: theme.caption.copyWith(color: theme.textSecondary),
              ),
            ),
          ],
          SizedBox(height: state.yoyoVariant == 1 ? 12.0 : 20.0),

          // Wave action card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(theme.icons.wavingHand, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Wave to Nearby',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Let people within 5km know you\'re here',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 16),
                ProtoPressButton(
                  onTap: _waveSent ? null : _handleSendWave,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _waveSent ? theme.secondary : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _waveSent
                          ? Row(
                              key: const ValueKey('sent'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(theme.icons.check, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                const Text('Sent!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            )
                          : Text(
                              'Send Wave',
                              key: const ValueKey('send'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.primary),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Recent Waves', style: theme.title),
          const SizedBox(height: 10),

          if (state.yoyoVariant == 1)
            // V2 waves with encounter context
            for (int i = 0; i < ProtoDemoData.v2Waves.length; i++) ...[
              Builder(builder: (context) {
                final wave = ProtoDemoData.v2Waves[i];
                final hasWavedBack = _wavedBackIndices.contains(i);
                return ProtoPressButton(
                  duration: const Duration(milliseconds: 100),
                  onTap: () => state.push(ProtoRoutes.yoyoProfile),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: theme.cardDecoration,
                    child: Row(
                      children: [
                        ProtoAvatar(radius: 20, imageUrl: wave.imageUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(wave.name, style: theme.title.copyWith(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Icon(
                                    wave.encounterType == EncounterType.passby ? Icons.flash_on_rounded : Icons.pin_drop_rounded,
                                    size: 12,
                                    color: wave.encounterType == EncounterType.passby ? Colors.amber.shade700 : theme.secondary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasWavedBack
                                    ? 'You waved back!'
                                    : wave.isIncoming ? 'Waved at you (${wave.encounterType == EncounterType.passby ? "pass-by" : "nearby"})' : 'You waved',
                                style: theme.caption.copyWith(
                                  color: hasWavedBack ? theme.secondary : null,
                                  fontWeight: hasWavedBack ? FontWeight.w600 : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(wave.timeAgo, style: theme.caption),
                        const SizedBox(width: 8),
                        if (wave.isIncoming && !hasWavedBack)
                          ProtoPressButton(
                            onTap: () => _handleWaveBack(i, wave.name),
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Icon(theme.icons.wavingHand, size: 16, color: theme.primary),
                            ),
                          )
                        else
                          Icon(theme.icons.check, size: 18, color: hasWavedBack ? theme.secondary : theme.textTertiary),
                      ],
                    ),
                  ),
                );
              }),
            ]
          else
            // V1 waves
            for (int i = 0; i < YoyoWaveScreen._recentWaves.length; i++) ...[
              Builder(builder: (context) {
                final wave = YoyoWaveScreen._recentWaves[i];
                final hasWavedBack = _wavedBackIndices.contains(i);
                return ProtoPressButton(
                  duration: const Duration(milliseconds: 100),
                  onTap: () => state.push(ProtoRoutes.yoyoProfile),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: theme.cardDecoration,
                    child: Row(
                      children: [
                        ProtoAvatar(radius: 20, imageUrl: wave.imageUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(wave.name, style: theme.title.copyWith(fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(
                                hasWavedBack
                                    ? 'You waved back!'
                                    : wave.isIncoming ? 'Waved at you' : 'You waved',
                                style: theme.caption.copyWith(
                                  color: hasWavedBack ? theme.secondary : null,
                                  fontWeight: hasWavedBack ? FontWeight.w600 : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(wave.timeAgo, style: theme.caption),
                        const SizedBox(width: 8),
                        if (wave.isIncoming && !hasWavedBack)
                          ProtoPressButton(
                            onTap: () => _handleWaveBack(i, wave.name),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(theme.icons.wavingHand, size: 16, color: theme.primary),
                            ),
                          )
                        else
                          Icon(
                            theme.icons.check,
                            size: 18,
                            color: hasWavedBack ? theme.secondary : theme.textTertiary,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
        ],
      ),
    );
  }
}

class _WaveData {
  final String name;
  final String timeAgo;
  final String imageUrl;
  final bool isIncoming;
  const _WaveData(this.name, this.timeAgo, this.imageUrl, this.isIncoming);
}
