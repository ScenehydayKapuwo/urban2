import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/simulation_model.dart';
import '../utils/environment.dart';  // Updated import

class SimulationService {
  Future<SimulationResults> runSimulation(SimulationParameters params) async {
    final url = Uri.parse('${AppConfig.baseUrl}/simulate');  // Uses environment config
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(params.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SimulationResults.fromJson(data);
        } else {
          throw Exception(data['error'] ?? 'Simulation failed');
        }
      } else {
        throw Exception('Failed to run simulation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}