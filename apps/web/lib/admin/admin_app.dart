import 'package:flutter/material.dart';
import 'admin_shell.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuwboo Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0d0d14),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0d0d14),
          primary: Color(0xFF8B5CF6),
        ),
        fontFamily: 'Inter',
      ),
      home: const AdminShell(),
    );
  }
}
