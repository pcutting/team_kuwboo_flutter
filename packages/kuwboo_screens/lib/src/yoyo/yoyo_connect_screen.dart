import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Pending connections — list of sent/received connection requests
/// with functional filter chips, accept/reject animations,
/// encounter context badges and mutual interest highlights.
class YoyoConnectScreen extends StatefulWidget {
  const YoyoConnectScreen({super.key});

  @override
  State<YoyoConnectScreen> createState() => _YoyoConnectScreenState();
}

class _YoyoConnectScreenState extends State<YoyoConnectScreen> {
  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('Connect', style: theme.headline.copyWith(fontSize: 24)),
              ],
            ),
          ),
          // Tab filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (final label in ['All', 'Received', 'Sent']) ...[
                  if (label != 'All') const SizedBox(width: 8),
                  ProtoPressButton(
                    duration: const Duration(milliseconds: 100),
                    onTap: () => state.onYoyoConnectFilterChanged(label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.yoyoConnectFilter == label ? theme.primary : theme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: state.yoyoConnectFilter == label
                            ? null
                            : Border.all(color: theme.text.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: state.yoyoConnectFilter == label ? Colors.white : theme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _buildConnectList(context, theme, state),
          ),
        ],
      );
  }

  Widget _buildConnectList(BuildContext context, ProtoTheme theme, PrototypeStateProvider state) {
    final connections = ProtoDemoData.connections;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: connections.length,
      itemBuilder: (context, i) {
        final conn = connections[i];
        return ProtoPressButton(
          duration: const Duration(milliseconds: 100),
          onTap: () => state.push(ProtoRoutes.yoyoProfile),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: theme.cardDecoration,
            child: Row(
              children: [
                ProtoAvatar(radius: 22, imageUrl: conn.imageUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(conn.name, style: theme.title.copyWith(fontSize: 14)),
                          const SizedBox(width: 6),
                          // "How you met" badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: conn.howMet == EncounterType.nearby
                                  ? theme.secondary.withValues(alpha: 0.15)
                                  : Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  conn.howMet == EncounterType.nearby ? Icons.pin_drop_rounded : Icons.flash_on_rounded,
                                  size: 10,
                                  color: conn.howMet == EncounterType.nearby ? theme.secondary : Colors.amber.shade700,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  conn.howMet == EncounterType.nearby ? 'Nearby' : 'Pass-by',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: conn.howMet == EncounterType.nearby ? theme.secondary : Colors.amber.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Mutual interests
                      if (conn.mutualInterests.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.interests_rounded, size: 12, color: theme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${conn.mutualInterests.length} shared: ${conn.mutualInterests.join(", ")}',
                                style: TextStyle(fontSize: 10, color: theme.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 2),
                      Text(conn.timeAgo, style: theme.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                // Direction indicator
                Icon(
                  conn.isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded,
                  size: 16,
                  color: conn.isIncoming ? theme.secondary : theme.textTertiary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
