import 'metrics_model.dart';

class OptimizationRequest {
  final List<NetworkMetrics> metrics;
  final Map<String, dynamic> parameters;

  OptimizationRequest({
    required this.metrics,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
    'metrics': metrics.map((m) => m.toJson()).toList(),
    'params': parameters,
  };
}

class OptimizationSuggestion {
  final String type;
  final String description;
  final String priority;

  OptimizationSuggestion({
    required this.type,
    required this.description,
    required this.priority,
  });

  factory OptimizationSuggestion.fromJson(Map<String, dynamic> json) {
    return OptimizationSuggestion(
      type: json['type'],
      description: json['description'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'priority': priority,
  };
}

class OptimizationResult {
  final List<OptimizationSuggestion> suggestions;
  final Map<String, dynamic> metricsSummary;
  final bool success;
  final String? error;

  OptimizationResult({
    required this.suggestions,
    required this.metricsSummary,
    required this.success,
    this.error,
  });

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    try {
      // Safely parse optimizations
      final optimizations = json['optimizations'];
      final suggestions = optimizations is List
          ? optimizations.map((s) => OptimizationSuggestion.fromJson(s)).toList()
          : <OptimizationSuggestion>[];

      // Safely parse metrics summary
      final metricsSummary = json['metrics_summary'] is Map
          ? Map<String, dynamic>.from(json['metrics_summary'])
          : <String, dynamic>{};

      return OptimizationResult(
        suggestions: suggestions,
        metricsSummary: metricsSummary,
        success: json['success'] ?? false,
        error: json['error'],
      );
    } catch (e) {
      return OptimizationResult(
        suggestions: [],
        metricsSummary: {},
        success: false,
        error: 'Failed to parse response: $e',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'optimizations': suggestions.map((s) => s.toJson()).toList(),
    'metrics_summary': metricsSummary,
    'success': success,
    if (error != null) 'error': error,
  };
}