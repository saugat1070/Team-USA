import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Sends the user's location to the backend via POST /api/v1/location.
/// Requires an authenticated user (Bearer token). No-op if not logged in.
/// Failures are logged and do not throw, so callers can use fire-and-forget.
class LocationApiService {
  static Future<void> sendLocation(double latitude, double longitude) async {
    final token = AuthService.authToken;
    if (token == null || token.isEmpty) return;

    final url = Uri.parse('http://192.168.1.72:3000/api/v1/get-district');
    try {
      await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );
    } catch (e) {
      // Fire-and-forget: log only so location flow is not broken
      print('LocationApiService.sendLocation error: $e');
    }
  }
}
