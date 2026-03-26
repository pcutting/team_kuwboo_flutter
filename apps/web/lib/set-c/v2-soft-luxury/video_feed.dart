import 'package:flutter/material.dart';
import '../../v2-soft-luxury/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V2: Soft Luxury Video Feed (Set C - Service Switcher FAB)
/// TikTok-style vertical video with elegant overlay treatment

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
            // Full-bleed "video" placeholder
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SoftLuxuryTheme.secondary.withValues(alpha: 0.6),
                      SoftLuxuryTheme.primary.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: KuwbooTopBar(
                backgroundColor: Colors.transparent,
                accentColor: SoftLuxuryTheme.primary,
                textColor: Colors.white,
              ),
            ),
            // Right action column
            Positioned(
              right: 12,
              bottom: 120,
              child: _buildActionColumn(video),
            ),
            // Bottom info overlay
            Positioned(
              left: 16,
              right: 80,
              bottom: 70,
              child: _buildVideoInfo(video),
            ),
            // Bottom nav
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
        // Creator avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: SoftLuxuryTheme.primary, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            video.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CircleAvatar(
              backgroundColor: SoftLuxuryTheme.primary.withValues(alpha: 0.3),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _ActionButton(
          icon: Icons.favorite_rounded,
          label: _formatCount(video.likes),
          color: SoftLuxuryTheme.primary,
        ),
        const SizedBox(height: 16),
        _ActionButton(
          icon: Icons.chat_bubble_rounded,
          label: _formatCount(video.comments),
        ),
        const SizedBox(height: 16),
        _ActionButton(
          icon: Icons.share_rounded,
          label: _formatCount(video.shares),
        ),
        const SizedBox(height: 16),
        _ActionButton(
          icon: Icons.bookmark_border_rounded,
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
        Text(
          video.creator,
          style: SoftLuxuryTheme.title.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          video.caption,
          style: SoftLuxuryTheme.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                video.musicTrack,
                style: SoftLuxuryTheme.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      activeColor: SoftLuxuryTheme.primary,
      inactiveColor: Colors.white.withValues(alpha: 0.7),
      fabColor: SoftLuxuryTheme.secondary,
      fabIconColor: Colors.white,
      height: 52,
      fabSize: 50,
      labelStyle: SoftLuxuryTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color ?? Colors.white),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
