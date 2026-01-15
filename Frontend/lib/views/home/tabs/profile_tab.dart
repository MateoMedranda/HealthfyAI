import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../controllers/auth_controller.dart';
import '../../../widgets/common/custom_button.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Card del perfil principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.white,
                    child: Text(
                      user?.nombre != null && user!.nombre.isNotEmpty
                          ? user.nombre.substring(0, 1).toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre
                Text(
                  user?.nombre ?? 'Usuario',
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sección de información
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Información Personal', style: AppTextStyles.h3),
          ),
          const SizedBox(height: 16),

          // Información adicional
          _buildInfoCard(
            Icons.cake_outlined,
            'Fecha de Nacimiento',
            user?.birthdate ?? 'No especificada',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.person_outline,
            'Género',
            user?.gender ?? 'No especificado',
          ),

          const SizedBox(height: 32),

          // Botón cerrar sesión
          CustomButton(
            text: 'Cerrar Sesión',
            onPressed: () async {
              await authController.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            backgroundColor: AppColors.error,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
