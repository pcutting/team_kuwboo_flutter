import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Placeholder Privacy Policy screen.
///
/// TODO(legal): replace with final Privacy Policy copy supplied by Neil.
/// Must cover GDPR (UK + EU) and CCPA disclosures once drafted — see
/// docs/team/internal/REGULATORY_REQUIREMENTS.md for the scope.
class LegalPrivacyScreen extends StatelessWidget {
  const LegalPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: theme.surface,
        foregroundColor: theme.text,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text.rich(
          TextSpan(
            text: 'Privacy Policy',
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
