// Location_provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/location_api_service.dart';
import '../services/socket_service.dart';
import '../providers/socket_provider.dart';

// Location state class
class LocationState {
  final Position? position;
  final bool isTracking;
  final String? error;
  final bool permissionGranted;

  LocationState({
    this.position,
    this.isTracking = false,
    this.error,
    this.permissionGranted = false,
  });

  LocationState copyWith({
    Position? position,
    bool? isTracking,
    String? error,
    bool? permissionGranted,
  }) {
    return LocationState(
      position: position ?? this.position,
      isTracking: isTracking ?? this.isTracking,
      error: error ?? this.error,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}

// Location provider
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    final socketService = ref.watch(socketServiceProvider);
    return LocationNotifier(socketService, ref);
  },
);

class LocationNotifier extends StateNotifier<LocationState> {
  final SocketService socketService;
  final Ref ref;

  LocationNotifier(this.socketService, this.ref) : super(LocationState());

  /// Request location permission and get current location
  Future<void> requestAndGetLocation() async {
    state = state.copyWith(isTracking: true, error: null);

    try {
      final hasPermission = await LocationService.requestLocationPermission();

      if (!hasPermission) {
        state = state.copyWith(
          isTracking: false,
          error: 'Location permission denied',
          permissionGranted: false,
        );
        return;
      }

      // Try to get last known position first (instant) for faster map render
      final lastKnown = await LocationService.getLastKnownLocation();
      if (lastKnown != null) {
        state = state.copyWith(
          position: lastKnown,
          isTracking: true, // Still tracking to get accurate position
          permissionGranted: true,
          error: null,
        );
      }

      // Now get accurate position (may take a few seconds)
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        state = state.copyWith(
          position: position,
          isTracking: false,
          permissionGranted: true,
          error: null,
        );

        // Send location via socket (server identifies user from JWT in socket connection)
        socketService.sendLocation(position.latitude, position.longitude);
        // Send location via POST API
        LocationApiService.sendLocation(position.latitude, position.longitude);
      } else {
        state = state.copyWith(
          isTracking: false,
          error: 'Could not get location',
          permissionGranted: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isTracking: false,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  /// Check if location permission is already granted
  Future<void> checkPermission() async {
    try {
      final hasPermission = await LocationService.isLocationPermissionGranted();
      state = state.copyWith(permissionGranted: hasPermission);

      if (hasPermission) {
        await requestAndGetLocation();
      }
    } catch (e) {
      state = state.copyWith(error: 'Error checking permission: $e');
    }
  }

  /// Get current location (without requesting permission)
  Future<void> getCurrentLocation() async {
    state = state.copyWith(isTracking: true, error: null);

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        state = state.copyWith(
          position: position,
          isTracking: false,
          error: null,
        );

        // Send location via socket (server identifies user from JWT in socket connection)
        socketService.sendLocation(position.latitude, position.longitude);
        // Send location via POST API
        LocationApiService.sendLocation(position.latitude, position.longitude);
      } else {
        state = state.copyWith(
          isTracking: false,
          error: 'Could not get location',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isTracking: false,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  /// Clear location data
  void clearLocation() {
    state = LocationState();
  }

  /// Start tracking
  void startTracking() {
    state = state.copyWith(isTracking: true);
    // Logic to start continuous tracking if needed, e.g. locationUpdatesProvider is already a stream
    // but here we just update the UI state.
    getCurrentLocation();
  }

  /// Stop tracking
  void stopTracking() {
    state = state.copyWith(isTracking: false);
    // Logic to stop tracking if needed
  }
}

// Stream provider for continuous location updates
final locationUpdatesProvider = StreamProvider<Position>((ref) {
  return LocationService.getLocationUpdates();
});
