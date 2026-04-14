import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class AuthSignupScreen extends StatelessWidget {
  const AuthSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: ProtoTheme.of(context).surface,
      child: Column(
        children: [
          ProtoSubBar(title: 'Sign Up'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 20),
                Text('Create your account', style: ProtoTheme.of(context).headline.copyWith(fontSize: 24)),
                const SizedBox(height: 6),
                Text('We just need a few details to get you started.', style: ProtoTheme.of(context).body),
                const SizedBox(height: 28),

                _SignupField(label: 'Phone Number', hint: '+44 7XXX XXX XXX', icon: Icons.phone_rounded),
                _SignupField(label: 'OTP Code', hint: '4 4 4 4', icon: Icons.pin_rounded),
                _SignupField(label: 'Full Name', hint: 'Your name', icon: Icons.person_rounded),
                _SignupField(label: 'Date of Birth', hint: 'DD / MM / YYYY', icon: Icons.cake_rounded),

                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => state.push(ProtoRoutes.authOnboarding),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: ProtoTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(ProtoTheme.of(context).radiusFull),
                    ),
                    child: Center(child: Text('Continue', style: ProtoTheme.of(context).button.copyWith(fontSize: 16))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ));
  }
}

class _SignupField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  const _SignupField({required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ProtoTheme.of(context).caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: ProtoTheme.of(context).background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ProtoTheme.of(context).text.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: ProtoTheme.of(context).textTertiary),
                const SizedBox(width: 12),
                Text(hint, style: ProtoTheme.of(context).body.copyWith(color: ProtoTheme.of(context).textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
