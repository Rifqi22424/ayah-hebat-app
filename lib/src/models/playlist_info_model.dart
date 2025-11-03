// models/playlist_info_model.dart

class PlaylistInfo {
  final int id;
  final String title;

  PlaylistInfo({required this.id, required this.title});

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) {
    return PlaylistInfo(
      id: json['id'],
      title: json['title'],
    );
  }
}
