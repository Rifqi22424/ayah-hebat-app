// responses/paginated_content_response.dart

import '../content_model.dart';
import '../pagination_metadata_model.dart';

class PaginatedContentResponse {
  final PaginationMetadata metadata;
  final List<Content> videos; // Sesuai dengan key 'videos' di controller

  PaginatedContentResponse({required this.metadata, required this.videos});

  factory PaginatedContentResponse.fromJson(Map<String, dynamic> json) {
    var videoList = json['videos'] as List? ?? [];

    return PaginatedContentResponse(
      metadata: PaginationMetadata.fromJson(json['metadata']),
      videos: videoList.map((item) => Content.fromJson(item)).toList(),
    );
  }
}
