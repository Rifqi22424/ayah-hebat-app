import 'dart:convert';

import 'package:ayahhebat/main.dart';
import 'package:ayahhebat/src/models/zone_model.dart';
import 'package:http/http.dart' as http;

class ZoneApi {
  Future<List<Zone>> getAllZone() async {
    final response = await http.get(
      Uri.parse('$serverPath/zones'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      }
    );

    print("response $response");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<dynamic> zonesJson = responseData['data'];
      return zonesJson.map((json) => Zone.fromJson(json)).toList();
    } else {
      throw Exception('Gagal Mengambil Zona');
    }
  }
}