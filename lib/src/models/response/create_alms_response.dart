class CreateAlmsResponse {
  final String id;
  final String orderId;
  final String message;

  CreateAlmsResponse({
    required this.id,
    required this.orderId,
    required this.message,
  });

  factory CreateAlmsResponse.fromJson(Map<String, dynamic> json) {
    return CreateAlmsResponse(
      id: json['data']['id']?.toString() ?? '',
      orderId: json['data']['orderId']?.toString() ?? '',
      message: json['message']?.toString() ?? 'Alms created successfully',
    );
  }
}
