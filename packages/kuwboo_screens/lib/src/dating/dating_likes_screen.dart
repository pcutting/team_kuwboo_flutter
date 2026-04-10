import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// People who liked you — grid of profile cards with like-back and dismiss actions
class DatingLikesScreen extends StatefulWidget {
  const DatingLikesScreen({super.key});

  @override
  State<DatingLikesScreen> createState() => _DatingLikesScreenState();
}

class _DatingLikesScreenState extends State<DatingLikesScreen> {
  static final _allLikers = [
    _LikerData('Sophia', '2m ago', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop'),
    _LikerData('Liam', '15m ago', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&h=200&fit=crop'),
    _LikerData('Emma', '1h ago', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&h=200&fit=crop'),
    _LikerData('Noah', '3h ago', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop'),
    _LikerData('Ava', '5h ago', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&h=200&fit=crop'),
    _LikerData('Mason', '1d ago', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop'),
  ];

  late final List<_LikerData> _likers;
  final Set<int> _likedBack = {};

  @override
  void initState() {
    super.initState();
    _likers = List.of(_allLikers);
  }

  void _handleLikeBack(int index) {
    setState(() => _likedBack.add(index));
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, theme.icons.favoriteFilled, "It's a match with ${_likers[index].name}!");
  }

  void _handleDismiss(int index) {
    final name = _likers[index].name;
    setState(() => _likers.removeAt(index));
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, theme.icons.close, 'Passed on $name');
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('Likes', style: theme.headline.copyWith(fontSize: 24)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_likers.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.accent),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('People who liked your profile', style: theme.body.copyWith(color: theme.textSecondary)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _likers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(theme.icons.favoriteOutline, size: 48, color: theme.textTertiary),
                        const SizedBox(height: 12),
                        Text('No more likes', style: theme.body),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _likers.length,
                    itemBuilder: (context, i) {
                      final liker = _likers[i];
                      final isLikedBack = _likedBack.contains(i);
                      return GestureDetector(
                        onTap: () => state.push(ProtoRoutes.datingProfile),
                        child: Container(
                          decoration: theme.cardDecoration,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ProtoNetworkImage(imageUrl: liker.imageUrl),
                                      // Liked-back badge
                                      if (isLikedBack)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.successColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text('Matched!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                                          ),
                                        )
                                      else
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: theme.accent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(theme.icons.favoriteFilled, size: 14, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(liker.name, style: theme.title.copyWith(fontSize: 14)),
                                          Text(liker.timeAgo, style: theme.caption),
                                        ],
                                      ),
                                    ),
                                    if (!isLikedBack) ...[
                                      // Dismiss button
                                      ProtoPressButton(
                                        onTap: () => _handleDismiss(i),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: theme.background,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(theme.icons.close, size: 14, color: theme.textTertiary),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Like-back button
                                      ProtoPressButton(
                                        onTap: () => _handleLikeBack(i),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: theme.accent.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(theme.icons.favoriteFilled, size: 14, color: theme.accent),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
  }
}

class _LikerData {
  final String name;
  final String timeAgo;
  final String imageUrl;
  const _LikerData(this.name, this.timeAgo, this.imageUrl);
}
