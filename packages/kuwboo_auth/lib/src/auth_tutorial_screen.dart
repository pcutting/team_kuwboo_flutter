import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import '_step_chip.dart';
import 'auth_callbacks.dart';

/// 4-page swipeable interaction tutorial shown after interest picking.
/// Teaches core gestures: tap, long-press, FAB switcher, and swiping.
class AuthTutorialScreen extends StatefulWidget {
  const AuthTutorialScreen({super.key});

  @override
  State<AuthTutorialScreen> createState() => _AuthTutorialScreenState();
}

class _AuthTutorialScreenState extends State<AuthTutorialScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_TutorialPage>[
    _TutorialPage(
      icon: Icons.touch_app_rounded,
      headline: 'Tap to explore',
      description:
          'Buttons, cards, and nav items all respond to taps with a satisfying bounce.',
    ),
    _TutorialPage(
      icon: Icons.back_hand_rounded,
      headline: 'Hold for more',
      description:
          'Long-press on messages and posts to reveal context menus with extra options.',
    ),
    _TutorialPage(
      icon: Icons.apps_rounded,
      headline: 'Switch between worlds',
      description:
          'Tap the red button to jump between Video, Dating, Social, YoYo, and Shop.',
    ),
    _TutorialPage(
      icon: Icons.swipe_rounded,
      headline: 'Swipe to discover',
      description:
          'Swipe cards left and right, browse photo carousels, and pull down to refresh.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _enterApp() async {
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onCompleteTutorial != null) {
      try {
        await callbacks!.onCompleteTutorial!();
      } catch (e, st) {
        // Non-fatal — user can retry from settings. Log so TestFlight
        // builds surface the failure in Crashlytics / debug console.
        debugLogAuthError('auth/tutorial-complete', e, st);
      }
    }
    if (callbacks?.onCompleteOnboarding != null) {
      try {
        await callbacks!.onCompleteOnboarding!();
      } catch (e, st) {
        // Non-fatal.
        debugLogAuthError('auth/onboarding-complete', e, st);
      }
    }
    if (!mounted) return;
    PrototypeStateProvider.of(context).switchModule(ProtoModule.video);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _enterApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        type: MaterialType.transparency,
        child: Container(
          color: theme.surface,
          child: SafeArea(
            child: Column(
              children: [
                // Skip button — top right
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _enterApp,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, right: 24),
                      child: Text(
                        'Skip',
                        style: theme.body.copyWith(
                          color: theme.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const StepChip(step: 6, almostDone: true),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon in circle
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primary.withValues(alpha: 0.10),
                              ),
                              child: Icon(
                                page.icon,
                                size: 80,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Headline
                            Text(
                              page.headline,
                              style: theme.headline.copyWith(fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),

                            // Description
                            Text(
                              page.description,
                              style: theme.body,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? theme.primary
                            : theme.text.withValues(alpha: 0.15),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Next / Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(theme.radiusFull),
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: theme.button.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data holder for a single tutorial page.
class _TutorialPage {
  final IconData icon;
  final String headline;
  final String description;

  const _TutorialPage({
    required this.icon,
    required this.headline,
    required this.description,
  });
}
