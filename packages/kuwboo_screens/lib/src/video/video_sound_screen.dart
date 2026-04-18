import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class VideoSoundScreen extends StatefulWidget {
  const VideoSoundScreen({super.key});

  @override
  State<VideoSoundScreen> createState() => _VideoSoundScreenState();
}

class _VideoSoundScreenState extends State<VideoSoundScreen> {
  bool _soundAdded = false;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(title: 'Sound'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),
                  // Sound info
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 28,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Midnight — DJ Maya', style: theme.title),
                            const SizedBox(height: 2),
                            Text('1.2K videos', style: theme.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Use sound button
                  ProtoPressButton(
                    onTap: () => setState(() => _soundAdded = !_soundAdded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _soundAdded ? theme.secondary : theme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _soundAdded ? 'Sound added \u2713' : 'Use this sound',
                          style: theme.button.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Videos using this sound
                  Text('Videos', style: theme.title),
                  const SizedBox(height: 8),
                  GridView.count(
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
                          color: theme.primary.withValues(
                            alpha: 0.1 + (i * 0.05),
                          ),
                          child: Center(
                            child: Icon(
                              theme.icons.playArrow,
                              size: 20,
                              color: theme.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
