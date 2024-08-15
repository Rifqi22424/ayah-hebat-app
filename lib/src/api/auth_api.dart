import 'dart:convert';
import 'package:ayahhebat/src/api/user_api.dart';
import 'package:ayahhebat/src/services/notification_service.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../models/login_response_model.dart';

class AuthApi {
  Future<bool> register(String username, String email, String password,
      String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$serverPath/auth/register'),
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
      Uri.parse('$serverPath/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      await _saveDeviceToken();
      final responseData = json.decode(response.body);
      return LoginResponse.fromJson(responseData);
    } else {
      throw Exception(response.body);
    }
  }

  Future<void> _saveDeviceToken() async {
    try {
      String? deviceToken = await PushNotifications.getDeviceToken();
      if (deviceToken != null) {
        await UserApi().saveDeviceToken(deviceToken);
      } else {
        print("Failed to obtain device token");
      }
    } catch (e) {
      print("Error saving device token: $e");
    }
  }

  Future<bool> verify(String email, String verificationCode) async {
    final response = await http.post(
      Uri.parse('$serverPath/auth/verify'),
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
    final response = await http.post(
      Uri.parse('$serverPath/auth/resend-verification'),
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
      print(response.body);
      throw (Exception(response.body));
    }
  }
}
