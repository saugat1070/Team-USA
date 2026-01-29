import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'socket_service.dart';

/// Sends the user's location to the backend via POST /api/v1/location.
/// Requires an authenticated user (Bearer token). No-op if not logged in.
/// Failures are logged and do not throw, so callers can use fire-and-forget.
class LocationApiService {
  static Future<void> sendLocation(double latitude, double longitude) async {
    final token = AuthService.authToken;
    if (token == null || token.isEmpty) return;

    final url = Uri.parse('https://team-usa-2.onrender.com/api/v1/get-district');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          String? roomId;

          if (jsonResponse is Map) {
            // Primary: room.roomId
            if (jsonResponse['room'] != null && jsonResponse['room'] is Map) {
              final room = jsonResponse['room'] as Map;
              if (room['roomId'] != null) {
                roomId = room['roomId'].toString();
              }
            }
          }

          if (roomId != null && roomId.isNotEmpty) {
            // Emit to socket to join the room. This will queue the join if socket isn't connected.
            try {
              SocketService().joinRoom(roomId);
              print('District ID is: $roomId');
            } catch (e) {
              print('Socket join error: $e');
            }
          }
        } catch (e) {
          print('Failed to parse get-district response: $e');
        }
      }
    } catch (e) {
      // Fire-and-forget: log only so location flow is not broken
      print('LocationApiService.sendLocation error: $e');
    }
  }
}
