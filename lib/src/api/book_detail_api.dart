import 'dart:convert';

import '../../main.dart';
import '../models/book_detail_model.dart';
import '../utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookDetailApi {
  Future<BookDetail> getBookById({required int id}) async {
    String? token = await SharedPreferencesHelper.getToken();

    final uri = Uri.parse('$serverPath/books/${id.toString()}');

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body)['data'];
      BookDetail book = BookDetail.fromJson(responseData);
      return book;
    } else {
      throw json.decode(response.body)['error'];
    }
  }
}
