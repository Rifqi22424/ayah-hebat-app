import 'dart:convert';

import '../../main.dart';
import '../models/post_model.dart';
import '../utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostApi {
  Future<List<Post>> getPosts({int limit = 5, int offset = 0}) async {
    final uri = Uri.parse('$serverPath/post').replace(queryParameters: {
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
      List<Post> posts =
          responseData.map((data) => Post.fromJson(data)).toList();
      return posts;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<List<Post>> searchPosts(
      {int limit = 5, int offset = 0, required String query}) async {
    String? token = await SharedPreferencesHelper.getToken();

    final uri = Uri.parse('$serverPath/post/search').replace(queryParameters: {
      'query': query,
      'limit': limit.toString(),
      'offset': offset.toString()
    });

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<Post> posts =
          responseData.map((data) => Post.fromJson(data)).toList();
      return posts;
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<Post> createPost(String body) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/post'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<Post> editPost(String body, int postId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.put(
      Uri.parse('$serverPath/post/${postId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<bool> deletePost(int postId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.delete(
      Uri.parse('$serverPath/post/${postId.toString()}'),
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

  Future<bool> likePost(int postId) async {
    String? token = await SharedPreferencesHelper.getToken();
    print(token);
    final response = await http.post(
      Uri.parse('$serverPath/post/${postId.toString()}/like'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("berhasil like");
      return true;
    } else {
      print("gagal like");
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<bool> dislikePost(int postId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.delete(
      Uri.parse('$serverPath/post/${postId.toString()}/like'),
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
