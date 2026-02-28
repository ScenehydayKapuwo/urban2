class NetworkMetrics {
  final DateTime timestamp;
  final double signalStrength; // dBm
  final double latency; // ms
  final double throughput; // Mbps
  final double packetLoss; // %
  final double jitter; // ms

  NetworkMetrics({
    required this.timestamp,
    required this.signalStrength,
    required this.latency,
    required this.throughput,
    required this.packetLoss,
    required this.jitter,
  });

  factory NetworkMetrics.fromJson(Map<String, dynamic> json) {
    return NetworkMetrics(
      timestamp: DateTime.parse(json['timestamp']),
      signalStrength: json['signal_strength']?.toDouble() ?? 0.0,
      latency: json['latency']?.toDouble() ?? 0.0,
      throughput: json['throughput']?.toDouble() ?? 0.0,
      packetLoss: json['packet_loss']?.toDouble() ?? 0.0,
      jitter: json['jitter']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'signal_strength': signalStrength,
      'latency': latency,
      'throughput': throughput,
      'packet_loss': packetLoss,
      'jitter': jitter,
    };
  }
}
