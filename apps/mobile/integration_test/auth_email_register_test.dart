import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Integration-test port of three `AuthEmailRegisterScreen` tests.
///
/// All three tests run against the live simulator binding. The screen
/// now uses `SingleChildScrollView + Column` so all children are always
/// materialised regardless of keyboard inset changes — the cacheExtent
/// eviction that previously required `skip: true` on the form-behaviour
/// tests no longer occurs.

Finder _bySemId(String id) {
  return find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.identifier == id,
    description: 'Semantics widget with identifier "$id"',
  );
}

/// Minimal host — ProtoTheme + a seeded GoRouter with marker screens
/// for the login / legal / birthday destinations the screen under test
/// can navigate to. Mirrors the widget-test `_host(...)` so the test
/// bodies stay close to the originals.
Widget _host(Widget child, {AuthCallbacks? callbacks}) {
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

/// Drag the register Column until the widget with [semId] lands in
/// the element tree — used for targets below the simulator fold
/// (e.g. the "Log in" link at the bottom of the list).
Future<void> _scrollIntoView(WidgetTester tester, String semId) async {
  if (_bySemId(semId).evaluate().isNotEmpty) return;
  final scrollable = find.byType(Scrollable).last;
  for (var attempt = 0; attempt < 15; attempt++) {
    if (_bySemId(semId).evaluate().isNotEmpty) break;
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (_bySemId(semId).evaluate().isEmpty) {
    throw StateError(
      'Could not scroll Semantics widget with identifier "$semId" '
      'into the element tree.',
    );
  }
  await tester.pumpAndSettle();
}

Future<void> _tapById(WidgetTester tester, String semId) async {
  await _scrollIntoView(tester, semId);
  // `warnIfMissed: false` because the tap point can sit below the
  // visible fold on the real simulator; the pointer event is still
  // dispatched to the GestureDetector / InkWell and its `onTap` fires.
  await tester.tap(_bySemId(semId).first, warnIfMissed: false);
  await tester.pumpAndSettle();
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
    testWidgets('tapping the "Log in" link navigates to login screen', (
      tester,
    ) async {
      await _pumpScreen(tester, const AuthEmailRegisterScreen());

      await _tapById(tester, AuthIds.registerLoginLink);
      await tester.pumpAndSettle();

      expect(find.text('login-screen'), findsOneWidget);
    });

    testWidgets('Create Account enables once email, passwords, and both '
        'checkboxes are satisfied', (tester) async {
      await _pumpScreen(tester, const AuthEmailRegisterScreen());

      // Submit must start disabled — no consent, no input.
      expect(_submitEnabled(tester), isFalse);

      await tester.enterText(
        _bySemId(AuthIds.registerEmailField),
        'alex@example.com',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        _bySemId(AuthIds.registerPasswordField),
        'correcthorse9',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        _bySemId(AuthIds.registerConfirmPasswordField),
        'correcthorse9',
      );
      await tester.pumpAndSettle();

      // Still disabled — neither checkbox ticked yet.
      expect(_submitEnabled(tester), isFalse);

      // Dismiss the iOS keyboard that came up during text entry so the
      // consent rows sit inside the hit-test region rather than behind
      // the IME overlay.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await _tapById(tester, AuthIds.registerAgeConfirm);
      // Still disabled — only one checkbox is on.
      expect(_submitEnabled(tester), isFalse);

      await _tapById(tester, AuthIds.registerLegalAccept);
      // Both checkboxes now on, fields populated: submit must be enabled.
      expect(_submitEnabled(tester), isTrue);
    });

    testWidgets('tapping Submit dispatches onEmailRegister with the entered '
        'values', (tester) async {
      EmailRegisterRequest? captured;
      final callbacks = AuthCallbacks(
        onEmailRegister: (req) async {
          captured = req;
        },
      );

      await _pumpScreen(
        tester,
        const AuthEmailRegisterScreen(),
        callbacks: callbacks,
      );

      await tester.enterText(
        _bySemId(AuthIds.registerEmailField),
        'alex@example.com',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        _bySemId(AuthIds.registerPasswordField),
        'correcthorse9',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        _bySemId(AuthIds.registerConfirmPasswordField),
        'correcthorse9',
      );
      await tester.pumpAndSettle();

      // Dismiss the iOS keyboard so consent + submit targets are hit-
      // testable rather than occluded by the IME overlay.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await _tapById(tester, AuthIds.registerAgeConfirm);
      await _tapById(tester, AuthIds.registerLegalAccept);
      await _tapById(tester, AuthIds.registerSubmit);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.email, 'alex@example.com');
      expect(captured!.password, 'correcthorse9');
      expect(captured!.legalAccepted, isTrue);
      expect(captured!.ageConfirmed, isTrue);
    });
  });
}

/// Read the `enabled` property off the submit button's Semantics widget.
/// Mirrors the widget-test `_props` helper — takes the first match to
/// tolerate the same widget appearing in both cached and live subtrees.
bool _submitEnabled(WidgetTester tester) {
  final matches = _bySemId(AuthIds.registerSubmit).evaluate().toList();
  if (matches.isEmpty) {
    throw StateError(
      'No Semantics widget with identifier "${AuthIds.registerSubmit}" '
      'in the tree.',
    );
  }
  return (matches.first.widget as Semantics).properties.enabled ?? false;
}
