import 'dart:convert';
import 'package:postgres/postgres.dart';

Future<dynamic> initDatabase() async {
  final host = 'localhost';
  final port = 5432;
  final database = 'media_gallery';
  final username = 'postgres';
  final password = 'postgres';

  final connection = PostgreSQLConnection(
    host,
    port,
    database,
    username: username,
    password: password,
    useSSL: false,
    encoding: utf8,
  );

  await connection.open();
  print('Connected to PostgreSQL database');
  return connection;
}