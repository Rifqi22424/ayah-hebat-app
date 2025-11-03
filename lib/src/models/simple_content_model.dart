// models/simple_content_model.dart

import 'uploader_model.dart';

class SimpleContent {
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

  SimpleContent({
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
  });

  factory SimpleContent.fromJson(Map<String, dynamic> json) {
    return SimpleContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      duration: json['duration'],
      views: json['views'] ?? 0,
      publishedAt: DateTime.parse(json['publishedAt']),
      uploaderId: json['uploaderId'],
      uploader: json['uploader'] != null
          ? Uploader.fromJson(json['uploader'])
          : Uploader(id: 0, username: 'Admin'),
    );
  }
}
