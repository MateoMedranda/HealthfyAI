/// Constantes globales de la aplicación
class AppConstants {
  /// URL base del backend API
  static const String baseUrl = 'http://192.168.1.54:8000';

  /// URLs de los endpoints
  static const String usersEndpoint = '$baseUrl/api/users';
  static const String medicalBotEndpoint = '$baseUrl/medical-bot';
  static const String imagePredictionEndpoint = '$baseUrl/image-prediction';

  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
}
