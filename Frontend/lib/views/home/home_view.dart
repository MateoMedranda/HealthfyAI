import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/chat_history_drawer.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/diagnostics_tab.dart';
import 'tabs/scan_tab.dart';
import 'tabs/profile_tab.dart';
import '../chat_view.dart';
import '../../controllers/auth_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  final List<String> _titles = [
    'Dashboard',
    'Escanear',
    'Diagnósticos',
    'Perfil',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = [
      const DashboardTab(),
      const ScanTab(),
      const DiagnosticsTab(),
      const ProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: AppColors.white,
                ),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
        ],
      ),
      drawer: const ScanHistoryDrawer(),
      body: _tabs[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para abrir chat independiente
          final authController = context.read<AuthController>();
          final userId = authController.currentUser?.email ?? 'unknown';
          // Usamos 'general_chat' o similar como sessionId para conversaciones libres
          const sessionId = 'general_chat';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatView(
                sessionId: sessionId,
                userId: userId, // Necesitarás pasar userId
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Escanear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // Icono más apropiado para historial
            label: 'Diagnósticos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
