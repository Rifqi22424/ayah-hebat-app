import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../main.dart';
import '../models/user_profile_model.dart';
import '../utils/shared_preferences.dart';

class KegiatanApi {
  String getMediaType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    if (extension == 'jpeg' || extension == 'jpg' || extension == 'png') {
      return 'image';
    } else if (extension == 'mp4') {
      return 'video';
    } else if (extension == 'mp3') {
      return 'audio';
    } else {
      return 'application';
    }
  }

  Future<bool> postKegiatan(
    String title,
    String userId,
    File? file1,
    File? file2,
    File? file3,
  ) async {
    try {
      final url = Uri.parse('$serverPath/kegiatan');
      final request = http.MultipartRequest('POST', url);
      String? token = await SharedPreferencesHelper.getToken();

      request.fields['title'] = title;
      request.fields['userId'] = userId;
      request.headers['Authorization'] = 'Bearer $token';
      print(token);

      if (file1 != null) {
        final fotoPart = await http.MultipartFile.fromPath(
          'file1',
          file1.path,
          contentType:
              MediaType(getMediaType(file1.path), file1.path.split('.').last),
        );
        request.files.add(fotoPart);
      }

      if (file2 != null) {
        final videoPart = await http.MultipartFile.fromPath(
          'file2',
          file2.path,
          contentType:
              MediaType(getMediaType(file2.path), file2.path.split('.').last),
        );
        request.files.add(videoPart);
      }

      if (file3 != null) {
        final audioPart = await http.MultipartFile.fromPath(
          'file3',
          file3.path,
          contentType:
              MediaType(getMediaType(file3.path), file3.path.split('.').last),
        );
        request.files.add(audioPart);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to upload data. Status code: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');

        return false;
      }
    } catch (error) {
      print('Error posting data: $error');
      return false;
    }
  }

  Future<List<UserProfile>> getTopUsers(String time, String token) async {
    final response = await http.get(
      Uri.parse('$serverPath/kegiatan/top-score/$time'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<UserProfile> topUsers = jsonResponse
          .map((data) => UserProfile.fromJson(data))
          .toList();
      return topUsers;
    } else {
      print(response.statusCode);
      throw Exception(response.statusCode);
    }
  }
}
