import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../services/chat_history_service.dart';
import '../../../../services/api_service.dart';
import '../../../../config/constants.dart';
import '../../../../controllers/auth_controller.dart';
import '../../chat_view.dart';

class DiagnosticsTab extends StatefulWidget {
  const DiagnosticsTab({super.key});

  @override
  State<DiagnosticsTab> createState() => _DiagnosticsTabState();
}

class _DiagnosticsTabState extends State<DiagnosticsTab> {
  late Future<List<ChatHistory>> _historyFuture;
  final ChatHistoryService _service = ChatHistoryService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final authController = context.read<AuthController>();
    final userId = authController.currentUser?.email ?? 'unknown';
    _historyFuture = _service.obtenerHistorial(userId);
  }

  Future<Map<String, dynamic>> _getImageAndConfidence(String sessionId) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/medical-bot/clinical-records/$sessionId',
      );

      final headers = {'Content-Type': 'application/json'};
      if (ApiService.authToken != null) {
        headers['Authorization'] = 'Bearer ${ApiService.authToken}';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['content'] is List && (data['content'] as List).isNotEmpty) {
          final firstRecord = (data['content'] as List)[0];
          if (firstRecord['origen_datos'] != null) {
            final imageUrl = firstRecord['origen_datos']['imagen_id'] as String?;
            final confidence = firstRecord['origen_datos']['cnn_confianza'] as num?;
            
            return {
              'image_url': imageUrl,
              'confidence': confidence != null ? (confidence * 100).toStringAsFixed(1) : null,
            };
          }
        }
      }
    } catch (e) {
      print('Error obteniendo imagen: $e');
    }
    return {'image_url': null, 'confidence': null};
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadHistory();
        });
      },
      child: FutureBuilder<List<ChatHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final conversations = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final chat = conversations[index];
              return _buildHistoryCard(chat);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.history_edu, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Sin Historial de Diagnósticos',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Aún no tienes diagnósticos guardados. Realiza una consulta para verla aquí.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error al cargar el historial'),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loadHistory();
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ChatHistory chat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          final authController = context.read<AuthController>();
          final userId = authController.currentUser?.email ?? 'unknown';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatView(
                sessionId: chat.conversationId,
                userId: userId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen thumbnail con carga asincrónica
              FutureBuilder<Map<String, dynamic>>(
                future: _getImageAndConfidence(chat.conversationId),
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data?['image_url'] as String?;
                  final confidence = snapshot.data?['confidence'] as String?;
                  
                  if (snapshot.hasData && imageUrl != null) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withAlpha(30),
                            ),
                          ),
                        ),
                        // Badge de confianza
                        if (confidence != null)
                          Positioned(
                            right: 12,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(200),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$confidence%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  
                  // Fallback icon si no hay imagen
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.medical_services_outlined, color: AppColors.primary),
                  );
                },
              ),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.diagnosis,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          chat.formattedDate,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.message_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${chat.messageCount} msgs',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
