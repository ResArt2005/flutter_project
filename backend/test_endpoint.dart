import 'package:postgres/postgres.dart';

void main() {
  var e = PostgreSQLConnection(
    'localhost',
    5432,
    'media_gallery',
    username: 'postgres',
    password: 'postgres',
    useSSL: false,
  );
  print(e.runtimeType);
  print(e);
}
