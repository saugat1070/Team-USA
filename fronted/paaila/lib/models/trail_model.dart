import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trail {
  final String trailId;
  final String activityType;
  final double distance;
  final double duration;
  final double areaCovered;
  final List<LatLng> pathCoordinates;

  Trail({
    required this.trailId,
    required this.activityType,
    required this.distance,
    required this.duration,
    required this.areaCovered,
    required this.pathCoordinates,
  });

  factory Trail.fromJson(Map<String, dynamic> json) {
    List<LatLng> pathCoordsList = [];

    if (json['pathCoordinates'] != null) {
      var pathCoordsFromJson = json['pathCoordinates'] as List;
      pathCoordsList = pathCoordsFromJson.map((coord) {
        return LatLng(coord['latitude'], coord['longitude']);
      }).toList();
    }

    return Trail(
      trailId: json['trailId'] ?? json['shapeName'] ?? 'unknown',
      activityType: json['activityType'] ?? 'Activity',
      distance: (json['distance'] ?? 0.0).toDouble(),
      duration: (json['duration'] ?? 0.0).toDouble(),
      areaCovered: (json['areaCovered'] ?? 0.0).toDouble(),
      pathCoordinates: pathCoordsList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, double>> pathCoordsToJson = pathCoordinates.map((coord) {
      return {'latitude': coord.latitude, 'longitude': coord.longitude};
    }).toList();

    return {
      'trailId': trailId,
      'activityType': activityType,
      'distance': distance,
      'duration': duration,
      'areaCovered': areaCovered,
      'pathCoordinates': pathCoordsToJson,
    };
  }
}
