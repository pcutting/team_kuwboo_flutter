import 'package:flutter/material.dart';
import '../../v4-dark-mode-native/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V4: Dark Mode Native Video Feed (Set C - Service Switcher FAB)
/// Full-screen OLED video with purple/pink gradient and glowing action buttons

class VideoFeed extends StatelessWidget {
  const VideoFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final video = DemoDataExtended.videos[0];

    return Container(
      color: DarkModeNativeTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            // Full-bleed video placeholder with purple/pink gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DarkModeNativeTheme.primary.withValues(alpha: 0.5),
                      DarkModeNativeTheme.tertiary.withValues(alpha: 0.3),
                      DarkModeNativeTheme.background,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DarkModeNativeTheme.text.withValues(alpha: 0.1),
                      border: Border.all(
                        color: DarkModeNativeTheme.text.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 40,
                      color: DarkModeNativeTheme.text.withValues(alpha: 0.4),
                    ),
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
                accentColor: DarkModeNativeTheme.primary,
                textColor: DarkModeNativeTheme.text,
              ),
            ),
            // Right action column with glowing buttons
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: DarkModeNativeTheme.primary,
              width: 2,
            ),
            boxShadow: DarkModeNativeTheme.subtleGlow(
              DarkModeNativeTheme.primary,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            video.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CircleAvatar(
              backgroundColor:
                  DarkModeNativeTheme.primary.withValues(alpha: 0.3),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Like with glow
        _ActionButton(
          icon: Icons.favorite_rounded,
          label: _formatCount(video.likes),
          color: DarkModeNativeTheme.tertiary,
          glowing: true,
        ),
        const SizedBox(height: 16),
        // Comment
        _ActionButton(
          icon: Icons.chat_bubble_rounded,
          label: _formatCount(video.comments),
          color: DarkModeNativeTheme.text,
        ),
        const SizedBox(height: 16),
        // Share with glow
        _ActionButton(
          icon: Icons.share_rounded,
          label: _formatCount(video.shares),
          color: DarkModeNativeTheme.secondary,
          glowing: true,
        ),
        const SizedBox(height: 16),
        // Bookmark
        _ActionButton(
          icon: Icons.bookmark_border_rounded,
          label: 'Save',
          color: DarkModeNativeTheme.primary,
          glowing: true,
        ),
      ],
    );
  }

  Widget _buildVideoInfo(DemoVideo video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator name with glow
        Text(
          video.creator,
          style: DarkModeNativeTheme.title.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          video.caption,
          style: DarkModeNativeTheme.bodySmall.copyWith(
            color: DarkModeNativeTheme.text.withValues(alpha: 0.9),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Music track with neon icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: DarkModeNativeTheme.surfaceElevated.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm),
            border: Border.all(
              color: DarkModeNativeTheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 12,
                color: DarkModeNativeTheme.primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  video.musicTrack,
                  style: DarkModeNativeTheme.mono.copyWith(
                    fontSize: 10,
                    color: DarkModeNativeTheme.textSecondary,
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
      backgroundColor:
          DarkModeNativeTheme.background.withValues(alpha: 0.9),
      activeColor: DarkModeNativeTheme.primary,
      inactiveColor: DarkModeNativeTheme.textTertiary,
      fabColor: DarkModeNativeTheme.tertiary,
      fabIconColor: DarkModeNativeTheme.text,
      height: 52,
      fabSize: 50,
      labelStyle: DarkModeNativeTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool glowing;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(
              color: color.withValues(alpha: glowing ? 0.4 : 0.2),
            ),
            boxShadow: glowing
                ? DarkModeNativeTheme.subtleGlow(color)
                : null,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: DarkModeNativeTheme.caption.copyWith(
            fontSize: 10,
            color: DarkModeNativeTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
