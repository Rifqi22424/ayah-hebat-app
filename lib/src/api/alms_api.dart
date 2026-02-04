import 'dart:convert';
import 'dart:io';

import 'package:ayahhebat/src/models/response/almss_response.dart';
import 'package:ayahhebat/src/utils/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;

import '../models/entity/alms_model.dart';
import '../models/response/create_alms_response.dart';
import '../utils/get_media_type.dart';

class AlmsApi {
  Future<AlmssResponse> fetchAlmss({int limit = 15, int page = 1}) async {
    String? token = await SharedPreferencesHelper.getToken();
    print(token);
    final Uri uri =
        Uri.parse('$serverPath/alms/history').replace(queryParameters: {
      'limit': limit.toString(),
      'page': page.toString(),
    });
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return AlmssResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<int> fetchTotalAmountUser() async {
    String? token = await SharedPreferencesHelper.getToken();
    final Uri uri = Uri.parse('$serverPath/alms/amount');
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

  Future<DetailAlms> fetchDetailAlms({required String id}) async {
    String? token = await SharedPreferencesHelper.getToken();
    final Uri uri = Uri.parse('$serverPath/alms/$id');
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return DetailAlms.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }

  Future<CreateAlmsResponse> createAlms({
    required int amount,
    required String allocationTypeCode,
    required File transactionProof,
    String? message,
  }) async {
    final url = Uri.parse('$serverPath/alms');
    final request = http.MultipartRequest('POST', url);
    String? token = await SharedPreferencesHelper.getToken();

    request.fields['amount'] = amount.toString();
    request.fields['allocationTypeCode'] = allocationTypeCode;
    if (message != null && message.isNotEmpty) {
      request.fields['message'] = message;
    }

    request.headers['Authorization'] = 'Bearer $token';

    final fotoPart = await http.MultipartFile.fromPath(
      'photo',
      transactionProof.path,
      contentType: MediaType(GetMediaType.getMediaType(transactionProof.path),
          transactionProof.path.split('.').last),
    );
    request.files.add(fotoPart);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreateAlmsResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body)['error'];
      throw errorData;
    }
  }
}
