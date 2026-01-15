import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.login(email, password);

    if (result['success']) {
      _currentUser = UserModel.fromJson(result['data']);
      await _saveSession(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.register(user);

    if (result['success']) {
      _currentUser = UserModel.fromJson(result['data']);
      await _saveSession(user.email);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    notifyListeners();
  }

  // Guardar sesión en SharedPreferences
  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // Restaurar sesión
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    if (email != null) {
      final user = await _apiService.getUser(email);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
