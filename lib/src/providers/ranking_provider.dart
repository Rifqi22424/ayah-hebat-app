import 'package:flutter/foundation.dart';

import '../api/kegiatan_api.dart';
import '../api/profile_api.dart';
import '../models/user_profile_model.dart';
import '../utils/shared_preferences.dart';

enum RankingState { initial, loading, loaded, error }

enum RankingPeriod { daily, weekly, monthly }

class RankingProvider with ChangeNotifier {
  KegiatanApi kegiatanApi = KegiatanApi();

  static const int _pageSize = 20;

  RankingState _state = RankingState.initial;
  List<UserProfile> _users = [];
  RankingPeriod _selectedPeriod = RankingPeriod.daily;
  int? _currentUserId;
  String? _errorMessage;
  UserProfile? _ownProfile;

  // Pagination state
  bool _hasMore = true;
  bool _loadingMore = false;
  int _offset = 0;

  RankingState get state => _state;
  List<UserProfile> get users => _users;
  RankingPeriod get selectedPeriod => _selectedPeriod;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  int? get currentUserRank {
    if (_currentUserId == null) return null;
    final index = _users.indexWhere((u) => u.id == _currentUserId);
    return index == -1 ? null : index + 1;
  }

  UserProfile? get currentUser {
    if (_currentUserId != null) {
      try {
        return _users.firstWhere((u) => u.id == _currentUserId);
      } catch (_) {}
    }
    return _ownProfile;
  }

  /// Initial fetch — resets list and loads first page.
  Future<void> fetchRanking() async {
    try {
      _state = RankingState.loading;
      _errorMessage = null;
      _users = [];
      _offset = 0;
      _hasMore = true;
      notifyListeners();

      final token = await SharedPreferencesHelper.getToken();
      _currentUserId = await SharedPreferencesHelper.getId();

      // Fetch first page + own profile in parallel
      final results = await Future.wait([
        kegiatanApi.getAllScores(
          _periodToApiParam(_selectedPeriod),
          token!,
          limit: _pageSize,
          offset: 0,
        ),
        ProfileApi().getUserNProfile(),
      ]);

      final page = results[0] as List<UserProfile>;
      _ownProfile = results[1] as UserProfile;

      _users = page;
      _offset = page.length;
      _hasMore = page.length >= _pageSize;
      _state = RankingState.loaded;
    } catch (e) {
      _state = RankingState.error;
      _errorMessage = e.toString();
      _users = [];
    } finally {
      notifyListeners();
    }
  }

  /// Load next page — appends to existing list.
  Future<void> fetchMore() async {
    if (_loadingMore || !_hasMore) return;

    try {
      _loadingMore = true;
      notifyListeners();

      final token = await SharedPreferencesHelper.getToken();
      final page = await kegiatanApi.getAllScores(
        _periodToApiParam(_selectedPeriod),
        token!,
        limit: _pageSize,
        offset: _offset,
      );

      _users = [..._users, ...page];
      _offset += page.length;
      _hasMore = page.length >= _pageSize;
    } catch (_) {
      // Silent fail on pagination — show what we already have
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> changePeriod(RankingPeriod period) async {
    _selectedPeriod = period;
    await fetchRanking();
  }

  String _periodToApiParam(RankingPeriod period) {
    switch (period) {
      case RankingPeriod.daily:
        return "day";
      case RankingPeriod.weekly:
        return "month";
      case RankingPeriod.monthly:
        return "year";
    }
  }

  int getScoreForPeriod(UserProfile user) {
    switch (_selectedPeriod) {
      case RankingPeriod.daily:
        return user.totalScoreDay;
      case RankingPeriod.weekly:
        return user.totalScoreMonth;
      case RankingPeriod.monthly:
        return user.totalScoreYear;
    }
  }
}
