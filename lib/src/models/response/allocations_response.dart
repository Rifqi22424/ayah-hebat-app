import '../entity/allocation_model.dart';

class AllocationsResponse {
  final String message;
  final List<Allocation> data;

  AllocationsResponse({
    required this.message,
    required this.data,
  });

  factory AllocationsResponse.fromJson(Map<String, dynamic> json) {
    return AllocationsResponse(
      message: json['message'] ?? 'No message',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Allocation.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
