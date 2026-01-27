class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class SignUpRequest {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  // Validate request
  String? validate() {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }
}
