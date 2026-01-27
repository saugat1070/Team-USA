// service_location

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Request location permission from the user
  static Future<bool> requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Geolocator.checkPermission();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  /// Get current user location
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await isLocationPermissionGranted();

      if (!hasPermission) {
        final requested = await requestLocationPermission();
        if (!requested) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Stream of location updates
  static Stream<Position> getLocationUpdates() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, // Update when moved 10 meters
      ),
    );
  }

  /// Open app settings for location permission
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
