import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_model.dart';

class PhotoDetectionService {
  static const String baseUrl = 'http://192.168.100.73:8000';

  Future<Photo?> detectPhoto({required String filePath, required String userId, required String conversationId}) async {
    final uri = Uri.parse('$baseUrl/image-prediction/detect-image?user_id=$userId&conversation_id=$conversationId');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String imageUrl = data['image_url'];
      final String fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '$baseUrl/$imageUrl';
      return Photo(
        path: fullUrl,
        name: data['class_name'] ?? '',
        confidence: 'Confianza: ${data['confidence']}',
      );
    }
    return null;
  }
}