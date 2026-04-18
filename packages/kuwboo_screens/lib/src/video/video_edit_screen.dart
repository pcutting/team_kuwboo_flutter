import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class VideoEditScreen extends StatefulWidget {
  const VideoEditScreen({super.key});

  @override
  State<VideoEditScreen> createState() => _VideoEditScreenState();
}

class _VideoEditScreenState extends State<VideoEditScreen> {
  int _selectedTool = -1; // -1 = none selected
  double _scrubberPosition = 0.3; // 0.0 to 1.0

  static const _toolLabels = ['Trim', 'Text', 'Sticker', 'Sound', 'Filter'];

  Future<void> _handleBack() async {
    final confirmed = await ProtoConfirmDialog.show(
      context,
      title: 'Discard changes?',
      message: 'Your edits will be lost if you go back.',
    );
    if (confirmed && mounted) {
      PrototypeStateProvider.of(context).pop();
    }
  }

  Future<void> _handlePost() async {
    final confirmed = await ProtoConfirmDialog.show(
      context,
      title: 'Post this video?',
      message: 'Your video will be shared with your followers.',
    );
    if (confirmed && mounted) {
      ProtoToast.show(
        context,
        ProtoTheme.of(context).icons.checkCircle,
        'Video posted!',
      );
      PrototypeStateProvider.of(context).push(ProtoRoutes.videoFeed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final toolIcons = [
      theme.icons.contentCut,
      theme.icons.textFields,
      theme.icons.emojiEmotions,
      Icons.music_note_rounded,
      theme.icons.filterVintage,
    ];

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: const Color(0xFF1a1a2e),
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.only(
                top: 56,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _handleBack,
                    child: Icon(
                      theme.icons.arrowBack,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  ProtoPressButton(
                    onTap: _handlePost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video preview
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    theme.icons.playCircleOutline,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),

            // Timeline with draggable scrubber
            LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _scrubberPosition =
                          (details.localPosition.dx / constraints.maxWidth)
                              .clamp(0.0, 1.0);
                    });
                  },
                  onTapDown: (details) {
                    setState(() {
                      _scrubberPosition =
                          (details.localPosition.dx / constraints.maxWidth)
                              .clamp(0.0, 1.0);
                    });
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Thumbnail frames
                        Row(
                          children: List.generate(
                            8,
                            (i) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: 0.15 + (i * 0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Scrubber playhead
                        Positioned(
                          left: (constraints.maxWidth - 32) * _scrubberPosition,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Edit tools
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_toolLabels.length, (i) {
                  final icon = toolIcons[i];
                  final label = _toolLabels[i];
                  final isSelected = i == _selectedTool;
                  return ProtoPressButton(
                    onTap: () {
                      setState(
                        () => _selectedTool = _selectedTool == i ? -1 : i,
                      );
                      if (label == 'Sound') {
                        state.push(ProtoRoutes.videoSound);
                      } else if (_selectedTool == i) {
                        ProtoToast.show(context, icon, '$label tool selected');
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: isSelected ? 0.2 : 0.1,
                            ),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: theme.primary, width: 2)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: isSelected ? theme.primary : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? theme.primary : Colors.white60,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Caption input
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => ProtoToast.show(
                      context,
                      theme.icons.edit,
                      'Caption editor would open',
                    ),
                    child: Text(
                      'Add caption...',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ProtoToast.show(
                      context,
                      theme.icons.tag,
                      'Tag suggestions would appear',
                    ),
                    child: Text(
                      '#tags',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
