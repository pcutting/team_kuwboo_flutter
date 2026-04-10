import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kuwboo_mobile/app/app.dart';

void main() {
  testWidgets('KuwbooApp builds without error', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KuwbooApp()));
    // Just verify it builds — pumpAndSettle may time out due to async auth,
    // so pump a few frames instead.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // App should have rendered something.
    expect(find.byType(KuwbooApp), findsOneWidget);
  });
}
