import 'dart:convert';
import 'package:ayahhebat/src/models/news/newest_news_model.dart';
import 'package:ayahhebat/src/models/news/popular_news_model.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../models/news/news_model.dart';
import '../utils/shared_preferences.dart';

class NewsApi {
  // Future<bool> createQuestion(String question) async {
  //   String? token = await SharedPreferencesHelper.getToken();
  //   final response = await http.post(
  //     Uri.parse('$serverPath/question'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'Bearer $token',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'question': question,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     return true;
  //   } else {
  //     throw Exception(response.body);
  //   }
  // }

  Future<List<PopularNews>> getPopularNews() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/news/popular'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<PopularNews> popularNews =
          responseData.map((data) => PopularNews.fromJson(data)).toList();
      return popularNews;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<NewestNews>> getNewestNews(
      {int limit = 5, int offset = 0}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/news/new?limit=$limit&offset=$offset'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<NewestNews> newestNews =
          responseData.map((data) => NewestNews.fromJson(data)).toList();
      return newestNews;
    } else {
      throw Exception(response.body);
    }
  }

  Future<News> getNewsById(int newsId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/news/${newsId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      News news = News.fromJson(jsonResponse);
      return news;
    } else {
      throw Exception(response.body);
    }
  }

  // Future<List<Question>> getAllQuestionWithAnswer() async {
  //   String? token = await SharedPreferencesHelper.getToken();
  //   final response = await http.get(
  //     Uri.parse('$serverPath/question/answer'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> responseData = json.decode(response.body);
  //     List<Question> questions =
  //         responseData.map((data) => Question.fromJson(data)).toList();
  //     return questions;
  //   } else {
  //     throw Exception(response.body);
  //   }
  // }

  // Future<bool> resendVerif(String email) async {
  //   final response = await http.post(
  //     Uri.parse('$serverPath/user/resend-verification'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'email': email,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     return true;
  //   } else {
  //     throw (Exception(response.body));
  //   }
  // }
}
