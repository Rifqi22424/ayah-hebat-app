import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';

class UserApi {
  Future<bool> changePassword(String email, String oldPassword,
      String newPassword, confirmNewPassword) async {
    final response = await http.put(
      Uri.parse('$serverPath/user/change-password'),
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
      print(response.statusCode);
      print(response.body);
      return false;
    }
  }
}
