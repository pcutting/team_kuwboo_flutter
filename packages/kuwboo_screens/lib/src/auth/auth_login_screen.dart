import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    return Container(
      color: theme.surface,
      child: Column(
        children: [
          ProtoSubBar(title: 'Log In'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // SSO buttons
                  _SsoButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Continue with Google',
                    onTap: () => state.switchModule(ProtoModule.video),
                  ),
                  const SizedBox(height: 12),
                  _SsoButton(
                    icon: Icons.apple_rounded,
                    label: 'Continue with Apple',
                    onTap: () => state.switchModule(ProtoModule.video),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.text.withValues(alpha: 0.08))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: theme.caption.copyWith(color: theme.textTertiary)),
                      ),
                      Expanded(child: Divider(color: theme.text.withValues(alpha: 0.08))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _TabPill(
                          label: 'Phone',
                          active: _tabController.index == 0,
                          onTap: () => _tabController.animateTo(0),
                        ),
                        _TabPill(
                          label: 'Email',
                          active: _tabController.index == 1,
                          onTap: () => _tabController.animateTo(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _LoginPhoneTab(state: state, theme: theme),
                        _LoginEmailTab(state: state, theme: theme),
                      ],
                    ),
                  ),

                  // Sign up link
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: GestureDetector(
                      onTap: () => state.push(ProtoRoutes.authMethod),
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        style: theme.body.copyWith(color: theme.textSecondary),
                      ),
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

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? theme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : theme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SsoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SsoButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: theme.text.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(theme.radiusFull),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: theme.text),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPhoneTab extends StatelessWidget {
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  const _LoginPhoneTab({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone', style: theme.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.text.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Text('🇬🇧 +44', style: theme.body),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 18, color: theme.textSecondary),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.text.withValues(alpha: 0.08)),
                ),
                child: Text(
                  '7XXX XXX XXX',
                  style: theme.body.copyWith(color: theme.textTertiary),
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => state.switchModule(ProtoModule.video),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(theme.radiusFull),
            ),
            child: Center(
              child: Text('Send Code', style: theme.button.copyWith(fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LoginEmailTab extends StatelessWidget {
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  const _LoginEmailTab({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: theme.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, size: 20, color: theme.textTertiary),
              const SizedBox(width: 12),
              Text('you@example.com', style: theme.body.copyWith(color: theme.textTertiary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Password', style: theme.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 20, color: theme.textTertiary),
              const SizedBox(width: 12),
              Text('Enter password', style: theme.body.copyWith(color: theme.textTertiary)),
              const Spacer(),
              Icon(Icons.visibility_off_outlined, size: 20, color: theme.textTertiary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Forgot password?',
            style: theme.caption.copyWith(color: theme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => state.switchModule(ProtoModule.video),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(theme.radiusFull),
            ),
            child: Center(
              child: Text('Log In', style: theme.button.copyWith(fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
