import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paaila/models/trail_model.dart';

/// Service to handle territory conquest/overlap logic
/// When a newer territory overlaps with an older one, the overlapping
/// portion is "conquered" by the newer territory owner.
class TerritoryConquestService {
  /// Process territories to handle overlaps - newer territories conquer older ones
  /// Returns a map of territory ID to list of polygons (may be split due to conquest)
  static Map<String, TerritoryDisplay> processConquest(
    List<Territory> territories,
  ) {
    if (territories.isEmpty) return {};

    // Sort by creation date (oldest first)
    final sorted = List<Territory>.from(territories)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Map to store final display polygons for each territory
    final Map<String, TerritoryDisplay> result = {};

    for (int i = 0; i < sorted.length; i++) {
      final current = sorted[i];

      if (current.polygonCoordinates.isEmpty) continue;

      // Start with the current territory's polygon
      List<List<LatLng>> currentPolygons = [current.polygonCoordinates];

      // Check against all NEWER territories (those that come after in time)
      for (int j = i + 1; j < sorted.length; j++) {
        final newer = sorted[j];
        if (newer.polygonCoordinates.isEmpty) continue;

        // Subtract the newer polygon from all current polygons
        List<List<LatLng>> updatedPolygons = [];
        for (var poly in currentPolygons) {
          final subtracted = _subtractPolygon(poly, newer.polygonCoordinates);
          updatedPolygons.addAll(subtracted);
        }
        currentPolygons = updatedPolygons;
      }

      // Calculate remaining area
      double remainingArea = 0;
      for (var poly in currentPolygons) {
        remainingArea += _calculateArea(poly);
      }

      result[current.id] = TerritoryDisplay(
        territory: current,
        displayPolygons: currentPolygons,
        remainingAreaM2: remainingArea,
        originalAreaM2: current.areaM2,
        conqueredAreaM2: current.areaM2 - remainingArea,
      );
    }

    return result;
  }

  /// Subtract polygon B from polygon A, returning remaining parts of A
  static List<List<LatLng>> _subtractPolygon(
    List<LatLng> polygonA,
    List<LatLng> polygonB,
  ) {
    // Check if there's any intersection
    if (!_polygonsIntersect(polygonA, polygonB)) {
      return [polygonA]; // No intersection, return original
    }

    // Check if B completely contains A
    if (_polygonContainsPolygon(polygonB, polygonA)) {
      return []; // Completely conquered
    }

    // Check if A completely contains B (B is inside A)
    if (_polygonContainsPolygon(polygonA, polygonB)) {
      // Create a hole - but for simplicity, we'll use clipping
      return _clipPolygonDifference(polygonA, polygonB);
    }

    // Partial overlap - compute difference
    return _clipPolygonDifference(polygonA, polygonB);
  }

  /// Sutherland-Hodgman based polygon clipping for difference
  static List<List<LatLng>> _clipPolygonDifference(
    List<LatLng> subject,
    List<LatLng> clip,
  ) {
    // For a proper difference, we need to:
    // 1. Find intersection points
    // 2. Create the difference polygon

    // Simplified approach: clip subject against inverted clip edges
    // This gives us the parts of subject that are OUTSIDE clip

    final result = <List<LatLng>>[];

    // Get the bounding boxes
    final subjectBounds = _getBounds(subject);
    final clipBounds = _getBounds(clip);

    // Quick rejection test
    if (!_boundsIntersect(subjectBounds, clipBounds)) {
      return [subject];
    }

    // Use point sampling to create approximate difference
    // This is a simplified but practical approach
    final differencePoints = <LatLng>[];

    for (var point in subject) {
      if (!_pointInPolygon(point, clip)) {
        differencePoints.add(point);
      }
    }

    // Add intersection points at boundary crossings
    for (int i = 0; i < subject.length; i++) {
      final p1 = subject[i];
      final p2 = subject[(i + 1) % subject.length];

      final intersections = _findEdgeIntersections(p1, p2, clip);
      differencePoints.addAll(intersections);
    }

    if (differencePoints.length >= 3) {
      // Sort points to form a proper polygon (convex hull approach for simplicity)
      final sortedPoints = _sortPointsClockwise(differencePoints);
      if (sortedPoints.length >= 3) {
        result.add(sortedPoints);
      }
    }

    return result.isEmpty ? [subject] : result;
  }

  /// Find intersection points between an edge and a polygon
  static List<LatLng> _findEdgeIntersections(
    LatLng p1,
    LatLng p2,
    List<LatLng> polygon,
  ) {
    final intersections = <LatLng>[];

    for (int i = 0; i < polygon.length; i++) {
      final q1 = polygon[i];
      final q2 = polygon[(i + 1) % polygon.length];

      final intersection = _lineIntersection(p1, p2, q1, q2);
      if (intersection != null) {
        intersections.add(intersection);
      }
    }

    return intersections;
  }

  /// Calculate line intersection point
  static LatLng? _lineIntersection(LatLng p1, LatLng p2, LatLng q1, LatLng q2) {
    final d1x = p2.longitude - p1.longitude;
    final d1y = p2.latitude - p1.latitude;
    final d2x = q2.longitude - q1.longitude;
    final d2y = q2.latitude - q1.latitude;

    final cross = d1x * d2y - d1y * d2x;
    if (cross.abs() < 1e-10) return null; // Parallel lines

    final dx = q1.longitude - p1.longitude;
    final dy = q1.latitude - p1.latitude;

    final t = (dx * d2y - dy * d2x) / cross;
    final u = (dx * d1y - dy * d1x) / cross;

    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      return LatLng(p1.latitude + t * d1y, p1.longitude + t * d1x);
    }

