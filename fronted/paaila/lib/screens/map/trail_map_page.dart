import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paaila/models/trail_model.dart';
import 'package:paaila/services/trail_service.dart';
import 'package:paaila/services/territory_conquest_service.dart';
import 'package:paaila/widgets/app_header.dart';

class TrailMapPage extends StatefulWidget {
  const TrailMapPage({super.key});

  @override
  State<TrailMapPage> createState() => _TrailMapPageState();
}

class _TrailMapPageState extends State<TrailMapPage> {
  GoogleMapController? _mapController;
  Set<Polygon> _polygons = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  bool _enableConquest = true; // Toggle for territory conquest feature
  Map<String, TerritoryDisplay> _territoryDisplays = {};

  @override
  void initState() {
    super.initState();
    _loadPolygons();
  }

  void _showTerritoryDetailsDialog(
    Territory territory,
    Color color, {
    TerritoryDisplay? display,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Territory Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(
              icon: Icons.person,
              label: 'User',
              value: territory.user.fullName,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.square_foot,
              label: 'Original Area',
              value: territory.formattedArea,
            ),
            if (display != null && display.wasConquered) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.remove_circle_outline,
                label: 'Conquered Area',
                value:
                    '${display.formattedConqueredArea} (${display.conqueredPercentage.toStringAsFixed(1)}%)',
                valueColor: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.check_circle_outline,
                label: 'Remaining Area',
                value: display.formattedRemainingArea,
                valueColor: Colors.green,
              ),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.timer,
              label: 'Duration',
              value: territory.formattedDuration,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.directions_walk,
              label: 'Activity',
              value: territory.activityType,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.straighten,
              label: 'Distance',
              value: territory.formattedDistance,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Captured On',
              value: _formatDate(territory.createdAt),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00A86B)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00A86B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadPolygons() async {
    try {
      final territories = await TrailService.loadTrails();

      final colors = [
        const Color.fromARGB(200, 156, 39, 176), // Purple
        const Color.fromARGB(200, 255, 193, 7), // Yellow
        const Color.fromARGB(200, 76, 175, 80), // Green
        const Color.fromARGB(200, 33, 150, 243), // Blue
        const Color.fromARGB(200, 255, 87, 34), // Orange
        const Color.fromARGB(200, 0, 137, 249), // Light Blue
      ];

      // Process territory conquest if enabled
      Map<String, TerritoryDisplay> conquestResult = {};
      if (_enableConquest) {
        conquestResult = TerritoryConquestService.processConquest(territories);
      }

      int colorIndex = 0;

      final Set<Polygon> loadedPolygons = {};
      final Set<Polyline> loadedPolylines = {};
      final Map<String, TerritoryDisplay> displayMap = {};

      for (var territory in territories) {
        final color = colors[colorIndex++ % colors.length];

        // Create polyline from track coordinates
        final trackCoords = territory.trackCoordinates;
        if (trackCoords.isNotEmpty) {
          loadedPolylines.add(
            Polyline(
              polylineId: PolylineId('track_${territory.id}'),
              points: trackCoords,
              width: 4,
              color: color,
              consumeTapEvents: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${territory.user.firstName} • ${territory.activityType} • ${territory.formattedDistance}',
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Create polygon(s) - either original or conquered versions
        if (_enableConquest && conquestResult.containsKey(territory.id)) {
          final display = conquestResult[territory.id]!;
          displayMap[territory.id] = display;

          // Skip fully conquered territories (no remaining area)
          if (display.isFullyConquered) continue;

          // Add remaining polygon(s) after conquest
          int subIndex = 0;
          for (var polygonCoords in display.displayPolygons) {
            if (polygonCoords.length >= 3) {
              loadedPolygons.add(
                Polygon(
                  polygonId: PolygonId('polygon_${territory.id}_$subIndex'),
                  points: polygonCoords,
                  strokeWidth: 3,
                  strokeColor: color,
                  fillColor: color.withOpacity(
                    display.wasConquered ? 0.3 : 0.4,
                  ),
                  consumeTapEvents: true,
                  onTap: () => _showTerritoryDetailsDialog(
                    territory,
                    color,
                    display: display,
                  ),
                ),
              );
              subIndex++;
            }
          }
        } else {
          // Original behavior without conquest
          final polygonCoords = territory.polygonCoordinates;
          if (polygonCoords.isNotEmpty) {
            loadedPolygons.add(
              Polygon(
                polygonId: PolygonId('polygon_${territory.id}'),
                points: polygonCoords,
                strokeWidth: 3,
                strokeColor: color,
                fillColor: color.withOpacity(0.4),
                consumeTapEvents: true,
                onTap: () => _showTerritoryDetailsDialog(territory, color),
              ),
            );
          }
        }
      }

      setState(() {
        _polylines = loadedPolylines;
        _polygons = loadedPolygons;
        _territoryDisplays = displayMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading trails: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  LatLngBounds _calculateBounds() {
    final allPoints = [
      ..._polygons.expand((p) => p.points),
      ..._polylines.expand((p) => p.points),
    ];

    if (allPoints.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(27.7, 85.3),
        northeast: const LatLng(27.8, 85.4),
      );
    }

    double south = allPoints.first.latitude;
    double north = allPoints.first.latitude;
    double west = allPoints.first.longitude;
    double east = allPoints.first.longitude;

    for (final p in allPoints) {
      south = south < p.latitude ? south : p.latitude;
      north = north > p.latitude ? north : p.latitude;
      west = west < p.longitude ? west : p.longitude;
      east = east > p.longitude ? east : p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(28.252, 83.98),
                            zoom: 13,
                          ),
                          polygons: _polygons,
                          polylines: _polylines,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          buildingsEnabled: false,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            if (_polygons.isNotEmpty || _polylines.isNotEmpty) {
                              controller.animateCamera(
                                CameraUpdate.newLatLngBounds(
                                  _calculateBounds(),
                                  100,
                                ),
                              );
                            }
                          },
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.02),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Conquest toggle button
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _enableConquest = !_enableConquest;
                                  _isLoading = true;
                                });
                                _loadPolygons();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  _enableConquest
                                      ? Icons.layers
                                      : Icons.layers_outlined,
                                  color: const Color(0xFF00A86B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
