import 'dart:convert';

import '../../main.dart';
import '../models/comment_model.dart';
import '../models/reply_model.dart';
import '../utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommentApi {
  Future<List<Comment>> getComments({int limit = 5, int offset = 0}) async {
    final uri = Uri.parse('$serverPath/comment').replace(queryParameters: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });

    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<Comment> comments =
          responseData.map((data) => Comment.fromJson(data)).toList();
      return comments;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<Comment> createComment(String body, int postId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/comment/${postId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<Comment> editComment(String body, int commentId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.put(
      Uri.parse('$serverPath/comment/${commentId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<bool> deleteComment(int commentId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.delete(
      Uri.parse('$serverPath/comment/${commentId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<bool> likeComment(int commentId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/post/${commentId.toString()}/like'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<List<Reply>> getReplies({int limit = 5, int offset = 1}) async {
    final uri = Uri.parse('$serverPath/reply').replace(queryParameters: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });

    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<Reply> replies =
          responseData.map((data) => Reply.fromJson(data)).toList();
      return replies;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

    Future<bool> likeReply(int replyId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/reply/${replyId.toString()}/like'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<Reply> createReply(String body, int commentId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/reply/${commentId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      return Reply.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<Reply> editReply(String body, int replyId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.put(
      Uri.parse('$serverPath/reply/${replyId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      return Reply.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<bool> deleteReply(int replyId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.delete(
      Uri.parse('$serverPath/reply/${replyId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }
}
