import 'package:flutter/material.dart';
import '../api/allocation_api.dart';
import '../models/entity/allocation_model.dart';
import '../models/response/allocations_response.dart';

enum AllocationState { initial, loading, loaded, error }

class AllocationProvider extends ChangeNotifier {
  List<Allocation> _allocations = [];
  AllocationState _state = AllocationState.initial;
  String? _errorMessage;

  // Getters
  List<Allocation> get allocations => _allocations;
  AllocationState get state => _state;
  String? get errorMessage => _errorMessage;

  final AllocationApi _categoryApi = AllocationApi();

  // Fetch categories dengan optional search
  Future<void> fetchAllocations() async {
    try {
      print("masuk fetch allocation provider");
      // Set loading state
      if (state == AllocationState.initial) {
        _state = AllocationState.loading;
        notifyListeners();
      }

      // Get categories dari API
      final AllocationsResponse response = await _categoryApi.fetchAlocations();

      final data = response.data;
      // Update categories list
      _allocations = data;

      _state = AllocationState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AllocationState.error;
    } finally {
      print(_errorMessage);
      notifyListeners();
    }
  }

  // Clear categories
  void clearAllocations() {
    _allocations = [];
    _state = AllocationState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
