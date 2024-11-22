import 'post_model.dart';

class BookDetail {
  final String name;
  final String description;
  final String imageUrl;
  final String location;
  final int stock;
  final List<String> categories;
  final List<Review> reviews;

  BookDetail({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.stock,
    required this.categories,
    required this.reviews,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageurl'] ?? '',
      location: json['location'] ?? '',
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
      'name': name,
      'description': description,
      'location': location,
      'imageurl': imageUrl,
      'stock': stock,
      'categories': reviews.map((category) => {'name': category}).toList(),
      'comment_book': reviews.map((review) => review.toJson()).toList(),
    };
  }

  BookDetail copyWith({
    String? name,
    String? description,
    String? location,
    String? imageUrl,
    int? stock,
    List<String>? categories,
    List<Review>? reviews,
  }) {
    return BookDetail(
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      categories: categories ?? this.categories,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  String toString() {
    return 'BookDetail(name: $name, description: $description, location: $location, imageUrl: $imageUrl, stock: $stock, categories: $categories, reviews: $reviews)';
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
