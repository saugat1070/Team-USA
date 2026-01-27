import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/run.dart';
import '../../providers/location_provider.dart';
import '../../repositories/run_repository.dart';
import '../../providers/socket_provider.dart';
import '../../providers/auth_provider.dart';

class MapForRunningPage extends ConsumerStatefulWidget {
  const MapForRunningPage({super.key});

  @override
  ConsumerState<MapForRunningPage> createState() => _MapForRunningPageState();
}

class _MapForRunningPageState extends ConsumerState<MapForRunningPage> {
  GoogleMapController? _mapController;

  final List<LatLng> _routePoints = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  final List<Run> _savedRuns = [];

  /// Initial position of the user (locked once set)
  LatLng? _initialPosition;

  DateTime? _startTime;
  double _totalDistance = 0.0;

  /// Run session state
  bool _isTracking = false;
  Duration _lastRunDuration = Duration.zero;
  double _lastRunDistance = 0.0;
  double _lastRunPace = 0.0; // min/km

  @override
  void initState() {
    super.initState();

    /// Request permission + initial location
    Future.microtask(() {
      ref.read(locationProvider.notifier).requestAndGetLocation();
      _loadSavedRuns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final locationStream = ref.watch(locationUpdatesProvider);

    return Scaffold(
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: locationState.isTracking
          ? const Center(child: CircularProgressIndicator())
          : locationState.position == null
              ? const Center(child: Text('Location not available'))
              : Column(
                  children: [
                    /// 🗺 Google Map
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                locationState.position!.latitude,
                                locationState.position!.longitude,
                              ),
                              zoom: 17,
                            ),
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            polylines: _polylines,
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                          ),
                        ),
                      ),
                    ),

                    /// ▶️ Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isTracking ? null : _startRun,
                              child: const Text('Start'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isTracking ? _stopRun : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text('Stop'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 📊 Stats Panel
                    locationStream.when(
                      data: (position) {
                        if (_isTracking) {
                          _handleNewPosition(position);
                        }

                        return _buildStats();
                      },
                      loading: () => _buildStats(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ],
                ),
    );
  }

  /// Handle live location updates
  void _handleNewPosition(Position position) {
    final newPoint = LatLng(position.latitude, position.longitude);
    print('New Position: ${position.latitude}, ${position.longitude}');


    if (_routePoints.isEmpty) {
      /// First point: lock as initial position and add a marker
      _initialPosition = newPoint;
      _markers
        ..clear()
        ..add(
          const Marker(
            markerId: MarkerId('start'),
            // position is set below when copying with newPoint
          ),
        );

      // Replace the default marker with one at the actual coordinates
      _markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('start'),
            position: newPoint,
            infoWindow: const InfoWindow(title: 'Start Location'),
          ),
        );

      _startTime = DateTime.now();
    } else {
      _totalDistance += _calculateDistance(
        _routePoints.last.latitude,
        _routePoints.last.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
    }

    _routePoints.add(newPoint);

    // Update the current run polyline while preserving saved run polylines.
    _polylines.removeWhere(
      (polyline) => polyline.polylineId.value == 'current_route',
    );

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('current_route'),
        points: List.unmodifiable(_routePoints),
        color: Colors.blue,
        width: 5,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newPoint),
    );
  }

  /// Stats UI
  Widget _buildStats() {
    final bool isRunning = _isTracking;

    final duration = isRunning
        ? (_startTime == null
            ? Duration.zero
            : DateTime.now().difference(_startTime!))
        : _lastRunDuration;

    final distanceMeters =
        isRunning ? _totalDistance : _lastRunDistance; // meters
    final distanceKm = distanceMeters / 1000.0;

    // Calculate current or last pace
    final pace = () {
      if (distanceKm <= 0 || duration.inSeconds == 0) return 0.0;
      final minutes = duration.inSeconds / 60.0;
      return minutes / distanceKm; // min/km
    }();

    if (!isRunning) {
      // Cache last run stats so they don't change after stop
      _lastRunPace = pace;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Distance', '${distanceKm.toStringAsFixed(2)} km'),
          _statItem(
            'Time',
            '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
          ),
          _statItem(
            'Pace',
            (pace == 0.0 && !_isTracking && _lastRunPace > 0)
                ? '${_lastRunPace.toStringAsFixed(2)} min/km'
                : (pace == 0.0
                    ? '-'
                    : '${pace.toStringAsFixed(2)} min/km'),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  void _startRun() {
    setState(() {
      _isTracking = true;
      _routePoints.clear();
      _polylines.clear();
      _markers.clear();
      _initialPosition = null;
      _startTime = null;
      _totalDistance = 0.0;
      _lastRunDuration = Duration.zero;
      _lastRunDistance = 0.0;
      _lastRunPace = 0.0;
    });
  }

  void _stopRun() {
    if (!_isTracking) return;

    final DateTime? startedAt = _startTime;
    final DateTime endedAt = DateTime.now();

    setState(() {
      _isTracking = false;

      if (startedAt != null) {
        _lastRunDuration = endedAt.difference(startedAt);
      } else {
        _lastRunDuration = Duration.zero;
      }

      _lastRunDistance = _totalDistance;

      final distanceKm = _lastRunDistance / 1000.0;
      if (distanceKm > 0 && _lastRunDuration.inSeconds > 0) {
        final minutes = _lastRunDuration.inSeconds / 60.0;
        _lastRunPace = minutes / distanceKm;
      } else {
        _lastRunPace = 0.0;
      }
    });

    // Persist this run so it can be shown later on the map / in history.
    if (startedAt != null && _routePoints.isNotEmpty) {
      final run = Run(
        id: endedAt.millisecondsSinceEpoch.toString(), // simple local id
        startedAt: startedAt,
        endedAt: endedAt,
        distanceMeters: _totalDistance,
        path: List.unmodifiable(_routePoints),
      );

      // Fire-and-forget; in a real app you may want to show errors / loading.
      ref.read(runRepositoryProvider).saveRun(run);

      // Also add to in-memory list so it appears immediately.
      setState(() {
        _savedRuns.add(run);
      });
      _rebuildSavedRunPolylines();
    }
  }

  Future<void> _loadSavedRuns() async {
    final runs = await ref.read(runRepositoryProvider).getRuns();
    if (!mounted) return;

    setState(() {
      _savedRuns
        ..clear()
        ..addAll(runs);
    });
    _rebuildSavedRunPolylines();
  }

  void _rebuildSavedRunPolylines() {
    // Remove existing saved run polylines (those whose id starts with 'run_')
    _polylines.removeWhere(
      (polyline) => polyline.polylineId.value.startsWith('run_'),
    );

    for (final run in _savedRuns) {
      final id = PolylineId('run_${run.id}');
      _polylines.add(
        Polyline(
          polylineId: id,
          points: run.path,
          color: Colors.green.withOpacity(0.7),
          width: 4,
          consumeTapEvents: true,
          onTap: () => _showRunDetails(run),
        ),
      );
    }
  }

  void _showRunDetails(Run run) {
    final duration = run.duration;
    final pace = run.paceMinutesPerKm;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Run Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem('Distance', '${run.distanceKm.toStringAsFixed(2)} km'),
                  _statItem(
                    'Duration',
                    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  ),
                  _statItem(
                    'Pace',
                    pace == null ? '-' : '${pace.toStringAsFixed(2)} min/km',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Started: ${run.startedAt}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Ended:   ${run.endedAt}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Distance calculation (Haversine)
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
