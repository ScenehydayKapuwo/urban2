import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  // Appearance Settings
  bool _isDarkMode = false;
  String _currentLanguage = 'English';

  // Simulation Preferences
  int _defaultSimulationDuration = 60;
  bool _autoSaveResults = true;
  String _exportFormat = 'PDF';

  // Notification Settings
  bool _simulationAlerts = true;
  bool _optimizationAlerts = true;
  bool _metricAlerts = true;

  // Measurement Units
  bool _useMetric = true;

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;
  int get defaultSimulationDuration => _defaultSimulationDuration;
  bool get autoSaveResults => _autoSaveResults;
  String get exportFormat => _exportFormat;
  bool get simulationAlerts => _simulationAlerts;
  bool get optimizationAlerts => _optimizationAlerts;
  bool get metricAlerts => _metricAlerts;
  bool get useMetric => _useMetric;

  // Setters
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  void setSimulationDuration(int duration) {
    _defaultSimulationDuration = duration;
    notifyListeners();
  }

  void toggleAutoSave(bool value) {
    _autoSaveResults = value;
    notifyListeners();
  }

  void setExportFormat(String format) {
    _exportFormat = format;
    notifyListeners();
  }

  void toggleSimulationAlerts(bool value) {
    _simulationAlerts = value;
    notifyListeners();
  }

  void toggleOptimizationAlerts(bool value) {
    _optimizationAlerts = value;
    notifyListeners();
  }

  void toggleMetricAlerts(bool value) {
    _metricAlerts = value;
    notifyListeners();
  }

  void toggleMeasurementUnits() {
    _useMetric = !_useMetric;
    notifyListeners();
  }

  void resetToDefaults() {
    _isDarkMode = false;
    _currentLanguage = 'English';
    _defaultSimulationDuration = 60;
    _autoSaveResults = true;
    _exportFormat = 'PDF';
    _simulationAlerts = true;
    _optimizationAlerts = true;
    _metricAlerts = true;
    _useMetric = true;
    notifyListeners();
  }
}