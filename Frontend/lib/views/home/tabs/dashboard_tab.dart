import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/chat_history_service.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late Future<List<ChatHistory>> _historyFuture;
  final ChatHistoryService _service = ChatHistoryService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.email ?? 'unknown';
    _historyFuture = _service.obtenerHistorial(userId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final nombre = auth.currentUser?.nombre ?? 'Usuario';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/bot_logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido,', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 4),
                      Text(nombre, style: AppTextStyles.h2),
                    ],
                  ),
                ),
                // Contador en recuadro verde
                FutureBuilder<List<ChatHistory>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    final count = (snapshot.data ?? []).length;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$count',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chats',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Card con mensaje descriptivo
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    FutureBuilder<List<ChatHistory>>(
                      future: _historyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 40,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final count = (snapshot.data ?? []).length;
                        return Text(
                          count > 0
                              ? 'Tienes $count conversaciones. Pulsa en Historial para ver detalles.'
                              : 'Aún no tienes conversaciones. Inicia un análisis para comenzar.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card: Sobre la aplicación
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sobre HealthfyAI', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      'HealthfyAI es una aplicación diseñada para detectar posibles enfermedades dermatológicas y ofrecer recomendaciones iniciales. Utiliza inteligencia artificial generativa y redes neuronales entrenadas para analizar imágenes de la piel y generar un diagnóstico preliminar junto con sugerencias y recursos de referencia.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cómo funciona: sube o toma una foto de la lesión dermatológica, el sistema procesa la imagen y devuelve un diagnóstico probable con un porcentaje de confianza. A partir de ahí, el asistente puede ofrecer información adicional y recomendaciones generales.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Card: Advertencia (color suave)
            Card(
              color: AppColors.warningLight,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.warningLight)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Advertencia', style: AppTextStyles.h3.copyWith(color: AppColors.warningText)),
                    const SizedBox(height: 8),
                    Text(
                      'El sistema puede fallar o generar diagnósticos imprecisos; los resultados son indicativos y no sustituyen la evaluación, diagnóstico ni tratamiento proporcionado por un profesional de la salud. No reemplaza la supervisión médica experta. Ante dudas o signos graves, consulta inmediatamente con un especialista.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
