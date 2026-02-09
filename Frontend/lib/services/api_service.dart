import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 60);
  static String? authToken;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // Registrar usuario
  Future<Map<String, dynamic>> register(UserModel user) async {
    try {
      final jsonData = user.toJson();

      final response = await http
          .post(
            Uri.parse('${AppConstants.usersEndpoint}/'),
            headers: _headers,
            body: jsonEncode(jsonData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return {'success': true, 'data': responseData['user_data']};
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message':
              'Datos inválidos. Verifica que todos los campos estén correctos.',
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Este correo electrónico ya está registrado.',
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Error al registrar usuario. Intenta nuevamente.',
        };
      }
    } on http.ClientException {
      return {
        'success': false,
        'message':
            'No se pudo conectar al servidor. Verifica que el backend esté corriendo.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'La solicitud tardó demasiado. Verifica tu conexión.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: ${e.toString()}'};
    }
  }

  // Login usuario
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.usersEndpoint}/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return {
            'success': true,
            'data': responseData['user_data'],
            'token': responseData['access_token'],
          };
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Credenciales incorrectas.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No existe una cuenta con este correo electrónico.',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al iniciar sesión. Intenta nuevamente.',
        };
      }
    } on http.ClientException {
      return {
        'success': false,
        'message':
            'No se pudo conectar al servidor. Verifica que el backend esté corriendo.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: ${e.toString()}'};
    }
  }

  // Obtener usuario por email
  Future<UserModel?> getUser(String email) async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConstants.usersEndpoint}/$email'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return UserModel.fromJson(responseData['user_data']);
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
