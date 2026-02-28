class SimulationParameters {
  final double userDensity;
  final double buildingDensity;
  final double frequency;
  final double txPower;
  final int numBaseStations;
  final DateTime timestamp;
  final int? id;

  SimulationParameters({
    required this.userDensity,
    required this.buildingDensity,
    required this.frequency,
    required this.txPower,
    required this.numBaseStations,
    DateTime? timestamp,
    this.id,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'user_density': userDensity,
    'building_density': buildingDensity,
    'frequency': frequency,
    'tx_power': txPower,
    'num_base_stations': numBaseStations,
    'timestamp': timestamp.millisecondsSinceEpoch,
    if (id != null) 'id': id,
  };

  factory SimulationParameters.fromJson(Map<String, dynamic> json) {
    return SimulationParameters(
      userDensity: json['user_density']?.toDouble() ?? 0.0,
      buildingDensity: json['building_density']?.toDouble() ?? 0.0,
      frequency: json['frequency']?.toDouble() ?? 0.0,
      txPower: json['tx_power']?.toDouble() ?? 0.0,
      numBaseStations: json['num_base_stations']?.toInt() ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
      id: json['id']?.toInt(),
    );
  }
}

class SimulationResults {
  final SimulationParameters parameters;
  final double receivedPower;
  final double pathLoss;
  final double shadowingLoss;
  final double sinr;
  final double capacityPerUser;
  final double totalCapacity;
  final double latency;
  final DateTime timestamp;
  final int? id;

  SimulationResults({
    required this.parameters,
    required this.receivedPower,
    required this.pathLoss,
    required this.shadowingLoss,
    required this.sinr,
    required this.capacityPerUser,
    required this.totalCapacity,
    required this.latency,
    DateTime? timestamp,
    this.id,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SimulationResults.fromJson(Map<String, dynamic> json) {
    return SimulationResults(
      parameters: SimulationParameters(
        userDensity: json['user_density'] ?? 0.0,
        buildingDensity: json['building_density'] ?? 0.0,
        frequency: json['frequency'] ?? 0.0,
        txPower: json['tx_power'] ?? 0.0,
        numBaseStations: json['num_base_stations'] ?? 0,
      ),
      receivedPower: json['received_power'] ?? 0.0,
      pathLoss: json['path_loss'] ?? 0.0,
      shadowingLoss: json['shadowing_loss'] ?? 0.0,
      sinr: json['sinr'] ?? 0.0,
      capacityPerUser: json['capacity_per_user'] ?? 0.0,
      totalCapacity: json['total_capacity'] ?? 0.0,
      latency: json['latency'] ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
      id: json['id'],
    );
  }
}