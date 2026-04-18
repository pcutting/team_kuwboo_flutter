import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'video_providers.dart';

class VideoCreatorProfile extends ConsumerStatefulWidget {
  /// Optional creator id. When null, pulled from GoRouter `extra` or falls
  /// back to the currently-authenticated user.
  final String? userId;
  const VideoCreatorProfile({super.key, this.userId});

  @override
  ConsumerState<VideoCreatorProfile> createState() =>
      _VideoCreatorProfileState();
}

class _VideoCreatorProfileState extends ConsumerState<VideoCreatorProfile> {
  bool _isFollowing = false;

  String _resolveUserId(BuildContext context) {
    if (widget.userId != null) return widget.userId!;
    final extra = GoRouterState.of(context).extra;
    if (extra is Map && extra['userId'] is String) {
      return extra['userId'] as String;
    }
    // Empty string → provider falls back to `me()`.
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final userId = _resolveUserId(context);
    final userAsync = ref.watch(creatorProfileProvider(userId));

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(title: 'Creator Profile'),
            Expanded(
              child: userAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Couldn\'t load profile.\n$err',
                      textAlign: TextAlign.center,
                      style: theme.body.copyWith(color: theme.textSecondary),
                    ),
                  ),
                ),
                data: (user) => _buildProfile(context, state, theme, user),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    PrototypeStateProvider state,
    ProtoTheme theme,
    User user,
  ) {
    final displayName = _displayName(user);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              ProtoAvatar(radius: 40, imageUrl: user.avatarUrl ?? ''),
              const SizedBox(height: 12),
              Text(displayName, style: theme.headline.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                user.bio ?? 'Creator',
                style: theme.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats — backend doesn't yet expose follower/video counts on User,
        // so these remain placeholders until the endpoint is extended.
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(count: '—', label: 'Videos'),
              _Stat(count: '—', label: 'Followers'),
              _Stat(count: '—', label: 'Following'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: ProtoPressButton(
                  onTap: () => setState(() => _isFollowing = !_isFollowing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isFollowing ? Colors.transparent : theme.primary,
                      border: Border.all(
                        color: _isFollowing
                            ? theme.text.withValues(alpha: 0.2)
                            : theme.primary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: _isFollowing
                            ? theme.title.copyWith(fontSize: 14)
                            : theme.button.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ProtoPressButton(
                  onTap: () => state.push(ProtoRoutes.chatConversation),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.text.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Message',
                        style: theme.title.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Video grid — placeholder tiles (no per-user video list endpoint
        // yet; the feed endpoint doesn't filter by creator).
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 0.75,
            children: List.generate(
              9,
              (i) => GestureDetector(
                onTap: () => state.push(ProtoRoutes.videoFeed),
                child: Container(
                  color: Color.lerp(
                    theme.primary,
                    theme.secondary,
                    i / 9,
                  )!.withValues(alpha: 0.3),
                  child: Center(
                    child: Icon(
                      theme.icons.playArrow,
                      size: 24,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _displayName(User user) {
    if (user.username != null && user.username!.isNotEmpty) {
      return '@${user.username}';
    }
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name!;
    }
    return 'Creator';
  }
}

class _Stat extends StatelessWidget {
  final String count;
  final String label;
  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: ProtoTheme.of(context).title.copyWith(fontSize: 18)),
        Text(label, style: ProtoTheme.of(context).caption),
      ],
    );
  }
}
