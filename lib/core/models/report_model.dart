import 'package:urban2/core/models/simulation_model.dart';
import 'metrics_model.dart';
import 'optimization_model.dart';

class NetworkReport {
  final DateTime generatedAt;
  final SimulationResults? simulation;
  final List<NetworkMetrics>? metrics;
  final OptimizationResult? optimization;
  final String title;

  NetworkReport({
    required this.title,
    this.simulation,
    this.metrics,
    this.optimization,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'title': title,
    'generated_at': generatedAt.toIso8601String(),
    'simulation': simulation?.parameters.toJson(),
    'metrics': metrics?.map((m) => m.toJson()).toList(),
    'optimization': optimization?.toJson(),
  };

  // Helper method to generate a filename
  String get fileName =>
      '${title.toLowerCase().replaceAll(' ', '_')}_${generatedAt.toIso8601String()}.pdf';
}