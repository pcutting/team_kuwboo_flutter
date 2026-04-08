import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../../providers/yoyo_provider.dart';

/// Main YoYo tab screen showing nearby users within proximity.
class YoyoNearbyScreen extends ConsumerWidget {
  const YoyoNearbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('YoYo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.waves),
            tooltip: 'Waves',
            onPressed: () => context.push('/yoyo/waves'),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Settings',
            onPressed: () => context.push('/yoyo/settings'),
          ),
        ],
      ),
      body: nearbyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48),
              const SizedBox(height: 16),
              Text(
                'Could not load nearby users',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(nearbyUsersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (users) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(nearbyUsersProvider),
          child: users.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.explore_outlined, size: 64),
                          SizedBox(height: 16),
                          Text('No one nearby right now'),
                          SizedBox(height: 8),
                          Text('Pull down to refresh'),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) => _NearbyUserTile(
                    user: users[index],
                  ),
                ),
        ),
      ),
    );
  }
}

class _NearbyUserTile extends StatelessWidget {
  const _NearbyUserTile({required this.user});

  final NearbyUser user;

  Color? _statusColor(String? status) {
    switch (status) {
      case 'ONLINE':
        return Colors.green;
      case 'AWAY':
        return Colors.orange;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: theme.textTheme.titleMedium,
                  )
                : null,
          ),
          if (_statusColor(user.onlineStatus) != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _statusColor(user.onlineStatus),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(user.name),
      subtitle: Text('${user.distanceKm.toStringAsFixed(1)} km away'),
      trailing: FilledButton.tonal(
        onPressed: () => _showProfileSheet(context),
        child: const Text('Wave'),
      ),
      onTap: () => _showProfileSheet(context),
    );
  }

  void _showProfileSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${user.distanceKm.toStringAsFixed(1)} km away',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (user.onlineStatus != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _statusColor(user.onlineStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.onlineStatus!.toLowerCase(),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wave sent to ${user.name}')),
                    );
                  },
                  icon: const Icon(Icons.waves),
                  label: const Text('Send Wave'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
