import 'package:flutter/material.dart';
import '../api/infaq_api.dart';
import '../models/entity/infaq_model.dart';
import '../models/response/infaqs_response.dart';

enum InfaqState { initial, loading, loaded, error }

enum TotalInfaqState { initial, loading, loaded, error }

class InfaqProvider extends ChangeNotifier {
  List<Infaq> _infaqs = [];
  int _totalInfaq = 0;
  int _currentPage = 1;
  bool _hasMoreData = true;
  InfaqState _state = InfaqState.initial;
  TotalInfaqState _totalAmountinfaqState = TotalInfaqState.initial;
  String? _errorMessage;
  String? _totalInfaqErrorMessage;

  // Getters
  List<Infaq> get infaqs => _infaqs;
  int get totalInfaq => _totalInfaq;
  InfaqState get state => _state;
  TotalInfaqState get totalAmountinfaqState => _totalAmountinfaqState;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  String? get totalInfaqErrorMessage => _totalInfaqErrorMessage;

  final InfaqApi _infaqApi = InfaqApi();

  // Fetch categories dengan optional search
  Future<void> fetchInfaqs() async {
    if (!hasMoreData) return;

    try {
      print("masuk fetch allocation provider");
      // Set loading state
      _state = InfaqState.loading;
      notifyListeners();

      // Get categories dari API
      final InfaqsResponse response =
          await _infaqApi.fetchInfaqs(page: _currentPage);

      final data = response.data;

      if (data.isNotEmpty) {
        _infaqs.addAll(data);
        _currentPage++;
        _hasMoreData = data.length >= response.pagination.itemsPerPage;
      } else {
        _hasMoreData = false;
      }

      _state = InfaqState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print(_errorMessage);
      _state = InfaqState.error;
    } finally {
      print("Infaq State $_state");
      notifyListeners();
    }
  }

  Future<void> refreshInfaqs() async {
    try {
      _infaqs = [];
      _hasMoreData = true;
      _currentPage = 1;
      await fetchInfaqs();
    } catch (e) {
      _errorMessage = e.toString();
      _state = InfaqState.error;
      notifyListeners();
    }
  }

  // Clear categories
  void clearInfaqs() {
    _infaqs = [];
    _state = InfaqState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchTotalInfaq() async {
    try {
      print("masuk fetch total infaq provider");
      // Set loading state
      _totalAmountinfaqState = TotalInfaqState.loading;
      notifyListeners();

      // Get categories dari API
      final int response = await _infaqApi.fetchTotalAmountUser();

      _totalInfaq = response;

      _totalAmountinfaqState = TotalInfaqState.loaded;
      _totalInfaqErrorMessage = null;
    } catch (e) {
      _totalInfaqErrorMessage = e.toString();
      _totalAmountinfaqState = TotalInfaqState.error;
    } finally {
      notifyListeners();
      print("Total Infaq State $_totalAmountinfaqState");
    }
  }

  Future<void> refreshTotalInfaq() async {
    try {
      _totalInfaq = 0;
      await fetchTotalInfaq();
    } catch (e) {
      _totalInfaqErrorMessage = e.toString();
      _totalAmountinfaqState = TotalInfaqState.error;
      notifyListeners();
    }
  }

  Future<void> clearTotalInfaq() async {
    _totalInfaq = 0;
    _totalAmountinfaqState = TotalInfaqState.initial;
    _totalInfaqErrorMessage = null;
    notifyListeners();
  }
}
