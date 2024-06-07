class News {
  final int id;
  final String title;
  final String subTitle;
  final String author;
  final String imageUrl;
  final String content;
  final String createdAt;
  final String updatedAt;

  News(
      {required this.id,
      required this.title,
      required this.subTitle,
      required this.author,
      required this.imageUrl,
      required this.content,
      required this.createdAt,
      required this.updatedAt});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      subTitle: json['subTitle'] ?? "",
      author: json['author'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      content: json['content'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}
