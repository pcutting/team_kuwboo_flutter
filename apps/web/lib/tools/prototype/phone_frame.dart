import 'package:flutter/material.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // iPhone 15 Pro dimensions (scaled)
    const frameWidth = 320.0;
    const frameHeight = 693.0;
    const borderRadius = 44.0;
    const bezelWidth = 12.0;

    return Container(
      width: frameWidth + bezelWidth * 2,
      height: frameHeight + bezelWidth * 2,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(borderRadius + bezelWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(bezelWidth),
        child: Stack(
          children: [
            // Screen content
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                color: Colors.white,
                child: child,
              ),
            ),
            // Dynamic Island
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            // Home indicator
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
