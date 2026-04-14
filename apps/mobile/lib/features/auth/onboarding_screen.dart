import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';

/// Initial profile setup after first-time verification.
///
/// This screen compresses the post-verify onboarding steps (birthday,
/// profile name, tutorial) into a single mobile form. Tapping **Skip**
/// mirrors the prototype's `onboardingSkippedProvider` by PATCHing
/// `birthday_skipped: true` and advancing `onboarding_progress` to
/// `tutorial`, so the next auth round-trip surfaces the user at the
/// correct resume step.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  bool _isSaving = false;
  bool _isSkipping = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a display name');
      return;
    }

    final auth = ref.read(authProvider);
    if (auth.userId == null) {
      setState(() => _error = 'Not signed in');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final users = ref.read(usersApiProvider);
      final updated = await users.patchMe({
        'name': name,
        'onboarding_progress': OnboardingProgress.complete.value,
      });
      ref.read(authProvider.notifier).updateUser(updated);
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      setState(() => _error = (data is Map && data['message'] is String)
          ? data['message'] as String
          : 'Could not save profile');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _skip() async {
    setState(() {
      _isSkipping = true;
      _error = null;
    });
    try {
      final users = ref.read(usersApiProvider);
      final updated = await users.patchMe({
        'birthday_skipped': true,
        'onboarding_progress': OnboardingProgress.tutorial.value,
      });
      ref.read(authProvider.notifier).updateUser(updated);
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      setState(() => _error = (data is Map && data['message'] is String)
          ? data['message'] as String
          : 'Could not skip');
    } finally {
      if (mounted) setState(() => _isSkipping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Set up your profile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_add_outlined,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: const Icon(Icons.person_outlined),
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving || _isSkipping ? null : _complete,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Started'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSaving || _isSkipping ? null : _skip,
                child: _isSkipping
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
