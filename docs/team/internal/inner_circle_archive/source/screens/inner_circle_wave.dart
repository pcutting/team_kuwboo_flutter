import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'inner_circle_shared.dart';

/// Inner Circle Wave: "Ping my people" screen with quick check-in messages.
class InnerCircleWaveView extends StatefulWidget {
  const InnerCircleWaveView({super.key});

  @override
  State<InnerCircleWaveView> createState() => _InnerCircleWaveViewState();
}

class _InnerCircleWaveViewState extends State<InnerCircleWaveView> {
  int? _sentPingIndex;

  static const _quickPings = [
    ("I'm here", Icons.place_rounded),
    ('Coming home', Icons.home_rounded),
    ('On my way', Icons.directions_walk_rounded),
    ('Running late', Icons.schedule_rounded),
    ('All good', Icons.check_circle_outline_rounded),
    ('Call me', Icons.phone_rounded),
  ];

  void _sendPing(int index, String message) {
    setState(() => _sentPingIndex = index);
    final theme = ProtoTheme.of(context);
    ProtoToast.show(context, Icons.send_rounded, 'Sent "$message" to your circle');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _sentPingIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return ProtoScaffold(
      activeModule: ProtoModule.yoyo,
      activeTab: 2,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Ping', style: theme.headline.copyWith(fontSize: 24, color: warmAmber)),
              const SizedBox(width: 8),
              innerCircleBadge(theme),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Send a quick check-in to your circle',
            style: theme.body.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: 20),

          // Quick ping grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_quickPings.length, (i) {
              final (label, icon) = _quickPings[i];
              final isSent = _sentPingIndex == i;
              return ProtoPressButton(
                onTap: isSent ? null : () => _sendPing(i, label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (MediaQuery.sizeOf(context).width - 48) / 2,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSent
                        ? warmAmber.withValues(alpha: 0.2)
                        : theme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSent
                          ? warmAmber
                          : warmAmber.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSent ? Icons.check_rounded : icon,
                        size: 20,
                        color: isSent ? warmAmber : warmAmber.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSent ? 'Sent!' : label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSent ? warmAmber : theme.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),
          Text('Recent Pings', style: theme.title),
          const SizedBox(height: 10),

          // Recent pings list
          for (final ping in ProtoDemoData.circlePings)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: warmAmber.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ping.isIncoming
                            ? warmAmber.withValues(alpha: 0.5)
                            : theme.textTertiary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(ping.senderImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              ping.senderName,
                              style: theme.title.copyWith(fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              ping.isIncoming
                                  ? Icons.call_received_rounded
                                  : Icons.call_made_rounded,
                              size: 12,
                              color: ping.isIncoming ? warmAmber : theme.textTertiary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '"${ping.message}"',
                          style: theme.body.copyWith(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(ping.timeAgo, style: theme.caption),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
