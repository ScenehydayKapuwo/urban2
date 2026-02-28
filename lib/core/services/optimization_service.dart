import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/optimization_model.dart';
import '../models/metrics_model.dart';
import '../utils/environment.dart';

class OptimizationService {
  Future<OptimizationResult> getOptimizations(
      List<NetworkMetrics> metrics,
      Map<String, dynamic> params
      ) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/optimize');
      final body = json.encode({
        'metrics': metrics.map((m) => m.toJson()).toList(),
        'params': params,
      });

      print('Sending optimization request: $body');  // Debug log

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      print('Received response: ${response.body}');  // Debug log

      if (response.statusCode == 200) {
        return OptimizationResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Optimization error: $e');  // Debug log
      rethrow;
    }
  }
}