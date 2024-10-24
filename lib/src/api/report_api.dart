import 'dart:convert';

import '../../main.dart';
import '../utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportApi {
  Future<bool> reportPost(int postId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.delete(
      Uri.parse('$serverPath/report/post/${postId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'reason': "Inappropriate Content",
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<bool> reportComment(int commentId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.delete(
      Uri.parse('$serverPath/report/comment/${commentId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'reason': "Inappropriate Content",
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<bool> reportReply(int commentId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.delete(
      Uri.parse('$serverPath/report/reply/${commentId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'reason': "Inappropriate Content",
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }
}
