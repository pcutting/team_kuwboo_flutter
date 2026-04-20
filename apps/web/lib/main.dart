import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock/package_overrides.dart';
import 'prototype/app.dart';
import 'providers/auth_provider.dart';
import 'widgets/phone_frame.dart';

Future<void> main() async {
  // Must initialize before any plugin call (flutter_secure_storage, etc.)
  // and before spinning up the ProviderContainer that reads from them.
  WidgetsFlutterBinding.ensureInitialized();

  // Build the container up-front so we can await AuthNotifier hydration
  // (localStorage read + /users/me) BEFORE the router evaluates its first
  // redirect. Without this, GoRouter sees `isLoading: true`, paints the
  // welcome screen for a frame, then refreshListenable flips to
  // authenticated — producing a visible flash AND a race where an early
  // tap during the flash discards the valid session.
  final container = ProviderContainer(
    overrides: buildWebPackageOverrides(),
  );
  try {
    await container.read(authProvider.notifier).ready;
  } catch (_) {/* non-fatal — boot with whatever state we have */}

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KuwbooPrototypeWeb(),
    ),
  );
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
