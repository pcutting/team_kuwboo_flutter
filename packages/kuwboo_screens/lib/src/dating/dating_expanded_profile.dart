import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'dating_providers.dart';

/// Full-profile modal shown when the user taps a card in the stack.
///
/// Takes a [userId] and resolves via [userProfileProvider]. The
/// underlying `UsersApi` does not yet expose a public `GET /users/:id`
/// endpoint, so the provider will throw `UnimplementedError` for any id
/// other than the current user — the screen surfaces that gap directly
/// rather than silently displaying mock data (see provider docstring).
class DatingExpandedProfile extends ConsumerWidget {
  const DatingExpandedProfile({super.key, this.userId});

  /// Id of the user whose profile to display. When null (the current
  /// routing scaffold passes no arg) the screen shows an empty-state
  /// prompting the caller to wire a real user id — once the route is
  /// parameterised, pass the matched user's id in.
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);
    final id = userId;
    if (id == null) {
      return const Scaffold(
        body: ProtoEmptyState(
          icon: Icons.person_outline_rounded,
          title: 'No profile selected',
          subtitle: 'Tap a card in the swipe stack to open a profile',
        ),
      );
    }
    final async = ref.watch(userProfileProvider(id));

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ProtoEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load profile',
          subtitle: err.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(userProfileProvider(id)),
        ),
        data: (user) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ProtoAvatar(
                  radius: 56,
                  imageUrl: user.avatarUrl ?? '',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name ?? user.username ?? 'User',
                style: theme.title,
                textAlign: TextAlign.center,
              ),
              if (user.bio != null) ...[
                const SizedBox(height: 12),
                Text(user.bio!, style: theme.body),
              ],
            ],
          );
        },
      ),
    );
  }
}
