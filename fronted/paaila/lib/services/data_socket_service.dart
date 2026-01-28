import 'dart:convert';
import 'package:flutter/services.dart';
import 'socket_service.dart';

class DataSocketService {
  static final DataSocketService _instance = DataSocketService._internal();
  final SocketService _socketService = SocketService();

  factory DataSocketService() => _instance;

  DataSocketService._internal();

  /// Load trails.json from assets
  Future<List<dynamic>> loadTrailsData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'data/trails.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      return jsonData['features'] ?? [];
    } catch (e) {
      print('Error loading trails data: $e');
      return [];
    }
  }

  /// Extract coordinates from a single trail feature
  List<List<double>> extractCoordinates(Map<String, dynamic> feature) {
    try {
      final coordinates = feature['geometry']['coordinates'] as List;
      return (coordinates[0] as List)
          .map((coord) => [
            (coord[0] as num).toDouble(), // longitude
            (coord[1] as num).toDouble(), // latitude
          ])
          .toList();
    } catch (e) {
      print('Error extracting coordinates: $e');
      return [];
    }
  }


  /// Send a single trail by shapeName


  /// Send coordinates for a specific trail activity
  Future<void> sendTrailCoordinates(String shapeName) async {
    try {
      final trails = await loadTrailsData();
      
      final trail = trails.firstWhere(
        (feature) => feature['shapeName'] == shapeName,
        orElse: () => null,
      );

      if (trail != null) {
        final coordinates = extractCoordinates(trail);
        _socketService.socket.emit('trail:coordinates', {
          'coordinates': coordinates,
        });
      }
    } catch (e) {
      print('Error sending trail coordinates: $e');
    }
  }

  /// Listen for trail acknowledgment from backend
  void listenToTrailAcknowledgment() {
    _socketService.socket.on('trail:ack', (data) {
      print('Trail acknowledged: $data');
    });
  }
}