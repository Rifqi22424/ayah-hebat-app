// providers/watch_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/watch_api.dart';
import '../models/content_model.dart';
import '../models/pagination_metadata_model.dart';

enum WatchListState { initial, loading, loaded, error }

enum WatchDetailState { initial, loading, loaded, error }

enum WatchActionState { initial, loading, loaded, error }

enum IconState { initial, loading, loaded }

class WatchProvider with ChangeNotifier {
  final WatchApi _watchApi = WatchApi();

  WatchListState _watchListState = WatchListState.initial;
  WatchDetailState _watchDetailState = WatchDetailState.initial;
  WatchActionState _watchActionState = WatchActionState.initial;
  IconState _iconState = IconState.initial;

  List<Content> _contentList = [];
  Content? _currentContent;
  PaginationMetadata? _metadata;
  bool _hasMoreData = true;
  int _currentPage = 1;

  String? _watchListError;
  String? _watchDetailError;
  String? _watchActionError;

  WatchListState get watchListState => _watchListState;
  WatchDetailState get watchDetailState => _watchDetailState;
  WatchActionState get watchActionState => _watchActionState;
  IconState get iconState => _iconState;

  List<Content> get contentList => _contentList;
  Content? get currentContent => _currentContent;
  PaginationMetadata? get metadata => _metadata;
  bool get hasMoreData => _hasMoreData;

  String? get watchListError => _watchListError;
  String? get watchDetailError => _watchDetailError;
  String? get watchActionError => _watchActionError;

  Future<void> fetchWatches({
    int limit = 10,
    String? search,
    bool refresh = false,
  }) async {
    if (!refresh &&
        _watchListState == WatchListState.loaded &&
        search == null) {
      return;
    }

    _watchListState = WatchListState.loading;
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _contentList.clear();
    }
    notifyListeners();

    try {
      final response =
          await _watchApi.getAllWatches(limit: limit, page: 1, search: search);

      _contentList = response.videos;
      _metadata = response.metadata;
      _currentPage = 1;
      _hasMoreData = _metadata!.currentPage < _metadata!.totalPages;
      _watchListState = WatchListState.loaded;
    } catch (e) {
      _watchListError = e.toString();
      _watchListState = WatchListState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMoreWatches({
    int limit = 10,
    String? search,
  }) async {
    if (_watchListState == WatchListState.loading || !_hasMoreData) return;

    _watchListState = WatchListState.loading;
    notifyListeners();

    try {
      final int offsetPage = _currentPage + 1;
      final response = await _watchApi.getAllWatches(
          limit: limit, page: offsetPage, search: search);

      _contentList.addAll(response.videos);
      _metadata = response.metadata;
      _currentPage = offsetPage;
      _hasMoreData = _metadata!.currentPage < _metadata!.totalPages;

      _watchListState = WatchListState.loaded;
    } catch (e) {
      _watchListError = e.toString();
      _watchListState = WatchListState.loaded;
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearWatches() async {
    _contentList.clear();
    _metadata = null;
    _hasMoreData = true;
    _currentPage = 1;
    _watchListState = WatchListState.initial;
    notifyListeners();
  }

  Future<void> fetchWatchById(int id) async {
    _watchDetailState = WatchDetailState.loading;
    notifyListeners();

    try {
      _currentContent = await _watchApi.getWatchById(id);
      _watchDetailState = WatchDetailState.loaded;
    } catch (e) {
      _watchDetailError = e.toString();
      _watchDetailState = WatchDetailState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createWatch({
    required String title,
    required String videoUrl,
    required File thumbnailFile,
    String? description,
    int? duration,
  }) async {
    _watchActionState = WatchActionState.loading;
    _iconState = IconState.loading;
    notifyListeners();

    try {
      final newContent = await _watchApi.createWatch(
        title: title,
        videoUrl: videoUrl,
        thumbnailFile: thumbnailFile,
        description: description,
        duration: duration,
      );

      _contentList.insert(0, newContent);
      _watchActionState = WatchActionState.loaded;
      return true;
    } catch (e) {
      _watchActionError = e.toString();
      _watchActionState = WatchActionState.error;
      return false;
    } finally {
      _iconState = IconState.loaded;
      notifyListeners();
    }
  }

  Future<bool> updateWatch({
    required int id,
    String? title,
    String? videoUrl,
    File? thumbnailFile,
    String? description,
    int? duration,
  }) async {
    _watchActionState = WatchActionState.loading;
    _iconState = IconState.loading;
    notifyListeners();

    try {
      final updatedContent = await _watchApi.updateWatch(
        id: id,
        title: title,
        videoUrl: videoUrl,
        thumbnailFile: thumbnailFile,
        description: description,
        duration: duration,
      );

      final index = _contentList.indexWhere((content) => content.id == id);
      if (index != -1) {
        _contentList[index] = updatedContent;
      }

      if (_currentContent?.id == id) {
        _currentContent = updatedContent;
      }

      _watchActionState = WatchActionState.loaded;
      return true;
    } catch (e) {
      _watchActionError = e.toString();
      _watchActionState = WatchActionState.error;
      return false;
    } finally {
      _iconState = IconState.loaded;
      notifyListeners();
    }
  }

  Future<bool> deleteWatch(int id) async {
    _watchActionState = WatchActionState.loading;
    notifyListeners();

    try {
      await _watchApi.deleteWatch(id);

      // Hapus dari list (seperti deleteComment)
      _contentList.removeWhere((content) => content.id == id);

      if (_currentContent?.id == id) {
        _currentContent = null;
        _watchDetailState = WatchDetailState.initial; // Reset halaman detail
      }

      _watchActionState = WatchActionState.loaded;
      return true;
    } catch (e) {
      _watchActionError = e.toString();
      _watchActionState = WatchActionState.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> incrementView(int id) async {
    try {
      await _watchApi.incrementWatchView(id);
    } catch (e) {
      debugPrint('Gagal increment view di backend: $e');
    }
  }
}
