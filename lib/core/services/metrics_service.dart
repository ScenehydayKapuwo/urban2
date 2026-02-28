import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/metrics_model.dart';
import '../utils/environment.dart';

class MetricsService {
  Future<List<NetworkMetrics>> getHistoricalMetrics({
    int duration = 60,
    int interval = 1,
  }) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/metrics/historical?duration=$duration&interval=$interval',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NetworkMetrics.fromJson(json)).toList();
    }
    throw Exception('Failed to load historical metrics');
  }

  Stream<NetworkMetrics> getRealTimeMetrics() {
    final url = Uri.parse('${AppConfig.baseUrl}/metrics/stream');
    final client = http.Client();
    final request = http.Request('GET', url);
    final stream = client.send(request).asStream()
        .asyncExpand((response) => response.stream)
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .map((line) => NetworkMetrics.fromJson(json.decode(line)));

    return stream;
  }
}