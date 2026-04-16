import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_step_chip.dart';
import 'auth_callbacks.dart';

class AuthProfileScreen extends StatefulWidget {
  const AuthProfileScreen({super.key});

  @override
  State<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends State<AuthProfileScreen> {
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _usernameError;
  bool _saving = false;

  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_validateUsername);
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _validateUsername() {
    final value = _usernameController.text.trim();
    String? error;
    if (value.isNotEmpty && !_usernameRegex.hasMatch(value)) {
      error = '3-20 chars, letters, numbers, and underscores only';
    }
    if (error != _usernameError) {
      setState(() => _usernameError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        type: MaterialType.transparency,
        child: Container(
          color: theme.surface,
          child: Column(
            children: [
              ProtoSubBar(title: 'Create Profile'),
              const StepChip(step: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 32),

                    // Avatar placeholder
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: theme.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.surface,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Add a photo',
                        style: theme.caption.copyWith(
                          color: theme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Display Name
                    Text(
                      'Display Name',
                      style: theme.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.text.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: theme.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _displayNameController,
                              textCapitalization: TextCapitalization.words,
                              style: theme.body.copyWith(color: theme.text),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Your name',
                                hintStyle: theme.body.copyWith(
                                  color: theme.textTertiary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Username
                    Text(
                      'Username',
                      style: theme.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _usernameError != null
                              ? Colors.red.withValues(alpha: 0.6)
                              : theme.text.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '@',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _usernameController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9_]'),
                                ),
                                LengthLimitingTextInputFormatter(20),
                              ],
                              style: theme.body.copyWith(color: theme.text),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'username',
                                hintStyle: theme.body.copyWith(
                                  color: theme.textTertiary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _usernameError ?? 'This is how others will find you',
                      style: theme.caption.copyWith(
                        color: _usernameError != null
                            ? Colors.red.shade700
                            : theme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: GestureDetector(
                  onTap: _saving ? null : () => _onContinue(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _saving
                          ? theme.primary.withValues(alpha: 0.6)
                          : theme.primary,
                      borderRadius: BorderRadius.circular(theme.radiusFull),
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Continue',
                              style: theme.button.copyWith(fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue(BuildContext context) async {
    final displayName = _displayNameController.text.trim();
    final username = _usernameController.text.trim();

    // Local username validation — full uniqueness check is still pending a
    // backend `/users/username-available` integration with debounce. For
    // now we just block obviously-malformed values.
    if (username.isNotEmpty && !_usernameRegex.hasMatch(username)) {
      setState(
        () => _usernameError =
            '3-20 chars, letters, numbers, and underscores only',
      );
      return;
    }

    setState(() => _saving = true);
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSaveProfile != null) {
      // Best-effort save — never block onboarding navigation on a backend
      // write. Matches the pattern established by the birthday screen in
      // PR #110: fields are editable later from profile/edit.
      unawaited(
        callbacks!
            .onSaveProfile!(
              displayName: displayName.isEmpty ? null : displayName,
              username: username.isEmpty ? null : username,
            )
            .catchError((Object e) {
              debugPrint(
                '[profile] save failed (will retry on next patch): $e',
              );
            }),
      );
    }
    if (!context.mounted) return;
    context.go(ProtoRoutes.authOnboarding);
  }
}
