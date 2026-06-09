// providers/kuttab_location_provider.dart
import 'package:ayahhebat/src/api/branch_api.dart';
import 'package:ayahhebat/src/api/zone_api.dart';
import 'package:ayahhebat/src/models/branch_model.dart';
import 'package:ayahhebat/src/models/zone_model.dart';
import 'package:flutter/material.dart';

enum ZoneBranchState { initial, loading, loaded, error }

class ZoneBranchProvider extends ChangeNotifier {
  ZoneApi zoneApi = ZoneApi();
  BranchApi branchApi = BranchApi();

  ZoneBranchState _state = ZoneBranchState.initial;
  List<Zone> _zones = [];
  Zone? _selectedZone;
  Branch? _selectedBranch;
  List<Branch> _branches = [];
  bool _isLoadingBranches = false;
  String? _errorMessage;

  // Getters
  ZoneBranchState get state => _state;
  List<Zone> get zones => _zones;
  Zone? get selectedZone => _selectedZone;
  Branch? get selectedBranch => _selectedBranch;
  List<Branch> get availableBranches => _branches;
  bool get isLoadingBranches => _isLoadingBranches;
  String? get errorMessage => _errorMessage;

  Future<void> fetchZones() async {
    try {
      _state = ZoneBranchState.loading;
      notifyListeners();

      final result = await zoneApi.getAllZone();

      _zones = result;
      _state = ZoneBranchState.loaded;
      _errorMessage = null;
    } catch (e) {
      _zones = [];
      _state = ZoneBranchState.error;
      _errorMessage = e.toString();
      print("_errorMessage $_errorMessage");
    } finally {
      notifyListeners();
    }
  }

  // Fetch branches when a zone is selected
  Future<void> fetchBranchesByZone(int zoneId) async {
    try {
      _isLoadingBranches = true;
      notifyListeners();

      final branches = await branchApi.getBranchesByZoneId(zoneId);
      _branches = branches;
    } catch (e) {
      _branches = [];
      _errorMessage = e.toString();
    } finally {
      _isLoadingBranches = false;
      notifyListeners();
    }
  }

  void setSelectedZone(Zone? zone) {
    _selectedZone = zone;
    _selectedBranch = null;
    _branches = [];
    
    if (zone != null) {
      // Fetch branches for the selected zone
      fetchBranchesByZone(zone.id);
    }
    
    notifyListeners();
  }

  void setSelectedBranch(Branch? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void resetSelection() {
    _selectedZone = null;
    _selectedBranch = null;
    _branches = [];
    notifyListeners();
  }
}