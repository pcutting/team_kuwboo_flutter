import 'package:flutter/material.dart';
import '../prototype/prototype_app.dart';
import 'phone_frame.dart';
import 'proto_design_sidebar.dart';

/// Medium layout (600-1024px) — phone frame + sidebar controls, no theme pickers.
class MediumLayout extends StatelessWidget {
  final int originalDesignIndex;
  final int? paletteIndex;
  final int? iconSetIndex;
  final int yoyoMode;
  final ValueChanged<int> onYoyoModeChanged;

  const MediumLayout({
    super.key,
    required this.originalDesignIndex,
    required this.paletteIndex,
    required this.iconSetIndex,
    required this.yoyoMode,
    required this.onYoyoModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d14),
      body: SafeArea(
        child: Column(
          children: [
            // Branding bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF16161e),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'KAWBOO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7c3aed),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'DESIGN',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ProtoDesignSidebar(
                      yoyoMode: yoyoMode,
                      onYoyoModeChanged: onYoyoModeChanged,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: PhoneFrame(
                        child: PrototypeApp(
                          designIndex: originalDesignIndex,
                          paletteIndex: paletteIndex,
                          iconSetIndex: iconSetIndex,
                          yoyoMode: yoyoMode,
                          onYoyoModeChanged: onYoyoModeChanged,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
