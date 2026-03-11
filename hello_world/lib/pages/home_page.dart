import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Photo> _photos = [];
  bool _loading = true;
  String? _error;
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  static const String baseUrl = 'http://localhost:8000'; // для локальной разработки
  // В Docker-сети используйте 'http://backend:8000'

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/photos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _photos = data.map((item) => Photo.fromJson(item)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Ошибка загрузки фото: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка сети: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadPhotos,
                        child: const Text('Повторить'),
                      ),
                    ],
                  )
                : _photos.isEmpty
                    ? const Text(
                        'Нет фото в базе',
                        style: TextStyle(fontSize: 24, color: Colors.grey),
                      )
                    : _buildPhotoGallery(),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    final bool autoPlay = _photos.length > 3;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 650,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: _photos.length,
            options: CarouselOptions(
              height: 200,
              viewportFraction: 0.35,
              autoPlay: autoPlay,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              enlargeCenterPage: true, // центральная картинка увеличена
              scrollDirection: Axis.horizontal,
              enableInfiniteScroll: _photos.length > 1,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final photo = _photos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF0F0F0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: '$baseUrl/media/${photo.filepath}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _photos.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.jumpToPage(entry.key),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withAlpha(
                        entry.key == _currentIndex ? 230 : 77,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
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
}