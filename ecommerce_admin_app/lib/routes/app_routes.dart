import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../screens/main_layout.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      dashboard: (context) => const MainLayout(),
    };
  }
}
