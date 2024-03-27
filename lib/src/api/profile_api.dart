import 'dart:convert';
import 'dart:io';
import 'package:ayahhebat/src/models/user_profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../main.dart';
import '../models/profile_model.dart';
import '../utils/shared_preferences.dart';

class ProfileApi {
  String getMediaType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    if (extension == 'jpeg' || extension == 'jpg' || extension == 'png') {
      return 'image';
    } else {
      return 'application';
    }
  }

  Future<bool> addProfile(
    String nama,
    String bio,
    String namaKuttab,
    String tahunMasukKuttab,
    String namaIstri,
    String namaAnak,
    File? photo,
  ) async {
    try {
      final url = Uri.parse('$serverPath/profile/add-profile');
      final request = http.MultipartRequest('POST', url);
      String? token = await SharedPreferencesHelper.getToken();

      request.fields['nama'] = nama;
      request.fields['bio'] = bio;
      request.fields['namaKuttab'] = namaKuttab;
      request.fields['tahunMasukKuttab'] = tahunMasukKuttab;
      request.fields['namaIstri'] = namaIstri;
      request.fields['namaAnak'] = namaAnak;
      request.headers['Authorization'] = 'Bearer $token';

      if (photo != null) {
        final fotoPart = await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType:
              MediaType(getMediaType(photo.path), photo.path.split('.').last),
        );
        request.files.add(fotoPart);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {

        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<bool> editProfile(
    String nama,
    String bio,
    String namaKuttab,
    String tahunMasukKuttab,
    String namaIstri,
    String namaAnak,
    File? photo,
  ) async {
    try {
      final url = Uri.parse('$serverPath/profile/edit-profile');
      final request = http.MultipartRequest('PUT', url);
      String? token = await SharedPreferencesHelper.getToken();

      request.fields['nama'] = nama;
      request.fields['bio'] = bio;
      request.fields['namaKuttab'] = namaKuttab;
      request.fields['tahunMasukKuttab'] = tahunMasukKuttab;
      request.fields['namaIstri'] = namaIstri;
      request.fields['namaAnak'] = namaAnak;
      request.headers['Authorization'] = 'Bearer $token';

      if (photo != null) {
        final fotoPart = await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType:
              MediaType(getMediaType(photo.path), photo.path.split('.').last),
        );
        request.files.add(fotoPart);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {

        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<Profile> getProfile() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/profile/get-profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Profile.getProfilefromJson(responseData);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<UserProfile> getUserNProfile() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/profile/get-user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return UserProfile.getUserNProfilefromJson(responseData);
    } else {
      throw Exception(response.statusCode);
    }
  }
}
