import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../models/login_response_model.dart';

class AuthApi {
  Future<bool> register(String username, String email, String password,
      String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$serverPath/user/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.body);
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$serverPath/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return LoginResponse.fromJson(responseData);
    } else {
      throw Exception(response.body);
    }
  }

  Future<bool> verify(String email, String verificationCode) async {
    print(email);
    print(verificationCode);
    final response = await http.post(
      Uri.parse('$serverPath/user/verify'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'verificationCode': verificationCode,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resendVerif(String email) async {
    print(email);
    final response = await http.post(
      Uri.parse('$serverPath/user/resend-verification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (Exception(response.body));
    }
  }
}
