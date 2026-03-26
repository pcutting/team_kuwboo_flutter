import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/phone_frame.dart';
import 'widgets/compact_layout.dart';
import 'widgets/medium_layout.dart';
import 'widgets/web_utils.dart' as web;
import 'data/design_registry.dart';
import 'data/badge_config.dart';
import 'data/badge_config_provider.dart';
import 'prototype/prototype_app.dart';
import 'widgets/proto_design_sidebar.dart';

class DesignViewerApp extends StatelessWidget {
  const DesignViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kawboo Design',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a1a2e),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const ViewerHome(),
    );
  }
}

class ViewerHome extends StatefulWidget {
  const ViewerHome({super.key});

  @override
  State<ViewerHome> createState() => _ViewerHomeState();
}

class _ViewerHomeState extends State<ViewerHome> {
  int _selectedDesign = 3; // Street (original index 6)
  int? _selectedPalette;
  int? _selectedIconSet;
  int _yoyoVariant = 0;
  int _yoyoMode = 0;
  DesignSet _designSet = DesignSet.setC;
  bool _updateAvailable = false;
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<BadgeConfig> _badgeConfig =
      ValueNotifier(const BadgeConfig());
  final ValueNotifier<String?> _navigateNotifier = ValueNotifier(null);
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    // Poll for service worker updates every 10 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_updateAvailable && web.hasUpdate) {
        setState(() => _updateAvailable = true);
        _updateTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _focusNode.dispose();
    _badgeConfig.dispose();
    _navigateNotifier.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    // Keyboard shortcuts removed — Street theme is locked in
  }

  void _onYoyoVariantChanged(int variant) {
    setState(() => _yoyoVariant = variant);
  }

  void _onYoyoModeChanged(int mode) {
    setState(() => _yoyoMode = mode);
  }

  Widget _buildPrototypePanel() {
    final designs = DesignRegistry.getDesigns(_designSet);
    final designName = designs[_selectedDesign].shortName.toUpperCase();

    return Container(
      color: const Color(0xFF0d0d14),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Design name header
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1877F2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    designName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            // Phone frame with prototype — map visible index to original design index
            PhoneFrame(
              child: PrototypeApp(
                designIndex: DesignRegistry.visibleOriginalIndices[_selectedDesign],
                paletteIndex: _selectedPalette,
                iconSetIndex: _selectedIconSet,
                yoyoVariant: _yoyoVariant,
                onYoyoVariantChanged: _onYoyoVariantChanged,
                yoyoMode: _yoyoMode,
                onYoyoModeChanged: _onYoyoModeChanged,
                navigateNotifier: _navigateNotifier,
              ),
            ),
            // Hint
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'Interactive prototype \u2022 Tap to navigate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedLayout(DesignMetadata design) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d14),
      body: Row(
        children: [
          // Left: sidebar controls
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: ProtoDesignSidebar(
              yoyoVariant: _yoyoVariant,
              onYoyoVariantChanged: _onYoyoVariantChanged,
              yoyoMode: _yoyoMode,
              onYoyoModeChanged: _onYoyoModeChanged,
              onNavigateRoute: (route) => _navigateNotifier.value = route,
            ),
          ),
          // Center: Prototype panel
          Expanded(
            child: _buildPrototypePanel(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final designs = DesignRegistry.getDesigns(_designSet);
    final design = designs[_selectedDesign];
    final width = MediaQuery.sizeOf(context).width;

    return BadgeConfigProvider(
      notifier: _badgeConfig,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            // Main content
            width < 600
                ? CompactLayout(
                    originalDesignIndex: DesignRegistry.visibleOriginalIndices[_selectedDesign],
                    paletteIndex: _selectedPalette,
                    iconSetIndex: _selectedIconSet,
                    yoyoVariant: _yoyoVariant,
                    onYoyoVariantChanged: _onYoyoVariantChanged,
                    yoyoMode: _yoyoMode,
                    onYoyoModeChanged: _onYoyoModeChanged,
                  )
                : width < 1024
                    ? MediumLayout(
                        originalDesignIndex: DesignRegistry.visibleOriginalIndices[_selectedDesign],
                        paletteIndex: _selectedPalette,
                        iconSetIndex: _selectedIconSet,
                        yoyoVariant: _yoyoVariant,
                        onYoyoVariantChanged: _onYoyoVariantChanged,
                        yoyoMode: _yoyoMode,
                        onYoyoModeChanged: _onYoyoModeChanged,
                      )
                    : _buildExpandedLayout(design),
            // Update available banner
            if (_updateAvailable)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _UpdateBanner(
                        onUpdate: web.applyUpdate,
                        onDismiss: () =>
                            setState(() => _updateAvailable = false),
                      ),
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

// ─── Update Available Banner ────────────────────────────────────────────

class _UpdateBanner extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  const _UpdateBanner({
    required this.onUpdate,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF7c3aed),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.system_update_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          const Text(
            'New version available',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onUpdate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
