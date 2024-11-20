import 'dart:convert';

import '../../main.dart';
import '../models/book_model.dart';
import '../utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookApi {
  Future<List<Book>> getAllBooks(
      {int limit = 10,
      int offset = 0,
      String? search,
      String? category}) async {
    String? token = await SharedPreferencesHelper.getToken();

    final queryParameters = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'search': search ?? '',
      'category': category ?? '',
    };

    final uri = Uri.parse('$serverPath/books')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body)['data'];
      List<Book> books =
          responseData.map((data) => Book.fromJson(data)).toList();
      return books;
    } else {
      throw json.decode(response.body)['error'];
    }
  }
}
