// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/map_provider.dart';
import 'core/providers/metrics_provider.dart';
import 'core/providers/optimization_provider.dart';
import 'core/providers/report_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/simulation_provider.dart';
import 'core/services/database_service.dart';
import 'core/utils/environment.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(env: Environment.development);

  final databaseService = DatabaseService.instance;
  await databaseService.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SimulationProvider()),
        ChangeNotifierProvider(create: (_) => MetricsProvider()),
        ChangeNotifierProvider(create: (_) => OptimizationProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wireless Network Evaluator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
