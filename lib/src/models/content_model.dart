// models/content_model.dart

import 'uploader_model.dart';
import 'content_playlist_item_model.dart';

class Content {
  final int id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String videoUrl;
  final int? duration;
  final int views;
  final DateTime publishedAt;
  final int uploaderId;
  final Uploader uploader;
  final List<ContentPlaylistItem> playlistContent;

  Content({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.duration,
    required this.views,
    required this.publishedAt,
    required this.uploaderId,
    required this.uploader,
    required this.playlistContent,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    var playlistContentList = json['PlaylistContent'] as List? ?? [];
    var uploaderData = json['uploader'] as Map<String, dynamic>?;

    return Content(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      duration: json['duration'],
      views: json['views'] ?? 0,
      publishedAt: DateTime.parse(json['publishedAt']),
      uploaderId: json['uploaderId'],
      uploader: uploaderData != null
          ? Uploader.fromJson(uploaderData)
          : Uploader(id: json['uploaderId'], username: 'Unknown'), // Fallback
      playlistContent: playlistContentList
          .map((item) => ContentPlaylistItem.fromJson(item))
          .toList(),
    );
  }
}
