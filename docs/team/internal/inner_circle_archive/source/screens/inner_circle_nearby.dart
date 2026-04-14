import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'inner_circle_shared.dart';

/// Inner Circle Nearby: Full-screen map with family member pins and floating card.
class InnerCircleNearbyView extends StatefulWidget {
  const InnerCircleNearbyView({super.key});

  @override
  State<InnerCircleNearbyView> createState() => _InnerCircleNearbyViewState();
}

class _InnerCircleNearbyViewState extends State<InnerCircleNearbyView> {
  int? _selectedMember;

  @override
  Widget build(BuildContext context) {
    // TODO: Wire Inner Circle filter settings (distance, age, online-only) to nearby filtering in production
    final members = ProtoDemoData.familyMembers;
    final theme = ProtoTheme.of(context);

    return ProtoScaffold(
      activeModule: ProtoModule.yoyo,
      activeTab: 0,
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: InnerCircleMapPlaceholder(
              members: members,
              selectedIndex: _selectedMember,
              onPinTapped: (index) {
                setState(() {
                  _selectedMember = _selectedMember == index ? null : index;
                });
              },
            ),
          ),
          // Floating card at bottom when a pin is selected
          if (_selectedMember != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: InnerCircleFloatingCard(
                member: members[_selectedMember!],
                onClose: () => setState(() => _selectedMember = null),
              ),
            ),
          // Top-left family count indicator
          Positioned(
            top: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: warmAmber.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.family_restroom_rounded, size: 14, color: warmAmber),
                  const SizedBox(width: 6),
                  Text(
                    '${members.length} tracked',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.successColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${members.where((m) => m.isOnline).length} online',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
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
