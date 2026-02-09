import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../config/constants.dart';

class MessageService {
  Future<List<Message>> getChatMessages({required String sessionId}) async {
    final uri = Uri.parse(
      '${AppConstants.medicalBotEndpoint}/chat-messages/$sessionId',
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final chats = data['messages'];
      if (chats != null) {
        return (chats as List).map((json) => Message.fromJson(json)).toList();
      }
    }
    return [];
  }

  Future<Message> sendMessage({
    required String userId,
    required String sessionId,
    required String message,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.medicalBotEndpoint}/chat/$sessionId?user_id=$userId',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final botResponse = data['bot_response'];
      return Message.fromBotResponse(botResponse);
    } else {
      throw Exception('Error enviando mensaje');
    }
  }
}
