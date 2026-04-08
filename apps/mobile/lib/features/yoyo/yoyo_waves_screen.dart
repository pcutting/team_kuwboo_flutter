import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../../providers/yoyo_provider.dart';

/// Screen showing incoming and sent waves with tab navigation.
class YoyoWavesScreen extends ConsumerWidget {
  const YoyoWavesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Waves'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReceivedWavesTab(),
            _SentWavesTab(),
          ],
        ),
      ),
    );
  }
}

class _ReceivedWavesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wavesAsync = ref.watch(incomingWavesProvider);

    return wavesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load waves'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => ref.invalidate(incomingWavesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (waves) => waves.isEmpty
          ? const Center(child: Text('No waves received yet'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: waves.length,
              itemBuilder: (context, index) => _WaveTile(
                wave: waves[index],
                showActions: true,
              ),
            ),
    );
  }
}

class _SentWavesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wavesAsync = ref.watch(sentWavesProvider);

    return wavesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load sent waves'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => ref.invalidate(sentWavesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (waves) => waves.isEmpty
          ? const Center(child: Text('No waves sent yet'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: waves.length,
              itemBuilder: (context, index) => _WaveTile(
                wave: waves[index],
                showActions: false,
              ),
            ),
    );
  }
}

class _WaveTile extends StatelessWidget {
  const _WaveTile({required this.wave, required this.showActions});

  final Wave wave;
  final bool showActions;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: wave.fromUserAvatar != null
            ? NetworkImage(wave.fromUserAvatar!)
            : null,
        child: wave.fromUserAvatar == null
            ? Text(
                (wave.fromUserName ?? '?')[0].toUpperCase(),
                style: theme.textTheme.titleMedium,
              )
            : null,
      ),
      title: Text(wave.fromUserName ?? 'Unknown'),
      subtitle: Text(
        '${wave.message ?? 'Waved at you'} \u00b7 ${_timeAgo(wave.createdAt)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: showActions && wave.status == 'PENDING'
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.green,
                  tooltip: 'Accept',
                  onPressed: () {
                    // Accept wave → navigate to chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Connected with ${wave.fromUserName ?? ""}'),
                      ),
                    );
                    context.push('/chat/${wave.fromUserId}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  color: theme.colorScheme.error,
                  tooltip: 'Decline',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wave declined')),
                    );
                  },
                ),
              ],
            )
          : Text(
              _statusLabel(wave.status),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _statusColor(wave.status, theme),
              ),
            ),
      isThreeLine: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACCEPTED':
        return 'Accepted';
      case 'DECLINED':
        return 'Declined';
      case 'PENDING':
        return 'Pending';
      default:
        return status;
    }
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status) {
      case 'ACCEPTED':
        return Colors.green;
      case 'DECLINED':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}
