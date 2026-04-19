import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'video_providers.dart';

class VideoDiscoverScreen extends ConsumerStatefulWidget {
  const VideoDiscoverScreen({super.key});

  @override
  ConsumerState<VideoDiscoverScreen> createState() =>
      _VideoDiscoverScreenState();
}

class _VideoDiscoverScreenState extends ConsumerState<VideoDiscoverScreen> {
  final Set<String> _selectedCategories = {};

  static const _categories = [
    'Trending',
    'Music',
    'Comedy',
    'Dance',
    'Food',
    'Travel',
    'Sports',
    'Art',
  ];

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    // Live discover feed. Tiles use backend counts when available; the
    // grid falls back to a fixed-length skeleton during loading / error.
    final discoverAsync = ref.watch(videoFeedProvider(VideoFeedKind.discover));
    final items = discoverAsync.asData?.value.items ?? const [];
    final tileCount = items.isEmpty ? 4 : items.length.clamp(1, 8);

    // The video module uses an overlay (transparent) top bar in the shell,
    // so the first list item needs enough top padding to clear the safe
    // area + the floating top-bar icon circles. Otherwise the search
    // input sits underneath the YoYo / chat / profile icons.
    final topInset = MediaQuery.paddingOf(context).top + 56;
    return ListView(
      padding: EdgeInsets.fromLTRB(12, topInset, 12, 0),
      children: [
        // Search bar
        GestureDetector(
          onTap: () => ProtoToast.show(
            context,
            theme.icons.search,
            'Search keyboard would open',
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.text.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(theme.icons.search, size: 20, color: theme.textTertiary),
                const SizedBox(width: 10),
                Text(
                  'Search videos, sounds, creators...',
                  style: theme.body.copyWith(color: theme.textTertiary),
                ),
              ],
            ),
          ),
        ),

        // Category chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return ProtoPressButton(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(cat);
                  } else {
                    _selectedCategories.add(cat);
                  }
                });
                if (!isSelected) {
                  ProtoToast.show(
                    context,
                    theme.icons.filterList,
                    'Filter: $cat applied',
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primary.withValues(alpha: 0.12)
                      : theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.primary
                        : theme.text.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  cat,
                  style: theme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.primary : theme.textTertiary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Trending section
        Text('Trending', style: theme.title),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
          children: List.generate(tileCount, (i) {
            final content = i < items.length ? items[i] : null;
            final label =
                content?.caption ?? (content?.title ?? '#trending${i + 1}');
            final viewCount = content?.viewCount ?? (i + 1) * 1200;
            return GestureDetector(
              onTap: () {
                final id = content?.id;
                if (id != null) {
                  state.pushWithArgs(ProtoRoutes.videoFeed, {'contentId': id});
                } else {
                  state.push(ProtoRoutes.videoSound);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color.lerp(
                    theme.primary,
                    theme.tertiary,
                    i / tileCount,
                  )!.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.isEmpty ? '#trending${i + 1}' : label,
                            style: theme.title.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('$viewCount views', style: theme.caption),
                        ],
                      ),
                    ),
                    Center(
                      child: Icon(
                        theme.icons.playArrow,
                        size: 32,
                        color: theme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
