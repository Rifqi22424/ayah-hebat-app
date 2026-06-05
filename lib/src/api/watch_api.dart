// api/watch_api.dart

import 'dart:convert';
import 'dart:io'; // Untuk File
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Untuk MediaType

import '../../main.dart';
import '../utils/shared_preferences.dart';

import '../models/content_model.dart';
import '../models/playlist_model.dart';
import '../models/simple_playlist_model.dart';
import '../models/response/paginated_content_response.dart';

class WatchApi {
  // --- Helper ---

  Future<Map<String, String>> _getAuthHeaders({bool isJson = true}) async {
    String? token = await SharedPreferencesHelper.getToken();
    var headers = <String, String>{
      'Authorization': 'Bearer $token',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    return headers;
  }

  dynamic _handleErrorResponse(http.Response response) {
    // Coba decode error, jika gagal, lempar status code saja
    try {
      final errorData = json.decode(response.body)['error'];
      throw errorData ?? 'Unknown error: ${response.statusCode}';
    } catch (e) {
      throw 'Failed to parse error: ${response.body}';
    }
  }

  // --- Content Endpoints (/content) ---

  Future<PaginatedContentResponse> getAllWatches({
    int limit = 10,
    int page = 1,
    String? search,
  }) async {
    final queryParams = {
      'limit': limit.toString(),
      'page': page.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri =
        Uri.parse('$serverPath/watch').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _getAuthHeaders());
    print(uri);
    print(response);

    if (response.statusCode == 200) {
      return PaginatedContentResponse.fromJson(json.decode(response.body));
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<Content> getWatchById(int id) async {
    final uri = Uri.parse('$serverPath/watch/${id.toString()}');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      // Data ada di dalam key 'video'
      return Content.fromJson(json.decode(response.body)['video']);
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<Content> createWatch({
    required String title,
    required String videoUrl,
    required File thumbnailFile,
    String? description,
    int? duration,
  }) async {
    final uri = Uri.parse('$serverPath/content');
    String? token = await SharedPreferencesHelper.getToken();

    var request = http.MultipartRequest('POST', uri);

    // Header
    request.headers['Authorization'] = 'Bearer $token';

    // Fields
    request.fields['title'] = title;
    request.fields['videoUrl'] = videoUrl;
    if (description != null) {
      request.fields['description'] = description;
    }
    if (duration != null) {
      request.fields['duration'] = duration.toString();
    }

    // File
    request.files.add(await http.MultipartFile.fromPath(
      'thumbnail', // Key ini HARUS SAMA dengan di backend: upload.single("thumbnail")
      thumbnailFile.path,
      contentType:
          MediaType('image', 'jpeg'), // Sesuaikan jika perlu (png, dll)
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      // 201 Created
      return Content.fromJson(json.decode(response.body)['video']);
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<Content> updateWatch({
    required int id,
    String? title,
    String? videoUrl,
    File? thumbnailFile, // Thumbnail opsional
    String? description,
    int? duration,
  }) async {
    final uri = Uri.parse('$serverPath/watch/${id.toString()}');
    String? token = await SharedPreferencesHelper.getToken();

    var request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Fields opsional
    if (title != null) request.fields['title'] = title;
    if (videoUrl != null) request.fields['videoUrl'] = videoUrl;
    if (description != null) request.fields['description'] = description;
    if (duration != null) request.fields['duration'] = duration.toString();

    // File opsional
    if (thumbnailFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'thumbnail',
        thumbnailFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Content.fromJson(json.decode(response.body)['video']);
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<bool> deleteWatch(int id) async {
    final uri = Uri.parse('$serverPath/watch/${id.toString()}');
    final response = await http.delete(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      return true;
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<void> incrementWatchView(int id) async {
    final uri = Uri.parse('$serverPath/watch/${id.toString()}/view');

    final response =
        await http.patch(uri, headers: await _getAuthHeaders(isJson: false));

    if (response.statusCode == 200) {
      return;
    } else {
      return _handleErrorResponse(response);
    }
  }

  // --- Playlist Endpoints (/playlist) ---

  Future<List<SimplePlaylist>> getAllPlaylists() async {
    final uri = Uri.parse('$serverPath/playlist');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => SimplePlaylist.fromJson(data)).toList();
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<Playlist> getPlaylistById(int id) async {
    final uri = Uri.parse('$serverPath/playlist/${id.toString()}');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      // Controller Anda sudah memformat ini dengan benar
      return Playlist.fromJson(json.decode(response.body));
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<SimplePlaylist> createPlaylist(String title,
      {String? description}) async {
    final uri = Uri.parse('$serverPath/playlist');
    final body = jsonEncode(<String, String>{
      'title': title,
      if (description != null) 'description': description,
    });

    final response =
        await http.post(uri, headers: await _getAuthHeaders(), body: body);

    if (response.statusCode == 201) {
      return SimplePlaylist.fromJson(json.decode(response.body));
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<SimplePlaylist> updatePlaylist(int id,
      {String? title, String? description}) async {
    final uri = Uri.parse('$serverPath/playlist/${id.toString()}');
    final bodyMap = <String, String>{};
    if (title != null) bodyMap['title'] = title;
    if (description != null) bodyMap['description'] = description;

    final response = await http.patch(uri,
        headers: await _getAuthHeaders(), body: jsonEncode(bodyMap));

    if (response.statusCode == 200) {
      return SimplePlaylist.fromJson(json.decode(response.body));
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<bool> deletePlaylist(int id) async {
    final uri = Uri.parse('$serverPath/playlist/${id.toString()}');
    final response = await http.delete(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 204) {
      // 204 No Content
      return true;
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<bool> addContentToPlaylist(
      {required int playlistId, required int contentId}) async {
    final uri = Uri.parse('$serverPath/playlist/$playlistId/contents');
    final body = jsonEncode(<String, String>{
      'contentId': contentId.toString(),
    });

    final response =
        await http.post(uri, headers: await _getAuthHeaders(), body: body);

    if (response.statusCode == 201) {
      return true;
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<bool> removeContentFromPlaylist(
      {required int playlistId, required int contentId}) async {
    final uri =
        Uri.parse('$serverPath/playlist/$playlistId/contents/$contentId');
    final response = await http.delete(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 204) {
      return true;
    } else {
      return _handleErrorResponse(response);
    }
  }

  Future<bool> updateContentOrder({
    required int playlistId,
    required int contentId,
    required int newOrder,
  }) async {
    final uri =
        Uri.parse('$serverPath/playlist/$playlistId/contents/$contentId');
    final body = jsonEncode(<String, dynamic>{
      'newOrder': newOrder,
    });

    final response =
        await http.patch(uri, headers: await _getAuthHeaders(), body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return _handleErrorResponse(response);
    }
  }
}
