import 'package:flutter/material.dart';
import '../providers/message_provider.dart';
import '../services/message_service.dart';
import '../models/message_model.dart';

class MessageController {
  final MessageProvider provider;
  final MessageService service = MessageService();

  MessageController(this.provider);

  Future<void> enviarMensaje({
    required BuildContext context,
    required String message,
    required String sessionId,
    required String userId,
  }) async {
    if (message == '') return;

    provider.setLoading(true);
    final ctx = context;

    try {
      final Message botResponse = await service.sendMessage(
        userId: userId,
        sessionId: sessionId,
        message: message,
      );

      if (botResponse.content != '') {
        provider.addMessage(botResponse);
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Error al obtener respuesta del bot')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      provider.setLoading(false);
    }
  }

  Future<void> obtenerMensajes({required String sessionId}) async {
    if (sessionId == '') return;

    final List<Message> messages = await service.getChatMessages(
      sessionId: sessionId,
    );

    if (messages.isNotEmpty) {
      provider.addMessages(messages);
    }
  }
}
