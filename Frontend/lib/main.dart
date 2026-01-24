import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'providers/photo_provider.dart';
import 'providers/message_provider.dart';
import 'routes/app_routes.dart';
import 'views/auth/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_)=> MessageProvider()),
      ],
      child: MaterialApp(
        title: 'HealthfyAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginView(),
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
