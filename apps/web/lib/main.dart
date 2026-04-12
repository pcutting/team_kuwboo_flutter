import 'package:flutter/material.dart';
import 'prototype/prototype_app.dart';
import 'widgets/phone_frame.dart';

void main() {
  runApp(const KuwbooPrototypeWeb());
}

/// Web entry point for the Kuwboo prototype.
///
/// Previously this app wrapped a design-variant picker (Set A/B/C). The
/// design is finalized to Urban Warmth, so we now launch the prototype
/// directly inside a PhoneFrame for desktop preview (and full-bleed on
/// mobile widths).
class KuwbooPrototypeWeb extends StatelessWidget {
  const KuwbooPrototypeWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuwboo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a1a2e),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const _PrototypeHost(),
    );
  }
}

class _PrototypeHost extends StatelessWidget {
  const _PrototypeHost();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    const prototype = PrototypeApp();

    if (width < 600) return prototype;

    return const Scaffold(
      backgroundColor: Color(0xFF0d0d14),
      body: Center(child: PhoneFrame(child: prototype)),
    );
  }
}
