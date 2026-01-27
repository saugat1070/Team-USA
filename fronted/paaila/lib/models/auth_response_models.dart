import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  // Convert JSON to LoginResponse
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }
}

class SignUpResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  SignUpResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  // Convert JSON to SignUpResponse
  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiError({required this.message, this.statusCode, this.error});

  // Convert JSON error response to ApiError
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'Unknown error',
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  String toString() => 'ApiError: $message (Status: $statusCode)';
}
