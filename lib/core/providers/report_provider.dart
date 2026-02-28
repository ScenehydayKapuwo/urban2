import 'package:flutter/material.dart';
import '../models/metrics_model.dart';
import '../models/optimization_model.dart';
import '../models/report_model.dart';
import '../models/simulation_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();
  bool _isGenerating = false;
  String? _lastGeneratedPath;

  bool get isGenerating => _isGenerating;
  String? get lastGeneratedPath => _lastGeneratedPath;

  Future<String> generateReport({
    required String title,
    SimulationResults? simulation,
    List<NetworkMetrics>? metrics,
    OptimizationResult? optimization,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final report = NetworkReport(
        title: title,
        simulation: simulation,
        metrics: metrics,
        optimization: optimization,
      );

      final file = await _service.generatePdfReport(report);
      _lastGeneratedPath = file.path;
      return file.path;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}