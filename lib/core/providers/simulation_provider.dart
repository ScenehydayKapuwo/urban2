import 'package:flutter/material.dart';
import '../models/simulation_model.dart';
import '../services/database_service.dart';
import '../services/simulation_service.dart';

class SimulationProvider with ChangeNotifier {
  final SimulationService _service = SimulationService();
  final DatabaseService _db = DatabaseService.instance;

  bool _isLoading = false;
  String? _error;
  SimulationResults? _results;
  List<SimulationResults> _history = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  SimulationResults? get results => _results;
  List<SimulationResults> get history => _history.reversed.toList(); // Show newest first


  Future<void> loadHistory() async {
    _history = await _db.getAllSimulations();
    notifyListeners();
  }

  Future<void> runSimulation(SimulationParameters params) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _service.runSimulation(params);
      final completeResults = SimulationResults(
        parameters: params, // Make sure we're saving the original parameters
        receivedPower: results.receivedPower,
        pathLoss: results.pathLoss,
        shadowingLoss: results.shadowingLoss,
        sinr: results.sinr,
        capacityPerUser: results.capacityPerUser,
        totalCapacity: results.totalCapacity,
        latency: results.latency,
      );

      _results = completeResults;
      await _db.insertSimulation(completeResults);
      await loadHistory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSimulation(int id) async {
    await _db.deleteSimulation(id);
    await loadHistory(); // Refresh history after deletion
  }


  void clearResults() {
    _results = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _results = null;
    notifyListeners();
  }
}