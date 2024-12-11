// import 'dart:convert';

// import '../../main.dart';
// import '../models/borrow_book_response.dart';
// import '../utils/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class BorrowBookApi {
//   Future<BorrowBookResponse> borrowABook(
//       int bookId, String plannedPickUpDate, String deadlineDate) async {
//     String? token = await SharedPreferencesHelper.getToken();
//     final response = await http.post(
//       Uri.parse('$serverPath/pinjam-buku'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode(<String, String>{
//         'bookId': bookId.toString(),
//         'plannedPickUpDate': plannedPickUpDate,
//         'deadlineDate': deadlineDate,
//       }),
//     );

//     if (response.statusCode == 202) {
//       return BorrowBookResponse.fromJson(json.decode(response.body)['data']);
//     } else {
//       final errorData = json.decode(response.body)['error'];
//       throw errorData;
//     }
//   }
// }
