// Location_provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

// Location state class
class LocationState {
  final Position? position;
  final bool isLoading;
  final String? error;
  final bool permissionGranted;

  LocationState({
    this.position,
    this.isLoading = false,
    this.error,
    this.permissionGranted = false,
  });

  LocationState copyWith({
    Position? position,
    bool? isLoading,
    String? error,
    bool? permissionGranted,
  }) {
    return LocationState(
      position: position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}

// Location provider
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  /// Request location permission and get current location
  Future<void> requestAndGetLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final hasPermission = await LocationService.requestLocationPermission();

      if (!hasPermission) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission denied',
          permissionGranted: false,
        );
        return;
      }

      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        state = state.copyWith(
          position: position,
          isLoading: false,
          permissionGranted: true,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get location',
          permissionGranted: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: ${e.toString()}');
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        state = state.copyWith(
          position: position,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get location',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: ${e.toString()}');
    }
  }

  /// Clear location data
  void clearLocation() {
    state = LocationState();
  }
}

// Stream provider for continuous location updates
final locationUpdatesProvider = StreamProvider<Position>((ref) {
  return LocationService.getLocationUpdates();
});
