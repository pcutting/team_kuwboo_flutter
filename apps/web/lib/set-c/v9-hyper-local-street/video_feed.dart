import 'package:flutter/material.dart';
import '../../v9-hyper-local-street/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V9: Hyper-Local Street Video Feed (Set C - Service Switcher FAB)
/// Street-style video overlay, red/blue gradient, condensed type, raw action buttons

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
            // Red/blue gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      HyperLocalStreetTheme.primary.withValues(alpha: 0.5),
                      HyperLocalStreetTheme.secondary.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.play_circle_filled_rounded,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.2)),
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
                accentColor: HyperLocalStreetTheme.primary,
                textColor: Colors.white,
              ),
            ),
            // Feed type tabs
            Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: _buildFeedTabs(),
            ),
            // Action column - raw/minimal style
            Positioned(
              right: 12,
              bottom: 120,
              child: _buildActionColumn(video),
            ),
            // Video info
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

  Widget _buildFeedTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'FOLLOWING',
          style: HyperLocalStreetTheme.label.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        Container(
          width: 2,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white.withValues(alpha: 0.3),
        ),
        Column(
          children: [
            Text(
              'FOR YOU',
              style: HyperLocalStreetTheme.label.copyWith(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 24,
              height: 2,
              color: HyperLocalStreetTheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionColumn(DemoVideo video) {
    return Column(
      children: [
        // Creator avatar - sharp square
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
                color: HyperLocalStreetTheme.primary, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            video.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: HyperLocalStreetTheme.primary.withValues(alpha: 0.3),
              child:
                  const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _ActionButton(
          icon: Icons.favorite_rounded,
          label: _formatCount(video.likes),
          color: HyperLocalStreetTheme.primary,
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
        const _ActionButton(
          icon: Icons.bookmark_border_rounded,
          label: 'SAVE',
        ),
      ],
    );
  }

  Widget _buildVideoInfo(DemoVideo video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator name in Bebas Neue condensed uppercase
        Text(
          video.creator.toUpperCase(),
          style: HyperLocalStreetTheme.headline.copyWith(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          video.caption,
          style: HyperLocalStreetTheme.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Music track with marker red icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
                HyperLocalStreetTheme.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note_rounded,
                  size: 12, color: HyperLocalStreetTheme.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  video.musicTrack.toUpperCase(),
                  style: HyperLocalStreetTheme.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
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
      activeColor: HyperLocalStreetTheme.primary,
      inactiveColor: Colors.white.withValues(alpha: 0.7),
      fabColor: HyperLocalStreetTheme.primary,
      fabIconColor: Colors.white,
      height: 52,
      fabSize: 50,
      labelStyle: HyperLocalStreetTheme.label.copyWith(fontSize: 8),
    );
  }
}

/// Raw, minimal action button - no backgrounds, just icon + label
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
          style: HyperLocalStreetTheme.label.copyWith(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
