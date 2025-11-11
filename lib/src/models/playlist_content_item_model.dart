// models/playlist_content_item_model.dart

import 'simple_content_model.dart';

class PlaylistContentItem {
  final int order;
  final SimpleContent content;

  PlaylistContentItem({required this.order, required this.content});

  factory PlaylistContentItem.fromJson(Map<String, dynamic> json) {
    return PlaylistContentItem(
      order: json['order'],
      content: SimpleContent.fromJson(json),
    );
  }
}
