class PopularNews {
  final int id;
  final String title;
  final String imageUrl;

  PopularNews({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory PopularNews.fromJson(Map<String, dynamic> json) {
    return PopularNews(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
    );
  }
}
