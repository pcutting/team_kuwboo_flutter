import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../../data/demo_data.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';

class VideoCreatorProfile extends StatefulWidget {
  const VideoCreatorProfile({super.key});

  @override
  State<VideoCreatorProfile> createState() => _VideoCreatorProfileState();
}

class _VideoCreatorProfileState extends State<VideoCreatorProfile> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final followerCount = _isFollowing ? '12.5K' : '12.4K';

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(title: 'Creator Profile'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                // Avatar + stats
                Center(
                  child: Column(
                    children: [
                      ProtoAvatar(radius: 40, imageUrl: DemoDataExtended.videos[0].avatarUrl),
                      const SizedBox(height: 12),
                      Text(DemoDataExtended.videos[0].creator, style: theme.headline.copyWith(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text('Creator & DJ', style: theme.body),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(count: '234', label: 'Videos'),
                      _Stat(count: followerCount, label: 'Followers'),
                      _Stat(count: '891', label: 'Following'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Follow / Message buttons
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
                                color: _isFollowing ? theme.text.withValues(alpha: 0.2) : theme.primary,
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
                              border: Border.all(color: theme.text.withValues(alpha: 0.2)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text('Message', style: theme.title.copyWith(fontSize: 14))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Video grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 0.75,
                    children: List.generate(9, (i) => GestureDetector(
                      onTap: () => state.push(ProtoRoutes.videoFeed),
                      child: Container(
                        color: Color.lerp(theme.primary, theme.secondary, i / 9)!.withValues(alpha: 0.3),
                        child: Center(
                          child: Icon(theme.icons.playArrow, size: 24, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
