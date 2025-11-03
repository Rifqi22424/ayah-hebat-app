// models/playlist_model.dart

import 'playlist_content_item_model.dart';

class Playlist {
  final int id;
  final String title;
  final String? description;
  final List<PlaylistContentItem> contents;

  Playlist({
    required this.id,
    required this.title,
    this.description,
    required this.contents,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    var contentList = json['contents'] as List? ?? [];

    return Playlist(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      contents: contentList
          .map((item) => PlaylistContentItem.fromJson(item))
          .toList(),
    );
  }
}
