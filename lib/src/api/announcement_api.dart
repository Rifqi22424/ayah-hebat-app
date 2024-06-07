import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../models/announcement_model.dart';
import '../utils/shared_preferences.dart';

class AnnouncementApi {
  Future<List<Announcement>> getUserAnnouncements() async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/notification/user-notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Announcement> announcements =
          body.map((dynamic item) => Announcement.fromJson(item)).toList();
      return announcements;
    } else {
      throw Exception(response.body);
    }
  }

  Future<Announcement> getAnnouncementById(int announcementId) async {
    String? token = await SharedPreferencesHelper.getToken();
    final response = await http.get(
      Uri.parse('$serverPath/notification/id/$announcementId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      Announcement announcement = Announcement.fromJson(body);
      return announcement;
    } else {
      throw Exception(response.body);
    }
  }
}
