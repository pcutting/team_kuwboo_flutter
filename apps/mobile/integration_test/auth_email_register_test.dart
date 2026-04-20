import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Integration-test port of three `AuthEmailRegisterScreen` tests that
/// couldn't run reliably under `flutter test`. `TextFormField` +
/// `AutofillHints` + GoRouter page replacement trips a
/// `_FocusInheritedScope` dispose assertion in the widget-test harness,
/// but the full integration-test binding mounts the real engine and
/// doesn't hit that path.
///
/// The lightweight initial-render assertion (Create Account disabled
/// until consent is confirmed) stays in
/// `packages/kuwboo_auth/test/email_register_screen_test.dart`.

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

/// Minimal host — ProtoTheme + a seeded GoRouter with marker screens for
/// the login / legal / birthday destinations the screen under test can
/// navigate to. Intentionally mirrors the widget-test `_host(...)` so
/// the test bodies stay close to the originals.
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

class _MarkerScreen extends StatelessWidget {
  const _MarkerScreen({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

/// Scroll the register ListView so the widget with [semId] is mounted
/// in the element tree. Needed because `IntegrationTestWidgetsFlutterBinding`
/// ignores `setSurfaceSize` — the real simulator viewport leaves the
/// consent checkboxes / submit below the fold on first pump, and
/// unmounted children can't be tapped or queried.
Future<void> _scrollIntoView(WidgetTester tester, String semId) async {
  if (_bySemId(semId).evaluate().isNotEmpty) return;
  final scrollable = _registerScrollable();
  for (var attempt = 0; attempt < 15; attempt++) {
    if (_bySemId(semId).evaluate().isNotEmpty) break;
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (_bySemId(semId).evaluate().isEmpty) {
    throw StateError(
      'Could not scroll Semantics widget with identifier "$semId" into '
      'the element tree.',
    );
  }
  await tester.pump();
}

/// Find the ListView's Scrollable inside `AuthEmailRegisterScreen`.
/// Anchored on the email field (always at the top of the list) so we
/// don't accidentally grab a different scrollable from overlays.
Finder _registerScrollable() {
  return find.ancestor(
    of: _bySemId(AuthIds.registerEmailField).first,
    matching: find.byType(Scrollable),
  );
}

/// Enter text into the field identified by [semId], scrolling it into
/// view first so it's realised and focusable.
Future<void> _enterTextById(
  WidgetTester tester,
  String semId,
  String text,
) async {
  await _scrollIntoView(tester, semId);
  final editable = find.descendant(
    of: _bySemId(semId).first,
    matching: find.byType(EditableText),
  );
  await tester.enterText(editable, text);
  await tester.pump();
}

Future<void> _tapById(WidgetTester tester, String semId) async {
  await _scrollIntoView(tester, semId);
  await tester.tap(_bySemId(semId).first);
  await tester.pump();
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget child, {
  AuthCallbacks? callbacks,
}) async {
  await tester.pumpWidget(_host(child, callbacks: callbacks));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AuthEmailRegisterScreen (integration)', () {
    testWidgets(
        'Create Account enables once email, passwords, and both '
        'checkboxes are satisfied', (tester) async {
      await _pumpScreen(tester, const AuthEmailRegisterScreen());

      await _enterTextById(
        tester,
        AuthIds.registerEmailField,
        'phil@example.com',
      );
      await _enterTextById(
        tester,
        AuthIds.registerPasswordField,
        'correcthorse1',
      );
      await _enterTextById(
        tester,
        AuthIds.registerConfirmPasswordField,
        'correcthorse1',
      );

      // Submit should still be disabled — checkboxes are unticked.
      await _scrollIntoView(tester, AuthIds.registerSubmit);
      expect(
        _props(tester, AuthIds.registerSubmit).enabled,
        isFalse,
        reason:
            'Submit should stay disabled with valid form but unticked consents',
      );

      await _tapById(tester, AuthIds.registerAgeConfirm);
      await _tapById(tester, AuthIds.registerLegalAccept);

      await _scrollIntoView(tester, AuthIds.registerSubmit);
      expect(
        _props(tester, AuthIds.registerSubmit).enabled,
        isTrue,
        reason:
            'Submit must enable once both checkboxes are ticked and the '
            'form is valid.',
      );
    });

    testWidgets(
        'tapping Submit dispatches onEmailRegister with the entered '
        'values', (tester) async {
      EmailRegisterRequest? captured;
      final callbacks = AuthCallbacks(
        onEmailRegister: (req) async => captured = req,
      );

      await _pumpScreen(
        tester,
        const AuthEmailRegisterScreen(),
        callbacks: callbacks,
      );

      await _enterTextById(
        tester,
        AuthIds.registerEmailField,
        'phil@example.com',
      );
      await _enterTextById(
        tester,
        AuthIds.registerPasswordField,
        'correcthorse1',
      );
      await _enterTextById(
        tester,
        AuthIds.registerConfirmPasswordField,
        'correcthorse1',
      );
      await _enterTextById(
        tester,
        AuthIds.registerNameField,
        'Phil',
      );

      await _tapById(tester, AuthIds.registerAgeConfirm);
      await _tapById(tester, AuthIds.registerLegalAccept);
      await _tapById(tester, AuthIds.registerSubmit);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.email, 'phil@example.com');
      expect(captured!.password, 'correcthorse1');
      expect(captured!.name, 'Phil');
      expect(captured!.ageConfirmed, isTrue);
      expect(captured!.legalAccepted, isTrue);
    });

    testWidgets('tapping the "Log in" link navigates to login screen',
        (tester) async {
      await _pumpScreen(tester, const AuthEmailRegisterScreen());

      await _tapById(tester, AuthIds.registerLoginLink);
      await tester.pumpAndSettle();

      expect(find.text('login-screen'), findsOneWidget);
    });
  });
}
