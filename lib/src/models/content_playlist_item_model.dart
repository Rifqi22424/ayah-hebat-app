// models/content_playlist_item_model.dart

import 'playlist_info_model.dart';

class ContentPlaylistItem {
  final PlaylistInfo playlist;
  final int order;

  ContentPlaylistItem({required this.playlist, required this.order});

  factory ContentPlaylistItem.fromJson(Map<String, dynamic> json) {
    return ContentPlaylistItem(
      playlist: PlaylistInfo.fromJson(json['playlist']),
      order: json['order'],
    );
  }
}
