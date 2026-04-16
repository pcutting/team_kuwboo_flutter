/// Stable identifiers for chat inbox + conversation widgets.
/// Used by Semantics(identifier:) — maps to iOS UIAccessibilityIdentifier
/// and Android resource-id for Maestro / Patrol.
abstract class ChatIds {
  // inbox
  static String inboxCard(int i) => 'chat.inbox.card_conversation_$i';
  static String inboxBadgeModule(String m) =>
      'chat.inbox.badge_module_$m';
  static String inboxBadgeUnread(int i) => 'chat.inbox.badge_unread_$i';

  // conversation
  static String conversationMsgOwn(int i) =>
      'chat.conversation.msg_own_$i';
  static String conversationMsgOther(int i) =>
      'chat.conversation.msg_other_$i';
  static const conversationInput = 'chat.conversation.input_message';
  static const conversationSend = 'chat.conversation.btn_send';
}
