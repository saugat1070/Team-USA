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
import '../../widgets/app_header.dart';

class MapForRunningPage extends ConsumerStatefulWidget {
  const MapForRunningPage({super.key});

  @override
  ConsumerState<MapForRunningPage> createState() => _MapForRunningPageState();
}

class _MapForRunningPageState extends ConsumerState<MapForRunningPage> {
  GoogleMapController? _mapController;

  // Theme colors
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _fireOrange = Color(0xFFFF7043);

  final List<LatLng> _routePoints = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  final List<Run> _savedRuns = [];

  /// Initial position of the user (locked once set)
  // ignore: unused_field - kept for potential future use
  LatLng? _initialPosition;

  DateTime? _startTime;
  double _totalDistance = 0.0;

  /// Run session state
  bool _isTracking = false;
  Duration _lastRunDuration = Duration.zero;
  double _lastRunDistance = 0.0;
  double _lastRunPace = 0.0; // km/min
  String? _redisActivity; // Store the activity type (Walking or Running)

  @override
  void initState() {
    super.initState();

    /// Request permission + initial location
    Future.microtask(() {
      ref.read(locationProvider.notifier).requestAndGetLocation();
      _loadSavedRuns();
    });
  }

  /// Track if we've already centered on user's location
  bool _hasCenteredOnUser = false;

  /// Fallback center if location is not yet available (Kathmandu)
  static const LatLng _kDefaultCenter = LatLng(27.7172, 85.3240);

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final locationStream = ref.watch(locationUpdatesProvider);

    // Use position if available, otherwise fallback to default
    final LatLng mapCenter = (locationState.position != null)
        ? LatLng(
            locationState.position!.latitude,
            locationState.position!.longitude,
          )
        : _kDefaultCenter;

    // Auto-center on user when position becomes available
    if (locationState.position != null &&
        !_hasCenteredOnUser &&
        _mapController != null) {
      _hasCenteredOnUser = true;
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            locationState.position!.latitude,
            locationState.position!.longitude,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),

            /// 🗺 Google Map - renders immediately with fallback position
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: mapCenter,
                          zoom: 17,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        webCameraControlEnabled: false,
                        myLocationButtonEnabled: false,
                        polylines: _polylines,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (locationState.position != null) {
                            controller.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(
                                  locationState.position!.latitude,
                                  locationState.position!.longitude,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      // Recenter button at bottom right
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          heroTag: 'recenter_btn',
                          backgroundColor: Colors.white,
                          onPressed: _recenterMap,
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFF00A86B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// ▶️ Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isTracking ? null : _startRun,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: _isTracking ? Colors.grey : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isTracking ? Colors.grey : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isTracking ? _stopRun : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _fireOrange,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_rounded,
                            color: _isTracking ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Stop',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isTracking ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
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
      ),
    );
  }

  /// Recenter map to current location
  void _recenterMap() {
    final locationState = ref.read(locationProvider);
    if (locationState.position != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            locationState.position!.latitude,
            locationState.position!.longitude,
          ),
        ),
      );
    }
  }

  /// Handle live location updates
  void _handleNewPosition(Position position) {
    final newPoint = LatLng(position.latitude, position.longitude);

    // Send every new position to the server (continuous stream)
    final socketService = ref.read(socketServiceProvider);
    if (_routePoints.isEmpty) {
      socketService.sendLocation(
        position.latitude,
        position.longitude,
      ); // walk:start with first point
    } else {
      print("Location sent: ${position.latitude}, ${position.longitude}");
      socketService.sendLocationUpdate(
        position.latitude,
        position.longitude,
      ); // walk:location stream
    }

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
        color: _primaryGreen,
        width: 5,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLng(newPoint));
  }

  /// Stats UI
  Widget _buildStats() {
    final bool isRunning = _isTracking;

    final duration = isRunning
        ? (_startTime == null
              ? Duration.zero
              : DateTime.now().difference(_startTime!))
        : _lastRunDuration;

    final distanceMeters = isRunning
        ? _totalDistance
        : _lastRunDistance; // meters
    final distanceKm = distanceMeters / 1000.0;

    // Calculate current or last pace
    final pace = () {
      if (distanceKm <= 0 || duration.inSeconds == 0) return 0.0;
      final minutes = duration.inSeconds / 60.0;
      return distanceKm / minutes; // km/min
    }();

    if (!isRunning) {
      // Cache last run stats so they don't change after stop
      _lastRunPace = pace;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            'Distance',
            '${distanceKm.toStringAsFixed(2)} km',
            Icons.straighten_rounded,
          ),
          _statItem(
            'Time',
            '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
            Icons.timer_outlined,
          ),
          _statItem(
            'Pace',
            (pace == 0.0 && !_isTracking && _lastRunPace > 0)
                ? '${_lastRunPace.toStringAsFixed(2)}'
                : (pace == 0.0 ? '-' : '${pace.toStringAsFixed(2)}'),
            Icons.speed_rounded,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _primaryGreen, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  void _startRun() async {
    // Show dialog to choose activity type
    final activityType = await showDialog<String>(
      context: context,
      barrierDismissible: false, // User must choose
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Choose Activity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: const Text(
            'What activity are you starting?',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop('Walking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Walk',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop('Running'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _fireOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bike,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Cycle',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    // If user dismissed dialog or didn't choose, don't start
    if (activityType == null) return;

    setState(() {
      _redisActivity = activityType; // Store the choice
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
        _lastRunPace = distanceKm / minutes;
      } else {
        _lastRunPace = 0.0;
      }
    });

    // Notify server that the run has ended
    ref.read(socketServiceProvider).stopRun();

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

      // Push activity to Redis with the chosen activity type
      if (_redisActivity != null) {
        _pushRedis(_redisActivity!);
      }

      // Navigate back to home page after stopping
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _pushRedis(String activityType) {
    ref.read(socketServiceProvider).pushRedis(activityType);
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
          color: _primaryGreen.withOpacity(0.7),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem(
                    'Distance',
                    '${run.distanceKm.toStringAsFixed(2)} km',
                    Icons.straighten_rounded,
                  ),
                  _statItem(
                    'Duration',
                    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    Icons.timer_outlined,
                  ),
                  _statItem(
                    'Pace',
                    pace == null ? '-' : '${pace.toStringAsFixed(2)}',
                    Icons.speed_rounded,
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

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * pi / 180;
}
