import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';

import '../../ui/screens/map_screen.dart';

class MapProvider with ChangeNotifier {
  List<SignalDataPoint> _signalData = [];
  bool _isCollecting = false;
  Position? _currentPosition;
  Timer? _collectionTimer;
  String? _lastError;
  bool _isInitialized = false;

  List<SignalDataPoint> get signalData => _signalData;
  bool get isCollecting => _isCollecting;
  String? get lastError => _lastError;
  bool get isInitialized => _isInitialized;

  Future<void> startDataCollection() async {
    if (_isCollecting) return;

    try {
      _lastError = null;
      await _checkAndRequestLocationPermission();

      _isCollecting = true;
      notifyListeners();

      // Use Timer.periodic for more reliable collection
      _collectionTimer = Timer.periodic(
        const Duration(seconds: 5),
            (timer) async {
          if (!_isCollecting) {
            timer.cancel();
            return;
          }

          try {
            await _collectDataPoint();
          } catch (e) {
            _lastError = 'Data collection error: $e';
            debugPrint('Data collection error: $e');
            // Continue collecting despite errors
          }
        },
      );

      // Collect first data point immediately
      try {
        await _collectDataPoint();
      } catch (e) {
        debugPrint('Initial data collection failed: $e');
        // Continue even if first collection fails
      }
    } catch (e) {
      _isCollecting = false;
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void stopDataCollection() {
    _isCollecting = false;
    _collectionTimer?.cancel();
    _collectionTimer = null;
    notifyListeners();
  }

  Future<void> _collectDataPoint() async {
    try {
      Position? position;

      // Try to get current position with very short timeout
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Current position failed, trying last known: $e');

        // Fallback to last known position
        position = await Geolocator.getLastKnownPosition();

        if (position == null) {
          // If no position available, skip this collection cycle
          debugPrint('No position available, skipping data collection cycle');
          return;
        }
      }

      _currentPosition = position;

      // Simulate more realistic RSSI values with some variation
      double rssi = _generateRealisticRSSI();

      final newPoint = SignalDataPoint(
        location: LatLng(
          position.latitude,
          position.longitude,
        ),
        signalStrength: rssi,
        timestamp: DateTime.now(),
      );

      _signalData.add(newPoint);

      // Limit data points to prevent memory issues (keep last 1000 points)
      if (_signalData.length > 1000) {
        _signalData.removeRange(0, _signalData.length - 1000);
      }

      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to collect data point: $e';
      debugPrint('Failed to collect data point: $e');
      // Don't throw exception to keep collection running
    }
  }

  Future<void> loadCurrentLocationData() async {
    try {
      _lastError = null;

      // First check permissions without trying to get location
      await _checkAndRequestLocationPermission();

      Position? position;

      // Try multiple strategies with very short timeouts
      try {
        // Strategy 1: Quick high accuracy attempt (3 seconds max)
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 3));
        debugPrint('Got high accuracy location');
      } catch (e) {
        debugPrint('High accuracy failed: $e');

        try {
          // Strategy 2: Medium accuracy with short timeout
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(const Duration(seconds: 2));
          debugPrint('Got medium accuracy location');
        } catch (e2) {
          debugPrint('Medium accuracy failed: $e2');

          try {
            // Strategy 3: Get last known position (instant)
            position = await Geolocator.getLastKnownPosition();
            debugPrint('Got last known location');
          } catch (e3) {
            debugPrint('Last known position failed: $e3');
          }
        }
      }

      // If all location methods fail, use default location
      if (position == null) {
        debugPrint('All location methods failed, using default location (Lusaka)');
        position = Position(
          latitude: -15.3875,
          longitude: 28.3228,
          timestamp: DateTime.now(),
          accuracy: 1000.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }

      _currentPosition = position;

      // Generate initial signal strength
      double signalStrength = _generateRealisticRSSI();

      final initialPoint = SignalDataPoint(
        location: LatLng(
          position.latitude,
          position.longitude,
        ),
        signalStrength: signalStrength,
        timestamp: DateTime.now(),
      );

      _signalData.add(initialPoint);
      _isInitialized = true;
      _lastError = null;
      notifyListeners();

      debugPrint('Location initialization completed successfully');

    } catch (e) {
      debugPrint('Location initialization failed: $e');

      // Even if permissions fail, create a default data point so app works
      try {
        final defaultPoint = SignalDataPoint(
          location: const LatLng(-15.3875, 28.3228), // Lusaka coordinates
          signalStrength: _generateRealisticRSSI(),
          timestamp: DateTime.now(),
        );

        _signalData.add(defaultPoint);
        _isInitialized = true;
        _lastError = 'Using default location - please check location permissions';
        notifyListeners();
        debugPrint('Fallback to default location completed');
      } catch (defaultError) {
        _lastError = 'Failed to initialize: $e';
        _isInitialized = false;
        debugPrint('Complete initialization failure: $defaultError');
        throw Exception('Failed to initialize location services: $e');
      }
    }
  }

