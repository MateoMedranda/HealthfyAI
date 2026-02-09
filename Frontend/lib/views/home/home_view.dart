import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../widgets/chat_history_drawer.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/chat_tab.dart';
import 'tabs/scan_tab.dart';
import 'tabs/profile_tab.dart';

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
      const ChatTab(),
      const ProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1
          ? null
          : AppBar(
              title: Text(_titles[_currentIndex]),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              centerTitle: true,
              elevation: 0,
            ),
      drawer: const ScanHistoryDrawer(),
      body: _tabs[_currentIndex],
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
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Diagnósticos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
