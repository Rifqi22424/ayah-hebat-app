import 'dart:convert';

import '../../main.dart';
import '../models/office_address_model.dart';
import '../utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OfficeAddressApi {
  Future<List<OfficeAddress>> getAllOfficeAddress() async {
    String? token = await SharedPreferencesHelper.getToken();

    final uri = Uri.parse('$serverPath/address');

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      final List<OfficeAddress> officeAddresses =
          data.map((item) => OfficeAddress.fromJson(item)).toList();

      return officeAddresses;
    } else {
      throw json.decode(response.body)['error'];
    }
  }
}
