import 'package:postgres/postgres.dart';

void main() async {
  var connection = PostgreSQLConnection(
    'localhost',
    5432,
    'media_gallery',
    username: 'postgres',
    password: 'postgres',
    useSSL: false,
  );
  await connection.open();
  print('Connected');
  // Пример использования
  var result = await connection.query('SELECT 1');
  print('Query result: $result');
  await connection.close();
}
