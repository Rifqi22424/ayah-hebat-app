import 'dart:convert';
import 'package:ayahhebat/src/models/question_model.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../utils/shared_preferences.dart';

class QuestionApi {
  Future<bool> createQuestion(String question) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/question'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'question': question,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Question>> getAllQuestion() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/question'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<Question> questions =
          responseData.map((data) => Question.fromJson(data)).toList();
      return questions;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Question>> getAllQuestionWithAnswer() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/question/answer'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<Question> questions =
          responseData.map((data) => Question.fromJson(data)).toList();
      return questions;
    } else {
      throw Exception(response.body);
    }
  }

  Future<bool> resendVerif(String email) async {
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