  /// Generate more realistic RSSI values with variation
  double _generateRealisticRSSI() {
    final random = Random();

    // Base RSSI values with some randomness
    final baseValues = [-45, -55, -65, -75, -85];
    final baseRSSI = baseValues[random.nextInt(baseValues.length)];

    // Add some variation (±10 dBm)
    final variation = (random.nextDouble() - 0.5) * 20;

    return (baseRSSI + variation).clamp(-100.0, -30.0);
  }

  void clearSignalData() {
    _signalData.clear();
    _lastError = null;
    notifyListeners();
  }

  /// Get signal data within a specific radius (in meters) from a point
  List<SignalDataPoint> getSignalDataInRadius(LatLng center, double radiusMeters) {
    return _signalData.where((point) {
      final distance = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        point.location.latitude,
        point.location.longitude,
      );
      return distance <= radiusMeters;
    }).toList();
  }

  /// Get average signal strength for all collected data
  double getAverageSignalStrength() {
    if (_signalData.isEmpty) return 0.0;

    final total = _signalData.fold<double>(
      0.0,
          (sum, point) => sum + point.signalStrength,
    );

    return total / _signalData.length;
  }

  /// Get signal strength statistics
  Map<String, dynamic> getSignalStatistics() {
    if (_signalData.isEmpty) {
      return {
        'count': 0,
        'average': 0.0,
        'min': 0.0,
        'max': 0.0,
        'excellent': 0,
        'good': 0,
        'fair': 0,
        'poor': 0,
        'veryPoor': 0,
      };
    }

    final strengths = _signalData.map((p) => p.signalStrength).toList();
    strengths.sort();

    int excellent = 0, good = 0, fair = 0, poor = 0, veryPoor = 0;

    for (final strength in strengths) {
      if (strength > -50) excellent++;
      else if (strength > -60) good++;
      else if (strength > -70) fair++;
      else if (strength > -80) poor++;
      else veryPoor++;
    }

    return {
      'count': _signalData.length,
      'average': strengths.reduce((a, b) => a + b) / strengths.length,
      'min': strengths.first,
      'max': strengths.last,
      'excellent': excellent,
      'good': good,
      'fair': fair,
      'poor': poor,
      'veryPoor': veryPoor,
    };
  }

  /// Export signal data to CSV format
  String exportToCSV() {
    if (_signalData.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('Latitude,Longitude,Signal Strength (dBm),Timestamp');

    for (final point in _signalData) {
      buffer.writeln(
        '${point.location.latitude},${point.location.longitude},'
            '${point.signalStrength},${point.timestamp.toIso8601String()}',
      );
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    stopDataCollection();
    super.dispose();
  }

  /// Helper method to handle all permission logic with better error handling
  Future<void> _checkAndRequestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings
        try {
          await Geolocator.openLocationSettings();
          // Wait a bit and check again
          await Future.delayed(const Duration(seconds: 1));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();

          if (!serviceEnabled) {
            throw Exception(
              'Location services are disabled. Please enable GPS/Location services in your device settings.',
            );
          }
        } catch (e) {
          throw Exception(
            'Location services are disabled. Please enable GPS/Location services in your device settings.',
          );
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            'Location permission denied. Please allow location access to use this feature.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Try to open app settings
        try {
          await Geolocator.openAppSettings();
        } catch (e) {
          // Ignore if can't open settings
        }

        throw Exception(
          'Location permission permanently denied. Please enable location permission in app settings:\n\n'
              '1. Go to Settings > Apps > Urban2\n'
              '2. Tap Permissions\n'
              '3. Enable Location permission\n'
              '4. Restart the app',
        );
      }

      // Check if we have the required permissions
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Insufficient location permissions granted.');
      }

    } catch (e) {
      debugPrint('Permission check failed: $e');
      rethrow;
    }
  }

  /// Retry initialization with exponential backoff
  Future<void> retryInitialization({int maxRetries = 3}) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        await loadCurrentLocationData();
        return; // Success, exit retry loop
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          rethrow; // Final attempt failed
        }

        // Exponential backoff: wait 2^retryCount seconds
        final waitTime = Duration(seconds: (2 << retryCount));
        debugPrint('Retry $retryCount failed, waiting ${waitTime.inSeconds}s before next attempt...');
        await Future.delayed(waitTime);
      }
    }
  }

  /// Get the most recent location
  LatLng? getCurrentLocation() {
    if (_signalData.isNotEmpty) {
      return _signalData.last.location;
    }
    return null;
  }

  /// Check if we have recent data (within last 5 minutes)
  bool hasRecentData() {
    if (_signalData.isEmpty) return false;

    final lastDataTime = _signalData.last.timestamp;
    final now = DateTime.now();
    final difference = now.difference(lastDataTime);

    return difference.inMinutes < 5;
  }
}