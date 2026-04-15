import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'social_providers.dart';

class SocialComposerScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? repostVideoArgs;

  const SocialComposerScreen({super.key, this.repostVideoArgs});

  @override
  ConsumerState<SocialComposerScreen> createState() => _SocialComposerScreenState();
}

class _SocialComposerScreenState extends ConsumerState<SocialComposerScreen> {
  String _contentType = 'Post';
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ProtoToast.show(context, Icons.error_outline, 'Please write something first');
      return;
    }

    final controller = ref.read(socialComposerControllerProvider.notifier);
    final post = await controller.submit(text: text);

    if (!mounted) return;
    if (post != null) {
      ProtoToast.show(context, Icons.check_circle_rounded, '$_contentType published');
      // Refresh the feed so the new post appears.
      ref.invalidate(socialFeedProvider);
      PrototypeStateProvider.of(context).pop();
    } else {
      final state = ref.read(socialComposerControllerProvider);
      ProtoToast.show(
        context,
        Icons.error_outline,
        'Could not publish: ${state.error}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final submitState = ref.watch(socialComposerControllerProvider);

    return Container(
      color: theme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: submitState.isSubmitting ? null : () => state.pop(),
                  child: Text('Cancel', style: TextStyle(fontSize: 15, color: theme.textSecondary)),
                ),
                const Spacer(),
                Text('New $_contentType', style: theme.title),
                const Spacer(),
                GestureDetector(
                  onTap: submitState.isSubmitting ? null : _onSubmit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: submitState.isSubmitting
                          ? theme.primary.withValues(alpha: 0.5)
                          : theme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: submitState.isSubmitting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Post',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['Post', 'Blog', 'Video', 'Event'].map((type) {
                final isActive = type == _contentType;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _contentType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? theme.primary : theme.background,
                        borderRadius: BorderRadius.circular(16),
                        border: isActive ? null : Border.all(color: theme.text.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : theme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: theme.text.withValues(alpha: 0.06)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProtoAvatar(
                        radius: 20,
                        imageUrl:
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          autofocus: true,
                          enabled: !submitState.isSubmitting,
                          style: theme.body.copyWith(fontSize: 16),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: widget.repostVideoArgs != null
                                ? 'Add your thoughts...'
                                : "What's on your mind?",
                            hintStyle: theme.body.copyWith(
                              fontSize: 16,
                              color: theme.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.repostVideoArgs != null) ...[
                    const SizedBox(height: 16),
                    _ComposerVideoEmbed(
                      creator: widget.repostVideoArgs!['creator'] as String,
                      caption: widget.repostVideoArgs!['caption'] as String,
                      gradientIndex: widget.repostVideoArgs!['gradientIndex'] as int,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.text.withValues(alpha: 0.06))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ComposeAction(icon: theme.icons.photoLibrary, label: 'Photo', color: theme.secondary),
                _ComposeAction(icon: theme.icons.videocam, label: 'Video', color: theme.accent),
                _ComposeAction(icon: theme.icons.locationOn, label: 'Location', color: theme.primary),
                _ComposeAction(icon: theme.icons.lockOutline, label: 'Privacy', color: theme.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ComposeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ComposeAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: ProtoTheme.of(context).textTertiary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Video gradients (mirrors video_feed_screen.dart) ───────────────────
const _composerVideoGradients = <List<Color>>[
  [Color(0xFF1a1a2e), Color(0xFF16213e)],
  [Color(0xFF2d1b69), Color(0xFF11001c)],
  [Color(0xFF4a0e2e), Color(0xFF1a0a1a)],
  [Color(0xFF0d3b3b), Color(0xFF0a1628)],
  [Color(0xFF1b3a2d), Color(0xFF0a1a12)],
  [Color(0xFF3b1a0d), Color(0xFF1a0e08)],
  [Color(0xFF1a2e4a), Color(0xFF0c1220)],
  [Color(0xFF2e1a3b), Color(0xFF120a1a)],
  [Color(0xFF3b3a1a), Color(0xFF1a1808)],
  [Color(0xFF1a3b3b), Color(0xFF081a1a)],
  [Color(0xFF3b1a2e), Color(0xFF1a0a14)],
  [Color(0xFF1a2e1a), Color(0xFF0a180a)],
];

class _ComposerVideoEmbed extends StatelessWidget {
  final String creator;
  final String caption;
  final int gradientIndex;

  const _ComposerVideoEmbed({
    required this.creator,
    required this.caption,
    required this.gradientIndex,
  });

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final colors = _composerVideoGradients[gradientIndex % _composerVideoGradients.length];

    return GestureDetector(
      onTap: () => state.push(ProtoRoutes.videoFeed),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[0], colors[1]],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35)),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_rounded, size: 12, color: Colors.white70),
                    SizedBox(width: 3),
                    Text(
                      'Video Repost',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Icon(Icons.person, size: 14, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      creator,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        caption,
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
