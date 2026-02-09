import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/photo_controller.dart';
import '../../../providers/photo_provider.dart';
import '../../../widgets/photo_item.dart';
import '../../../widgets/chat_history_drawer.dart';
import '../../../widgets/common/hamburguer_button.dart';

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PhotoProvider>();
    final controller = PhotoController(provider);
    final photo = context.watch<PhotoProvider>().foto;
    final hasPhoto = photo != null;

    return Scaffold(
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.80,
        child: ScanHistoryDrawer(),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 64),
                  if (!hasPhoto) ...[
                    Text(
                      'Toma una foto clara de la zona afectada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Asegúrate de que esté bien iluminada y enfocada para obtener un análisis dermatológico más preciso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 16),
                  ],
                  BigPhotoBox(),
                  SizedBox(height: 16),
                  if (hasPhoto) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Resultado del Análisis',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 6),
                          Text(
                            photo.confidence,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                  if (hasPhoto) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        // aquí navegas al chatbot
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Iniciar chatbot médico'),
                    ),
                    SizedBox(height: 12),
                  ],
                  ElevatedButton.icon(
                    onPressed: () => controller.tomarFoto(context),
                    icon: Icon(Icons.camera),
                    label: Text(hasPhoto ? 'Tomar otra foto' : 'Tomar foto'),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            HamburguerButton(top: 12, left: 12),
          ],
        ),
      ),
    );
  }
}
