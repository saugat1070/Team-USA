import 'package:flutter/material.dart';
import 'package:paaila/models/trail_model.dart';
import 'package:paaila/services/trail_service.dart' as trail_service;

class TrailProvider extends ChangeNotifier {
  List<Territory> _territories = [];
  bool _isLoading = false;
  String? _error;
  Territory? _selectedTerritory;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Territory? get selectedTerritory => _selectedTerritory;

  // Get total distance across all territories
  double get totalDistanceM {
    return _territories.fold(0.0, (sum, t) => sum + t.metrics.distanceM);
  }

  // Get total area across all territories
  double get totalAreaM2 {
    return _territories.fold(0.0, (sum, t) => sum + t.areaM2);
  }

  // Get total duration across all territories
  int get totalDurationSec {
    return _territories.fold(0, (sum, t) => sum + t.durationSec);
  }

  String get formattedTotalDistance {
    if (totalDistanceM >= 1000) {
      return '${(totalDistanceM / 1000).toStringAsFixed(2)} km';
    }
    return '${totalDistanceM.toStringAsFixed(0)} m';
  }

  String get formattedTotalArea {
    if (totalAreaM2 >= 1000000) {
      return '${(totalAreaM2 / 1000000).toStringAsFixed(2)} km²';
    }
    return '${totalAreaM2.toStringAsFixed(0)} m²';
  }

  Future<void> fetchTerritories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _territories = (await trail_service.TrailService.fetchUserTerritories()).cast<Territory>();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _territories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTerritory(Territory? territory) {
    _selectedTerritory = territory;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
