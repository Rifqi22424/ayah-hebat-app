import '../borrow_books_model.dart';
import '../entity/infaq_model.dart';

class InfaqsResponse {
  final String message;
  final DetailInfaq data;

  InfaqsResponse({
    required this.message,
    required this.data,
  });

  factory InfaqsResponse.fromJson(Map<String, dynamic> json) {
    return InfaqsResponse(
        message: json['message'] ?? 'No message',
        data: DetailInfaq.fromJson(json['data']));
  }
}
