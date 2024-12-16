class DonationBook {
  final int id;
  final int stock;
  final String name;
  final String status;
  final String description;
  final DateTime planSentAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? canceledAt;
  final String imageUrl;
  final List<String> categories;
  final int borrowedCount;

  DonationBook({
    required this.id,
    required this.stock,
    required this.name,
    required this.status,
    required this.description,
    required this.planSentAt,
    this.acceptedAt,
    this.rejectedAt,
    this.canceledAt,
    required this.imageUrl,
    required this.categories,
    required this.borrowedCount,
  });

  factory DonationBook.fromJson(Map<String, dynamic> json) {
    return DonationBook(
      id: json['id'] ?? 0,
      stock: json['stock'] ?? 0,
      name: json['name'] ?? 'Unknown',
      status: json['status'] ?? 'PENDING',
      description: json['description'] ?? 'Deskripsi buku',
      planSentAt: json['planSentAt'] != null
          ? DateTime.parse(json['planSentAt'])
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'])
          : null,
      imageUrl: json['imageurl'] ?? '',
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((item) => item['category']['name'] as String)
          .toList(),
      borrowedCount: json['_count']?['peminjaman'] ?? 0,
    );
  }

  @override
  String toString() {
    return '''
DonationBook {
  id: $id,
  stock: $stock,
  name: "$name",
  description: "$description",
  planSentAt: $planSentAt,
  acceptedAt: $acceptedAt,
  rejectedAt: $rejectedAt,
  canceledAt: $canceledAt,
  imageUrl: "$imageUrl",
  categories: ${categories.join(', ')},
  borrowedCount: $borrowedCount
}
''';
  }
}

class DonationBooksResponse {
  final String message;
  final List<DonationBook> data;
  final Pagination pagination;

  DonationBooksResponse({
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory DonationBooksResponse.fromJson(Map<String, dynamic> json) {
    return DonationBooksResponse(
      message: json['message'] ?? 'No message',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => DonationBook.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class DonationBookByIdResponse {
  final String message;
  final DonationBook data;

  DonationBookByIdResponse({
    required this.message,
    required this.data,
  });

  factory DonationBookByIdResponse.fromJson(Map<String, dynamic> json) {
    return DonationBookByIdResponse(
      message: json['message'] ?? 'No message',
      data: DonationBook.fromJson(json['data'] ?? {}),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPage;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPage,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPage: json['totalPage'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 0,
    );
  }
}
