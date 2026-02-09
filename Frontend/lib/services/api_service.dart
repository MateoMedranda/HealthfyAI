import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 60);
  // Registrar usuario
  Future<Map<String, dynamic>> register(UserModel user) async {
    try {
      final jsonData = user.toJson();
      print('📤 REGISTER: Enviando datos al backend...');
      print('📤 URL: ${AppConstants.usersEndpoint}/');
      print('📤 Datos: $jsonData');

      final response = await http
          .post(
            Uri.parse('${AppConstants.usersEndpoint}/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(jsonData),
          )
          .timeout(_timeout);

      print('📥 REGISTER: Respuesta recibida (${response.statusCode})');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ REGISTER: Status exitoso recibido');
        if (responseData['status'] == 'success') {
          print('✅ REGISTER: Usuario registrado exitosamente');
          return {'success': true, 'data': responseData['user_data']};
        } else {
          print(
            '❌ REGISTER: Backend retornó error: ${responseData['message']}',
          );
          return {'success': false, 'message': responseData['message']};
        }
      } else if (response.statusCode == 422) {
        print('❌ REGISTER: Error 422 - Datos inválidos');
        return {
          'success': false,
          'message':
              'Datos inválidos. Verifica que todos los campos estén correctos.',
        };
      } else if (response.statusCode == 409) {
        print('❌ REGISTER: Error 409 - Email duplicado');
        return {
          'success': false,
          'message': 'Este correo electrónico ya está registrado.',
        };
      } else {
        print('❌ REGISTER: Error ${response.statusCode}');
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Error al registrar usuario. Intenta nuevamente.',
        };
      }
    } on http.ClientException catch (e) {
      print('❌ REGISTER: Error de conexión: $e');
      return {
        'success': false,
        'message':
            'No se pudo conectar al servidor. Verifica que el backend esté corriendo.',
      };
    } on TimeoutException {
      print('❌ REGISTER: Timeout - 30 segundos sin respuesta');
      return {
        'success': false,
        'message': 'La solicitud tardó demasiado. Verifica tu conexión.',
      };
    } catch (e) {
      print('❌ REGISTER: Error inesperado: $e');
      return {'success': false, 'message': 'Error inesperado: ${e.toString()}'};
    }
  }

  // Login usuario
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('📤 LOGIN: Enviando credenciales...');
      print('📤 Email: $email');

      final response = await http
          .post(
            Uri.parse('${AppConstants.usersEndpoint}/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 LOGIN: Respuesta recibida (${response.statusCode})');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // El backend devuelve {status, message, user_data}
        if (responseData['status'] == 'success') {
          print('✅ LOGIN: Autenticación exitosa');
          return {'success': true, 'data': responseData['user_data']};
        } else {
          print('❌ LOGIN: Backend retornó error: ${responseData['message']}');
          return {'success': false, 'message': responseData['message']};
        }
      } else if (response.statusCode == 401) {
        print('❌ LOGIN: Error 401 - Credenciales incorrectas');
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Credenciales incorrectas.',
        };
      } else if (response.statusCode == 404) {
        print('❌ LOGIN: Error 404 - Usuario no encontrado');
        return {
          'success': false,
          'message': 'No existe una cuenta con este correo electrónico.',
        };
      } else {
        print('❌ LOGIN: Error ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error al iniciar sesión. Intenta nuevamente.',
        };
      }
    } on http.ClientException catch (e) {
      print('❌ LOGIN: Error de conexión: $e');
      print('❌ URL: ${AppConstants.baseUrl}');
      return {
        'success': false,
        'message':
            'No se pudo conectar al servidor. Verifica que el backend esté corriendo en ${AppConstants.baseUrl}',
      };
    } catch (e) {
      print('❌ LOGIN: Error inesperado: $e');
      return {'success': false, 'message': 'Error inesperado: ${e.toString()}'};
    }
  }

  // Obtener usuario por email
  Future<UserModel?> getUser(String email) async {
    try {
      print('👤 Obteniendo usuario: $email');
      final response = await http
          .get(Uri.parse('${AppConstants.usersEndpoint}/$email'))
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
      print('❌ Error obteniendo usuario: $e');
      return null;
    }
  }
}
