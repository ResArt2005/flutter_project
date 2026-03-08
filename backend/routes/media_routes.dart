import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/media.dart';

Handler mediaRoutes(dynamic db) {
  final router = Router();

  // GET /api/media - list all media with optional type filter
  router.get('/', (Request req) async {
    final type = req.url.queryParameters['type'];
    String query = 'SELECT * FROM media';
    if (type != null && ['photo', 'video', 'gif'].contains(type)) {
      query += ' WHERE type = @type';
    }
    query += ' ORDER BY created_at DESC';

    final result = await db.execute(
      query,
      parameters: type != null ? {'type': type} : {},
    );

    final mediaList = result.map((row) => Media.fromMap(row.toColumnMap())).toList();
    return Response.ok(
      mediaList.map((m) => m.toMap()).toList().toString(),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // GET /api/media/{id} - get single media
  router.get('/<id>', (Request req, String id) async {
    final result = await db.execute(
      'SELECT * FROM media WHERE id = @id',
      parameters: {'id': int.parse(id)},
    );

    if (result.isEmpty) {
      return Response.notFound('Media not found');
    }

    final media = Media.fromMap(result.first.toColumnMap());
    return Response.ok(
      media.toMap().toString(),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // POST /api/media - upload new media (simplified)
  router.post('/', (Request req) async {
    // In a real implementation, parse multipart form
    return Response.ok('Upload endpoint - not implemented');
  });

  // DELETE /api/media/{id}
  router.delete('/<id>', (Request req, String id) async {
    await db.execute(
      'DELETE FROM media WHERE id = @id',
      parameters: {'id': int.parse(id)},
    );
    return Response.ok('Media deleted');
  });

  return router;
}