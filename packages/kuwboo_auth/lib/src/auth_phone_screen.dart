import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({super.key});

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen>
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

    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: theme.surface,
      child: Column(
        children: [
          ProtoSubBar(title: 'Sign Up'),
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              margin: const EdgeInsets.only(top: 16),
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
          ),
          const SizedBox(height: 24),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PhoneTab(state: state, theme: theme),
                _EmailTab(state: state, theme: theme),
              ],
            ),
          ),
        ],
      ),
        ));
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

class _PhoneTab extends StatelessWidget {
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  const _PhoneTab({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone', style: theme.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              // Country code
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
              // Phone number field
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
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: () => state.push(ProtoRoutes.authOtp),
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
          ),
        ],
      ),
    );
  }
}

class _EmailTab extends StatelessWidget {
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  const _EmailTab({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
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
                Text('Create a password', style: theme.body.copyWith(color: theme.textTertiary)),
                const Spacer(),
                Icon(Icons.visibility_off_outlined, size: 20, color: theme.textTertiary),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: () => state.push(ProtoRoutes.authBirthday),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(theme.radiusFull),
                ),
                child: Center(
                  child: Text('Next', style: theme.button.copyWith(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
