import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paaila/models/trail_model.dart';
import 'package:paaila/services/auth_service.dart';

class TrailService {
  static const String baseUrl = 'http://192.168.1.72:3000';

  static Future<List<Territory>> loadTrails() async {
    try {
      final token = AuthService.authToken;
      if (token == null) {
        print('No auth token found, returning empty trails list');
        return [];
      }

      final url = '$baseUrl/api/v1/user/teritory';
      print('Fetching trails from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Parsed JSON data: ${jsonData.keys}');

        if (jsonData['ok'] != true) {
          print('API returned ok: false');
          throw Exception('API returned error');
        }

        final List<dynamic> territories = jsonData['territory'] ?? [];
        print('Fetched ${territories.length} territories');
        if (territories.isEmpty) {
          print('WARNING: No territories found in response');
        }

        final List<Territory> territoryList = territories
            .map((data) => Territory.fromJson(data))
            .toList();

        print('Successfully parsed ${territoryList.length} territories');

        // Log coordinates for debugging
        for (var t in territoryList) {
          print(
            'Territory ${t.id}: ${t.trackCoordinates.length} track points, ${t.polygonCoordinates.length} polygon points',
          );
        }

        return territoryList;
      } else {
        throw Exception('Failed to load trails: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading trails: $e');
      return [];
    }
  }

  static Future<List<Territory>> fetchUserTerritories() async {
    try {
      final token = AuthService.authToken;
      if (token == null) {
        throw Exception('Authentication token not found. Please login first.');
      }

      final url = '$baseUrl/api/v1/user/teritory';
      print('Fetching territories from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['ok'] != true) {
          throw Exception('API returned error');
        }

        final List<dynamic> territories = jsonData['territory'] ?? [];
        return territories.map((data) => Territory.fromJson(data)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception(
          'Failed to load territories: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching territories: $e');
      throw Exception('Error fetching territories: $e');
    }
  }
}
