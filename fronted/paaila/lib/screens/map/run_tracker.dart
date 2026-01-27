import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simple service that:
/// - Tracks the user's live location
/// - Stores all visited points as a route (trail)
/// - Calculates total distance
///
/// Intended usage from a widget (e.g. `MapPage`):
///
/// ```dart
/// final tracker = RunTracker();
/// await tracker.start();
///
/// // Listen to route updates
/// tracker.routeStream.listen((points) {
///   // Use `points` to update a Polyline on the map
/// });
///
/// // When done
/// tracker.dispose();
/// ```
class RunTracker {
  RunTracker({
    LocationSettings? locationSettings,
  }) : _locationSettings = locationSettings ??
            const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 5, // meters between updates
            );

  final LocationSettings _locationSettings;

  final List<LatLng> _routePoints = [];
  final _routeController = StreamController<List<LatLng>>.broadcast();

  StreamSubscription<Position>? _positionSub;

  DateTime? _startTime;
  double _totalDistance = 0.0; // meters

  /// Locked initial position when tracking starts.
  LatLng? _initialPosition;

  /// Public getters
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  Stream<List<LatLng>> get routeStream => _routeController.stream;

  LatLng? get initialPosition => _initialPosition;
  DateTime? get startTime => _startTime;
  double get totalDistance => _totalDistance;

  /// Start listening to location updates and building the trail.
  Future<void> start() async {
    // Ensure permissions are granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission not granted');
    }

    // Reset state for a new run
    _routePoints.clear();
    _totalDistance = 0.0;
    _startTime = null;
    _initialPosition = null;

    _positionSub?.cancel();

    _positionSub = Geolocator.getPositionStream(locationSettings: _locationSettings)
        .listen(_onNewPosition);
  }

  /// Stop listening to location updates.
  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  void _onNewPosition(Position position) {
    final newPoint = LatLng(position.latitude, position.longitude);

    if (_routePoints.isEmpty) {
      // First point -> lock as initial position and start timer
      _initialPosition = newPoint;
      _startTime = DateTime.now();
    } else {
      // Add distance from previous point
      _totalDistance += _calculateDistance(
        _routePoints.last.latitude,
        _routePoints.last.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
    }

    _routePoints.add(newPoint);

    // Emit updated route list so UI can draw / update the polyline
    _routeController.add(List.unmodifiable(_routePoints));
  }

  /// Call when the service is no longer needed.
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _routeController.close();
  }

  /// Haversine distance in meters between two lat/lon points.
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // meters

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * pi / 180;
}

