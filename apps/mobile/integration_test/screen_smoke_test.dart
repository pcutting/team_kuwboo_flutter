import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kuwboo_api_client/kuwboo_api_client.dart';

import 'package:kuwboo_mobile/app/test_app.dart';
import 'package:kuwboo_mobile/config/environment.dart';

/// Smoke tests that verify each major screen renders without assertion errors.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Helper: launch app, authenticate, and wait for the home screen.
  Future<void> launchAndAuthenticate(WidgetTester tester) async {
    await KuwbooApiClient(baseUrl: Environment.apiBaseUrl).clearTokens();

    await tester.pumpWidget(const ProviderScope(child: KuwbooTestApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Login screen -> enter phone -> Send OTP.
    await tester.enterText(find.byType(TextField), '+44 7700 900000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // OTP screen -> enter code -> Verify.
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  group('Screen smoke tests', () {
    testWidgets('app launches and shows login screen', (tester) async {
      await KuwbooApiClient(baseUrl: Environment.apiBaseUrl).clearTokens();

      await tester.pumpWidget(const ProviderScope(child: KuwbooTestApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Welcome to Kuwboo'), findsOneWidget);
    });

    testWidgets('home screen renders after auth without assertion errors',
        (tester) async {
      await launchAndAuthenticate(tester);

      // Should be on the home screen (no auth screens visible).
      expect(find.text('Welcome to Kuwboo'), findsNothing);
      expect(find.text('Verify your number'), findsNothing);

      // No assertion errors should have been thrown.
      expect(tester.takeException(), isNull);
    });
  });
}
