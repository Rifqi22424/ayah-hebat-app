class BookCategory {
  int id;
  String name;

  BookCategory({
    required this.id,
    required this.name,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  BookCategory copyWith({
    int? id,
    String? name,
  }) {
    return BookCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  
}
