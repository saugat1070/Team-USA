import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/location_provider.dart';

/// Fallback center if location is not yet available.
const LatLng _kDefaultCenter = LatLng(27.7172, 85.3240); // Kathmandu

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final Set<Polygon> _polygons = {};

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/district.json',
      );
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);
      final List<dynamic> features = jsonResponse['features'] ?? [];

      final Set<Polygon> newPolygons = {};

      for (var feature in features) {
        // Handle Polygon type
        if (feature['geometry']['type'] == 'Polygon') {
          // GeoJSON coordinates for Polygon are typically a list of rings (List<List<List<double>>>)
          // The first ring is the exterior boundary.
          final List<dynamic> coordinates =
              feature['geometry']['coordinates'][0];
          final List<LatLng> points = coordinates.map((coord) {
            // GeoJSON order is [longitude, latitude]
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          }).toList();

          newPolygons.add(
            Polygon(
              polygonId: PolygonId(
                feature['properties']['shapeName'] ?? 'unknown',
              ),
              points: points,
              strokeWidth: 2,
              strokeColor: const Color(0xFF00A86B),
              fillColor: const Color(0xFF000000), // Fixed typo
            ),
          );
        }
      }

      setState(() {
        _polygons.addAll(newPolygons);
      });
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }

    // Load trails
    await _loadTrails();
  }

  Future<void> _loadTrails() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/trails.json',
      );
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);
      final List<dynamic> features = jsonResponse['features'] ?? [];

      final Set<Polygon> trailPolygons = {};
      final List<Color> colors = [
        const Color.fromARGB(200, 156, 39, 176), // Purple
        const Color.fromARGB(200, 255, 193, 7), // Yellow
        const Color.fromARGB(200, 76, 175, 80), // Green
        const Color.fromARGB(200, 33, 150, 243), // Blue
        const Color.fromARGB(200, 255, 87, 34), // Orange
        const Color.fromARGB(200, 0, 137, 249), // Light Blue
      ];

      for (int i = 0; i < features.length; i++) {
        var feature = features[i];
        if (feature['geometry']['type'] == 'Polygon') {
          final List<dynamic> coordinates =
              feature['geometry']['coordinates'][0];
          final List<LatLng> points = coordinates.map((coord) {
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          }).toList();

          final color = colors[i % colors.length];

          trailPolygons.add(
            Polygon(
              polygonId: PolygonId(
                feature['properties']['shapeName'] ?? 'unknown_trail',
              ),
              points: points,
              strokeWidth: 3,
              strokeColor: color,
              fillColor: color.withOpacity(0.4),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${feature['properties']['shapeName']} • ${feature['properties']['activityType']}',
                    ),
                  ),
                );
              },
            ),
          );
        }
      }

      setState(() {
        _polygons.addAll(trailPolygons);
      });
    } catch (e) {
      debugPrint('Error loading trails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    // Determine map center: use current location if available, otherwise fallback.
    final LatLng center = (locationState.position != null)
        ? LatLng(
            locationState.position!.latitude,
            locationState.position!.longitude,
          )
        : _kDefaultCenter;

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
              'Paaila',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Claim your territory, one step at a time',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Google Map as background
          Positioned.fill(
            child: _BackgroundMap(center: center, polygons: _polygons),
          ),

          // Light gradient overlay to keep soft look
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Colored territory shapes
          // const _TerritoryShapes(),

          // Territory summary card
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TerritoryCard(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          // Intentionally left empty – visual only.
        },
        child: const Icon(Icons.navigation_rounded, color: Color(0xFF00A86B)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _TerritoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: Color(0xFF00A86B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Territory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kathmandu Valley',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TerritoryStat(label: 'Claimed Routes', value: '2'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TerritoryStat(
                  label: 'Total Distance',
                  value: '5.3 km',
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TerritoryStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _TerritoryStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF0FFF9) : const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A86B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerritoryShapes extends StatelessWidget {
  const _TerritoryShapes();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              _blob(
                left: width * 0.15,
                top: height * 0.32,
                color: const Color(0xFF4CAF50).withOpacity(0.4),
              ),
              _blob(
                left: width * 0.45,
                top: height * 0.30,
                color: const Color(0xFF42A5F5).withOpacity(0.4),
              ),
              _blob(
                left: width * 0.25,
                top: height * 0.55,
                color: const Color(0xFF7E57C2).withOpacity(0.4),
              ),
              _blob(
                left: width * 0.58,
                top: height * 0.48,
                color: const Color(0xFFEF5350).withOpacity(0.4),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blob({
    required double left,
    required double top,
    required Color color,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: 0.2,
        child: Container(
          width: 90,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
    );
  }
}

class _BackgroundMap extends StatelessWidget {
  const _BackgroundMap({required this.center, required this.polygons});

  final LatLng center;
  final Set<Polygon> polygons;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: center, zoom: 13),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      trafficEnabled: false,
      buildingsEnabled: false,
      polygons: polygons,
    );
  }
}
