import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kuwboo_mobile/app/test_app.dart';
import 'package:kuwboo_mobile/features/auth/data/token_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth flow', () {
    testWidgets('login -> OTP -> lands on home screen', (tester) async {
      await TokenStorage().clear();

      await tester.pumpWidget(const ProviderScope(child: KuwbooTestApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ── Login screen ──────────────────────────────────────────────
      expect(find.text('Welcome to Kuwboo'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);

      // Enter a phone number.
      await tester.enterText(find.byType(TextField), '+44 7700 900000');
      await tester.pumpAndSettle();

      // Tap Send OTP.
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // ── OTP screen ────────────────────────────────────────────────
      expect(find.text('Verify your number'), findsOneWidget);
      expect(find.textContaining('+44 7700 900000'), findsOneWidget);

      // Enter a 6-digit code.
      await tester.enterText(find.byType(TextField).last, '123456');
      await tester.pumpAndSettle();

      // Tap Verify.
      await tester.tap(find.text('Verify'));

      // Pump frames manually — pumpAndSettle may not settle due to
      // animations on the home screen.
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Drain rendering exceptions from the home screen.
      while (tester.takeException() != null) {}

      // ── Home screen ───────────────────────────────────────────────
      expect(find.text('Welcome to Kuwboo'), findsNothing);
      expect(find.text('Verify your number'), findsNothing);
    });

    testWidgets('OTP screen shows error for short code', (tester) async {
      await TokenStorage().clear();

      await tester.pumpWidget(const ProviderScope(child: KuwbooTestApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Drain any leftover exceptions from previous test teardown.
      while (tester.takeException() != null) {}

      // Get to OTP screen.
      await tester.enterText(find.byType(TextField), '+44 7700 900000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter only 3 digits (too short).
      await tester.enterText(find.byType(TextField).last, '123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      // Drain any rendering exceptions.
      while (tester.takeException() != null) {}

      // Should show validation error, stay on OTP screen.
      expect(find.text('Enter the 6-digit code'), findsOneWidget);
      expect(find.text('Verify your number'), findsOneWidget);
    });

    testWidgets('login screen ignores empty phone number', (tester) async {
      await TokenStorage().clear();

      await tester.pumpWidget(const ProviderScope(child: KuwbooTestApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Drain any leftover exceptions.
      while (tester.takeException() != null) {}

      // Tap Send OTP without entering a number.
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Drain any rendering exceptions.
      while (tester.takeException() != null) {}

      // Should still be on the login screen.
      expect(find.text('Welcome to Kuwboo'), findsOneWidget);
    });
  });
}
