import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/models/simulation_model.dart';

class DatabaseService {
  static const _databaseName = 'simulations.db';
  static const _databaseVersion = 1;

  static const table = 'simulations';

  static const columnId = 'id';
  static const columnTimestamp = 'timestamp';
  static const columnUserDensity = 'user_density';
  static const columnBuildingDensity = 'building_density';
  static const columnFrequency = 'frequency';
  static const columnTxPower = 'tx_power';
  static const columnNumBaseStations = 'num_base_stations';
  static const columnReceivedPower = 'received_power';
  static const columnPathLoss = 'path_loss';
  static const columnShadowingLoss = 'shadowing_loss';
  static const columnSinr = 'sinr';
  static const columnCapacityPerUser = 'capacity_per_user';
  static const columnTotalCapacity = 'total_capacity';
  static const columnLatency = 'latency';

  // Singleton pattern
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTimestamp INTEGER NOT NULL,
        $columnUserDensity REAL NOT NULL,
        $columnBuildingDensity REAL NOT NULL,
        $columnFrequency REAL NOT NULL,
        $columnTxPower REAL NOT NULL,
        $columnNumBaseStations INTEGER NOT NULL,
        $columnReceivedPower REAL NOT NULL,
        $columnPathLoss REAL NOT NULL,
        $columnShadowingLoss REAL NOT NULL,
        $columnSinr REAL NOT NULL,
        $columnCapacityPerUser REAL NOT NULL,
        $columnTotalCapacity REAL NOT NULL,
        $columnLatency REAL NOT NULL
      )
    ''');
  }

  Future<int> insertSimulation(SimulationResults results) async {
    final db = await database;
    return await db.insert(table, _resultsToMap(results));
  }

  Future<List<SimulationResults>> getAllSimulations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$columnTimestamp DESC',
    );
    return List.generate(maps.length, (i) => _mapToResults(maps[i]));
  }

  Future<int> deleteSimulation(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _resultsToMap(SimulationResults results) {
    return {
      columnTimestamp: results.timestamp.millisecondsSinceEpoch,
      columnUserDensity: results.parameters.userDensity,
      columnBuildingDensity: results.parameters.buildingDensity,
      columnFrequency: results.parameters.frequency,
      columnTxPower: results.parameters.txPower,
      columnNumBaseStations: results.parameters.numBaseStations,
      columnReceivedPower: results.receivedPower,
      columnPathLoss: results.pathLoss,
      columnShadowingLoss: results.shadowingLoss,
      columnSinr: results.sinr,
      columnCapacityPerUser: results.capacityPerUser,
      columnTotalCapacity: results.totalCapacity,
      columnLatency: results.latency,
    };
  }

  SimulationResults _mapToResults(Map<String, dynamic> map) {
    final params = SimulationParameters(
      userDensity: map[columnUserDensity],
      buildingDensity: map[columnBuildingDensity],
      frequency: map[columnFrequency],
      txPower: map[columnTxPower],
      numBaseStations: map[columnNumBaseStations],
    );

    return SimulationResults(
      parameters: params,
      receivedPower: map[columnReceivedPower],
      pathLoss: map[columnPathLoss],
      shadowingLoss: map[columnShadowingLoss],
      sinr: map[columnSinr],
      capacityPerUser: map[columnCapacityPerUser],
      totalCapacity: map[columnTotalCapacity],
      latency: map[columnLatency],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map[columnTimestamp]),
      id: map[columnId],
    );
  }
}