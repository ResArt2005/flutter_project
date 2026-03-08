import 'dart:convert';
import 'package:postgres/postgres.dart';

void main() async {
  try {
    final conn = PostgreSQLConnection(
      'localhost',
      5432,
      'media_gallery',
      username: 'postgres',
      password: 'postgres',
      useSSL: false,
      encoding: utf8,
    );
    await conn.open();
    print('SUCCESS');
    await conn.close();
  } catch (e, s) {
    print('ERROR: $e');
    print(s);
  }
}