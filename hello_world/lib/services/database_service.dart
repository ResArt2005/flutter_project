// Сервис для имитации работы с PostgreSQL
class DatabaseService {
  // Временное хранилище пользователей в памяти
  static final List<Map<String, dynamic>> _users = [
    {'id': 1, 'name': 'Иван Иванов', 'email': 'ivan@example.com', 'passwordHash': ''},
    {'id': 2, 'name': 'Петр Петров', 'email': 'petr@example.com', 'passwordHash': ''},
    {'id': 3, 'name': 'Сидор Сидоров', 'email': 'sidor@example.com', 'passwordHash': ''},
  ];
  static int _nextId = 4;

  // Имитация подключения к базе данных
  static Future<bool> connect() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Получение списка пользователей
  static Future<List<Map<String, dynamic>>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_users);
  }

  // Добавление пользователя
  static Future<bool> addUser(String name, String email, {String password = ''}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newUser = {
      'id': _nextId++,
      'name': name,
      'email': email,
      'passwordHash': password.isNotEmpty ? _hashPassword(password) : '',
    };
    _users.add(newUser);
    return true;
  }

  // Обновление пользователя
  static Future<bool> updateUser(int id, String name, String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _users.indexWhere((user) => user['id'] == id);
    if (index >= 0) {
      _users[index]['name'] = name;
      _users[index]['email'] = email;
      return true;
    }
    return false;
  }

  // Удаление пользователя
  static Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _users.removeWhere((user) => user['id'] == id);
    return true;
  }

  // Хеширование пароля (упрощённое)
  static String _hashPassword(String password) {
    // В реальном приложении используйте bcrypt или аналоги
    return password.hashCode.toString();
  }
}