import 'package:flutter/material.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Single conversation view with message bubbles and text input.
class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({required this.threadId, super.key});

  final String threadId;

  @override
  State<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // Current user ID placeholder.
  static const _currentUserId = 'user_1';

  // Demo messages for UI scaffolding.
  late final List<Message> _messages = [
    Message(
      id: 'msg_1',
      threadId: widget.threadId,
      senderId: 'user_2',
      text: 'Hi, is this item still available?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Message(
      id: 'msg_2',
      threadId: widget.threadId,
      senderId: _currentUserId,
      text: 'Yes it is! Are you interested?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    Message(
      id: 'msg_3',
      threadId: widget.threadId,
      senderId: 'user_2',
      text: 'Definitely. What condition is it in?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    Message(
      id: 'msg_4',
      threadId: widget.threadId,
      senderId: _currentUserId,
      text: 'It\'s in great condition, barely used. '
          'I can send you more photos if you want.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    Message(
      id: 'msg_5',
      threadId: widget.threadId,
      senderId: 'user_2',
      text: 'That would be great, thanks!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          id: 'msg_${_messages.length + 1}',
          threadId: widget.threadId,
          senderId: _currentUserId,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    // Scroll to bottom after frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: call MessagingApi.sendMessage()
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMine = message.senderId == _currentUserId;
                return _MessageBubble(
                  message: message,
                  isMine: isMine,
                  timeLabel: _formatTime(message.createdAt),
                );
              },
            ),
          ),

          // Input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor:
                            theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.timeLabel,
  });

  final Message message;
  final bool isMine;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMine
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isMine
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
