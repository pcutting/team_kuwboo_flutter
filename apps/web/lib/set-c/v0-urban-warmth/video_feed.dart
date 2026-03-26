import 'package:flutter/material.dart';
import '../../v0-urban-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V0: Urban Warmth Video Feed (Set C - Service Switcher FAB)
/// Full-bleed terracotta/sage gradient, Bebas Neue overlays, organic action pills

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
            // Full-bleed warm gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      UrbanWarmthTheme.primary.withValues(alpha: 0.6),
                      UrbanWarmthTheme.secondary.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.25),
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
                accentColor: UrbanWarmthTheme.primary,
                textColor: Colors.white,
              ),
            ),
            // Feed type tabs — Bebas Neue condensed
            Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: _buildFeedTabs(),
            ),
            // Right action column — organic pill buttons
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

  Widget _buildFeedTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'FOLLOWING',
          style: UrbanWarmthTheme.label.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        Container(
          width: 2,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        Column(
          children: [
            Text(
              'FOR YOU',
              style: UrbanWarmthTheme.label.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: UrbanWarmthTheme.primary,
                borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionColumn(DemoVideo video) {
    return Column(
      children: [
        // Creator avatar — warm terracotta border
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: UrbanWarmthTheme.primary, width: 2.5),
            boxShadow: UrbanWarmthTheme.colorShadow(UrbanWarmthTheme.primary),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            video.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CircleAvatar(
              backgroundColor: UrbanWarmthTheme.primary.withValues(alpha: 0.3),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _ActionButton(
          icon: Icons.favorite_rounded,
          label: _formatCount(video.likes),
          color: UrbanWarmthTheme.accent,
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
        // Creator name in Bebas Neue display
        Text(
          video.creator.toUpperCase(),
          style: UrbanWarmthTheme.headline.copyWith(
            color: Colors.white,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          video.caption,
          style: UrbanWarmthTheme.body.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Music track pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: UrbanWarmthTheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 12,
                color: UrbanWarmthTheme.tertiary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  video.musicTrack,
                  style: UrbanWarmthTheme.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
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
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      activeColor: UrbanWarmthTheme.primary,
      inactiveColor: Colors.white.withValues(alpha: 0.7),
      fabColor: UrbanWarmthTheme.secondary,
      fabIconColor: Colors.white,
      height: 52,
      fabSize: 50,
      labelStyle: UrbanWarmthTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color ?? Colors.white),
        const SizedBox(height: 2),
        Text(
          label,
          style: UrbanWarmthTheme.caption.copyWith(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
