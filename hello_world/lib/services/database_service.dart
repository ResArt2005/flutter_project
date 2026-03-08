import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  static const String baseUrl = 'http://localhost:8000'; // для локальной разработки
  // В Docker-сети используйте 'http://backend:8000'

  // Получение списка пользователей
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((user) => {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'passwordHash': '',
        }).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Добавление пользователя
  static Future<bool> addUser(String name, String email, {String password = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Удаление пользователя
  static Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Обновление пользователя (опционально, если нужно)
  static Future<bool> updateUser(int id, String name, String email) async {
    // Эндпоинт для обновления не реализован в бэкенде, можно добавить позже
    return false;
  }

  // Имитация подключения к базе данных (оставлено для совместимости)
  static Future<bool> connect() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}