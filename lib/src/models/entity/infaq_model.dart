// class InfaqData {
//   final int totalAmount;
//   final List<Infaq> infaqs;

//   InfaqData({
//     required this.totalAmount,
//     required this.infaqs,
//   });

//   factory InfaqData.fromJson(Map<String, dynamic> json) {
//     return InfaqData(
//       totalAmount: json['totalAmount'] ?? 0,
//       infaqs: (json['infaqs'] as List<dynamic>? ?? [])
//           .map((item) => Infaq.fromJson(item as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }

class DetailInfaq {
  final String id;
  final int amount;
  final String status;
  final String orderId;
  final String infaqType;
  final String redirectUrl;
  final String? paymentType;
  final String createdAt;
  final String updatedAt;

  DetailInfaq({
    required this.id,
    required this.amount,
    required this.status,
    required this.orderId,
    required this.infaqType,
    required this.redirectUrl,
    this.paymentType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetailInfaq.fromJson(Map<String, dynamic> json) {
    return DetailInfaq(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'unknown',
      orderId: json['orderId'] ?? '',
      redirectUrl: json['redirectUrl'] ?? '',
      infaqType: json['infaqType']['name'] ?? '',
      paymentType: json['paymentType'], // Nullable field
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Infaq {
  final String id;
  // final int userId;
  final int amount;
  final String status;
  final String orderId;
  // final String allocationTypeCode;
  // final String? paymentType;
  final String createdAt;
  final String updatedAt;

  Infaq({
    required this.id,
    // required this.userId,
    required this.amount,
    required this.status,
    required this.orderId,
    // required this.allocationTypeCode,
    // this.paymentType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Infaq.fromJson(Map<String, dynamic> json) {
    return Infaq(
      id: json['id'] ?? '',
      // // userId: json['userId'] ?? 0,
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'unknown',
      orderId: json['orderId'] ?? '',
      // allocationTypeCode: json['allocationTypeCode'] ?? '',
      // paymentType: json['paymentType'], // Nullable field
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
