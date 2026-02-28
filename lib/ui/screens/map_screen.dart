import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/map_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  double _currentZoom = 15;
  LatLng? _center;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _initializeLocation();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final provider = Provider.of<MapProvider>(context, listen: false);
      await provider.loadCurrentLocationData();

      if (provider.signalData.isNotEmpty) {
        setState(() {
          _center = provider.signalData.last.location;
          _isLoading = false;
          _errorMessage = null;
        });
        _fabAnimationController.forward();
      } else {
        // Default to a central location if no data
        setState(() {
          _center = const LatLng(-15.3875, 28.3228); // Lusaka, Zambia
          _isLoading = false;
        });
        _fabAnimationController.forward();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _center = const LatLng(-15.3875, 28.3228); // Fallback location
      });
      _fabAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(theme),
      body: _isLoading ? _buildLoadingScreen() : _buildMapContent(provider, theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButtons(provider, theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'Network Coverage',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.cell_tower,
          color: Colors.blue[600],
          size: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.my_location, size: 20),
          onPressed: _zoomToUserLocation,
          tooltip: 'My location',
        ),
        IconButton(
          icon: const Icon(Icons.legend_toggle, size: 20),
          onPressed: _showLegendDialog,
          tooltip: 'Legend',
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.white],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 24),
            Text(
              'Loading map data...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Initializing location services',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent(MapProvider provider, ThemeData theme) {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center ?? const LatLng(-15.3875, 28.3228),
                initialZoom: _currentZoom,
                minZoom: 5,
                maxZoom: 18,
                onPositionChanged: (position, hasGesture) {
                  setState(() {
                    _currentZoom = position.zoom!;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.urban2',
                  tileBuilder: (context, tileWidget, tile) {
                    return ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.blue.withOpacity(0.05),
                        BlendMode.overlay,
                      ),
                      child: tileWidget,
                    );
                  },
                ),
                // Heatmap layer
                CircleLayer(
                  circles: provider.signalData.map((point) {
                    return CircleMarker(
                      point: point.location,
                      radius: _getHeatmapRadius(_currentZoom),
                      color: _getSignalColor(point.signalStrength).withOpacity(0.3),
                      borderStrokeWidth: 2,
                      borderColor: _getSignalColor(point.signalStrength).withOpacity(0.6),
                    );
                  }).toList(),
                ),
                // Marker layer
                MarkerLayer(
                  markers: provider.signalData.map((point) => Marker(
                    point: point.location,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showSignalDetails(point),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getSignalIcon(point.signalStrength),
                          color: _getSignalColor(point.signalStrength),
                          size: 24,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        _buildMapOverlays(provider),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red[50]!, Colors.white],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to load map',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapOverlays(MapProvider provider) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Status card
          if (provider.isCollecting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.radio_button_checked,
                    color: Colors.white,
                    size: 20,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: const Text('Close'),
                  ),
                  const Text(
                    'Collecting Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Data points counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.data_usage,
                  color: Colors.blue[600],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${provider.signalData.length} data points',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(MapProvider provider, ThemeData theme) {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Navigation FAB
                FloatingActionButton.extended(
                  heroTag: 'nav_fab',
                  onPressed: _navigateToCurrentLocation,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate'),
                ),

                // Data collection FAB
                FloatingActionButton.extended(
                  heroTag: 'collect_fab',
                  onPressed: () => _toggleDataCollection(provider),
                  backgroundColor: provider.isCollecting ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  icon: Icon(
                    provider.isCollecting ? Icons.stop : Icons.play_arrow,
                  ),
                  label: Text(
                    provider.isCollecting ? 'Stop' : 'Start',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleDataCollection(MapProvider provider) {
    if (provider.isCollecting) {
      provider.stopDataCollection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.stop, color: Colors.white),
              SizedBox(width: 8),
              Text('Data collection stopped'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      provider.startDataCollection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.play_arrow, color: Colors.white),
              SizedBox(width: 8),
              Text('Data collection started'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  double _getHeatmapRadius(double zoom) {
    if (zoom < 10) return 1200;
    if (zoom < 13) return 800;
    if (zoom < 15) return 500;
    if (zoom < 17) return 300;
    return 150;
  }

  void _zoomToUserLocation() {
    final provider = Provider.of<MapProvider>(context, listen: false);
    if (provider.signalData.isNotEmpty) {
      _mapController.move(provider.signalData.last.location, 16);
    }
  }

  void _showLegendDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.signal_cellular_alt,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Signal Strength Legend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLegendItem('Excellent (-30 to -50 dBm)', Colors.green, Icons.signal_cellular_4_bar),
              _buildLegendItem('Good (-50 to -60 dBm)', Colors.lightGreen, Icons.signal_cellular_4_bar),
              _buildLegendItem('Fair (-60 to -70 dBm)', Colors.yellow, Icons.network_cell),
              _buildLegendItem('Poor (-70 to -80 dBm)', Colors.orange, Icons.signal_cellular_connected_no_internet_0_bar),
              _buildLegendItem('Very Poor (< -80 dBm)', Colors.red, Icons.signal_cellular_no_sim),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignalDetails(SignalDataPoint point) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSignalColor(point.signalStrength).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSignalIcon(point.signalStrength),
                      color: _getSignalColor(point.signalStrength),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Signal Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Signal Strength', '${point.signalStrength.toStringAsFixed(2)} dBm', Icons.signal_cellular_alt),
              _buildDetailRow('Latitude', point.location.latitude.toStringAsFixed(6), Icons.location_on),
              _buildDetailRow('Longitude', point.location.longitude.toStringAsFixed(6), Icons.location_on),
              _buildDetailRow('Timestamp', _formatDateTime(point.timestamp), Icons.access_time),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Copy coordinates to clipboard
                      final coordinates = '${point.location.latitude.toStringAsFixed(6)},${point.location.longitude.toStringAsFixed(6)}';
                      Clipboard.setData(ClipboardData(text: coordinates));

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.copy, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('Coordinates copied to clipboard'),
                            ],
                          ),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 16),
                        SizedBox(width: 4),
                        Text('Copy'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _navigateToLocation(point.location);
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _navigateToLocation(LatLng location) async {
    try {
      // Try multiple URL schemes in order of preference
      final List<String> urlSchemes = [
        // Google Maps app (preferred)
        'google.navigation:q=${location.latitude},${location.longitude}',
        // Google Maps web with app fallback
        'https://maps.google.com/maps?daddr=${location.latitude},${location.longitude}',
        // Generic geo URI (works with most map apps)
        'geo:${location.latitude},${location.longitude}',
        // Fallback web URL
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
      ];

      bool launched = false;

      for (String urlScheme in urlSchemes) {
        try {
          final uri = Uri.parse(urlScheme);
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            launched = true;
            break;
          }
        } catch (e) {
          debugPrint('Failed to launch $urlScheme: $e');
          continue;
        }
      }

      if (!launched) {
        // If all URL schemes fail, show coordinates to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Navigation not available'),
                  Text('Coordinates: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}'),
                ],
              ),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: '${location.latitude},${location.longitude}'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coordinates copied to clipboard'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _navigateToCurrentLocation() async {
    final provider = Provider.of<MapProvider>(context, listen: false);
    if (provider.signalData.isNotEmpty) {
      final location = provider.signalData.last.location;
      await _navigateToLocation(location);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No location data available'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  IconData _getSignalIcon(double strength) {
    if (strength > -50) return Icons.signal_cellular_4_bar;
    if (strength > -60) return Icons.signal_cellular_4_bar;
    if (strength > -70) return Icons.network_cell;
    if (strength > -80) return Icons.signal_cellular_connected_no_internet_0_bar;
    return Icons.signal_cellular_no_sim;
  }

  Color _getSignalColor(double strength) {
    if (strength > -50) return Colors.green;
    if (strength > -60) return Colors.lightGreen;
    if (strength > -70) return Colors.yellow;
    if (strength > -80) return Colors.orange;
    return Colors.red;
  }
}

class SignalDataPoint {
  final LatLng location;
  final double signalStrength;
  final DateTime timestamp;

  SignalDataPoint({
    required this.location,
    required this.signalStrength,
    required this.timestamp,
  });
}