import 'package:flutter/material.dart';
import '../models/metrics_model.dart';
import '../services/metrics_service.dart';

class MetricsProvider with ChangeNotifier {
  final MetricsService _service = MetricsService();
  List<NetworkMetrics> _historicalMetrics = [];
  List<NetworkMetrics> _realTimeMetrics = [];
  bool _isLoading = false;
  String? _error;

  List<NetworkMetrics> get historicalMetrics => _historicalMetrics;
  List<NetworkMetrics> get realTimeMetrics => _realTimeMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistoricalMetrics() async {
    _isLoading = true;
    notifyListeners();

    try {
      _historicalMetrics = await _service.getHistoricalMetrics();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<NetworkMetrics> startRealTimeMonitoring() {
    _realTimeMetrics = [];
    notifyListeners();
    return _service.getRealTimeMetrics();
  }

  void addRealTimeMetric(NetworkMetrics metric) {
    _realTimeMetrics = [..._realTimeMetrics, metric].take(100).toList();
    notifyListeners();
  }

  void clearMetrics() {
    _historicalMetrics = [];
    _realTimeMetrics = [];
    notifyListeners();
  }
}