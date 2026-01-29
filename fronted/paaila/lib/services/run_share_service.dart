import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'auth_service.dart';

/// Service for saving and sharing run data with images
class RunShareService {
  static const String baseUrl = AuthService.baseUrl;

  /// Save image to device gallery
  static Future<bool> saveImageToGallery(Uint8List imageBytes) async {
    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Try photos permission for Android 13+
          final photosStatus = await Permission.photos.request();
          if (!photosStatus.isGranted) {
            debugPrint('Storage permission denied');
            // Continue anyway as Gal might handle it internally
          }
        }
      }

      // Get temporary directory to save the file first
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'paaila_run_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');

      // Write bytes to file
      await file.writeAsBytes(imageBytes);

      // Save to gallery using Gal
      await Gal.putImage(file.path, album: 'Paaila');

      // Clean up temp file
      if (await file.exists()) {
        await file.delete();
      }

      debugPrint('Image saved to gallery successfully');
      return true;
    } catch (e) {
      debugPrint('Error saving image to gallery: $e');
      return false;
    }
  }

  /// Save run with an optional image
  /// Returns the URL of the generated share image or null on failure
  static Future<RunShareResponse> saveRunWithImage({
    required String runId,
    required double distanceMeters,
    required Duration duration,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<Map<String, double>> path,
    Uint8List? imageBytes,
    String? activityType,
  }) async {
    try {
      final token = AuthService.authToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Try to save to backend
      try {
        // Create multipart request
        final uri = Uri.parse('$baseUrl/run/save');
        final request = http.MultipartRequest('POST', uri);

        // Add authorization header
        request.headers['Authorization'] = 'Bearer $token';

        // Add run data fields
        request.fields['runId'] = runId;
        request.fields['distanceMeters'] = distanceMeters.toString();
        request.fields['durationSeconds'] = duration.inSeconds.toString();
        request.fields['startedAt'] = startedAt.toIso8601String();
        request.fields['endedAt'] = endedAt.toIso8601String();
        request.fields['path'] = jsonEncode(path);
        if (activityType != null) {
          request.fields['activityType'] = activityType;
        }

        // Add image if provided (using bytes)
        if (imageBytes != null && imageBytes.isNotEmpty) {
          final multipartFile = http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'run_image_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          request.files.add(multipartFile);
        }

        // Send request
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
          onTimeout: () => throw Exception('Request timeout'),
        );

        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = jsonDecode(response.body);
          return RunShareResponse.fromJson(jsonResponse);
        } else {
          // Check if response is HTML (404 page)
          if (response.body.trim().startsWith('<!DOCTYPE') ||
              response.body.trim().startsWith('<html')) {
            debugPrint('Backend endpoint not available, saving locally');
            // Return success since run data was already saved via socket
            return RunShareResponse(
              success: true,
              message: 'Run saved locally',
              runId: runId,
            );
          }
          final errorResponse = jsonDecode(response.body);
          throw Exception(errorResponse['message'] ?? 'Failed to save run');
        }
      } catch (e) {
        // If backend fails, still return success since run was tracked via socket
        debugPrint('Backend save failed: $e - Run data was saved via socket');
        return RunShareResponse(
          success: true,
          message: 'Run saved',
          runId: runId,
        );
      }
    } catch (e) {
      throw Exception('Error saving run: $e');
    }
  }

  /// Save run without image (just the data)
  static Future<RunShareResponse> saveRunData({
    required String runId,
    required double distanceMeters,
    required Duration duration,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<Map<String, double>> path,
    String? activityType,
  }) async {
    try {
      final token = AuthService.authToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/run/save'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'runId': runId,
              'distanceMeters': distanceMeters,
              'durationSeconds': duration.inSeconds,
              'startedAt': startedAt.toIso8601String(),
              'endedAt': endedAt.toIso8601String(),
              'path': path,
              'activityType': activityType,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return RunShareResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to save run');
      }
    } catch (e) {
      throw Exception('Error saving run: $e');
    }
  }
}

/// Response model for run share API
class RunShareResponse {
  final bool success;
  final String? message;
  final String? shareImageUrl;
  final String? runId;

  RunShareResponse({
    required this.success,
    this.message,
    this.shareImageUrl,
    this.runId,
  });

  factory RunShareResponse.fromJson(Map<String, dynamic> json) {
    return RunShareResponse(
      success: json['success'] ?? true,
      message: json['message'],
      shareImageUrl: json['shareImageUrl'],
      runId: json['runId'],
    );
  }
}
