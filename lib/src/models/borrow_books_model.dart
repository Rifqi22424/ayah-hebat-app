class BorrowBook {
  final int id;
  final String status;
  final DateTime submissionDate;
  final DateTime deadlineDate;
  final DateTime? plannedPickUpDate;
  final DateTime? actualPickUpDate;
  final DateTime? returnDate;
  final DateTime? cancelDate;
  final BookData book;

  BorrowBook({
    required this.id,
    required this.status,
    required this.submissionDate,
    required this.deadlineDate,
    this.plannedPickUpDate,
    this.actualPickUpDate,
    this.returnDate,
    this.cancelDate,
    required this.book,
  });

  factory BorrowBook.fromJson(Map<String, dynamic> json) {
    return BorrowBook(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'PENDING',
      submissionDate: json['submissionDate'] != null
          ? DateTime.parse(json['submissionDate'])
          : DateTime.now(),
      deadlineDate: json['deadlineDate'] != null
          ? DateTime.parse(json['deadlineDate'])
          : DateTime.now(),
      plannedPickUpDate: json['plannedPickUpDate'] != null
          ? DateTime.parse(json['plannedPickUpDate'])
          : null,
      actualPickUpDate: json['actualPickUpDate'] != null
          ? DateTime.parse(json['actualPickUpDate'])
          : null,
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
      cancelDate: json['cancelDate'] != null
          ? DateTime.parse(json['cancelDate'])
          : null,
      book: json['book'] != null
          ? BookData.fromJson(json['book'])
          : BookData(name: 'Unknown', imageUrl: '', categories: []),
    );
  }
}

class BookData {
  final String name;
  final String imageUrl;
  final List<String> categories;

  BookData({
    required this.name,
    required this.imageUrl,
    required this.categories,
  });

  factory BookData.fromJson(Map<String, dynamic> json) {
    return BookData(
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageurl'] ?? '',
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((item) => item['category']['name'] as String)
          .toList(),
    );
  }
}

class BorrowBookByIdResponse {
  final String message;
  final BorrowBook data;

  BorrowBookByIdResponse({
    required this.message,
    required this.data,
  });

  factory BorrowBookByIdResponse.fromJson(Map<String, dynamic> json) {
    return BorrowBookByIdResponse(
      message: json['message'] ?? 'No message',
      data: BorrowBook.fromJson(json['data'] ?? {}),
    );
  }
}

class BorrowBooksResponse {
  final String message;
  final List<BorrowBook> data;
  final Pagination pagination;

  BorrowBooksResponse({
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory BorrowBooksResponse.fromJson(Map<String, dynamic> json) {
    return BorrowBooksResponse(
      message: json['message'] ?? 'No message',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => BorrowBook.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
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