    return null;
  }

  /// Sort points clockwise around their centroid
  static List<LatLng> _sortPointsClockwise(List<LatLng> points) {
    if (points.length < 3) return points;

    // Calculate centroid
    double cx = 0, cy = 0;
    for (var p in points) {
      cx += p.longitude;
      cy += p.latitude;
    }
    cx /= points.length;
    cy /= points.length;

    // Sort by angle from centroid
    final sorted = List<LatLng>.from(points);
    sorted.sort((a, b) {
      final angleA = math.atan2(a.latitude - cy, a.longitude - cx);
      final angleB = math.atan2(b.latitude - cy, b.longitude - cx);
      return angleA.compareTo(angleB);
    });

    return sorted;
  }

  /// Check if two polygons intersect
  static bool _polygonsIntersect(List<LatLng> a, List<LatLng> b) {
    // Check if any point of A is inside B
    for (var point in a) {
      if (_pointInPolygon(point, b)) return true;
    }

    // Check if any point of B is inside A
    for (var point in b) {
      if (_pointInPolygon(point, a)) return true;
    }

    // Check if any edges intersect
    for (int i = 0; i < a.length; i++) {
      final a1 = a[i];
      final a2 = a[(i + 1) % a.length];

      for (int j = 0; j < b.length; j++) {
        final b1 = b[j];
        final b2 = b[(j + 1) % b.length];

        if (_lineIntersection(a1, a2, b1, b2) != null) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if polygon A completely contains polygon B
  static bool _polygonContainsPolygon(List<LatLng> a, List<LatLng> b) {
    for (var point in b) {
      if (!_pointInPolygon(point, a)) return false;
    }
    return true;
  }

  /// Point in polygon test using ray casting algorithm
  static bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    int crossings = 0;
    final x = point.longitude;
    final y = point.latitude;

    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      final y1 = p1.latitude;
      final y2 = p2.latitude;
      final x1 = p1.longitude;
      final x2 = p2.longitude;

      if (((y1 <= y && y < y2) || (y2 <= y && y < y1)) &&
          x < (x2 - x1) * (y - y1) / (y2 - y1) + x1) {
        crossings++;
      }
    }

    return crossings % 2 == 1;
  }

  /// Get bounding box of polygon
  static _Bounds _getBounds(List<LatLng> polygon) {
    if (polygon.isEmpty) {
      return _Bounds(0, 0, 0, 0);
    }

    double minLat = polygon[0].latitude;
    double maxLat = polygon[0].latitude;
    double minLng = polygon[0].longitude;
    double maxLng = polygon[0].longitude;

    for (var point in polygon) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return _Bounds(minLat, maxLat, minLng, maxLng);
  }

  /// Check if two bounding boxes intersect
  static bool _boundsIntersect(_Bounds a, _Bounds b) {
    return !(a.maxLng < b.minLng ||
        b.maxLng < a.minLng ||
        a.maxLat < b.minLat ||
        b.maxLat < a.minLat);
  }

  /// Calculate area of a polygon using Shoelace formula (in square meters approximation)
  static double _calculateArea(List<LatLng> polygon) {
    if (polygon.length < 3) return 0;

    // Use spherical excess formula for better accuracy
    double area = 0;
    const double earthRadius = 6371000; // meters

    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      final lat1 = p1.latitude * math.pi / 180;
      final lat2 = p2.latitude * math.pi / 180;
      final dLng = (p2.longitude - p1.longitude) * math.pi / 180;

      area += dLng * (2 + math.sin(lat1) + math.sin(lat2));
    }

    area = area.abs() * earthRadius * earthRadius / 2;
    return area;
  }
}

/// Bounding box helper class
class _Bounds {
  final double minLat, maxLat, minLng, maxLng;
  _Bounds(this.minLat, this.maxLat, this.minLng, this.maxLng);
}

/// Display model for a territory after conquest processing
class TerritoryDisplay {
  final Territory territory;
  final List<List<LatLng>> displayPolygons;
  final double remainingAreaM2;
  final double originalAreaM2;
  final double conqueredAreaM2;

  TerritoryDisplay({
    required this.territory,
    required this.displayPolygons,
    required this.remainingAreaM2,
    required this.originalAreaM2,
    required this.conqueredAreaM2,
  });

  bool get wasConquered => conqueredAreaM2 > 0;
  bool get isFullyConquered => displayPolygons.isEmpty;

  double get conqueredPercentage =>
      originalAreaM2 > 0 ? (conqueredAreaM2 / originalAreaM2) * 100 : 0;

  String get formattedRemainingArea {
    if (remainingAreaM2 >= 1000000) {
      return '${(remainingAreaM2 / 1000000).toStringAsFixed(2)} km²';
    }
    return '${remainingAreaM2.toStringAsFixed(0)} m²';
  }

  String get formattedConqueredArea {
    if (conqueredAreaM2 >= 1000000) {
      return '${(conqueredAreaM2 / 1000000).toStringAsFixed(2)} km²';
    }
    return '${conqueredAreaM2.toStringAsFixed(0)} m²';
  }
}
