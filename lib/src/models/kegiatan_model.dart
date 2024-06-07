class Kegiatan {
  int id;
  String title;
  String? file1;
  String? file2;
  String? file3;
  int userId;
  int score;
  String createdAt;
  String updatedAt;

  Kegiatan(
      {required this.id,
      required this.title,
      this.file1,
      this.file2,
      this.file3,
      required this.userId,
      required this.score,
      required this.createdAt,
      required this.updatedAt});

  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    return Kegiatan(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      file1: json['file1'] ?? "",
      file2: json['file2'] ?? "",
      file3: json['file3'] ?? "",
      userId: json['userId'] ?? 0,
      score: json['score'] ?? 0,
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}
