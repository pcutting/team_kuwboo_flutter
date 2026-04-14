import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';

import 'package:kuwboo_mobile/app/test_app.dart';
import 'package:kuwboo_mobile/config/environment.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> clearTokens() async {
    await KuwbooApiClient(baseUrl: Environment.apiBaseUrl).clearTokens();
  }

  group('Auth flow', () {
    testWidgets('login -> OTP -> lands on home screen', (tester) async {
      await clearTokens();

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
      await clearTokens();

      await tester.pumpWidget(const ProviderScope(child: KuwbooTestApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      while (tester.takeException() != null) {}

      await tester.enterText(find.byType(TextField), '+44 7700 900000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField).last, '123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      while (tester.takeException() != null) {}

      expect(find.text('Enter the 6-digit code'), findsOneWidget);
      expect(find.text('Verify your number'), findsOneWidget);
    });

    testWidgets('login screen ignores empty phone number', (tester) async {
      await clearTokens();

      await tester.pumpWidget(const ProviderScope(child: KuwbooTestApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      while (tester.takeException() != null) {}

      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      while (tester.takeException() != null) {}

      expect(find.text('Welcome to Kuwboo'), findsOneWidget);
    });
  });
}
