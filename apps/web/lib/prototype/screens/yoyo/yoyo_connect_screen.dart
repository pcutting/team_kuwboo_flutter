import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import 'yoyo_shared.dart';
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
  ValueNotifier<int>? _variantCount;
  ValueNotifier<int>? _variantIndex;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = PrototypeStateProvider.maybeOf(context);
    if (provider != null && _variantIndex == null) {
      _variantCount = provider.screenVariantCount;
      _variantIndex = provider.screenVariantIndex;
      _variantIndex!.value = provider.yoyoVariant;
      _variantIndex!.addListener(_onExternalVariantChange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _variantCount!.value = 2;
      });
    }
  }

  void _onExternalVariantChange() {
    final idx = _variantIndex?.value ?? 0;
    final state = PrototypeStateProvider.maybeOf(context);
    if (state != null && idx != state.yoyoVariant && idx >= 0 && idx < 2) {
      state.onYoyoVariantChanged(idx);
    }
  }

  @override
  void dispose() {
    _variantIndex?.removeListener(_onExternalVariantChange);
    _variantCount?.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final filtered = _filteredRequests(state.yoyoConnectFilter);
    if (_variantIndex != null && _variantIndex!.value != state.yoyoVariant) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _variantIndex!.value = state.yoyoVariant;
      });
    }

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
                const SizedBox(width: 8),
                if (state.yoyoVariant == 1) yoyoV2Badge(theme),
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
            child: state.yoyoVariant == 1
                ? _buildV2ConnectList(context, theme, state)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final req = filtered[i];
                final origIdx = _originalIndex(req);
                final isAccepted = _acceptedIndices.contains(origIdx);
                final isRejected = _rejectedIndices.contains(origIdx);

                return ProtoPressButton(
                  duration: const Duration(milliseconds: 100),
                  onTap: () => state.push(ProtoRoutes.yoyoProfile),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isRejected ? 0.3 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: theme.cardDecoration,
                      child: Row(
                        children: [
                          ProtoAvatar(radius: 18, imageUrl: req.imageUrl),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(req.name, style: theme.title.copyWith(fontSize: 13)),
                                const SizedBox(height: 2),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isAccepted
                                      ? Text('Connected!', key: const ValueKey('connected'), style: theme.caption.copyWith(fontSize: 10, color: theme.secondary, fontWeight: FontWeight.w600))
                                      : isRejected
                                          ? Text('Declined', key: const ValueKey('declined'), style: theme.caption.copyWith(fontSize: 10, color: theme.textTertiary))
                                          : Text(req.timeAgo, key: ValueKey('time-$origIdx'), style: theme.caption.copyWith(fontSize: 10), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (req.isIncoming && !isAccepted && !isRejected) ...[
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() => _acceptedIndices.add(origIdx));
                                ProtoToast.show(context, theme.icons.group, 'Connected with ${req.name}!');
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(theme.icons.check, size: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() => _rejectedIndices.add(origIdx));
                                ProtoToast.show(context, theme.icons.close, 'Declined ${req.name}');
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.textTertiary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(theme.icons.close, size: 16, color: theme.textTertiary),
                              ),
                            ),
                          ] else if (isAccepted)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                key: const ValueKey('accepted-badge'),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(theme.icons.check, size: 16, color: Colors.white),
                              ),
                            )
                          else if (!req.isIncoming && !isAccepted && !isRejected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.textTertiary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Pending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: theme.textSecondary)),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
