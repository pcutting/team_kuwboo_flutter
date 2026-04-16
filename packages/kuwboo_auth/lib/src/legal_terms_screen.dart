import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Placeholder Terms of Service screen.
///
/// TODO(legal): replace with final Terms of Service copy supplied by Neil
/// and add a last-updated marker + version string so in-app changes are
/// surfaced on next launch.
class LegalTermsScreen extends StatelessWidget {
  const LegalTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: theme.surface,
        foregroundColor: theme.text,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text.rich(
          TextSpan(
            text: 'Terms of Service',
            style: theme.headline.copyWith(fontSize: 20),
            children: [
              TextSpan(
                text:
                    '\n\nPlaceholder. Final legal copy pending from Neil.',
                style: theme.body.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
