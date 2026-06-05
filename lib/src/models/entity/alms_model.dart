class DetailAlms {
  final String id;
  final int amount;
  final String status;
  final String almsType;
  final String? evidenceImageUrl;
  final String? message;
  final String createdAt;
  final String updatedAt;

  DetailAlms({
    required this.id,
    required this.amount,
    required this.status,
    required this.almsType,
    this.evidenceImageUrl,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetailAlms.fromJson(Map<String, dynamic> json) {
    return DetailAlms(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'unknown',
      almsType: json['almsType']['name'] ?? '',
      evidenceImageUrl: json['evidenceImageUrl'],
      message: json['message'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Alms {
  final String id;
  final int amount;
  final String status;
  final String? evidenceImageUrl;
  final String createdAt;
  final String updatedAt;

  Alms({
    required this.id,
    required this.amount,
    required this.status,
    this.evidenceImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Alms.fromJson(Map<String, dynamic> json) {
    return Alms(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'unknown',
      evidenceImageUrl: json['evidenceImageUrl'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
