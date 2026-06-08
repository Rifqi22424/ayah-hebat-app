import 'package:flutter/material.dart';
import '../api/kuttab_location_api.dart';
import '../models/kuttab_branch_model.dart';
import '../models/kuttab_zone_model.dart';

enum KuttabLocationState { initial, loading, loaded, error }

class KuttabLocationProvider extends ChangeNotifier {
  KuttabLocationApi kuttabLocationApi = KuttabLocationApi();

  KuttabLocationState _state = KuttabLocationState.initial;
  List<KuttabZone> _zones = [];
  KuttabZone? _selectedZone;
  KuttabBranch? _selectedBranch;
  String? _errorMessage;

  // Getters
  KuttabLocationState get state => _state;
  List<KuttabZone> get zones => _zones;
  KuttabZone? get selectedZone => _selectedZone;
  KuttabBranch? get selectedBranch => _selectedBranch;
  String? get errorMessage => _errorMessage;

  // Returns only the branches belonging to the currently selected zone.
  List<KuttabBranch> get availableBranches => _selectedZone?.branches ?? [];

  Future<void> fetchKuttabLocations() async {
    try {
      _state = KuttabLocationState.loading;
      notifyListeners();

      final result = await kuttabLocationApi.getAllKuttabLocations();

      _zones = result;
      _state = KuttabLocationState.loaded;
      _errorMessage = null;
    } catch (e) {
      _zones = [];
      _state = KuttabLocationState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void setSelectedZone(KuttabZone? zone) {
    _selectedZone = zone;
    _selectedBranch = null;
    notifyListeners();
  }

  void setSelectedBranch(KuttabBranch? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void resetSelection() {
    _selectedZone = null;
    _selectedBranch = null;
    notifyListeners();
  }
}
