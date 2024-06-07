class Announcement {
  final int id;
  final String title;
  final String body;
  final String content;
  final String routes;
  final String imageUrl;
  final int userId;
  final String createdAt;
  final String updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.content,
    required this.routes,
    required this.imageUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      body: json['body'] ?? "",
      content:
          json['data']['content'] ?? "", 
      routes: json['data']['routes'] ?? "", 
      imageUrl: json['imageUrl'] ?? "",
      userId: json['userId'] ?? 0,
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}
