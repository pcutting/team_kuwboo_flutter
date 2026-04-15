import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'dating_providers.dart';

/// Active mutual matches — backed by `GET /dating/matches` via
/// [datingMatchesProvider]. The backend shape is stubbed (`{matches: []}`)
/// so we render raw map fields defensively until the full dating SOW
/// lands the typed response.
class DatingMatchesList extends ConsumerWidget {
  const DatingMatchesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);
    final async = ref.watch(datingMatchesProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => ProtoEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load matches',
        subtitle: err.toString(),
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(datingMatchesProvider),
      ),
      data: (matches) {
        if (matches.isEmpty) {
          return const ProtoEmptyState(
            icon: Icons.favorite_outline_rounded,
            title: 'No matches yet',
            subtitle: 'Keep swiping to find your people',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final m = matches[i];
            final name = (m['name'] as String?) ?? 'Match';
            final avatar = m['avatarUrl'] as String?;
            final preview = m['lastMessage'] as String?;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: theme.cardDecoration,
              child: Row(
                children: [
                  ProtoAvatar(radius: 24, imageUrl: avatar ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.title.copyWith(fontSize: 14),
                        ),
                        if (preview != null)
                          Text(
                            preview,
                            style: theme.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
