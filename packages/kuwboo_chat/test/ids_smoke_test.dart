import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuwboo_chat/kuwboo_chat.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Finder that matches the [Semantics] widget element with the given
/// identifier (see kuwboo_auth/test/ids_smoke_test.dart for rationale —
/// the widget tree is the source of truth Maestro / Patrol read at
/// runtime).
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

Widget _host(Widget child) {
  return ProtoThemeProvider(
    theme: ProtoTheme.v0UrbanWarmth(),
    child: MaterialApp(
      home: Material(child: child),
    ),
  );
}

void main() {
  group('ChatIds constant format', () {
    test('inboxCard interpolates index', () {
      expect(ChatIds.inboxCard(0), 'chat.inbox.card_conversation_0');
      expect(ChatIds.inboxCard(7), 'chat.inbox.card_conversation_7');
    });

    test('inboxBadgeModule slots the module name', () {
      expect(
        ChatIds.inboxBadgeModule('yoyo'),
        'chat.inbox.badge_module_yoyo',
      );
      expect(
        ChatIds.inboxBadgeModule('dating'),
        'chat.inbox.badge_module_dating',
      );
    });

    test('conversationMsgOwn / conversationMsgOther interpolate index', () {
      expect(
        ChatIds.conversationMsgOwn(0),
        'chat.conversation.msg_own_0',
      );
      expect(
        ChatIds.conversationMsgOther(2),
        'chat.conversation.msg_other_2',
      );
    });

    test('conversationInput / conversationSend are the fixed strings', () {
      expect(ChatIds.conversationInput, 'chat.conversation.input_message');
      expect(ChatIds.conversationSend, 'chat.conversation.btn_send');
    });
  });

  group('ProtoConversationCard smoke', () {
    testWidgets('inbox card carries inboxCard identifier with peer + last msg',
        (tester) async {
      const conv = DemoConversation(
        name: 'Alice',
        lastMessage: 'See you tomorrow!',
        timeAgo: '5m',
        unreadCount: 3,
        moduleContext: 'YoYo',
        avatarUrl: '',
      );
      await tester.pumpWidget(_host(
        ProtoConversationCard(
          conversation: conv,
          index: 2,
          showModuleBadge: true,
          onTap: () {},
        ),
      ));
      // No pumpAndSettle — ProtoNetworkImage may try to load the avatar
      // URL forever in a unit test. One pump is enough for the synchronous
      // Semantics tree.
      await tester.pump();

      // Card identifier is rendered with the right index slot.
      expect(_bySemId(ChatIds.inboxCard(2)), findsOneWidget);

      // The card's value is the peer-name + last-msg pair Maestro reads.
      final cardProps = _props(tester, ChatIds.inboxCard(2));
      expect(cardProps.value, 'Alice: See you tomorrow!');

      // Module badge identifier is lowercased.
      expect(
        _bySemId(ChatIds.inboxBadgeModule('yoyo')),
        findsOneWidget,
      );

      // Unread badge carries the count as its semantic value.
      final unreadProps = _props(tester, ChatIds.inboxBadgeUnread(2));
      expect(unreadProps.value, '3');
    });

    testWidgets(
      'unread badge is omitted when count is 0 (matches Maestro selector contract)',
      (tester) async {
        const conv = DemoConversation(
          name: 'Bob',
          lastMessage: 'hey',
          timeAgo: '1h',
          unreadCount: 0,
          moduleContext: 'Dating',
          avatarUrl: '',
        );
        await tester.pumpWidget(_host(
          ProtoConversationCard(
            conversation: conv,
            index: 0,
            onTap: () {},
          ),
        ));
        await tester.pump();

        // Card present, but unread badge id should NOT be present.
        expect(_bySemId(ChatIds.inboxCard(0)), findsOneWidget);
        expect(_bySemId(ChatIds.inboxBadgeUnread(0)), findsNothing);
      },
    );
  });
}
