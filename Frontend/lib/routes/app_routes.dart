import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/home_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginView(),
      register: (context) => const RegisterView(),
      home: (context) => const HomeView(),
    };
  }
}
