class NewestNews {
  final int id;
  final String title;
  final String subTitle;
  final String author;
  final String imageUrl;

  NewestNews(
      {required this.id,
      required this.title,
      required this.subTitle,
      required this.author,
      required this.imageUrl});

  factory NewestNews.fromJson(Map<String, dynamic> json) {
    return NewestNews(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      subTitle: json['subTitle'] ?? "",
      author: json['author'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
    );
  }
}
