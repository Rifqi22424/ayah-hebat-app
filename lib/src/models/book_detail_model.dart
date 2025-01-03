import 'post_model.dart';

class BookDetail {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int stock;
  final List<String> categories;
  final List<Review> reviews;

  BookDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.stock,
    required this.categories,
    required this.reviews,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageurl'] ?? '',
      stock: json['stock'] ?? '',
      reviews: (json['comment_book'] as List<dynamic>)
          .map((review) => Review.fromJson(review))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((category) => category['category']['name'] as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageurl': imageUrl,
      'stock': stock,
      'categories': reviews.map((category) => {'name': category}).toList(),
      'comment_book': reviews.map((review) => review.toJson()).toList(),
    };
  }

  BookDetail copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    int? stock,
    List<String>? categories,
    List<Review>? reviews,
  }) {
    return BookDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      categories: categories ?? this.categories,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  String toString() {
    return 'BookDetail(id: $id, name: $name, description: $description, imageUrl: $imageUrl, stock: $stock, categories: $categories, reviews: $reviews)';
  }
}

class Review {
  final int id;
  final String description;
  final UserData user;

  Review({
    required this.id,
    required this.description,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      user: UserData.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'user': user.toJson(),
    };
  }

  Review copyWith({
    int? id,
    String? description,
    UserData? user,
  }) {
    return Review(
      id: id ?? this.id,
      description: description ?? this.description,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, description: $description, user: $user)';
  }
}
