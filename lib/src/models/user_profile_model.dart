import 'profile_model.dart';

class UserProfile {
  final int id;
  final String username;
  final String email;
  final int totalScoreYear;
  final int totalScoreMonth;
  final int totalScoreDay;
  final Profile profile;

  UserProfile(
      {required this.id,
      required this.username,
      required this.email,
      required this.totalScoreYear,
      required this.totalScoreMonth,
      required this.totalScoreDay,
      required this.profile});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      totalScoreYear: json['totalScoreYear'] ?? 0,
      totalScoreMonth: json['totalScoreMonth'] ?? 0,
      totalScoreDay: json['totalScoreDay'] ?? 0,
      profile: Profile.fromJson(json['profile'] ?? {}),
    );
  }

  factory UserProfile.getUserNProfilefromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user']['id'] ?? 0,
      username: json['user']['username'] ?? "",
      email: json['user']['email'] ?? "",
      totalScoreYear: json['user']['totalScoreYear'] ?? 0,
      totalScoreMonth: json['user']['totalScoreMonth'] ?? 0,
      totalScoreDay: json['user']['totalScoreDay'] ?? 0,
      profile: Profile.fromJson(json['user']['profile'] ?? {}),
    );
  }
}
