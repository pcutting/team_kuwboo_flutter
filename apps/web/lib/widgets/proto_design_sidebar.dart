import 'package:flutter/material.dart';

/// Sidebar controls for the desktop viewer — YoYo toggles and Auth flow nav.
/// Theme/palette/icon pickers removed (Street theme is locked in).
class ProtoDesignSidebar extends StatelessWidget {
  final int yoyoMode;
  final ValueChanged<int>? onYoyoModeChanged;
  final ValueChanged<String>? onNavigateRoute;

  const ProtoDesignSidebar({
    super.key,
    this.yoyoMode = 0,
    this.onYoyoModeChanged,
    this.onNavigateRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // YoYo Mode toggle (Social / Inner Circle)
          if (onYoyoModeChanged != null) ...[
            _YoyoModeToggle(
              mode: yoyoMode,
              onChanged: onYoyoModeChanged!,
            ),
          ],
          // Auth Flow quick-launch
          if (onNavigateRoute != null) ...[
            const SizedBox(height: 16),
            _AuthFlowSection(
              onNavigate: onNavigateRoute!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Social / Inner Circle pill toggle for the YoYo module.
class _YoyoModeToggle extends StatelessWidget {
  final int mode;
  final ValueChanged<int> onChanged;

  const _YoyoModeToggle({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const warmAmber = Color(0xFFD4A04A);
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'YoYo Mode',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: mode == 0
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: mode == 0
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Social',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: mode == 0 ? FontWeight.w700 : FontWeight.w400,
                          color: mode == 0
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: mode == 1
                          ? warmAmber.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: mode == 1
                            ? warmAmber.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Circle',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: mode == 1 ? FontWeight.w700 : FontWeight.w400,
                          color: mode == 1
                              ? warmAmber
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Auth flow quick-launch section in the sidebar.
class _AuthFlowSection extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const _AuthFlowSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'Auth Flow',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          _AuthFlowButton(
            label: 'Sign Up',
            icon: Icons.person_add_outlined,
            route: '/auth/method',
            onNavigate: onNavigate,
          ),
          const SizedBox(height: 4),
          _AuthFlowButton(
            label: 'Log In',
            icon: Icons.login_rounded,
            route: '/auth/login',
            onNavigate: onNavigate,
          ),
        ],
      ),
    );
  }
}

class _AuthFlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final ValueChanged<String> onNavigate;

  const _AuthFlowButton({
    required this.label,
    required this.icon,
    required this.route,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onNavigate(route),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

