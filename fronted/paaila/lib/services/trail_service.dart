import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trail {
  final String name;
  final String activity;
  final double distance;
  final double duration;
  final double area;
  final List<LatLng> coordinates;

  Trail({
    required this.name,
    required this.activity,
    required this.distance,
    required this.duration,
    required this.area,
    required this.coordinates,
  });
}

class TrailService {
  static Future<List<Trail>> loadTrails() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/dummy_trails.json',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final List<dynamic> features = json['features'] ?? [];

      List<Trail> trails = [];

      for (var feature in features) {
        if (feature['geometry']['type'] == 'Polygon') {
          final List<dynamic> coords = feature['geometry']['coordinates'][0];
          final List<LatLng> points = coords.map((coord) {
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          }).toList();

          trails.add(
            Trail(
              name: feature['properties']['shapeName'] ?? 'Unknown',
              activity: feature['properties']['activityType'] ?? 'Activity',
              distance: (feature['properties']['distance'] ?? 0).toDouble(),
              duration: (feature['properties']['duration'] ?? 0).toDouble(),
              area: (feature['properties']['areaCovered'] ?? 0).toDouble(),
              coordinates: points,
            ),
          );
        }
      }

      return trails;
    } catch (e) {
      print('Error loading trails: $e');
      return [];
    }
  }
}
