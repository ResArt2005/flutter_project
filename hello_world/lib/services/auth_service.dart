import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static String? _username;

  static const String _storedHashedPassword = '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'; // sha256 of "admin"

  // Хеширование пароля
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Проверка логина и пароля
  static Future<bool> login(String username, String password) async {
    // Простая проверка: пользователь "admin", пароль "admin"
    if (username == 'admin' && _hashPassword(password) == _storedHashedPassword) {
      _isLoggedIn = true;
      _username = username;
      return true;
    }
    return false;
  }

  // Выход
  static Future<void> logout() async {
    _isLoggedIn = false;
    _username = null;
  }

  // Проверка, авторизован ли пользователь
  static Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  // Получение имени текущего пользователя
  static Future<String?> getCurrentUser() async {
    return _username;
  }
}