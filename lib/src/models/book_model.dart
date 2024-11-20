class Book {
  final int id;
  final String name;
  final int stock;
  final String imageurl;
  final List<String> categories;

  Book({
    required this.id,
    required this.name,
    required this.stock,
    required this.imageurl,
    required this.categories,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      stock: json['stock'] ?? 0,
      imageurl: json['imageurl'] ?? "",
      categories: (json['categories'] as List<dynamic>)
          .map((category) => category['category']['name'] as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'imageurl': imageurl,
      'categories': categories.map((category) => {'name': category}).toList(),
    };
  }

  Book copyWith({
    int? id,
    String? name,
    String? description,
    int? stock,
    String? imageurl,
    List<String>? categories,
  }) {
    return Book(
        id: id ?? this.id,
        name: name ?? this.name,
        stock: stock ?? this.stock,
        imageurl: imageurl ?? this.imageurl,
        categories: categories ?? this.categories);
  }

  @override
  String toString() {
    return 'Book(id: $id, name: $name, stock: $stock, imageurl: $imageurl, categories: $categories)';
  }
}
