import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_dialogs.dart';

class SocialComposerScreen extends StatefulWidget {
  final Map<String, dynamic>? repostVideoArgs;

  const SocialComposerScreen({super.key, this.repostVideoArgs});

  @override
  State<SocialComposerScreen> createState() => _SocialComposerScreenState();
}

class _SocialComposerScreenState extends State<SocialComposerScreen> {
  String _contentType = 'Post';
  bool _eventCostFree = true;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => state.pop(),
                  child: Text('Cancel', style: TextStyle(fontSize: 15, color: theme.textSecondary)),
                ),
                const Spacer(),
                Text('New $_contentType', style: theme.title),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final msg = _contentType == 'Event' ? 'Event created' : '$_contentType published';
                    ProtoToast.show(context, Icons.check_circle_rounded, msg);
                    state.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _contentType == 'Event' ? 'Create Event' : 'Post',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content type selector
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProtoAvatar(radius: 20, imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _contentType == 'Event'
                            ? 'Event name'
                            : widget.repostVideoArgs != null
                                ? 'Add your thoughts...'
                                : "What's on your mind?",
                        style: theme.body.copyWith(fontSize: 16, color: theme.textTertiary),
                      ),
                    ),
                  ],
                ),
                // Video repost preview card
                if (widget.repostVideoArgs != null) ...[
                  const SizedBox(height: 16),
                  _ComposerVideoEmbed(
                    creator: widget.repostVideoArgs!['creator'] as String,
                    caption: widget.repostVideoArgs!['caption'] as String,
                    gradientIndex: widget.repostVideoArgs!['gradientIndex'] as int,
                  ),
                ],
                // Event-specific fields
                if (_contentType == 'Event') ...[
                  const SizedBox(height: 20),
                  // Date & Time row
                  Row(
                    children: [
                      Icon(theme.icons.calendarToday, size: 18, color: theme.textSecondary),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.text.withValues(alpha: 0.1)),
                        ),
                        child: Text('Sat, 15 Mar', style: theme.body.copyWith(fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.text.withValues(alpha: 0.1)),
                        ),
                        child: Text('7:00 PM', style: theme.body.copyWith(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Location field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.text.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(theme.icons.locationOn, size: 18, color: theme.textTertiary),
                        const SizedBox(width: 10),
                        Text('Add venue or address', style: theme.body.copyWith(fontSize: 14, color: theme.textTertiary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Cost row
                  Row(
                    children: [
                      Icon(Icons.local_offer_outlined, size: 18, color: theme.textSecondary),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setState(() => _eventCostFree = !_eventCostFree),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _eventCostFree
                                ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                                : theme.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _eventCostFree
                                  ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                                  : theme.text.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            'Free',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _eventCostFree ? const Color(0xFF2E7D32) : theme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (!_eventCostFree) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: theme.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.text.withValues(alpha: 0.1)),
                            ),
                            child: Text('£0.00', style: theme.body.copyWith(fontSize: 13, color: theme.textTertiary)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Cover image placeholder
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.text.withValues(alpha: 0.15),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(theme.icons.cameraAltOutline, size: 28, color: theme.textTertiary),
                        const SizedBox(height: 6),
                        Text('Add cover image', style: theme.caption.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Bottom actions
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
    final theme = ProtoTheme.of(context);
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
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),

            // Video badge (top-left)
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

            // Play icon (centered)
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

            // Bottom strip: creator + caption
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
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
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
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
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
