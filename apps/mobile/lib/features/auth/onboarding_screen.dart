import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import 'data/auth_models.dart';

/// Initial profile setup after first-time verification.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  bool _isSaving = false;
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
    final userId = auth.userId;
    if (userId == null) {
      setState(() => _error = 'Not signed in');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final res = await dio.patch<Map<String, dynamic>>(
        '/users/$userId',
        data: {'name': name},
      );
      final updated = res.data != null
          ? AuthUser.fromJson(res.data!)
          : (auth.user ?? AuthUser(id: userId, name: name))
              .copyWith(name: name);
      await ref.read(authProvider.notifier).updateUser(updated);
      // Router redirect handles navigation once isNewUser clears.
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
                onPressed: _isSaving ? null : _complete,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
