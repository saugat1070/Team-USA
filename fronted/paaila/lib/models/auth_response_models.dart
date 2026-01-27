import 'user_model.dart';

class LoginResponse {
  final String message;
  final String token;

  LoginResponse({required this.message, required this.token});

  // Convert JSON to LoginResponse
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      token: json['token'] as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'message': message, 'token': token};
  }
}

class SignUpResponse {
  final String message;
  final String token;
  final User user;

  SignUpResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  // Convert JSON to SignUpResponse
  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      message: json['message'] as String,
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'message': message, 'token': token, 'user': user.toJson()};
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
