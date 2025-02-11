import '../borrow_books_model.dart';
import '../entity/infaq_model.dart';

class InfaqsResponse {
  final String message;
  final List<Infaq> data;
  final Pagination pagination;

  InfaqsResponse({
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory InfaqsResponse.fromJson(Map<String, dynamic> json) {
    return InfaqsResponse(
      message: json['message'] ?? 'No message',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Infaq.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
