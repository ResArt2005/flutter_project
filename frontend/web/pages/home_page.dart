import 'package:flutter/material.dart';
import '../widgets/media_card.dart';
import '../models/media_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MediaModel> mediaList = [];
  String selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  void _loadMedia() {
    // Mock data
    setState(() {
      mediaList = [
        MediaModel(
          id: 1,
          type: 'photo',
          url: 'https://picsum.photos/800/600',
          thumbnail: 'https://picsum.photos/200/150',
          title: 'Beautiful Landscape',
        ),
        MediaModel(
          id: 2,
          type: 'video',
          url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          thumbnail: 'https://img.youtube.com/vi/YE7VzlLtp-4/0.jpg',
          title: 'Big Buck Bunny',
        ),
        MediaModel(
          id: 3,
          type: 'gif',
          url: 'https://media.giphy.com/media/3o7abAHdYvZdBNnGZq/giphy.gif',
          thumbnail: 'https://media.giphy.com/media/3o7abAHdYvZdBNnGZq/giphy.gif',
          title: 'Funny Cat GIF',
        ),
        MediaModel(
          id: 4,
          type: 'photo',
          url: 'https://picsum.photos/800/601',
          thumbnail: 'https://picsum.photos/200/151',
          title: 'Mountain View',
        ),
        MediaModel(
          id: 5,
          type: 'video',
          url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          thumbnail: 'https://img.youtube.com/vi/yourthumbnail.jpg',
          title: 'Elephants Dream',
        ),
        MediaModel(
          id: 6,
          type: 'gif',
          url: 'https://media.giphy.com/media/xT0xeJpnrWC4XWblEk/giphy.gif',
          thumbnail: 'https://media.giphy.com/media/xT0xeJpnrWC4XWblEk/giphy.gif',
          title: 'Dancing Robot',
        ),
      ];
    });
  }

  void _openMediaModal(MediaModel media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: media.type == 'video'
                    ? const Center(child: Icon(Icons.play_circle_fill, size: 100))
                    : Image.network(media.url, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6b28c9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = selectedType == 'all'
        ? mediaList
        : mediaList.where((m) => m.type == selectedType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Gallery'),
        backgroundColor: const Color(0xFF6b28c9),
        actions: [
          DropdownButton<String>(
            value: selectedType,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Media')),
              DropdownMenuItem(value: 'photo', child: Text('Photos')),
              DropdownMenuItem(value: 'video', child: Text('Videos')),
              DropdownMenuItem(value: 'gif', child: Text('GIFs')),
            ],
            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },
            dropdownColor: Colors.white,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final media = filteredList[index];
            return MediaCard(
              media: media,
              onTap: () => _openMediaModal(media),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to admin page
        },
        backgroundColor: const Color(0xFFd91136),
        child: const Icon(Icons.admin_panel_settings),
      ),
    );
  }
}