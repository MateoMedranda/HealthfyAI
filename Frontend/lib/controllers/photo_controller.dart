import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/photo_provider.dart';
import '../services/photo_detection_service.dart';

class PhotoController {
  final PhotoProvider provider;
  final ImagePicker picker = ImagePicker();
  final PhotoDetectionService service = PhotoDetectionService();

  PhotoController(this.provider);

  Future<void> tomarFoto(BuildContext context) async {
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto == null) return;

    const userId = 'test_user';
    const conversationId = 'scan_1';
    final ctx = context;

    final detectedPhoto = await service.detectPhoto(
      filePath: foto.path,
      userId: userId,
      conversationId: conversationId,
    );

    if (detectedPhoto != null) {
      provider.takePhoto(detectedPhoto);
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Error al analizar la imagen')),
      );
    }
  }
}
