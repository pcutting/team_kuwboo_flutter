import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Material(
      type: MaterialType.transparency,
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProtoTheme.of(context).primary,
            ProtoTheme.of(context).primary.withValues(alpha: 0.8),
            ProtoTheme.of(context).background,
          ],
        ),
      ),
      child: Column(
        children: [
          const Spacer(flex: 3),
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: ProtoTheme.of(context).warmShadow,
            ),
            child: Image.asset(
              'assets/images/kuwboo-logo.png',
              package: 'kuwboo_shell',
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          Text('Connect. Discover. Be You.', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7))),

          const Spacer(flex: 2),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => context.go(ProtoRoutes.authMethod),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ProtoTheme.of(context).radiusFull),
                    ),
                    child: Center(
                      child: Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ProtoTheme.of(context).primary)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.go(ProtoRoutes.authLogin),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(ProtoTheme.of(context).radiusFull),
                    ),
                    child: Center(
                      child: Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
        ));
  }
}
