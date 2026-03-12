import 'package:flutter/material.dart';
import 'admin_nav_bar.dart';
import '../tools/prototype/prototype_tool_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedTool = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d14),
      body: Column(
        children: [
          if (!isMobile)
            AdminNavBar(
              selectedIndex: _selectedTool,
              onTabSelected: (index) {
                // Only allow selecting the Prototype tab (index 0) for now
                if (index == 0) {
                  setState(() => _selectedTool = index);
                }
              },
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedTool,
              children: const [
                PrototypeToolPage(),
                _ComingSoonPage(icon: Icons.analytics_outlined, label: 'Analytics'),
                _ComingSoonPage(icon: Icons.article_outlined, label: 'Content'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComingSoonPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
