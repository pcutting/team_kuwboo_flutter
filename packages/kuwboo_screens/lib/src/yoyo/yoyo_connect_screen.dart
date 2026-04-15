import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart' as api;
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'yoyo_providers.dart';

/// Pending connections — list of sent/received connection requests
/// with functional filter chips, accept/reject animations,
/// encounter context badges and mutual interest highlights.
class YoyoConnectScreen extends ConsumerStatefulWidget {
  const YoyoConnectScreen({super.key});

  @override
  ConsumerState<YoyoConnectScreen> createState() => _YoyoConnectScreenState();
}

class _YoyoConnectScreenState extends ConsumerState<YoyoConnectScreen> {
  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('Connect', style: theme.headline.copyWith(fontSize: 24)),
              ],
            ),
          ),
          // Tab filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (final label in ['All', 'Received', 'Sent']) ...[
                  if (label != 'All') const SizedBox(width: 8),
                  ProtoPressButton(
                    duration: const Duration(milliseconds: 100),
                    onTap: () => state.onYoyoConnectFilterChanged(label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.yoyoConnectFilter == label ? theme.primary : theme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: state.yoyoConnectFilter == label
                            ? null
                            : Border.all(color: theme.text.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: state.yoyoConnectFilter == label ? Colors.white : theme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _buildConnectList(context, theme, state),
          ),
        ],
      );
  }

  Widget _buildConnectList(BuildContext context, ProtoTheme theme, PrototypeStateProvider state) {
    final nearbyAsync = ref.watch(yoyoNearbyProvider);
    return nearbyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load nearby users: $e', style: theme.body),
        ),
      ),
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Text('No nearby users', style: theme.caption),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u = users[i];
            return _NearbyConnectRow(user: u);
          },
        );
      },
    );
  }
}

class _NearbyConnectRow extends ConsumerWidget {
  final api.NearbyUser user;
  const _NearbyConnectRow({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);
    final distanceKm = (user.distanceMeters / 1000).toStringAsFixed(1);
    return ProtoPressButton(
      duration: const Duration(milliseconds: 100),
      onTap: () => state.push(ProtoRoutes.yoyoProfile),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: theme.cardDecoration,
        child: Row(
          children: [
            ProtoAvatar(
              radius: 22,
              imageUrl: user.avatarUrl ??
                  'https://i.pravatar.cc/100?u=${user.id}',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: theme.title.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('$distanceKm km away', style: theme.caption),
                  if (user.onlineStatus != null) ...[
                    const SizedBox(height: 2),
                    Text(user.onlineStatus!, style: theme.caption.copyWith(fontSize: 10)),
                  ],
                ],
              ),
            ),
            ProtoPressButton(
              onTap: () async {
                try {
                  await ref
                      .read(yoyoApiProvider)
                      .sendWave(toUserId: user.id);
                  ref.invalidate(yoyoSentWavesProvider);
                  if (!context.mounted) return;
                  ProtoToast.show(context, theme.icons.wavingHand,
                      'Waved at ${user.name}');
                } catch (e) {
                  if (!context.mounted) return;
                  ProtoToast.show(context, theme.icons.close,
                      'Failed to wave');
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(theme.icons.wavingHand,
                    size: 18, color: theme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
