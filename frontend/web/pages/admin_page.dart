import 'package:flutter/material.dart';
import '../models/media_model.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<MediaModel> mediaList = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedType;

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
          title: 'Sample Photo',
        ),
        MediaModel(
          id: 2,
          type: 'video',
          url: 'https://example.com/video.mp4',
          thumbnail: 'https://example.com/thumb.jpg',
          title: 'Sample Video',
        ),
      ];
    });
  }

  void _deleteMedia(int id) {
    setState(() {
      mediaList.removeWhere((media) => media.id == id);
    });
  }

  void _uploadMedia() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select media type')),
      );
      return;
    }
    // Mock upload
    setState(() {
      mediaList.add(MediaModel(
        id: mediaList.length + 1,
        type: _selectedType!,
        url: 'https://example.com/new.jpg',
        thumbnail: 'https://example.com/thumb.jpg',
        title: _titleController.text,
        description: _descriptionController.text,
      ));
      _titleController.clear();
      _descriptionController.clear();
      _selectedType = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Media uploaded (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF6b28c9),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar form
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload New Media',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'photo', child: Text('Photo')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                    DropdownMenuItem(value: 'gif', child: Text('GIF')),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value),
                  decoration: const InputDecoration(labelText: 'Media Type'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _uploadMedia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3d9e33),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Upload Media'),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('1. Select media type'),
                const Text('2. Fill title and description'),
                const Text('3. Click upload'),
              ],
            ),
          ),
          // Media list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Existing Media',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: mediaList.length,
                      itemBuilder: (context, index) {
                        final media = mediaList[index];
                        return Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  media.thumbnail ?? media.url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      media.title ?? 'No title',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('Type: ${media.type}'),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () => _deleteMedia(media.id),
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}