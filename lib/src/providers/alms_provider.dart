import 'package:flutter/material.dart';
import '../api/alms_api.dart';
import '../models/entity/alms_model.dart';
import '../models/response/almss_response.dart';

enum AlmsState { initial, loading, loaded, error }

enum TotalAlmsState { initial, loading, loaded, error }

class AlmsProvider extends ChangeNotifier {
  List<Alms> _almss = [];
  int _totalAlms = 0;
  int _currentPage = 1;
  bool _hasMoreData = true;
  AlmsState _state = AlmsState.initial;
  TotalAlmsState _totalAmountAlmsState = TotalAlmsState.initial;
  String? _errorMessage;
  String? _totalAlmsErrorMessage;

  // Getters
  List<Alms> get almss => _almss;
  int get totalAlms => _totalAlms;
  AlmsState get state => _state;
  TotalAlmsState get totalAmountAlmsState => _totalAmountAlmsState;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  String? get totalAlmsErrorMessage => _totalAlmsErrorMessage;

  final AlmsApi _almsApi = AlmsApi();

  // Fetch alms with pagination
  Future<void> fetchAlmss() async {
    if (!hasMoreData) return;

    try {
      print("masuk fetch alms provider");
      // Set loading state
      _state = AlmsState.loading;
      notifyListeners();

      // Get alms from API
      final AlmssResponse response =
          await _almsApi.fetchAlmss(page: _currentPage);

      final data = response.data;

      if (data.isNotEmpty) {
        _almss.addAll(data);
        _currentPage++;
        _hasMoreData = data.length >= response.pagination.itemsPerPage;
      } else {
        _hasMoreData = false;
      }

      _state = AlmsState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print(_errorMessage);
      _state = AlmsState.error;
    } finally {
      print("Alms State $_state");
      notifyListeners();
    }
  }

  Future<void> refreshAlmss() async {
    try {
      _almss = [];
      _hasMoreData = true;
      _currentPage = 1;
      await fetchAlmss();
    } catch (e) {
      _errorMessage = e.toString();
      _state = AlmsState.error;
      notifyListeners();
    }
  }

  // Clear alms
  void clearAlmss() {
    _almss = [];
    _state = AlmsState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchTotalAlms() async {
    try {
      print("masuk fetch total alms provider");
      // Set loading state
      _totalAmountAlmsState = TotalAlmsState.loading;
      notifyListeners();

      // Get total amount from API
      final int response = await _almsApi.fetchTotalAmountUser();

      _totalAlms = response;

      _totalAmountAlmsState = TotalAlmsState.loaded;
      _totalAlmsErrorMessage = null;
    } catch (e) {
      _totalAlmsErrorMessage = e.toString();
      _totalAmountAlmsState = TotalAlmsState.error;
    } finally {
      notifyListeners();
      print("Total Alms State $_totalAmountAlmsState");
    }
  }

  Future<void> refreshTotalAlms() async {
    try {
      _totalAlms = 0;
      await fetchTotalAlms();
    } catch (e) {
      _totalAlmsErrorMessage = e.toString();
      _totalAmountAlmsState = TotalAlmsState.error;
      notifyListeners();
    }
  }

  Future<void> clearTotalAlms() async {
    _totalAlms = 0;
    _totalAmountAlmsState = TotalAlmsState.initial;
    _totalAlmsErrorMessage = null;
    notifyListeners();
  }
}
