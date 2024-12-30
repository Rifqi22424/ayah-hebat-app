import 'dart:convert';

import '../../main.dart';
import '../models/book_category_model.dart';
import '../utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookCategoryApi {
  Future<List<BookCategory>> getAllCategoryBooks({String? search}) async {
    String? token = await SharedPreferencesHelper.getToken();
    // print("masuk category");

    final queryParameters = {
      'search': search ?? '',
    };

    final uri = Uri.parse('$serverPath/categories')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      // print("responseData $responseData");
      List<BookCategory> categoryBooks =
          responseData.map((data) => BookCategory.fromJson(data)).toList();
      return categoryBooks;
    } else {
      throw json.decode(response.body)['error'];
    }
  }
}
