import 'package:flutter/material.dart';
import '../../v10-calm-tech/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V10: Calm Tech Video Feed (Set C - Service Switcher FAB)
/// Gentle, non-anxious video browsing — softer colors, rounded everything

class VideoFeed extends StatelessWidget {
  const VideoFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final video = DemoDataExtended.videos[0];

    return Container(
      color: CalmTechTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            // Calm video area (not full-black like V2)
            Positioned.fill(
              child: Column(
                children: [
                  KuwbooTopBar(
                    backgroundColor: CalmTechTheme.background,
                    accentColor: CalmTechTheme.primary,
                    textColor: CalmTechTheme.text,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CalmTechTheme.spacingLg,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(CalmTechTheme.radiusXl),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              CalmTechTheme.primary.withValues(alpha: 0.3),
                              CalmTechTheme.secondary.withValues(alpha: 0.2),
                              CalmTechTheme.tertiary.withValues(alpha: 0.15),
                            ],
                          ),
                          boxShadow: CalmTechTheme.gentleShadow,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Play icon
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 36,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            // Right action column
                            Positioned(
                              right: 12,
                              bottom: 80,
                              child: _buildActionColumn(video),
                            ),
                            // Bottom info
                            Positioned(
                              left: 16,
                              right: 70,
                              bottom: 16,
                              child: _buildVideoInfo(video),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
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
        _CalmActionButton(
          icon: Icons.favorite_rounded,
          label: _formatCount(video.likes),
          color: CalmTechTheme.tertiary,
        ),
        const SizedBox(height: 14),
        _CalmActionButton(
          icon: Icons.chat_bubble_rounded,
          label: _formatCount(video.comments),
          color: CalmTechTheme.primary,
        ),
        const SizedBox(height: 14),
        _CalmActionButton(
          icon: Icons.share_rounded,
          label: _formatCount(video.shares),
          color: CalmTechTheme.secondary,
        ),
      ],
    );
  }

  Widget _buildVideoInfo(DemoVideo video) {
    return Container(
      padding: const EdgeInsets.all(CalmTechTheme.spacingSm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(CalmTechTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  video.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    backgroundColor: CalmTechTheme.primary,
                    radius: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                video.creator,
                style: CalmTechTheme.title.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            video.caption,
            style: CalmTechTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  video.musicTrack,
                  style: CalmTechTheme.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.video,
      backgroundColor: CalmTechTheme.surface,
      activeColor: CalmTechTheme.primary,
      inactiveColor: CalmTechTheme.textSecondary,
      fabColor: CalmTechTheme.primary,
      fabIconColor: CalmTechTheme.surface,
      borderColor: CalmTechTheme.primary.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: CalmTechTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _CalmActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CalmActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
