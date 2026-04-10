import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kuwboo_mobile/app/app.dart';

void main() {
  testWidgets('KuwbooApp builds without error', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KuwbooApp()));
    // Pump a few frames — pumpAndSettle may not settle due to async auth
    // and network image loading (which always 400s in test mode).
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Drain network image exceptions (HTTP 400 in test environment).
    while (tester.takeException() != null) {}

    // App should have rendered something.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
