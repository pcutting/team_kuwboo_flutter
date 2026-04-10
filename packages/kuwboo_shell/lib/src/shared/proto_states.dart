import 'package:flutter/material.dart';
import '../theme/proto_theme.dart';

// ─── ProtoEmptyState ──────────────────────────────────────────────────────────
// Centered illustration + message for empty lists/feeds.

class ProtoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ProtoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.title.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.body,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: theme.primary,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── ProtoErrorState ──────────────────────────────────────────────────────────
// Centered error illustration + retry button.

class ProtoErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProtoErrorState({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: theme.errorColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.title.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── ProtoLoadingState ────────────────────────────────────────────────────────
// Shimmer placeholder that mimics content shape.

class ProtoLoadingState extends StatefulWidget {
  final int itemCount;
  final ProtoLoadingLayout layout;

  const ProtoLoadingState({
    super.key,
    this.itemCount = 5,
    this.layout = ProtoLoadingLayout.list,
  });

  @override
  State<ProtoLoadingState> createState() => _ProtoLoadingStateState();
}

enum ProtoLoadingLayout { list, grid, card }

class _ProtoLoadingStateState extends State<ProtoLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.3 + 0.3 * (0.5 + 0.5 * (_controller.value * 2 * 3.14159).clamp(-1.0, 1.0));
        return Opacity(
          opacity: opacity,
          child: widget.layout == ProtoLoadingLayout.grid
              ? _buildGrid(theme)
              : _buildList(theme),
        );
      },
    );
  }

  Widget _buildList(ProtoTheme theme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: theme.dividerColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 200,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(5),
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

  Widget _buildGrid(ProtoTheme theme) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      itemBuilder: (context, i) => Container(
        decoration: BoxDecoration(
          color: theme.dividerColor,
          borderRadius: BorderRadius.circular(theme.radiusMd),
        ),
      ),
    );
  }
}
