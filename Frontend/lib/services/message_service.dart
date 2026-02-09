import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../config/constants.dart';
import 'api_service.dart';

class MessageService {
  Future<List<Message>> getChatMessages({required String sessionId}) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.medicalBotEndpoint}/chat-messages/$sessionId',
      );

      final headers = {'Content-Type': 'application/json'};
      if (ApiService.authToken != null) {
        headers['Authorization'] = 'Bearer ${ApiService.authToken}';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chats = data['messages'];
        if (chats != null) {
          final messages = (chats as List)
              .map((json) => Message.fromJson(json))
              .toList();
          return messages;
        }
      }
    } catch (e) {
      //
    }
    return [];
  }

  Future<Message> sendMessage({
    required String userId,
    required String sessionId,
    required String message,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.medicalBotEndpoint}/chat/$sessionId?user_id=$userId',
      );

      final headers = {'Content-Type': 'application/json'};
      if (ApiService.authToken != null) {
        headers['Authorization'] = 'Bearer ${ApiService.authToken}';
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['bot_response'];
        final msg = Message.fromBotResponse(botResponse);
        return msg;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error enviando mensaje: $e');
    }
  }
}
