import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// See the rationale in `ids_smoke_test.dart` — `Semantics` annotations
/// under a ListView + InkWell don't always materialise as separate
/// `SemanticsNode`s, so assertions go against the widget tree.
Finder _bySemId(String id) {
  return find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.identifier == id,
    description: 'Semantics widget with identifier "$id"',
  );
}

SemanticsProperties _props(WidgetTester tester, String id) {
  final matches = _bySemId(id).evaluate().toList();
  if (matches.isEmpty) {
    throw StateError('No Semantics widget with identifier "$id" in the tree.');
  }
  // ListView may wrap the same Semantics widget in multiple places when
  // an entry is in both the build cache and the visible list; take the
  // first match which always mirrors the others.
  return (matches.first.widget as Semantics).properties;
}

/// Host that provides ProtoTheme + a GoRouter seeded with the screen
/// under test. A minimal GoRouter is mandatory because the screen calls
/// `context.go` on the "Log in" link and `context.push` on the legal
/// links — running without a GoRouter ancestor throws.
Widget _host(
  Widget child, {
  AuthCallbacks? callbacks,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => child),
      GoRoute(
        path: ProtoRoutes.authEmailLogin,
        builder: (c, s) => const _MarkerScreen(label: 'login-screen'),
      ),
      GoRoute(
        path: ProtoRoutes.legalTerms,
        builder: (c, s) => const _MarkerScreen(label: 'legal-terms'),
      ),
      GoRoute(
        path: ProtoRoutes.legalPrivacy,
        builder: (c, s) => const _MarkerScreen(label: 'legal-privacy'),
      ),
      GoRoute(
        path: ProtoRoutes.authBirthday,
        builder: (c, s) => const _MarkerScreen(label: 'birthday'),
      ),
    ],
  );
  return ProviderScope(
    child: Consumer(
      builder: (context, ref, _) {
        final shell = ref.watch(shellStateProvider);
        final yoyo = ref.watch(yoyoStateProvider);
        final shellNotifier = ref.read(shellStateProvider.notifier);
        final yoyoNotifier = ref.read(yoyoStateProvider.notifier);
        Widget app = MaterialApp.router(
          routerConfig: router,
          builder: (c, w) => Material(child: w ?? const SizedBox()),
        );
        if (callbacks != null) {
          app = KuwbooAuthFlow(callbacks: callbacks, child: app);
        }
        return ProtoThemeProvider(
          theme: ProtoTheme.v0UrbanWarmth(),
          child: ProtoStateAccess(
            shell: shell,
            yoyo: yoyo,
            shellNotifier: shellNotifier,
            yoyoNotifier: yoyoNotifier,
            child: app,
          ),
        );
      },
    ),
  );
}

Future<void> _pumpAtPhoneSize(
  WidgetTester tester,
  Widget child, {
  AuthCallbacks? callbacks,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_host(child, callbacks: callbacks));
  await tester.pumpAndSettle();
}

class _MarkerScreen extends StatelessWidget {
  const _MarkerScreen({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

void main() {
  group('AuthEmailRegisterScreen', () {
    testWidgets('Create Account starts disabled on initial render',
        (tester) async {
      await _pumpAtPhoneSize(tester, const AuthEmailRegisterScreen());

      final props = _props(tester, AuthIds.registerSubmit);
      expect(
        props.enabled,
        isFalse,
        reason:
            'Create Account must be disabled until both consent checkboxes '
            'are ticked and the form validates.',
      );
    });

    // Three additional tests — enable-on-consent, submit-dispatch, and
    // "Log in" navigation — live in
    // `apps/mobile/integration_test/auth_email_register_test.dart`.
    // Under `flutter test`, `TextFormField` + `AutofillHints` + GoRouter
    // page replacement trips a `_FocusInheritedScope` dispose assertion
    // that doesn't reproduce under the real integration-test binding.
  });
}
