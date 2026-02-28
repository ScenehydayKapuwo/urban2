import 'package:flutter/material.dart';
import '../models/metrics_model.dart';
import '../models/optimization_model.dart';
import '../services/optimization_service.dart';

class OptimizationProvider with ChangeNotifier {
  final OptimizationService _service = OptimizationService();
  OptimizationResult? _results;
  bool _isLoading = false;
  String? _error;

  OptimizationResult? get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> optimizeNetwork(
      List<NetworkMetrics> metrics, Map<String, dynamic> params) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _results = await _service.getOptimizations(metrics, params);

    if (_results?.error != null) {
      _error = _results!.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearResults() {
    _results = null;
    _error = null;
    notifyListeners();
  }
}