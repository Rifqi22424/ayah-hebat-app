import 'package:flutter/foundation.dart';
import '../api/watch_api.dart';
import '../models/playlist_model.dart';
import '../models/simple_playlist_model.dart';

enum PlaylistListState { initial, loading, loaded, error }

enum PlaylistDetailState { initial, loading, loaded, error }

enum PlaylistActionState { initial, loading, loaded, error }

enum PlaylistContentActionState { initial, loading, loaded, error }

class PlaylistProvider with ChangeNotifier {
  final WatchApi _watchApi = WatchApi();

  PlaylistListState _playlistListState = PlaylistListState.initial;
  PlaylistDetailState _playlistDetailState = PlaylistDetailState.initial;
  PlaylistActionState _playlistActionState = PlaylistActionState.initial;
  PlaylistContentActionState _contentActionState =
      PlaylistContentActionState.initial;

  List<SimplePlaylist> _playlistList = [];
  Playlist? _currentPlaylist;

  String? _playlistListError;
  String? _playlistDetailError;
  String? _playlistActionError;
  String? _contentActionError;

  PlaylistListState get playlistListState => _playlistListState;
  PlaylistDetailState get playlistDetailState => _playlistDetailState;
  PlaylistActionState get playlistActionState => _playlistActionState;
  PlaylistContentActionState get contentActionState => _contentActionState;

  List<SimplePlaylist> get playlistList => _playlistList;
  Playlist? get currentPlaylist => _currentPlaylist;

  String? get playlistListError => _playlistListError;
  String? get playlistDetailError => _playlistDetailError;
  String? get playlistActionError => _playlistActionError;
  String? get contentActionError => _contentActionError;

  Future<void> fetchAllPlaylists({bool refresh = false}) async {
    if (!refresh && _playlistListState == PlaylistListState.loaded) return;

    _playlistListState = PlaylistListState.loading;
    notifyListeners();

    try {
      _playlistList = await _watchApi.getAllPlaylists();
      _playlistListState = PlaylistListState.loaded;
    } catch (e) {
      _playlistListError = e.toString();
      _playlistListState = PlaylistListState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchPlaylistById(int id) async {
    _playlistDetailState = PlaylistDetailState.loading;
    notifyListeners();

    try {
      _currentPlaylist = await _watchApi.getPlaylistById(id);
      _playlistDetailState = PlaylistDetailState.loaded;
    } catch (e) {
      _playlistDetailError = e.toString();
      _playlistDetailState = PlaylistDetailState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createPlaylist(String title, {String? description}) async {
    _playlistActionState = PlaylistActionState.loading;
    notifyListeners();

    try {
      final newPlaylist =
          await _watchApi.createPlaylist(title, description: description);
      _playlistList.insert(0, newPlaylist); // Tambah ke list
      _playlistActionState = PlaylistActionState.loaded;
      return true;
    } catch (e) {
      _playlistActionError = e.toString();
      _playlistActionState = PlaylistActionState.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updatePlaylist(int id,
      {String? title, String? description}) async {
    _playlistActionState = PlaylistActionState.loading;
    notifyListeners();

    try {
      final updatedSimplePlaylist = await _watchApi.updatePlaylist(id,
          title: title, description: description);

      // Update di list
      final index = _playlistList.indexWhere((pl) => pl.id == id);
      if (index != -1) {
        _playlistList[index] = updatedSimplePlaylist;
      }

      // Jika di halaman detail, fetch ulang data detailnya
      if (_currentPlaylist?.id == id) {
        await fetchPlaylistById(id);
      }

      _playlistActionState = PlaylistActionState.loaded;
      return true;
    } catch (e) {
      _playlistActionError = e.toString();
      _playlistActionState = PlaylistActionState.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deletePlaylist(int id) async {
    _playlistActionState = PlaylistActionState.loading;
    notifyListeners();

    try {
      await _watchApi.deletePlaylist(id);
      _playlistList.removeWhere((pl) => pl.id == id); // Hapus dari list

      if (_currentPlaylist?.id == id) {
        _currentPlaylist = null;
        _playlistDetailState = PlaylistDetailState.initial;
      }
      _playlistActionState = PlaylistActionState.loaded;
      return true;
    } catch (e) {
      _playlistActionError = e.toString();
      _playlistActionState = PlaylistActionState.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addContentToPlaylist(int playlistId, int contentId) async {
    _contentActionState = PlaylistContentActionState.loading;
    notifyListeners();

    try {
      await _watchApi.addContentToPlaylist(
          playlistId: playlistId, contentId: contentId);

      // API tidak mengembalikan list baru, jadi kita fetch ulang
      if (_currentPlaylist?.id == playlistId) {
        await fetchPlaylistById(playlistId);
      }
      _contentActionState = PlaylistContentActionState.loaded;
      return true;
    } catch (e) {
      _contentActionError = e.toString();
      _contentActionState = PlaylistContentActionState.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> removeContentFromPlaylist(int playlistId, int contentId) async {
    _contentActionState = PlaylistContentActionState.loading;
    notifyListeners();

    try {
      await _watchApi.removeContentFromPlaylist(
          playlistId: playlistId, contentId: contentId);

      // Update UI lokal (seperti deleteReply)
      if (_currentPlaylist?.id == playlistId) {
        _currentPlaylist!.contents
            .removeWhere((item) => item.content.id == contentId);
      }
      _contentActionState = PlaylistContentActionState.loaded;
      return true;
    } catch (e) {
      _contentActionError = e.toString();
      _contentActionState = PlaylistContentActionState.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> reorderContentInPlaylist(
      int playlistId, int contentId, int newOrder) async {
    _contentActionState = PlaylistContentActionState.loading;
    notifyListeners();

    try {
      await _watchApi.updateContentOrder(
        playlistId: playlistId,
        contentId: contentId,
        newOrder: newOrder,
      );

      if (_currentPlaylist?.id == playlistId) {
        await fetchPlaylistById(playlistId);
      }
      _contentActionState = PlaylistContentActionState.loaded;
      return true;
    } catch (e) {
      _contentActionError = e.toString();
      _contentActionState = PlaylistContentActionState.error;
      return false;
    } finally {
      notifyListeners();
    }
  }
}
