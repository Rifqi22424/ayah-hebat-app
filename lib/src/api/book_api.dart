import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';

import '../../main.dart';
import '../models/book_model.dart';
import '../utils/get_media_type.dart';
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

  Future<bool> createBookRequest(
    String name,
    String description,
    String stock,
    String location,
    String activeAt,
    String categoryIds,
    File photo,
  ) async {
    try {
      final url = Uri.parse('$serverPath/books/request');
      final request = http.MultipartRequest('POST', url);
      String? token = await SharedPreferencesHelper.getToken();

      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['stock'] = stock;
      request.fields['location'] = location;
      request.fields['activeAt'] = activeAt;
      request.fields['categoryIds'] = categoryIds;

      request.headers['Authorization'] = 'Bearer $token';

      final fotoPart = await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType(
            GetMediaType.getMediaType(photo.path), photo.path.split('.').last),
      );
      request.files.add(fotoPart);

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.stream.bytesToString();
      }
    } catch (error) {
      return false;
    }
  }
}
