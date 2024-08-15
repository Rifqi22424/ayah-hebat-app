import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../utils/shared_preferences.dart';

class UserApi {
  Future<bool> changePassword(String email, String oldPassword,
      String newPassword, confirmNewPassword) async {
    final response = await http.put(
      Uri.parse('$serverPath/auth/change-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (Exception(response.body));
    }
  }

  Future<bool> sendDeleteAccountVerification(String email) async {
    final String? token = await SharedPreferencesHelper.getToken();

    if (token == null) {
      throw ('Token not available');
    }

    final response = await http.post(
      Uri.parse('$serverPath/user/delete-account/verification-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (response.body);
    }
  }

  Future<bool> sendVerifyAccount(String email, String verificationCode) async {
    final String? token = await SharedPreferencesHelper.getToken();

    if (token == null) {
      throw ('Token not available');
    }

    final response = await http.post(
      Uri.parse('$serverPath/user/delete-account/verify'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'verificationCode': verificationCode,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (response.body);
    }
  }

  Future<bool> resendDeleteAccountVerification(String email) async {
    final String? token = await SharedPreferencesHelper.getToken();

    if (token == null) {
      throw ('Token not available');
    }

    final response = await http.post(
      Uri.parse('$serverPath/user/delete-account/resend-verification-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (response.body);
    }
  }

  Future<bool> deleteAccount(String email, String password, String reason) async {
    final String? token = await SharedPreferencesHelper.getToken();

    if (token == null) {
      throw ('Token not available');
    }

    final response = await http.delete(
      Uri.parse('$serverPath/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (response.body);
    }
  }

  Future<bool> sendForgotPassword() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/user/send-forgot'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (Exception(response.body));
    }
  }

  Future<bool> forgotPassword(
      String newPassword, String confirmNewPassword, String token) async {
    final response = await http.put(
      Uri.parse('$serverPath/user/forgot-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (Exception(response.body));
    }
  }

  Future<bool> saveDeviceToken(String deviceToken) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.put(
      Uri.parse('$serverPath/user/save-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'token': deviceToken,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw (Exception(response.body));
    }
  }
}
