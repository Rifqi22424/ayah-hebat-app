import 'dart:convert';

import 'package:ayahhebat/main.dart';
import 'package:ayahhebat/src/models/branch_model.dart';
import 'package:http/http.dart' as http;

class BranchApi {
  Future<List<Branch>> getBranchesByZoneId(int zoneId) async {
    final response = await http.get(
      Uri.parse('$serverPath/branches/$zoneId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      }
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<dynamic> branchesJson = responseData['data'];
      return branchesJson.map((json) => Branch.fromJson(json)).toList();
    } else {
      throw Exception('Gagal Mengambil Cabang');
    }
  }
}