import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth_page.dart';

void main() {
  runApp(const EmmaApp());
}

class EmmaApp extends StatelessWidget {
  const EmmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMMA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthPage(),
    );
  }
}
