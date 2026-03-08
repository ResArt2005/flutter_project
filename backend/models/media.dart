class Media {
  final int id;
  final String type;
  final String url;
  final String? thumbnail;
  final String? title;
  final String? description;
  final int? uploadedBy;
  final DateTime createdAt;

  Media({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
    this.title,
    this.description,
    this.uploadedBy,
    required this.createdAt,
  });

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      id: map['id'] as int,
      type: map['type'] as String,
      url: map['url'] as String,
      thumbnail: map['thumbnail'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      uploadedBy: map['uploaded_by'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'thumbnail': thumbnail,
      'title': title,
      'description': description,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}