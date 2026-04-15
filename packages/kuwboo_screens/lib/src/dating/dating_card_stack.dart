import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'dating_match_overlay.dart';
import 'dating_providers.dart';

/// Swipe stack for the dating module. Backed by `GET /dating/discover`
/// via [datingCardsProvider]; the backend also enforces `DatingAgeGuard`,
/// so a 403 here signals an onboarding gap (no DOB / under 18) and the
/// UI shows the empty-state rather than retrying.
class DatingCardStack extends ConsumerStatefulWidget {
  const DatingCardStack({super.key});

  @override
  ConsumerState<DatingCardStack> createState() => _DatingCardStackState();
}

class _DatingCardStackState extends ConsumerState<DatingCardStack> {
  int _index = 0;
  bool _acting = false;

  Future<void> _like(Content card) async {
    if (_acting) return;
    setState(() => _acting = true);
    try {
      final interactions = ref.read(datingInteractionsApiProvider);
      final res = await interactions.likeContent(card.id);
      if (res.liked && mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => DatingMatchOverlay(match: card),
        );
      }
    } finally {
      if (mounted) setState(() => _acting = false);
      _advance();
    }
  }

  void _skip() => _advance();

  void _advance() {
    if (!mounted) return;
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final async = ref.watch(datingCardsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => ProtoEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load matches',
        subtitle: err.toString(),
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(datingCardsProvider),
      ),
      data: (page) {
        final items = page.items;
        if (items.isEmpty || _index >= items.length) {
          return const ProtoEmptyState(
            icon: Icons.favorite_outline_rounded,
            title: 'No one new nearby',
            subtitle: 'Check back later for fresh profiles',
          );
        }
        final current = items[_index];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: _card(context, theme, current)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleAction(
                    icon: Icons.close_rounded,
                    color: theme.textSecondary,
                    onTap: _acting ? null : _skip,
                  ),
                  _circleAction(
                    icon: Icons.favorite_rounded,
                    color: theme.primary,
                    onTap: _acting ? null : () => _like(current),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, ProtoTheme theme, Content card) {
    final creator = card.creator;
    return Container(
      decoration: theme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (card.thumbnailUrl != null)
            ProtoNetworkImage(imageUrl: card.thumbnailUrl!, fit: BoxFit.cover)
          else if (creator?.avatarUrl != null)
            ProtoNetworkImage(imageUrl: creator!.avatarUrl!, fit: BoxFit.cover)
          else
            Container(color: theme.surface),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator?.name ?? 'Someone',
                  style: theme.title.copyWith(color: Colors.white),
                ),
                if (card.caption != null)
                  Text(
                    card.caption!,
                    style: theme.body.copyWith(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAction({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return ProtoPressButton(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: const [
            BoxShadow(blurRadius: 8, color: Colors.black12),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
