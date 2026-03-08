// Сервис для имитации работы с PostgreSQL
class DatabaseService {
  // Имитация подключения к базе данных
  static Future<bool> connect() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Имитация получения данных
  static Future<List<Map<String, dynamic>>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': 1, 'name': 'Иван Иванов', 'email': 'ivan@example.com'},
      {'id': 2, 'name': 'Петр Петров', 'email': 'petr@example.com'},
      {'id': 3, 'name': 'Сидор Сидоров', 'email': 'sidor@example.com'},
    ];
  }

  // Имитация добавления данных
  static Future<bool> addUser(String name, String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // В реальности здесь был бы INSERT в PostgreSQL
    return true;
  }

  // Имитация обновления данных
  static Future<bool> updateUser(int id, String name, String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // Имитация удаления данных
  static Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}