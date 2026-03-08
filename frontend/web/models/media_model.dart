class MediaModel {
  final int id;
  final String type;
  final String url;
  final String? thumbnail;
  final String? title;
  final String? description;

  MediaModel({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
    this.title,
    this.description,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as int,
      type: json['type'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'thumbnail': thumbnail,
      'title': title,
      'description': description,
    };
  }
}