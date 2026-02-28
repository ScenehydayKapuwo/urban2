import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/models/metrics_model.dart';
import '../../core/providers/metrics_provider.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  StreamSubscription<NetworkMetrics>? _metricsSubscription;
  bool _isRealTime = false;
  bool _isInitialized = false;
  int _selectedChartIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with empty state first for faster loading
    setState(() {
      _isInitialized = true;
    });
    // Load data asynchronously after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAsync();
    });
  }

  Future<void> _loadDataAsync() async {
    final provider = Provider.of<MetricsProvider>(context, listen: false);
    // Load data in background without blocking UI
    provider.loadHistoricalMetrics();
  }

  @override
  void dispose() {
    _metricsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MetricsProvider>(context);
    final metrics = _isRealTime ? provider.realTimeMetrics : provider.historicalMetrics;

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
        title: Text(
          'Network Metrics',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isRealTime
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isRealTime ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _toggleMode,
            ),
          ),
        ],
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRealTime ? 'Real-time Monitoring' : 'Network Analysis',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRealTime
                                ? 'Live network performance data'
                                : 'Historical network performance metrics',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isRealTime ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isRealTime ? Colors.green : Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isRealTime ? 'LIVE' : 'HISTORICAL',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _isRealTime ? Colors.green[700] : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: provider.isLoading
                ? _buildLoadingState()
                : metrics.isEmpty
                ? _buildEmptyState()
                : _buildContent(metrics),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading metrics data...',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 40,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Metrics Data',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Network metrics will appear here\nonce monitoring begins',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<NetworkMetrics> metrics) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Key Metrics Cards
          _buildKeyMetricsSection(metrics),

          const SizedBox(height: 20),

          // Chart Section
          _buildChartSection(metrics),

          const SizedBox(height: 20),

          // Recent Data Table
          _buildRecentDataSection(metrics),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection(List<NetworkMetrics> metrics) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final latest = metrics.last;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Text(
              'Current Performance',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // First Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Signal Strength',
                    '${latest.signalStrength.toStringAsFixed(1)} dBm',
                    Icons.signal_cellular_alt_rounded,
                    _getSignalColor(latest.signalStrength),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Latency',
                    '${latest.latency.toStringAsFixed(1)} ms',
                    Icons.speed_rounded,
                    _getLatencyColor(latest.latency),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Second Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Throughput',
                    '${latest.throughput.toStringAsFixed(1)} Mbps',
                    Icons.speed_rounded,
                    Colors.blue[600]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Packet Loss',
                    '${latest.packetLoss.toStringAsFixed(1)}%',
                    Icons.warning_rounded,
                    _getPacketLossColor(latest.packetLoss),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<NetworkMetrics> metrics) {
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Trends',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chart Type Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildChartSelector('Signal', 0),
                        _buildChartSelector('Latency', 1),
                        _buildChartSelector('Throughput', 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chart
            Container(
              height: 200,
              padding: const EdgeInsets.only(left: 16, right: 20, bottom: 20),
              child: _buildSelectedChart(metrics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSelector(String title, int index) {
    final isSelected = _selectedChartIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedChartIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChart(List<NetworkMetrics> metrics) {
    // Limit data points for better performance
    final limitedMetrics = metrics.length > 50 ? metrics.sublist(metrics.length - 50) : metrics;

    switch (_selectedChartIndex) {
      case 0:
        return _buildSignalChart(limitedMetrics);
      case 1:
        return _buildLatencyChart(limitedMetrics);
      case 2:
        return _buildThroughputChart(limitedMetrics);
      default:
        return _buildSignalChart(limitedMetrics);
    }
  }

  Widget _buildSignalChart(List<NetworkMetrics> metrics) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: metrics.length.toDouble() - 1,
        minY: -100,
        maxY: -20,
        lineBarsData: [
          LineChartBarData(
            spots: metrics.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.signalStrength);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLatencyChart(List<NetworkMetrics> metrics) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: metrics.length.toDouble() - 1,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: metrics.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.latency);
            }).toList(),
            isCurved: true,
            color: Colors.red[600]!,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red[600]!.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildThroughputChart(List<NetworkMetrics> metrics) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: metrics.length.toDouble() - 1,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: metrics.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.throughput);
            }).toList(),
            isCurved: true,
            color: Colors.green[600]!,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green[600]!.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildRecentDataSection(List<NetworkMetrics> metrics) {
    final recentMetrics = metrics.reversed.take(5).toList();

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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Recent Data Points',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),

            // Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                columns: [
                  DataColumn(
                    label: Text(
                      'Time',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Signal',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Latency',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Throughput',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Loss',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
                rows: recentMetrics.map((metric) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          metric.timestamp.toString().substring(11, 19),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${metric.signalStrength.toStringAsFixed(1)} dBm',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _getSignalColor(metric.signalStrength),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${metric.latency.toStringAsFixed(1)} ms',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _getLatencyColor(metric.latency),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${metric.throughput.toStringAsFixed(1)} Mbps',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${metric.packetLoss.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _getPacketLossColor(metric.packetLoss),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMode() {
    final provider = Provider.of<MetricsProvider>(context, listen: false);

    if (_isRealTime) {
      _metricsSubscription?.cancel();
      // Use post frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadHistoricalMetrics();
      });
    } else {
      _metricsSubscription = provider.startRealTimeMonitoring().listen((metric) {
        provider.addRealTimeMetric(metric);
      });
    }

    setState(() {
      _isRealTime = !_isRealTime;
    });
  }

  // Color helper methods
  Color _getSignalColor(double signal) {
    if (signal >= -50) return Colors.green[600]!;
    if (signal >= -70) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Color _getLatencyColor(double latency) {
    if (latency <= 20) return Colors.green[600]!;
    if (latency <= 50) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Color _getPacketLossColor(double loss) {
    if (loss <= 1) return Colors.green[600]!;
    if (loss <= 5) return Colors.orange[600]!;
    return Colors.red[600]!;
  }
}