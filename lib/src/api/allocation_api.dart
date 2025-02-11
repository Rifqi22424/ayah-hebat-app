import 'dart:convert';

import 'package:ayahhebat/src/models/response/allocations_response.dart';
import 'package:ayahhebat/src/utils/shared_preferences.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;

class AllocationApi {
  Future<AllocationsResponse> fetchAlocations() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http
        .get(Uri.parse('$serverPath/allocation'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return AllocationsResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }
}
