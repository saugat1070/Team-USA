import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_models.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.1.72:3000/api/v1'; // Update with your API URL
  static String? _authToken;
  static const String _tokenKey = 'jwt_token';

  // Get stored auth token
  static String? get authToken => _authToken;

  // Initialize - load token from storage on app start
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  // Set auth token and persist to storage
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear auth token from memory and storage
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Check if user has a stored token (for auto-login)
  static Future<bool> hasStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  // Login with email and password
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        // Store token if login successful
        await setAuthToken(loginResponse.token);

        return loginResponse;
      } else if (response.statusCode == 401) {
        throw ApiError(
          message: 'Invalid email or password',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw ApiError(
          message: 'User not found',
          statusCode: response.statusCode,
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError(message: e.toString(), error: e);
    }
  }

  // Sign up with user information
  static Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      // Validate request before sending
      final validationError = request.validate();
      if (validationError != null) {
        throw ApiError(message: validationError);
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final signUpResponse = SignUpResponse.fromJson(jsonResponse);

        // Store token if signup successful
        await setAuthToken(signUpResponse.token);

        return signUpResponse;
      } else if (response.statusCode == 400) {
        final errorResponse = jsonDecode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Invalid input',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 409) {
        throw ApiError(
          message: 'Email already registered',
          statusCode: response.statusCode,
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Sign up failed',
          statusCode: response.statusCode,
        );
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError(message: e.toString(), error: e);
    }
  }

  // Logout (clear local token)
  static Future<void> logout() async {
    try {
      // Optional: Call logout endpoint if your API has one
      if (_authToken != null) {
        await http
            .post(
              Uri.parse('$baseUrl/auth/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_authToken',
              },
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw Exception('Request timeout'),
            );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await clearAuthToken();
    }
  }

  // Refresh token
  static Future<String?> refreshToken() async {
    try {
      if (_authToken == null) return null;

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_authToken',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final newToken = jsonResponse['token'] as String?;
        if (newToken != null) {
          await setAuthToken(newToken);
          return newToken;
        }
      }
      return null;
    } catch (e) {
      print('Token refresh error: $e');
      return null;
    }
  }

  // Get current user information
  static Future<User?> getCurrentUser() async {
    try {
      if (_authToken == null) return null;

      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_authToken',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return User.fromJson(jsonResponse['user']);
      } else if (response.statusCode == 401) {
        await clearAuthToken();
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }
}
