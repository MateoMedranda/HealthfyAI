import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../controllers/photo_controller.dart';
import '../../../providers/photo_provider.dart';
import '../../../widgets/photo_item.dart';
import '../../../widgets/chat_history_drawer.dart';

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

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 64,),
                if (!hasPhoto) ...[
                  Text(
                    'Toma una foto clara de la zona afectada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    child:Column(
                      children: [
                        Text(
                          'Análisis Preliminar',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                              'La imagen muestra una posible irritación cutánea. '
                              'Se recomienda evitar la exposición directa al sol y '
                              'consultar a un dermatólogo si los síntomas persisten.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
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
          Positioned(
            top: 12,
            left: 12,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, size: 28),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

