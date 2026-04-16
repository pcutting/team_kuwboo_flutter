import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart' as api;
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../screens_test_ids.dart';
import 'yoyo_providers.dart';

/// Broadcast wave — wave confirmation + recent waves list
/// with quick/full wave types, session context, reach indicator.
class YoyoWaveScreen extends ConsumerStatefulWidget {
  const YoyoWaveScreen({super.key});

  @override
  ConsumerState<YoyoWaveScreen> createState() => _YoyoWaveScreenState();
}

class _YoyoWaveScreenState extends ConsumerState<YoyoWaveScreen> {
  bool _waveSent = false;
  final Set<String> _respondedWaveIds = {};
  int _waveType = 0; // 0 = Quick Wave, 1 = Full Wave

  Future<void> _handleSendWave() async {
    setState(() => _waveSent = true);
    final theme = ProtoTheme.of(context);
    // Fire-and-forget wave to the first nearby user (prototype behaviour —
    // real "wave all" semantics are a backend RPC we don't yet have).
    final nearby = ref.read(yoyoNearbyProvider).valueOrNull ?? const [];
    if (nearby.isNotEmpty) {
      try {
        await ref.read(yoyoApiProvider).sendWave(toUserId: nearby.first.id);
        ref.invalidate(yoyoSentWavesProvider);
      } catch (_) {/* swallow */}
    }
    if (!mounted) return;
    ProtoToast.show(context, theme.icons.wavingHand, 'Wave sent to nearby users!');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _waveSent = false);
    });
  }

  Future<void> _handleWaveBack(api.Wave wave) async {
    setState(() => _respondedWaveIds.add(wave.id));
    final theme = ProtoTheme.of(context);
    try {
      await ref.read(yoyoApiProvider).respondToWave(
            waveId: wave.id,
            accept: true,
          );
      ref.invalidate(yoyoIncomingWavesProvider);
    } catch (_) {/* swallow */}
    if (!mounted) return;
    ProtoToast.show(
      context,
      theme.icons.wavingHand,
      'Waved back at ${wave.fromUserName ?? 'user'}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Wave', style: theme.headline.copyWith(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Broadcast your presence to nearby users', style: theme.body.copyWith(color: theme.textSecondary)),

          // Wave type selector + session context
          const SizedBox(height: 12),
          // Session context badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: state.yoyoSessionActive
                    ? theme.secondary.withValues(alpha: 0.1)
                    : theme.textTertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    state.yoyoSessionActive ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                    size: 16,
                    color: state.yoyoSessionActive ? theme.secondary : theme.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.yoyoSessionActive ? 'Session active' : 'No active session',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: state.yoyoSessionActive ? theme.secondary : theme.textTertiary),
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
                        onTap: () => setState(() => _waveType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _waveType == t ? theme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                t == 0 ? Icons.flash_on_rounded : Icons.pin_drop_rounded,
                                size: 18,
                                color: _waveType == t ? Colors.white : theme.textSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t == 0 ? 'Quick Wave' : 'Full Wave',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _waveType == t ? Colors.white : theme.textSecondary),
                              ),
                              Text(
                                t == 0 ? 'Pass-by, no reveal' : 'Nearby, invites connect',
                                style: TextStyle(fontSize: 9, color: _waveType == t ? Colors.white.withValues(alpha: 0.8) : theme.textTertiary),
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
                _waveType == 0 ? 'Reaches ~12 users passing by' : 'Reaches ~5 users within 500m',
                style: theme.caption.copyWith(color: theme.textSecondary),
              ),
            ),
          const SizedBox(height: 12.0),

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
                Semantics(
                  identifier: ScreensIds.yoyoWaveSend,
                  button: true,
                  enabled: !_waveSent,
                  label: _waveSent ? 'Wave sent' : 'Send Wave',
                  child: ProtoPressButton(
                    onTap: _waveSent ? null : () => _handleSendWave(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
                                  Icon(theme.icons.check,
                                      size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  const Text('Sent!',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              )
                            : Text(
                                'Send Wave',
                                key: const ValueKey('send'),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primary),
                              ),
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

          // Live incoming waves from backend.
          _IncomingWavesList(
            onWaveBack: _handleWaveBack,
            respondedIds: _respondedWaveIds,
          ),
        ],
      );
  }
}

class _IncomingWavesList extends ConsumerWidget {
  final Future<void> Function(api.Wave) onWaveBack;
  final Set<String> respondedIds;

  const _IncomingWavesList({
    required this.onWaveBack,
    required this.respondedIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);
    final wavesAsync = ref.watch(yoyoIncomingWavesProvider);

    return wavesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to load waves: $e', style: theme.caption),
      ),
      data: (waves) {
        if (waves.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text('No recent waves', style: theme.caption),
            ),
          );
        }
        return Column(
          children: [
            for (final wave in waves)
              Builder(builder: (context) {
                final hasWavedBack = respondedIds.contains(wave.id);
                return ProtoPressButton(
                  duration: const Duration(milliseconds: 100),
                  onTap: () => state.push(ProtoRoutes.yoyoProfile),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: theme.cardDecoration,
                    child: Row(
                      children: [
                        ProtoAvatar(
                          radius: 20,
                          imageUrl: wave.fromUserAvatar ??
                              'https://i.pravatar.cc/100?u=${wave.fromUserId}',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wave.fromUserName ?? 'Someone',
                                style: theme.title.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasWavedBack
                                    ? 'You waved back!'
                                    : (wave.message ?? 'Waved at you'),
                                style: theme.caption.copyWith(
                                  color: hasWavedBack ? theme.secondary : null,
                                  fontWeight:
                                      hasWavedBack ? FontWeight.w600 : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!hasWavedBack)
                          ProtoPressButton(
                            onTap: () => onWaveBack(wave),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(theme.icons.wavingHand,
                                  size: 16, color: theme.primary),
                            ),
                          )
                        else
                          Icon(theme.icons.check,
                              size: 18, color: theme.secondary),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

