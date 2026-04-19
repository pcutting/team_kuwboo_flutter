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
        path: ProtoRoutes.authEmailRegister,
        builder: (c, s) => const _MarkerScreen(label: 'register-screen'),
      ),
      GoRoute(
        path: ProtoRoutes.videoFeed,
        builder: (c, s) => const _MarkerScreen(label: 'feed'),
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
  group('AuthEmailLoginScreen', () {
    testWidgets('Log In button starts disabled', (tester) async {
      await _pumpAtPhoneSize(tester, const AuthEmailLoginScreen());

      expect(
        _props(tester, AuthIds.loginSubmit).enabled,
        isFalse,
        reason: 'Log in must be disabled before either field is filled',
      );
    });

    testWidgets('Log In enables once both fields are non-empty',
        (tester) async {
      await _pumpAtPhoneSize(tester, const AuthEmailLoginScreen());

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.at(0), 'phil@example.com');
      await tester.pump();
      // Still disabled — password empty.
      expect(_props(tester, AuthIds.loginSubmit).enabled, isFalse);

      await tester.enterText(fields.at(1), 'hunter22');
      await tester.pump();

      expect(
        _props(tester, AuthIds.loginSubmit).enabled,
        isTrue,
        reason: 'Log in must enable once both fields are non-empty',
      );
    });

    testWidgets('Submit invokes onEmailLogin with entered credentials',
        (tester) async {
      String? capturedEmail;
      String? capturedPassword;
      final callbacks = AuthCallbacks(
        onEmailLogin: (email, password) async {
          capturedEmail = email;
          capturedPassword = password;
        },
      );

      await _pumpAtPhoneSize(
        tester,
        const AuthEmailLoginScreen(),
        callbacks: callbacks,
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'phil@example.com');
      await tester.enterText(fields.at(1), 'hunter22');
      await tester.pump();

      await tester.tap(_bySemId(AuthIds.loginSubmit).first);
      await tester.pumpAndSettle();

      expect(capturedEmail, 'phil@example.com');
      expect(capturedPassword, 'hunter22');
    });

    testWidgets('Create account link navigates to register screen',
        (tester) async {
      await _pumpAtPhoneSize(tester, const AuthEmailLoginScreen());

      await tester.ensureVisible(_bySemId(AuthIds.loginRegisterLink).first);
      await tester.pumpAndSettle();
      await tester.tap(_bySemId(AuthIds.loginRegisterLink).first);
      await tester.pumpAndSettle();

      expect(find.text('register-screen'), findsOneWidget);
    });
  });
}
