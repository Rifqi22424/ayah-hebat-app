import '../borrow_books_model.dart';
import '../entity/alms_model.dart';

class AlmssResponse {
  final String message;
  final List<Alms> data;
  final Pagination pagination;

  AlmssResponse({
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory AlmssResponse.fromJson(Map<String, dynamic> json) {
    return AlmssResponse(
      message: json['message'] ?? 'No message',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Alms.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
