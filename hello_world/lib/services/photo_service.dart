import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class PhotoService {
  static const String baseUrl = 'http://localhost:8000'; // для локальной разработки
  // В Docker-сети используйте 'http://backend:8000'

  // Получение списка всех фото
  static Future<List<Photo>> getPhotos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/photos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Photo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching photos: $e');
      return [];
    }
  }

  // Загрузка нового фото (требует авторизации администратора)
  static Future<Photo?> uploadPhoto(
    List<int> fileBytes,
    String fileName,
    String mimeType, {
    required int userId, // ID текущего пользователя (администратора)
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/photos'));
      request.headers['X-User-Id'] = userId.toString();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: mimeType.isNotEmpty ? MediaType.parse(mimeType) : null,
      ));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        return Photo.fromJson(data);
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }

  // Удаление фото (требует авторизации администратора)
  static Future<bool> deletePhoto(int photoId, {required int userId}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/photos/$photoId'),
        headers: {'X-User-Id': userId.toString()},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }
}

class Photo {
  final int id;
  final String filename;
  final String filepath;
  final DateTime uploadedAt;
  final int size;
  final String mimeType;

  Photo({
    required this.id,
    required this.filename,
    required this.filepath,
    required this.uploadedAt,
    required this.size,
    required this.mimeType,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      filename: json['filename'],
      filepath: json['filepath'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      size: json['size'],
      mimeType: json['mime_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'filepath': filepath,
        'uploaded_at': uploadedAt.toIso8601String(),
        'size': size,
        'mime_type': mimeType,
      };
}