import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import 'inner_circle_connect.dart';

/// Pending connections — list of sent/received connection requests
/// with functional filter chips, accept/reject animations.
/// V2 adds encounter context badges and mutual interest highlights.
class YoyoConnectScreen extends StatefulWidget {
  const YoyoConnectScreen({super.key});

  static const _requests = [
    _ConnectionRequest('Maya', 'Sent you a request', '5m ago', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', true),
    _ConnectionRequest('Jordan', 'You sent a request', '1h ago', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', false),
    _ConnectionRequest('Sam', 'Sent you a request', '3h ago', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', true),
    _ConnectionRequest('Riley', 'You sent a request', '1d ago', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', false),
  ];

  @override
  State<YoyoConnectScreen> createState() => _YoyoConnectScreenState();
}

class _YoyoConnectScreenState extends State<YoyoConnectScreen> {
  final Set<int> _acceptedIndices = {};
  final Set<int> _rejectedIndices = {};

  List<_ConnectionRequest> _filteredRequests(String filter) {
    return YoyoConnectScreen._requests.asMap().entries.where((entry) {
      if (filter == 'Received') return entry.value.isIncoming;
      if (filter == 'Sent') return !entry.value.isIncoming;
      return true; // 'All'
    }).map((e) => e.value).toList();
  }

  /// Get the original index from the full list for a filtered item.
  int _originalIndex(_ConnectionRequest req) {
    return YoyoConnectScreen._requests.indexOf(req);
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final filtered = _filteredRequests(state.yoyoConnectFilter);

    if (state.yoyoMode == 1) {
      return const InnerCircleConnectView();
    }

    return ProtoScaffold(
      activeModule: ProtoModule.yoyo,
      activeTab: 1,
      body: Column(
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
            child: _buildV2ConnectList(context, theme, state),
          ),
        ],
      ),
    );
  }


  Widget _buildV2ConnectList(BuildContext context, ProtoTheme theme, PrototypeStateProvider state) {
    final connections = ProtoDemoData.v2Connections;
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

class _ConnectionRequest {
  final String name;
  final String status;
  final String timeAgo;
  final String imageUrl;
  final bool isIncoming;
  const _ConnectionRequest(this.name, this.status, this.timeAgo, this.imageUrl, this.isIncoming);
}
