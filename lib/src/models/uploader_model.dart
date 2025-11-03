class Uploader {
  final int id;
  final String username;

  Uploader({required this.id, required this.username});

  factory Uploader.fromJson(Map<String, dynamic> json) {
    return Uploader(
      id: json['id'],
      username: json['username'] ?? 'Unknown User',
    );
  }
}
