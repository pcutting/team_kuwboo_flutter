import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Wraps a widget with MaterialApp + ProtoThemeProvider so ProtoBottomNavC
/// and its friends can render in a widget test without a full app Scaffold.
Widget _host(Widget child) {
  return ProtoThemeProvider(
    theme: ProtoTheme.v0UrbanWarmth(),
    child: MaterialApp(
      home: Material(child: child),
    ),
  );
}

void main() {
  group('ShellIds constants', () {
    test('tab id is lowercase-slotted', () {
      expect(ShellIds.bottomnavTab('Dating'), 'shell.bottomnav.tab_dating');
      expect(ShellIds.bottomnavTab('For You'), 'shell.bottomnav.tab_for you');
    });

    test('service id includes module name', () {
      expect(ShellIds.bottomnavService('yoyo'), 'shell.bottomnav.service_yoyo');
    });

    test('share option id is lowercase-slotted', () {
      expect(ShellIds.shareOption('WhatsApp'),
          'shell.share_sheet.option_whatsapp');
    });
  });

  group('ProtoBottomNavC smoke', () {
    testWidgets('renders tab IDs for all feature tabs', (tester) async {
      // yoyo module → tabs: Nearby, Connect, Wave, Chat
      await tester.pumpWidget(_host(
        const SizedBox(
          height: 200,
          child: ProtoBottomNavC(
            activeModule: ProtoModule.yoyo,
            activeTab: 0,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(ShellIds.bottomnavTab('Nearby')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(ShellIds.bottomnavTab('Connect')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(ShellIds.bottomnavTab('Wave')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(ShellIds.bottomnavTab('Chat')),
        findsOneWidget,
      );
    });

    testWidgets('renders the FAB identifier', (tester) async {
      await tester.pumpWidget(_host(
        const SizedBox(
          height: 200,
          child: ProtoBottomNavC(
            activeModule: ProtoModule.yoyo,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(ShellIds.bottomnavFab),
        findsOneWidget,
      );
    });
  });

  group('ProtoBottomNavC selected state', () {
    testWidgets('active tab has isSelected flag; others do not', (tester) async {
      // Put Dating module active, with active tab 1 (Matches).
      await tester.pumpWidget(_host(
        const SizedBox(
          height: 200,
          child: ProtoBottomNavC(
            activeModule: ProtoModule.dating,
            activeTab: 1,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Matches tab → selected
      final matchesNode = tester.getSemantics(
        find.bySemanticsIdentifier(ShellIds.bottomnavTab('Matches')),
      );
      expect(
        matchesNode.hasFlag(SemanticsFlag.isSelected),
        isTrue,
        reason: 'active tab should carry SemanticsFlag.isSelected',
      );

      // Discover tab (index 0 in dating set) → NOT selected
      final discoverNode = tester.getSemantics(
        find.bySemanticsIdentifier(ShellIds.bottomnavTab('Discover')),
      );
      expect(
        discoverNode.hasFlag(SemanticsFlag.isSelected),
        isFalse,
        reason: 'inactive tab must not carry SemanticsFlag.isSelected',
      );

      // Likes tab (index 2) → NOT selected
      final likesNode = tester.getSemantics(
        find.bySemanticsIdentifier(ShellIds.bottomnavTab('Likes')),
      );
      expect(
        likesNode.hasFlag(SemanticsFlag.isSelected),
        isFalse,
      );
    });
  });
}
