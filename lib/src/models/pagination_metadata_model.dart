// models/pagination_metadata_model.dart

class PaginationMetadata {
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final int currentItemCount;

  PaginationMetadata({
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    required this.currentItemCount,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      currentItemCount: json['currentItemCount'],
    );
  }
}
