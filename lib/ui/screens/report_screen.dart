import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/providers/report_provider.dart';
import '../../core/providers/simulation_provider.dart';
import '../../core/providers/metrics_provider.dart';
import '../../core/providers/optimization_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _currentGeneratingReportType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 8,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Generate Reports',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional Reports',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate comprehensive PDF reports for analysis and documentation',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildReportOption(
                    context,
                    title: 'Simulation Report',
                    description: 'Detailed analysis of network simulation results with performance metrics and visualizations',
                    reportType: 'simulation',
                    icon: Icons.scatter_plot_rounded,
                    color: Colors.blue[600]!,
                    onGenerate: () => _generateSimulationReport(context),
                  ),

                  const SizedBox(height: 16),

                  _buildReportOption(
                    context,
                    title: 'Metrics Report',
                    description: 'Comprehensive overview of collected network metrics with trends and analysis',
                    reportType: 'metrics',
                    icon: Icons.analytics_rounded,
                    color: Colors.green[600]!,
                    onGenerate: () => _generateMetricsReport(context),
                  ),

                  const SizedBox(height: 16),

                  _buildReportOption(
                    context,
                    title: 'Optimization Report',
                    description: 'AI-powered optimization recommendations with implementation strategies',
                    reportType: 'optimization',
                    icon: Icons.auto_fix_high_rounded,
                    color: Colors.orange[600]!,
                    onGenerate: () => _generateOptimizationReport(context),
                  ),

                  const SizedBox(height: 16),

                  _buildReportOption(
                    context,
                    title: 'Comprehensive Report',
                    description: 'Complete network analysis combining all data sources and recommendations',
                    reportType: 'comprehensive',
                    icon: Icons.description_rounded,
                    color: Colors.purple[600]!,
                    onGenerate: () => _generateComprehensiveReport(context),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(
      BuildContext context, {
        required String title,
        required String description,
        required String reportType,
        required IconData icon,
        required Color color,
        required VoidCallback onGenerate,
      }) {
    final isGenerating = _currentGeneratingReportType == reportType;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  // Status Indicator
                  _buildStatusIndicator(reportType),

                  const Spacer(),

                  // Generate Button
                  _buildGenerateButton(
                    color: color,
                    isGenerating: isGenerating,
                    onPressed: isGenerating ? null : onGenerate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String reportType) {
    final hasData = _checkDataAvailability(reportType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasData ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasData ? Colors.green[200]! : Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hasData ? Colors.green[600] : Colors.orange[600],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            hasData ? 'Data Available' : 'No Data',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasData ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton({
    required Color color,
    required bool isGenerating,
    required VoidCallback? onPressed,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: onPressed != null
            ? LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        )
            : null,
        color: onPressed == null ? Colors.grey[300] : null,
        boxShadow: onPressed != null
            ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isGenerating
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Generating...',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.file_download_rounded,
              color: onPressed != null ? Colors.white : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Generate',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onPressed != null ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _checkDataAvailability(String reportType) {
    final simulationProvider = Provider.of<SimulationProvider>(context, listen: false);
    final metricsProvider = Provider.of<MetricsProvider>(context, listen: false);
    final optimizationProvider = Provider.of<OptimizationProvider>(context, listen: false);

    final hasMetrics = metricsProvider.historicalMetrics.isNotEmpty ||
        metricsProvider.realTimeMetrics.isNotEmpty;

    switch (reportType) {
      case 'simulation':
        return simulationProvider.results != null;
      case 'metrics':
        return hasMetrics;
      case 'optimization':
        return optimizationProvider.results != null;
      case 'comprehensive':
        return simulationProvider.results != null ||
            hasMetrics ||
            optimizationProvider.results != null;
      default:
        return false;
    }
  }

  void _showSuccessDialog(BuildContext context, String reportType) {
    final reportName = {
      'simulation': 'Simulation Report',
      'metrics': 'Metrics Report',
      'optimization': 'Optimization Report',
      'comprehensive': 'Comprehensive Report',
    }[reportType];

    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final filePath = reportProvider.lastGeneratedPath!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 32,
                  color: Colors.green[600],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Report Generated!',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                '$reportName has been generated successfully and saved to your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Share.shareXFiles([XFile(filePath)],
                          text: 'Check out this $reportName I generated',
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        OpenFile.open(filePath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Open',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Close Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateSimulationReport(BuildContext context) async {
    setState(() => _currentGeneratingReportType = 'simulation');

    try {
      final simulationProvider = Provider.of<SimulationProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);

      if (simulationProvider.results == null) {
        _showSnackBar('No simulation results available', isError: true);
        return;
      }

      await reportProvider.generateReport(
        title: 'Simulation Report',
        simulation: simulationProvider.results,
      );

      _showSuccessDialog(context, 'simulation');
    } catch (e) {
      _showSnackBar('Failed to generate simulation report: $e', isError: true);
    } finally {
      setState(() => _currentGeneratingReportType = null);
    }
  }

  Future<void> _generateMetricsReport(BuildContext context) async {
    setState(() => _currentGeneratingReportType = 'metrics');

    try {
      final metricsProvider = Provider.of<MetricsProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);

      final metrics = metricsProvider.historicalMetrics.isNotEmpty
          ? metricsProvider.historicalMetrics
          : metricsProvider.realTimeMetrics;

      if (metrics.isEmpty) {
        _showSnackBar('No metrics data available', isError: true);
        return;
      }

      await reportProvider.generateReport(
        title: 'Metrics Report',
        metrics: metrics,
      );

      _showSuccessDialog(context, 'metrics');
    } catch (e) {
      _showSnackBar('Failed to generate metrics report: $e', isError: true);
    } finally {
      setState(() => _currentGeneratingReportType = null);
    }
  }

  Future<void> _generateOptimizationReport(BuildContext context) async {
    setState(() => _currentGeneratingReportType = 'optimization');

    try {
      final optimizationProvider = Provider.of<OptimizationProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);

      if (optimizationProvider.results == null) {
        _showSnackBar('No optimization results available', isError: true);
        return;
      }

      await reportProvider.generateReport(
        title: 'Optimization Report',
        optimization: optimizationProvider.results,
      );

      _showSuccessDialog(context, 'optimization');
    } catch (e) {
      _showSnackBar('Failed to generate optimization report: $e', isError: true);
    } finally {
      setState(() => _currentGeneratingReportType = null);
    }
  }

  Future<void> _generateComprehensiveReport(BuildContext context) async {
    setState(() => _currentGeneratingReportType = 'comprehensive');

    try {
      final simulationProvider = Provider.of<SimulationProvider>(context, listen: false);
      final metricsProvider = Provider.of<MetricsProvider>(context, listen: false);
      final optimizationProvider = Provider.of<OptimizationProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);

      final metrics = metricsProvider.historicalMetrics.isNotEmpty
          ? metricsProvider.historicalMetrics
          : metricsProvider.realTimeMetrics;

      if (simulationProvider.results == null && metrics.isEmpty && optimizationProvider.results == null) {
        _showSnackBar('No data available for report generation', isError: true);
        return;
      }

      await reportProvider.generateReport(
        title: 'Comprehensive Network Report',
        simulation: simulationProvider.results,
        metrics: metrics.isNotEmpty ? metrics : null,
        optimization: optimizationProvider.results,
      );

      _showSuccessDialog(context, 'comprehensive');
    } catch (e) {
      _showSnackBar('Failed to generate comprehensive report: $e', isError: true);
    } finally {
      setState(() => _currentGeneratingReportType = null);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}