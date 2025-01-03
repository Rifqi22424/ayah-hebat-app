import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';

import '../../main.dart';
import '../models/book_model.dart';
import '../models/borrow_books_model.dart';
import '../models/donation_book.dart';
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

  Future<bool> createBookDonation(
    String name,
    String description,
    String stock,
    String planSentAt,
    String categoryIds,
    File photo,
  ) async {
    final url = Uri.parse('$serverPath/books/donation');
    final request = http.MultipartRequest('POST', url);
    String? token = await SharedPreferencesHelper.getToken();

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['stock'] = stock;
    request.fields['planSentAt'] = planSentAt;
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

    print(response.statusCode);

    final responseBody = await response.stream.bytesToString();
    final decodedResponse = json.decode(responseBody);

    // Check the response status
    if (response.statusCode == 201) {
      return true;
    } else {
      // If the status code is not 201, throw the error message
      throw decodedResponse['error'] ?? 'Unknown error';
    }
  }

  Future<BorrowBook> borrowABook(
      int bookId, String plannedPickUpDate, String deadlineDate) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.post(
      Uri.parse('$serverPath/pinjam-buku'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'bookId': bookId.toString(),
        'plannedPickUpDate': plannedPickUpDate,
        'deadlineDate': deadlineDate,
      }),
    );

    if (response.statusCode == 202) {
      return BorrowBook.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<BorrowBooksResponse> getBorrowBooks({int page = 1}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/pinjam-buku/me?page=$page'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return BorrowBooksResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<BorrowBookByIdResponse> getBorrowBookById(
      {required int borrowId}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/pinjam-buku/$borrowId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return BorrowBookByIdResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<DonationBooksResponse> getDonationBooks({int page = 1}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/books/donation?page=$page'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // print(json.decode(response.body)['data']);
      // print(json.decode(response.body));
      // print(response.body);
      return DonationBooksResponse.fromJson(json.decode(response.body));
    } else {
      // print(response.body);
      // print(json.decode(response.body));
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<DonationBookByIdResponse> getDonationBookById(
      {required int bookId}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/books/donation/$bookId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DonationBookByIdResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }
}
