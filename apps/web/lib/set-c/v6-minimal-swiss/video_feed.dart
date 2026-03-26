import 'package:flutter/material.dart';
import '../../v6-minimal-swiss/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V6: Minimal Swiss Video Feed (Set C - Service Switcher FAB)
/// Clean overlay, thin action buttons, red accent for likes

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
            // Video background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.play_circle_outline_rounded,
                      size: 64, color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            ),
            // Top bar
            Positioned(
              top: 0, left: 0, right: 0,
              child: KuwbooTopBar(
                backgroundColor: Colors.transparent,
                accentColor: MinimalSwissTheme.primary,
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: MinimalSwissTheme.spacingMd,
                  vertical: MinimalSwissTheme.spacingSm,
                ),
              ),
            ),
            // Action buttons (right side)
            Positioned(
              right: MinimalSwissTheme.spacingMd,
              bottom: 120,
              child: _buildActionColumn(video),
            ),
            // Video info (bottom left)
            Positioned(
              left: MinimalSwissTheme.spacingMd,
              right: 72,
              bottom: 68,
              child: _buildVideoInfo(video),
            ),
            // Bottom nav
            Positioned(
              left: 0, right: 0, bottom: 0,
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.5), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            video.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.white.withValues(alpha: 0.1),
              child: const Icon(Icons.person,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(height: MinimalSwissTheme.spacingLg),
        // Like - Swiss red accent
        _ActionButton(
          icon: Icons.favorite_outline_rounded,
          label: _formatCount(video.likes),
          color: MinimalSwissTheme.primary,
        ),
        const SizedBox(height: MinimalSwissTheme.spacingMd),
        // Comment
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: _formatCount(video.comments),
        ),
        const SizedBox(height: MinimalSwissTheme.spacingMd),
        // Share
        _ActionButton(
          icon: Icons.share_outlined,
          label: _formatCount(video.shares),
        ),
        const SizedBox(height: MinimalSwissTheme.spacingMd),
        // Save
        const _ActionButton(
          icon: Icons.bookmark_outline_rounded,
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
        Text(video.creator,
            style: MinimalSwissTheme.title
                .copyWith(color: Colors.white)),
        const SizedBox(height: MinimalSwissTheme.spacingXs),
        Text(
          video.caption,
          style: MinimalSwissTheme.bodySmall
              .copyWith(color: Colors.white.withValues(alpha: 0.85)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: MinimalSwissTheme.spacingSm),
        Row(
          children: [
            Icon(Icons.music_note_rounded,
                size: 12, color: Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                video.musicTrack,
                style: MinimalSwissTheme.caption
                    .copyWith(color: Colors.white.withValues(alpha: 0.5)),
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
      backgroundColor: const Color(0xF0111111),
      activeColor: MinimalSwissTheme.primary,
      inactiveColor: Colors.white.withValues(alpha: 0.6),
      fabColor: MinimalSwissTheme.primary,
      fabIconColor: MinimalSwissTheme.background,
      height: 52,
      fabSize: 50,
      labelStyle: MinimalSwissTheme.label
          .copyWith(fontSize: 8, color: Colors.white.withValues(alpha: 0.6)),
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
    final c = color ?? Colors.white;
    return Column(
      children: [
        Icon(icon, size: 24, color: c),
        const SizedBox(height: 2),
        Text(label,
            style: MinimalSwissTheme.caption
                .copyWith(fontSize: 10, color: Colors.white)),
      ],
    );
  }
}
