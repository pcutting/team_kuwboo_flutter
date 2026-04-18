import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'social_providers.dart';

/// Story viewer — backend has no dedicated stories endpoint, so we reuse
/// the first N social feed items as the thread. The optional [contentId]
/// is kept as the family key for when a real stories endpoint lands.
class SocialStoryViewer extends ConsumerWidget {
  const SocialStoryViewer({super.key, this.contentId = ''});

  final String contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final thread = ref.watch(storyThreadProvider(contentId));

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => state.pop(),
        child: Container(
          color: Colors.black,
          child: thread.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load stories',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No stories to show',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final first = items.first;
              final creatorName = first.creator?.name ?? 'Someone';
              final avatarUrl = first.creator?.avatarUrl ?? '';
              return Stack(
                children: [
                  // Backdrop
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primary.withValues(alpha: 0.6),
                            theme.secondary.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          theme.icons.image,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  // Progress bars — one per story in thread
                  Positioned(
                    top: 56,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: List.generate(
                        items.length,
                        (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: i == 0
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Author info
                  Positioned(
                    top: 68,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        ProtoAvatar(radius: 16, imageUrl: avatarUrl),
                        const SizedBox(width: 10),
                        Text(
                          creatorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _relativeTime(first.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => state.pop(),
                          child: Icon(
                            theme.icons.close,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Caption / post text
                  if ((first.text ?? first.caption ?? '').isNotEmpty)
                    Positioned(
                      bottom: 120,
                      left: 16,
                      right: 16,
                      child: Text(
                        first.text ?? first.caption ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Reply bar
                  Positioned(
                    bottom: 60,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Reply to story...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Tap to close',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.isNegative) return '';
    if (diff.inHours >= 24) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
