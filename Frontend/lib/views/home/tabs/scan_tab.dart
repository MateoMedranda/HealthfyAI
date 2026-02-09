import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/photo_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../providers/photo_provider.dart';
import '../../../widgets/photo_item.dart';
import '../../../widgets/common/hamburguer_button.dart';
import '../../chat_view.dart';

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PhotoProvider>();
    final controller = PhotoController(provider);
    final photoProvider = context.watch<PhotoProvider>();
    final photo = photoProvider.foto;
    final isAnalyzing = photoProvider.isAnalyzing;
    final hasPhoto = photo != null;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Instrucciones iniciales
                      if (!hasPhoto && !isAnalyzing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Text(
                                'Toma una foto clara de la zona afectada',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Asegúrate de que esté bien iluminada y enfocada.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Big Photo Box
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: BigPhotoBox(),
                      ),
                      // Estado de carga
                      if (isAnalyzing)
                        Column(
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Analizando imagen...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      // Resultado del análisis
                      if (hasPhoto && !isAnalyzing)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Resultado del Análisis',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                photo.name.isNotEmpty
                                    ? photo.name
                                    : 'No se pudo identificar la lesión',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                photo.confidence,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Botones de acción
                      if (hasPhoto && !isAnalyzing)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _buildActionButtons(
                            context,
                            provider,
                            controller,
                            photoProvider,
                          ),
                        )
                      else if (!hasPhoto && !isAnalyzing)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 56,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => controller.tomarFoto(context),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text(
                                'Tomar Foto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PhotoProvider provider,
    PhotoController controller,
    PhotoProvider photoProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Botón Iniciar Chat
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Abriendo chat...'),
                      ],
                    ),
                  ),
                );

                Future.delayed(const Duration(milliseconds: 800), () {
                  if (context.mounted) {
                    Navigator.pop(context);
                    final sessionId = photoProvider.conversationId ?? 'default';
                    final authController = context.read<AuthController>();
                    final userId =
                        authController.currentUser?.email ?? 'unknown';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatView(sessionId: sessionId, userId: userId),
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.chat_bubble),
              label: const Text(
                'Iniciar Chatbot Médico',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Botón Tomar otra foto
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                provider.clearPhoto();
                controller.tomarFoto(context);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Tomar Otra Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
