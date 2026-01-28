import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paaila/services/trail_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPolygons();
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

      int colorIndex = 0;

      final Set<Polygon> loadedPolygons = {};
      final Set<Polyline> loadedPolylines = {};

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

        // Create polygon from polygon coordinates
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${territory.user.firstName} • ${territory.activityType}',
                    ),
                  ),
                );
              },
            ),
          );
        }
      }

      setState(() {
        _polylines = loadedPolylines;
        _polygons = loadedPolygons;
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
      backgroundColor: const Color(0xFFF2FFF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trail Territories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your claimed territories',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoading
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
                        CameraUpdate.newLatLngBounds(_calculateBounds(), 100),
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
              ],
            ),
    );
  }
}
