import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../database/connection.dart';
import '../routes/media_routes.dart';
import '../routes/auth_routes.dart';
import '../middleware/auth_middleware.dart';

void main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final host = Platform.environment['HOST'] ?? 'localhost';

  // Initialize database connection with default values
  final db = await initDatabase();

  // Create router
  final router = Router()
    ..mount('/api/media', mediaRoutes(db))
    ..mount('/api/auth', authRoutes(db));

  // Add middleware
  final pipeline = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(authMiddleware(db));

  final handler = pipeline.addHandler(router);

  // Start server
  final server = await serve(handler, host, port);
  print('Server listening on http://${server.address.host}:${server.port}');
}