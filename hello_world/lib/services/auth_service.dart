import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static String? _username;
  static String? _email;

  static const String baseUrl = 'http://localhost:8000'; // для локальной разработки
  // В Docker-сети используйте 'http://backend:8000'

  // Проверка логина и пароля через API
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final bool success = data['success'] ?? false;
        if (success) {
          _isLoggedIn = true;
          _username = data['user']['name'];
          _email = data['user']['email'];
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Выход
  static Future<void> logout() async {
    _isLoggedIn = false;
    _username = null;
    _email = null;
  }

  // Проверка, авторизован ли пользователь
  static Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  // Получение имени текущего пользователя
  static Future<String?> getCurrentUser() async {
    return _username;
  }

  // Получение email текущего пользователя
  static Future<String?> getCurrentEmail() async {
    return _email;
  }
}