import 'package:flutter/material.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Celebration overlay shown after a swipe-right yields a mutual like.
/// Dumb presenter — takes the matched [Content] directly so it composes
/// cleanly from the card stack's local state.
class DatingMatchOverlay extends StatelessWidget {
  const DatingMatchOverlay({super.key, this.match});

  /// The matched content card. Optional because the prototype route
  /// builder still instantiates the overlay without context; in real use
  /// the card stack passes the live [Content] it just matched on.
  final Content? match;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final creator = match?.creator;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: theme.cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, color: theme.primary, size: 64),
            const SizedBox(height: 12),
            Text("It's a match!", style: theme.title),
            if (creator != null) ...[
              const SizedBox(height: 8),
              Text(
                'You and ${creator.name} liked each other.',
                style: theme.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ProtoAvatar(radius: 40, imageUrl: creator.avatarUrl ?? ''),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Keep swiping'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Say hi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
