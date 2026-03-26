import 'package:flutter/material.dart';
import '../../v3-vibrant-pop/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V3: Vibrant Pop Video Feed (Set C - Service Switcher FAB)
/// Full-screen dark with bold gradient overlays and energetic interactions

class VideoFeed extends StatelessWidget {
  const VideoFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final video = DemoDataExtended.videos[0];
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Video background with gradient using primary/secondary
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      VibrantPopTheme.primary.withValues(alpha: 0.5),
                      VibrantPopTheme.secondary.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            // Top bar (transparent)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: KuwbooTopBar(
                backgroundColor: Colors.transparent,
                accentColor: VibrantPopTheme.primary,
                textColor: Colors.white,
              ),
            ),
            // Action column (right side)
            Positioned(
              right: 12,
              bottom: 120,
              child: _buildActionColumn(video),
            ),
            // Video info overlay (bottom left)
            Positioned(
              left: 16,
              right: 80,
              bottom: 70,
              child: _buildVideoInfo(video),
            ),
            // Bottom nav with black background and funGradient accent
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionColumn(DemoVideo video) {
    return Column(
      children: [
        // Creator avatar with gradient border
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: VibrantPopTheme.funGradient,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipOval(
              child: Image.network(
                video.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: VibrantPopTheme.primary.withValues(alpha: 0.3),
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _ActionButton(
          icon: Icons.favorite_rounded,
          label: _formatCount(video.likes),
          color: VibrantPopTheme.secondary,
          gradient: VibrantPopTheme.funGradient,
        ),
        const SizedBox(height: 18),
        _ActionButton(
          icon: Icons.chat_bubble_rounded,
          label: _formatCount(video.comments),
        ),
        const SizedBox(height: 18),
        _ActionButton(
          icon: Icons.share_rounded,
          label: _formatCount(video.shares),
        ),
        const SizedBox(height: 18),
        const _ActionButton(
          icon: Icons.bookmark_rounded,
          label: 'Save',
        ),
      ],
    );
  }

  Widget _buildVideoInfo(DemoVideo video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator name with gradient text effect (simulated with colored text)
        Text(
          video.creator,
          style: VibrantPopTheme.subheadline.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          video.caption,
          style: VibrantPopTheme.body.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        // Music track with gradient pill
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(VibrantPopTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note_rounded,
                  size: 14, color: VibrantPopTheme.tertiary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  video.musicTrack,
                  style: VibrantPopTheme.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.video,
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      activeColor: VibrantPopTheme.secondary,
      inactiveColor: Colors.white.withValues(alpha: 0.7),
      fabColor: VibrantPopTheme.secondary,
      fabIconColor: Colors.white,
      height: 52,
      fabSize: 50,
      labelStyle: VibrantPopTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final LinearGradient? gradient;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: gradient == null
                ? Colors.white.withValues(alpha: 0.1)
                : null,
            gradient: gradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: color ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: VibrantPopTheme.caption.copyWith(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
