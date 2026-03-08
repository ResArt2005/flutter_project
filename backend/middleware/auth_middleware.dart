import 'package:shelf/shelf.dart';

Middleware authMiddleware(dynamic db) {
  return (Handler innerHandler) {
    return (Request request) async {
      // Simple authentication bypass for demo
      // In a real app, validate token, check db, etc.
      return await innerHandler(request);
    };
  };
}