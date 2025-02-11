class CreateInfaqResponse {
  final String redirectUrl;

  CreateInfaqResponse({
    required this.redirectUrl,
  });

  factory CreateInfaqResponse.fromJson(Map<String, dynamic> json) {
    return CreateInfaqResponse(
      redirectUrl: json['data']['redirect_url'] ?? '',
    );
  }
}
