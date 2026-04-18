import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'video_providers.dart';

class VideoCommentsSheet extends ConsumerStatefulWidget {
  /// Content id to load comments for. When null, the widget attempts to
  /// pull it from the GoRouter `extra` map (`{'contentId': '…'}`) pushed
  /// by [VideoFeedScreen].
  final String? contentId;
  const VideoCommentsSheet({super.key, this.contentId});

  @override
  ConsumerState<VideoCommentsSheet> createState() =>
      _VideoCommentsSheetState();
}

class _VideoCommentsSheetState extends ConsumerState<VideoCommentsSheet> {
  final Set<String> _likedCommentIds = {};
  final TextEditingController _inputController = TextEditingController();
  bool _sending = false;

  /// Locally-added comments appended after successful POSTs. Kept in state
  /// so the user sees their comment immediately even when the backend (or
  /// the web prototype's mock) doesn't yet persist it across refetches.
  final List<Comment> _localComments = <Comment>[];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String? _resolveContentId(BuildContext context) {
    if (widget.contentId != null) return widget.contentId;
    final extra = GoRouterState.of(context).extra;
    if (extra is Map && extra['contentId'] is String) {
      return extra['contentId'] as String;
    }
    return null;
  }

  Future<void> _submitComment(String contentId) async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final created = await ref
          .read(commentsApiProvider)
          .createComment(contentId, CreateCommentDto(text: text));
      _inputController.clear();
      // Append to local state so the comment is visible immediately,
      // independent of whether the backend's list endpoint has caught up.
      if (mounted) {
        setState(() => _localComments.add(created));
      }
      if (mounted) {
        ProtoToast.show(
            context, ProtoTheme.of(context).icons.checkCircle, 'Comment posted!');
      }
    } catch (e) {
      if (mounted) {
        ProtoToast.show(context, Icons.error_outline, 'Couldn\'t post: $e');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleCommentLike(Comment comment) async {
    final wasLiked = _likedCommentIds.contains(comment.id);
    setState(() {
      if (wasLiked) {
        _likedCommentIds.remove(comment.id);
      } else {
        _likedCommentIds.add(comment.id);
      }
    });
    try {
      await ref.read(commentsApiProvider).likeComment(comment.id);
    } catch (_) {
      // Revert on failure.
      if (!mounted) return;
      setState(() {
        if (wasLiked) {
          _likedCommentIds.add(comment.id);
        } else {
          _likedCommentIds.remove(comment.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final contentId = _resolveContentId(context);

    if (contentId == null) {
      return Material(
        color: theme.surface,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No video selected.',
              style: theme.body.copyWith(color: theme.textSecondary),
            ),
          ),
        ),
      );
    }

    final commentsAsync = ref.watch(videoCommentsProvider(contentId));
    final fetchedComments = commentsAsync.asData?.value ?? const <Comment>[];
    // Merge server-fetched comments with locally-added ones so a newly
    // posted comment shows immediately even if the backend list call
    // hasn't caught up (the web prototype's mock is intentionally
    // non-persistent). Local comments are appended at the end.
    final comments = commentsAsync.asData == null
        ? const <Comment>[]
        : <Comment>[...fetchedComments, ..._localComments];

    return Material(
      color: theme.surface,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  commentsAsync.asData == null
                      ? 'Comments'
                      : '${comments.length} Comments',
                  style: theme.title,
                ),
                const Spacer(),
                GestureDetector(
                    onTap: () => state.pop(),
                    child: Icon(theme.icons.close,
                        size: 22, color: theme.textSecondary)),
              ],
            ),
          ),
          Divider(height: 1, color: theme.text.withValues(alpha: 0.06)),

          // Comments list
          Expanded(
            child: commentsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Couldn\'t load comments.\n$err',
                    textAlign: TextAlign.center,
                    style: theme.body.copyWith(color: theme.textSecondary),
                  ),
                ),
              ),
              data: (_) {
                if (comments.isEmpty) {
                  return Center(
                    child: Text('No comments yet — be the first.',
                        style: theme.body
                            .copyWith(color: theme.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    final isLiked = _likedCommentIds.contains(c.id);
                    final displayLikes = c.likeCount + (isLiked ? 1 : 0);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ProtoAvatar(radius: 16, imageUrl: ''),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(c.authorId,
                                        style: theme.title
                                            .copyWith(fontSize: 15)),
                                    const SizedBox(width: 8),
                                    Text(_timeAgo(c.createdAt),
                                        style: theme.caption
                                            .copyWith(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(c.text,
                                    style: theme.body.copyWith(fontSize: 16)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    ProtoPressButton(
                                      onTap: () => _toggleCommentLike(c),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isLiked
                                                ? theme.icons.favoriteFilled
                                                : theme.icons.favoriteOutline,
                                            size: 14,
                                            color: isLiked
                                                ? theme.accent
                                                : theme.textTertiary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('$displayLikes',
                                              style: theme.caption
                                                  .copyWith(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () => ProtoToast.show(
                                          context,
                                          theme.icons.reply,
                                          'Reply thread would open here'),
                                      child: Text('Reply',
                                          style: theme.caption.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                  top: BorderSide(
                      color: theme.text.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                const ProtoAvatar(
                    radius: 14,
                    imageUrl:
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: !_sending,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: theme.body.copyWith(
                          fontSize: 16, color: theme.textTertiary),
                      filled: true,
                      fillColor: theme.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(contentId),
                  ),
                ),
                const SizedBox(width: 8),
                ProtoPressButton(
                  onTap: _sending ? () {} : () => _submitComment(contentId),
                  child: Icon(theme.icons.send,
                      size: 22,
                      color: _sending ? theme.textTertiary : theme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }
}
