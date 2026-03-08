
import 'package:flutter/material.dart';
import '../models/media_model.dart';

class MediaCard extends StatefulWidget {
  final MediaModel media;
  final VoidCallback onTap;

  const MediaCard({
    super.key,
    required this.media,
    required this.onTap,
  });

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? const Color(0xFF6b28c9) : Colors.transparent,
              width: 3,
            ),
            boxShadow: _isHovered
                ? [
                    const BoxShadow(
                      color: Color.fromARGB(127, 107, 40, 201),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
            image: DecorationImage(
              image: NetworkImage(widget.media.thumbnail ?? widget.media.url),
              fit: BoxFit.cover,
            ),
          ),
          transform: Matrix4.diagonal3Values(_isHovered ? 1.05 : 1.0, _isHovered ? 1.05 : 1.0, _isHovered ? 1.05 : 1.0),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color.fromARGB(204, 0, 0, 0),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    widget.media.title ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (widget.media.type == 'video')
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}