class Profile {
  final int id;
  final String nama;
  final String bio;
  final String namaIstri;
  final String namaAnak;
  final int tahunMasukKuttab;
  final int userId;
  final String photo;

  Profile({
    required this.id,
    required this.bio,
    required this.namaIstri,
    required this.namaAnak,
    required this.tahunMasukKuttab,
    required this.userId,
    required this.photo,
    required this.nama,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? "",
      bio: json['bio'] ?? "",
      namaIstri: json['namaIstri'] ?? "",
      namaAnak: json['namaAnak'] ?? "",
      tahunMasukKuttab: json['tahunMasukKuttab'] ?? 0,
      userId: json['userId'] ?? 0,
      photo: json['photo'] ?? "",
    );
  }

  factory Profile.getProfilefromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['profile']['id'] ?? 0,
      nama: json['profile']['nama'] ?? "",
      bio: json['profile']['bio'] ?? "",
      namaIstri: json['profile']['namaIstri'] ?? "",
      namaAnak: json['profile']['namaAnak'] ?? "",
      tahunMasukKuttab: json['profile']['tahunMasukKuttab'] ?? 0,
      userId: json['profile']['userId'] ?? 0,
      photo: json['profile']['photo'] ?? "",
    );
  }
}
