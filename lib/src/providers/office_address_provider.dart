import 'package:flutter/material.dart';
import '../api/office_address_api.dart';
import '../models/office_address_model.dart';

enum OfficeAddressState { initial, loading, loaded, error }

class OfficeAddressProvider extends ChangeNotifier {
  List<OfficeAddress> _officeAddresses = [];
  OfficeAddressState _state = OfficeAddressState.initial;
  String? _errorMessage;

  // Getters
  List<OfficeAddress> get officeAddresses => _officeAddresses;
  OfficeAddressState get state => _state;
  String? get errorMessage => _errorMessage;

  final OfficeAddressApi _officeAddressApi = OfficeAddressApi();

  // Fetch office addresses
  Future<void> fetchOfficeAddresses({
    bool refresh = false,
  }) async {
    try {
      // Set loading state
      if (refresh || _state == OfficeAddressState.initial) {
        _state = OfficeAddressState.loading;
        notifyListeners();
      }

      // Get addresses from API
      final response = await _officeAddressApi.getAllOfficeAddress();

      // Update the address list
      _officeAddresses = response;

      _state = OfficeAddressState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = OfficeAddressState.error;
    } finally {
      notifyListeners();
    }
  }

  // Refresh office addresses
  Future<void> refreshOfficeAddresses() async {
    _officeAddresses = [];
    await fetchOfficeAddresses(refresh: true);
  }

  // Clear office addresses
  void clearOfficeAddresses() {
    _officeAddresses = [];
    _state = OfficeAddressState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  // Get office address by ID
  OfficeAddress? getOfficeAddressById(int id) {
    try {
      return _officeAddresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get office address by name
  OfficeAddress? getOfficeAddressByName(String name) {
    try {
      return _officeAddresses.firstWhere(
        (address) => address.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
