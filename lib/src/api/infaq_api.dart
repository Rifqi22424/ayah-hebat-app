import 'dart:convert';

import 'package:ayahhebat/src/models/response/infaqs_response.dart';
import 'package:ayahhebat/src/utils/shared_preferences.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;

import '../models/entity/infaq_model.dart';
import '../models/response/create_infaq_response.dart';

class InfaqApi {
  Future<InfaqsResponse> fetchInfaqs({int limit = 5, int page = 1}) async {
    String? token = await SharedPreferencesHelper.getToken();
    print(token);
    final Uri uri =
        Uri.parse('$serverPath/infaq/history').replace(queryParameters: {
      'limit': limit.toString(),
      'page': page.toString(),
    });
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return InfaqsResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<int> fetchTotalAmountUser() async {
    String? token = await SharedPreferencesHelper.getToken();
    final Uri uri = Uri.parse('$serverPath/infaq/amount');
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<DetailInfaq> fetchDetailInfaq({required String id}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final Uri uri = Uri.parse('$serverPath/infaq/$id');
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return DetailInfaq.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<CreateInfaqResponse> createInfaq(
      {required int amount,
      required String phoneNumber,
      required String email,
      required String allocationTypeCode}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final body = json.encode({
      'amount': amount,
      'phoneNumber': phoneNumber,
      'email': email,
      'allocationTypeCode': allocationTypeCode,
    });

    final response = await http.post(
      Uri.parse('$serverPath/infaq'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return CreateInfaqResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }
}
