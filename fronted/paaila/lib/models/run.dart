import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a single run session.
///
/// Stores:
/// - start/end timestamps
/// - distance (meters)
/// - path coordinates (LatLng list)
///
/// This can be serialized to JSON and sent to your backend/database.
class Run {
  final String id; // e.g. UUID from backend or local timestamp id
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceMeters;
  final List<LatLng> path;

  const Run({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.distanceMeters,
    required this.path,
  });

  Duration get duration => endedAt.difference(startedAt);

  double get distanceKm => distanceMeters / 1000.0;

  /// min/km
  double? get paceMinutesPerKm {
    if (distanceKm <= 0 || duration.inSeconds == 0) return null;
    final minutes = duration.inSeconds / 60.0;
    return minutes / distanceKm;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'distanceMeters': distanceMeters,
      'path': path
          .map((p) => {
                'lat': p.latitude,
                'lng': p.longitude,
              })
          .toList(),
    };
  }

  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      path: (json['path'] as List<dynamic>)
          .map(
            (e) => LatLng(
              (e['lat'] as num).toDouble(),
              (e['lng'] as num).toDouble(),
            ),
          )
          .toList(),
    );
  }
}

