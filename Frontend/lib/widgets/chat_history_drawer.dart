import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class ScanHistoryDrawer extends StatelessWidget {
  const ScanHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: AppColors.primaryLight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Historial',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(thickness: 1),
            ListTile( leading: const Icon(Icons.image), title: const Text('Análisis 12/01/2026'), onTap: () => Navigator.pop(context), ),
            ListTile( leading: const Icon(Icons.image), title: const Text('Análisis 10/01/2026'), onTap: () => Navigator.pop(context), ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'HealthfyAI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
