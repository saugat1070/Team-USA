import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:paaila/services/auth_service.dart';

class RankingService {
  static const String baseUrl = 'http://192.168.1.72:3000';

  static Future<List<Runner>> fetchRankings({
    required String roomId,
  }) async {
    try {
      final token = AuthService.authToken;
      if (token == null) {
        throw Exception('Authentication token not found. Please login first.');
      }

      final url = '$baseUrl/api/v1/leaderboard/$roomId';
      print('Fetching rankings from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> leaderboard = jsonData['leaderboard'] ?? [];

        if (leaderboard.isEmpty) {
          throw Exception('Leaderboard is empty');
        }

        return leaderboard.map((data) => Runner.fromJson(data)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception(
          'Failed to load rankings: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching rankings: $e');
    }
  }
}

class Runner {
  final String name;
  final String distance;
  final int territories;
  final int rank;
  final Color color;
  final double score;
  final int sessions;
  final double avgSpeedMps;
  final String userId;

  Runner({
    required this.name,
    required this.distance,
    required this.territories,
    required this.rank,
    required this.color,
    required this.score,
    required this.sessions,
    required this.avgSpeedMps,
    required this.userId,
  });

  factory Runner.fromJson(Map<String, dynamic> json) {
    final totalDistanceM = json['totalDistanceM'] ?? 0.0;
    final distanceKm = (totalDistanceM / 1000).toStringAsFixed(1);
    final firstName = json['user']?['fullName']?['firstName'] ?? 'Unknown';

    return Runner(
      name: firstName,
      distance: '$distanceKm km',
      territories: json['sessions'] ?? 0,
      rank: json['rank'] ?? 0,
      color: _getColorForRank(json['rank'] ?? 0),
      score: json['score']?.toDouble() ?? 0.0,
      sessions: json['sessions'] ?? 0,
      avgSpeedMps: json['avgSpeedMps']?.toDouble() ?? 0.0,
      userId: json['userId'] ?? '',
    );
  }

  static Color _getColorForRank(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFC107); // Gold
      case 2:
        return const Color(0xFFCFD8DC); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white;
    }
  }
}
