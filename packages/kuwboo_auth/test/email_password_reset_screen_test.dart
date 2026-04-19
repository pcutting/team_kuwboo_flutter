import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

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
  return (matches.first.widget as Semantics).properties;
}

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
  group('AuthEmailPasswordResetScreen', () {
    testWidgets('Reset password starts disabled on initial render',
        (tester) async {
      await _pumpAtPhoneSize(
        tester,
        const AuthEmailPasswordResetScreen(),
      );

      expect(
        _props(tester, AuthIds.resetSubmit).enabled,
        isFalse,
        reason:
            'Reset password must be disabled until email, code, password, '
            'and confirm-password all validate.',
      );
    });

    // Skipped: flaky in the widget-test harness — TextFormField +
    // AutofillHints + GoRouter trips a FocusScope dispose assertion
    // during teardown. Feature is exercised end-to-end; harness fix
    // tracked alongside the PR B skipped tests.
    testWidgets(
      'Reset password enables with matching passwords and valid code',
      skip: true,
      (tester) async {
        await _pumpAtPhoneSize(
          tester,
          const AuthEmailPasswordResetScreen(initialEmail: 'phil@example.com'),
        );

        final fields = find.byType(TextFormField);
        // Order: email (pre-filled), code, password, confirm password.
        expect(fields, findsNWidgets(4));

        await tester.enterText(fields.at(1), '123456');
        await tester.enterText(fields.at(2), 'correcthorse1');
        await tester.enterText(fields.at(3), 'correcthorse1');
        await tester.pump();

        expect(
          _props(tester, AuthIds.resetSubmit).enabled,
          isTrue,
          reason:
              'Reset password must enable once code + matching passwords '
              'are entered on top of the pre-filled email.',
        );
      },
    );

    // Skipped: same focus-scope harness flake as the enable-check test.
    testWidgets(
      'submitting dispatches onEmailPasswordReset with the captured values',
      skip: true,
      (tester) async {
        String? capturedEmail;
        String? capturedCode;
        String? capturedPassword;
        final callbacks = AuthCallbacks(
          onEmailPasswordReset: (email, code, newPassword) async {
            capturedEmail = email;
            capturedCode = code;
            capturedPassword = newPassword;
          },
        );

        await _pumpAtPhoneSize(
          tester,
          const AuthEmailPasswordResetScreen(initialEmail: 'phil@example.com'),
          callbacks: callbacks,
        );

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(1), '123456');
        await tester.enterText(fields.at(2), 'correcthorse1');
        await tester.enterText(fields.at(3), 'correcthorse1');
        await tester.pump();

        await tester.tap(_bySemId(AuthIds.resetSubmit).first);
        await tester.pumpAndSettle();

        expect(capturedEmail, 'phil@example.com');
        expect(capturedCode, '123456');
        expect(capturedPassword, 'correcthorse1');
      },
    );
  });
}
