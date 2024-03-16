import 'profile_model.dart';

class LoginResponse {
  final String token;
  final int id;
  final String email;
  final Profile profile;

  LoginResponse({
    required this.token,
    required this.id,
    required this.email,
    required this.profile,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? "",
      id: json['user']['id'] ?? 0,
      email: json['user']['email'] ?? "",
      profile: Profile.fromJson(json['user']['profile'] ?? {}),
    );
  }
}
