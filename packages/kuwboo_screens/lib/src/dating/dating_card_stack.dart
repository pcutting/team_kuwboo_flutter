import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../screens_test_ids.dart';
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
    final cardId = card.id;
    // Content rows without an id can't be liked — advance silently
    // rather than crash. `datingCardsProvider` does not filter these
    // upstream because dating pulls from a dedicated endpoint.
    if (cardId == null) {
      _advance();
      return;
    }
    setState(() => _acting = true);
    try {
      final interactions = ref.read(datingInteractionsApiProvider);
      final res = await interactions.likeContent(cardId);
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
      error: (err, _) => _buildErrorState(context, err),
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
              Expanded(
                child: Semantics(
                  identifier: ScreensIds.datingDiscoverCard(_index),
                  label: current.creator?.name ?? 'Profile',
                  child: _card(context, theme, current),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Semantics(
                    identifier: ScreensIds.datingDiscoverPass,
                    button: true,
                    label: 'Pass',
                    enabled: !_acting,
                    child: _circleAction(
                      icon: Icons.close_rounded,
                      color: theme.textSecondary,
                      onTap: _acting ? null : _skip,
                    ),
                  ),
                  Semantics(
                    identifier: ScreensIds.datingDiscoverLike,
                    button: true,
                    label: 'Like',
                    enabled: !_acting,
                    child: _circleAction(
                      icon: Icons.favorite_rounded,
                      color: theme.primary,
                      onTap: _acting ? null : () => _like(current),
                    ),
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

  Widget _buildErrorState(BuildContext context, Object err) {
    final code = _extractErrorCode(err);
    final copy = _datingErrorCopy(code);
    final theme = ProtoTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                copy.icon,
                size: 36,
                color: theme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: theme.headline.copyWith(fontSize: 20),
            ),
            if (copy.body != null) ...[
              const SizedBox(height: 8),
              Text(
                copy.body!,
                textAlign: TextAlign.center,
                style: theme.body.copyWith(color: theme.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onErrorCta(context, copy.action),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(theme.radiusFull),
                ),
                child: Text(
                  copy.ctaLabel,
                  style: theme.button.copyWith(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onErrorCta(BuildContext context, _DatingErrorAction action) {
    switch (action) {
      case _DatingErrorAction.addBirthday:
        // TODO(router): if a dedicated Settings > DOB route lands later,
        // route there for users whose onboarding is already complete.
        // Until then the existing `/auth/birthday` screen is the only
        // DOB-editing surface, so fall back to it for all three tiers.
        context.go(ProtoRoutes.authBirthday);
      case _DatingErrorAction.retry:
        ref.invalidate(datingCardsProvider);
    }
  }
}

/// Backend error-code string returned on Dating guard failures. Kept as
/// a private constant set so adding a new code on the server surface
/// prompts a matching copy update here.
String? _extractErrorCode(Object err) {
  if (err is DioException) {
    final data = err.response?.data;
    if (data is Map) {
      final code = data['code'];
      if (code is String) return code;
      final message = data['message'];
      if (message is Map && message['code'] is String) {
        return message['code'] as String;
      }
    }
  }
  return null;
}

enum _DatingErrorAction { addBirthday, retry }

class _DatingErrorCopy {
  const _DatingErrorCopy({
    required this.icon,
    required this.title,
    required this.ctaLabel,
    required this.action,
    this.body,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String ctaLabel;
  final _DatingErrorAction action;
}

_DatingErrorCopy _datingErrorCopy(String? code) {
  switch (code) {
    case 'dob_required':
      return const _DatingErrorCopy(
        icon: Icons.cake_outlined,
        title: 'Dating needs your birthday',
        body:
            "We use your birthday to check you're old enough to match "
            'and to filter the age ranges you choose.',
        ctaLabel: 'Add your birthday to see matches',
        action: _DatingErrorAction.addBirthday,
      );
    case 'dob_privacy_declined':
      return const _DatingErrorCopy(
        icon: Icons.lock_outline_rounded,
        title: 'Dating is locked by your privacy choice',
        body:
            "You chose not to share your birthday. Dating needs it to "
            'match you safely — you can change the setting without '
            'making your birthday public.',
        ctaLabel: 'Change your DOB privacy setting',
        action: _DatingErrorAction.addBirthday,
      );
    case 'dob_skipped':
      return const _DatingErrorCopy(
        icon: Icons.event_available_outlined,
        title: 'Add your birthday to match',
        body:
            'You skipped this step during sign-up. Dating stays locked '
            'until we can confirm your age.',
        ctaLabel: 'Add your birthday now',
        action: _DatingErrorAction.addBirthday,
      );
    default:
      return const _DatingErrorCopy(
        icon: Icons.error_outline_rounded,
        title: 'Could not load matches',
        body: "Check your connection and try again.",
        ctaLabel: 'Retry',
        action: _DatingErrorAction.retry,
      );
  }
}
