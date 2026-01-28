import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/app_header.dart';

class TrailMapPage extends StatefulWidget {
  const TrailMapPage({super.key});

  @override
  State<TrailMapPage> createState() => _TrailMapPageState();
}

class _TrailMapPageState extends State<TrailMapPage> {
  // ignore: unused_field - kept for future map control features
  GoogleMapController? _mapController;
  Set<Polygon> _polygons = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolygons();
  }

  Future<void> _loadPolygons() async {
    try {
      final String geoJsonString = await rootBundle.loadString(
        'data/trails.json',
      );
      final decoded = json.decode(geoJsonString);
      final List features = decoded['features'] ?? [];

      final colors = [
        const Color.fromARGB(200, 156, 39, 176), // Purple
        const Color.fromARGB(200, 255, 193, 7), // Yellow
        const Color.fromARGB(200, 76, 175, 80), // Green
        const Color.fromARGB(200, 33, 150, 243), // Blue
        const Color.fromARGB(200, 255, 87, 34), // Orange
        const Color.fromARGB(200, 0, 137, 249), // Light Blue
      ];

      int colorIndex = 0;

      final Set<Polygon> loadedPolygons = features.map<Polygon>((feature) {
        final props = feature['properties'];
        final List coords = feature['geometry']['coordinates'][0];

        final List<LatLng> points = coords
            .map<LatLng>((c) => LatLng(c[0].toDouble(), c[1].toDouble()))
            .toList();

        final color = colors[colorIndex++ % colors.length];

        return Polygon(
          polygonId: PolygonId(props['shapeName'] ?? 'trail_$colorIndex'),
          points: points,
          strokeWidth: 3,
          strokeColor: color,
          fillColor: color.withOpacity(0.4),
          consumeTapEvents: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${props['shapeName']} • ${props['activityType']}',
                ),
              ),
            );
          },
        );
      }).toSet();

      setState(() {
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
    final allPoints = _polygons.expand((p) => p.points).toList();

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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00A86B),
                      ),
                    )
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(28.252, 83.98),
                            zoom: 13,
                          ),
                          polygons: _polygons,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          buildingsEnabled: false,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            if (_polygons.isNotEmpty) {
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
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.02),
                                  ],
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
