// models/simple_playlist_model.dart

class SimplePlaylist {
  final int id;
  final String title;
  final String? description;

  SimplePlaylist({
    required this.id,
    required this.title,
    this.description,
  });

  factory SimplePlaylist.fromJson(Map<String, dynamic> json) {
    return SimplePlaylist(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
