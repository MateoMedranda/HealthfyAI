import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Escanear', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Contenido próximamente...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
