import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrailMetrics {
  final double distanceM;
  final double avgSpeedMps;
  final double maxSpeedMps;
  final double totalAscentM;
  final double totalDescentM;

  TrailMetrics({
    required this.distanceM,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    required this.totalAscentM,
    required this.totalDescentM,
  });

  factory TrailMetrics.fromJson(Map<String, dynamic> json) {
    return TrailMetrics(
      distanceM: (json['distanceM'] ?? 0).toDouble(),
      avgSpeedMps: (json['avgSpeedMps'] ?? 0).toDouble(),
      maxSpeedMps: (json['maxSpeedMps'] ?? 0).toDouble(),
      totalAscentM: (json['totalAscentM'] ?? 0).toDouble(),
      totalDescentM: (json['totalDescentM'] ?? 0).toDouble(),
    );
  }

  double get distanceKm => distanceM / 1000;
}

class TrailUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  TrailUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory TrailUser.fromJson(Map<String, dynamic> json) {
    return TrailUser(
      id: json['_id'] ?? '',
      firstName: json['fullName']?['firstName'] ?? 'Unknown',
      lastName: json['fullName']?['lastName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Territory {
  final String id;
  final TrailUser user;
  final String roomId;
  final String activityType;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;
  final List<LatLng> trackCoordinates;
  final List<LatLng> polygonCoordinates;
  final double areaM2;
  final String status;
  final TrailMetrics metrics;
  final DateTime createdAt;

  Territory({
    required this.id,
    required this.user,
    required this.roomId,
    required this.activityType,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.trackCoordinates,
    required this.polygonCoordinates,
    required this.areaM2,
    required this.status,
    required this.metrics,
    required this.createdAt,
  });

  factory Territory.fromJson(Map<String, dynamic> json) {
    final trackCoords = <LatLng>[];
    if (json['track'] != null && json['track']['coordinates'] != null) {
      for (var coord in json['track']['coordinates']) {
        if (coord is List && coord.length >= 2) {
          trackCoords.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
        }
      }
    }

    final polygonCoords = <LatLng>[];
    if (json['polygon'] != null && json['polygon']['coordinates'] != null) {
      final polygonArray = json['polygon']['coordinates'];
      if (polygonArray is List && polygonArray.isNotEmpty) {
        for (var coord in polygonArray[0]) {
          if (coord is List && coord.length >= 2) {
            polygonCoords.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
          }
        }
      }
    }

    return Territory(
      id: json['_id'] ?? '',
      user: TrailUser.fromJson(json['userId'] ?? {}),
      roomId: json['roomId'] ?? '',
      activityType: json['activityType'] ?? 'walking',
      startedAt: DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      endedAt: DateTime.tryParse(json['endedAt'] ?? '') ?? DateTime.now(),
      durationSec: json['durationSec'] ?? 0,
      trackCoordinates: trackCoords,
      polygonCoordinates: polygonCoords,
      areaM2: (json['areaM2'] ?? 0).toDouble(),
      status: json['status'] ?? 'unknown',
      metrics: TrailMetrics.fromJson(json['metrics'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  double get areaKm2 => areaM2 / 1000000;

  String get formattedDuration {
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get formattedDistance {
    if (metrics.distanceM >= 1000) {
      return '${metrics.distanceKm.toStringAsFixed(2)} km';
    }
    return '${metrics.distanceM.toStringAsFixed(0)} m';
  }

  String get formattedArea {
    if (areaM2 >= 1000000) {
      return '${areaKm2.toStringAsFixed(2)} km²';
    }
    return '${areaM2.toStringAsFixed(0)} m²';
  }

  LatLng? get centerPoint {
    if (polygonCoordinates.isEmpty) return null;
    double totalLat = 0;
    double totalLng = 0;
    for (var coord in polygonCoordinates) {
      totalLat += coord.latitude;
      totalLng += coord.longitude;
    }
    return LatLng(
      totalLat / polygonCoordinates.length,
      totalLng / polygonCoordinates.length,
    );
  }
}
